/* =====================================================================
   BD_Script_Final.sql  -  DB_Inventario (versión final y única)
   ---------------------------------------------------------------------
   Reemplaza a BD_Script_Complementario.sql y a
   BD_Limpieza_Categorias_Duplicadas.sql (ambos quedan obsoletos).

   Este script es IDEMPOTENTE y sirve para dos escenarios:
     A) Instalación desde cero: crea base, tablas, datos semilla,
        procedimientos y trigger.
     B) Reparación de una base ya existente: no recrea nada que ya
        exista, actualiza los procedimientos, y al final elimina las
        categorías duplicadas re-apuntando antes los productos.

   Puede ejecutarse varias veces sin acumular datos repetidos.
   ===================================================================== */

/* ---------- BASE DE DATOS ---------- */
IF DB_ID('DB_Inventario') IS NULL
    CREATE DATABASE DB_Inventario;
GO
USE DB_Inventario;
GO

/* ---------- TABLAS ---------- */
IF OBJECT_ID('dbo.Roles', 'U') IS NULL
CREATE TABLE Roles (
    IdRol INT IDENTITY(1,1) PRIMARY KEY,
    NombreRol VARCHAR(50) NOT NULL
);
GO

IF OBJECT_ID('dbo.Usuarios', 'U') IS NULL
CREATE TABLE Usuarios (
    IdUsuario INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    NombreCompleto VARCHAR(100) NOT NULL,
    PasswordHash CHAR(64) NOT NULL,
    IdRol INT FOREIGN KEY REFERENCES Roles(IdRol),
    Estado BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('dbo.Categorias', 'U') IS NULL
CREATE TABLE Categorias (
    IdCategoria INT IDENTITY(1,1) PRIMARY KEY,
    NombreCategoria VARCHAR(100) NOT NULL,
    Estado BIT DEFAULT 1
);
GO

IF OBJECT_ID('dbo.Productos', 'U') IS NULL
CREATE TABLE Productos (
    IdProducto INT IDENTITY(1,1) PRIMARY KEY,
    Codigo VARCHAR(30) UNIQUE NOT NULL,
    Descripcion VARCHAR(200) NOT NULL,
    PrecioCompra DECIMAL(18,2) NOT NULL,
    PrecioVenta DECIMAL(18,2) NOT NULL,
    Impuesto DECIMAL(5,2) DEFAULT 15.00,
    Existencia INT NOT NULL DEFAULT 0,
    IdCategoria INT FOREIGN KEY REFERENCES Categorias(IdCategoria),
    RutaImagen VARCHAR(300) NULL,
    HashProducto CHAR(64) NULL,
    FechaRegistro DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('dbo.Bitacora', 'U') IS NULL
CREATE TABLE Bitacora (
    IdBitacora INT IDENTITY(1,1) PRIMARY KEY,
    Usuario VARCHAR(50),
    Fecha DATETIME DEFAULT GETDATE(),
    Operacion VARCHAR(20),
    Modulo VARCHAR(30) NULL,
    ValoresAnteriores VARCHAR(MAX),
    ValoresNuevos VARCHAR(MAX),
    DireccionIP VARCHAR(45)
);
GO

/* Columna agregada en una versión posterior: se suma a las bases ya creadas. */
IF COL_LENGTH('dbo.Bitacora', 'Modulo') IS NULL
    ALTER TABLE Bitacora ADD Modulo VARCHAR(30) NULL;
GO

/* ---------- DATOS SEMILLA (con guarda: no se duplican al re-ejecutar) ---------- */
IF NOT EXISTS (SELECT 1 FROM Roles WHERE NombreRol = 'Administrador')
    INSERT INTO Roles (NombreRol) VALUES ('Administrador');
IF NOT EXISTS (SELECT 1 FROM Roles WHERE NombreRol = 'Operador')
    INSERT INTO Roles (NombreRol) VALUES ('Operador');
GO

IF NOT EXISTS (SELECT 1 FROM Categorias WHERE NombreCategoria = 'Electrónica')
    INSERT INTO Categorias (NombreCategoria) VALUES ('Electrónica');
IF NOT EXISTS (SELECT 1 FROM Categorias WHERE NombreCategoria = 'Abarrotes')
    INSERT INTO Categorias (NombreCategoria) VALUES ('Abarrotes');
IF NOT EXISTS (SELECT 1 FROM Categorias WHERE NombreCategoria = 'Oficina')
    INSERT INTO Categorias (NombreCategoria) VALUES ('Oficina');
GO

--  User='admin', Pass='Admin123'
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Username = 'admin')
    INSERT INTO Usuarios (Username, NombreCompleto, PasswordHash, IdRol)
    VALUES ('admin', 'Administrador del Sistema',
            LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Admin123'), 2)), 1);
GO

--  User='operador', Pass='Opera123'  (para demostrar los permisos por rol)
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Username = 'operador')
    INSERT INTO Usuarios (Username, NombreCompleto, PasswordHash, IdRol)
    VALUES ('operador', 'Operador de Bodega',
            LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Opera123'), 2)),
            (SELECT IdRol FROM Roles WHERE NombreRol = 'Operador'));
GO

/* ---------- PROCEDIMIENTOS ---------- */
CREATE OR ALTER PROCEDURE sp_ValidarUsuario
    @Username VARCHAR(50),
    @Password VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PassHash CHAR(64);
    SET @PassHash = LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Password), 2));

    SELECT U.IdUsuario, U.Username, U.NombreCompleto, R.NombreRol
    FROM Usuarios U
    INNER JOIN Roles R ON U.IdRol = R.IdRol
    WHERE U.Username = @Username AND U.PasswordHash = @PassHash AND U.Estado = 1;
END;
GO

CREATE OR ALTER PROCEDURE sp_ListarProductos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.IdProducto, P.Codigo, P.Descripcion, P.PrecioCompra, P.PrecioVenta,
        P.Impuesto, P.Existencia, C.NombreCategoria, ISNULL(P.RutaImagen, '') AS RutaImagen
    FROM Productos P
    INNER JOIN Categorias C ON P.IdCategoria = C.IdCategoria
    ORDER BY P.IdProducto DESC;
END;
GO

CREATE OR ALTER PROCEDURE sp_BuscarProductos
    @Texto VARCHAR(100) = NULL,
    @IdCategoria INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.IdProducto, P.Codigo, P.Descripcion, P.PrecioCompra, P.PrecioVenta,
        P.Impuesto, P.Existencia, C.NombreCategoria, P.IdCategoria, ISNULL(P.RutaImagen, '') AS RutaImagen
    FROM Productos P
    INNER JOIN Categorias C ON P.IdCategoria = C.IdCategoria
    WHERE (@Texto IS NULL OR P.Codigo LIKE '%' + @Texto + '%' OR P.Descripcion LIKE '%' + @Texto + '%')
      AND (@IdCategoria = 0 OR P.IdCategoria = @IdCategoria)
    ORDER BY P.IdProducto DESC;
END;
GO

CREATE OR ALTER PROCEDURE sp_ObtenerProducto
    @IdProducto INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        P.IdProducto, P.Codigo, P.Descripcion, P.PrecioCompra, P.PrecioVenta,
        P.Impuesto, P.Existencia, P.IdCategoria, ISNULL(P.RutaImagen, '') AS RutaImagen
    FROM Productos P
    WHERE P.IdProducto = @IdProducto;
END;
GO

CREATE OR ALTER PROCEDURE sp_InsertarProducto
    @Codigo VARCHAR(30),
    @Descripcion VARCHAR(200),
    @PrecioCompra DECIMAL(18,2),
    @PrecioVenta DECIMAL(18,2),
    @Impuesto DECIMAL(5,2),
    @Existencia INT,
    @IdCategoria INT,
    @RutaImagen VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @HashProd CHAR(64);
    SET @HashProd = LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', CONCAT(@Codigo, @Descripcion, @PrecioVenta)), 2));

    INSERT INTO Productos (Codigo, Descripcion, PrecioCompra, PrecioVenta, Impuesto, Existencia, IdCategoria, RutaImagen, HashProducto)
    VALUES (@Codigo, @Descripcion, @PrecioCompra, @PrecioVenta, @Impuesto, @Existencia, @IdCategoria, @RutaImagen, @HashProd);
END;
GO

/* Si @RutaImagen llega en NULL se conserva la imagen actual,
   de modo que editar sin subir archivo no borre la foto. */
CREATE OR ALTER PROCEDURE sp_ActualizarProducto
    @IdProducto    INT,
    @Codigo        VARCHAR(30),
    @Descripcion   VARCHAR(200),
    @PrecioCompra  DECIMAL(18,2),
    @PrecioVenta   DECIMAL(18,2),
    @Impuesto      DECIMAL(5,2),
    @Existencia    INT,
    @IdCategoria   INT,
    @RutaImagen    VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Productos
    SET Codigo       = @Codigo,
        Descripcion  = @Descripcion,
        PrecioCompra = @PrecioCompra,
        PrecioVenta  = @PrecioVenta,
        Impuesto     = @Impuesto,
        Existencia   = @Existencia,
        IdCategoria  = @IdCategoria,
        RutaImagen   = ISNULL(@RutaImagen, RutaImagen),
        HashProducto = LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', CONCAT(@Codigo, @Descripcion, @PrecioVenta)), 2))
    WHERE IdProducto = @IdProducto;
END;
GO

CREATE OR ALTER PROCEDURE sp_EliminarProducto
    @IdProducto INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Productos WHERE IdProducto = @IdProducto;
END;
GO

CREATE OR ALTER PROCEDURE sp_ListarCategorias
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdCategoria, NombreCategoria, Estado
    FROM Categorias
    WHERE Estado = 1
    ORDER BY NombreCategoria ASC;
END;
GO

CREATE OR ALTER PROCEDURE sp_InsertarCategoria
    @NombreCategoria VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Categorias (NombreCategoria, Estado)
    VALUES (@NombreCategoria, 1);
END;
GO

CREATE OR ALTER PROCEDURE sp_ListarBitacora
    @Modulo VARCHAR(30) = NULL,
    @Operacion VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 200
        IdBitacora,
        ISNULL(Usuario, 'SYSTEM') AS Usuario,
        Fecha,
        Operacion,
        ISNULL(Modulo, 'GENERAL') AS Modulo,
        ISNULL(ValoresAnteriores, '-') AS ValoresAnteriores,
        ISNULL(ValoresNuevos, '-') AS ValoresNuevos,
        ISNULL(DireccionIP, 'Localhost') AS DireccionIP
    FROM Bitacora
    WHERE (@Modulo IS NULL OR Modulo = @Modulo)
      AND (@Operacion IS NULL OR Operacion = @Operacion)
    ORDER BY IdBitacora DESC;
END;
GO

/* Evento escrito por la aplicación (inicios de sesión, cambios de contraseña).
   Los INSERT/UPDATE/DELETE los registran los triggers. */
CREATE OR ALTER PROCEDURE sp_RegistrarEvento
    @Usuario   VARCHAR(50),
    @Operacion VARCHAR(20),
    @Modulo    VARCHAR(30),
    @Detalle   VARCHAR(MAX) = NULL,
    @IP        VARCHAR(45)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Bitacora (Usuario, Operacion, Modulo, ValoresNuevos, DireccionIP)
    VALUES (@Usuario, @Operacion, @Modulo, @Detalle, ISNULL(@IP, 'Localhost'));
END;
GO

/* ---------- ROLES Y USUARIOS ---------- */
CREATE OR ALTER PROCEDURE sp_ListarRoles
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdRol, NombreRol FROM Roles ORDER BY IdRol;
END;
GO

CREATE OR ALTER PROCEDURE sp_ListarUsuarios
AS
BEGIN
    SET NOCOUNT ON;
    SELECT U.IdUsuario, U.Username, U.NombreCompleto, U.IdRol,
           ISNULL(R.NombreRol, 'Sin rol') AS NombreRol,
           U.Estado, U.FechaCreacion
    FROM Usuarios U
    LEFT JOIN Roles R ON U.IdRol = R.IdRol
    ORDER BY U.Username;
END;
GO

CREATE OR ALTER PROCEDURE sp_ObtenerUsuario
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT U.IdUsuario, U.Username, U.NombreCompleto, U.IdRol,
           ISNULL(R.NombreRol, 'Sin rol') AS NombreRol, U.Estado
    FROM Usuarios U
    LEFT JOIN Roles R ON U.IdRol = R.IdRol
    WHERE U.IdUsuario = @IdUsuario;
END;
GO

CREATE OR ALTER PROCEDURE sp_InsertarUsuario
    @Username       VARCHAR(50),
    @NombreCompleto VARCHAR(100),
    @Password       VARCHAR(100),
    @IdRol          INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Usuarios (Username, NombreCompleto, PasswordHash, IdRol, Estado)
    VALUES (@Username, @NombreCompleto,
            LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Password), 2)),
            @IdRol, 1);
END;
GO

CREATE OR ALTER PROCEDURE sp_ActualizarUsuario
    @IdUsuario      INT,
    @NombreCompleto VARCHAR(100),
    @IdRol          INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Usuarios
    SET NombreCompleto = @NombreCompleto,
        IdRol          = @IdRol
    WHERE IdUsuario = @IdUsuario;
END;
GO

CREATE OR ALTER PROCEDURE sp_CambiarEstadoUsuario
    @IdUsuario INT,
    @Estado    BIT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Usuarios SET Estado = @Estado WHERE IdUsuario = @IdUsuario;
END;
GO

CREATE OR ALTER PROCEDURE sp_CambiarPasswordUsuario
    @IdUsuario      INT,
    @NuevaPassword  VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Usuarios
    SET PasswordHash = LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @NuevaPassword), 2))
    WHERE IdUsuario = @IdUsuario;
END;
GO

/* ---------- TRIGGER DE AUDITORÍA ---------- */
CREATE OR ALTER TRIGGER trg_AuditoriaProductos
ON Productos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Operacion VARCHAR(20);

    IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
        SET @Operacion = 'UPDATE';
    ELSE IF EXISTS(SELECT * FROM inserted)
        SET @Operacion = 'INSERT';
    ELSE IF EXISTS(SELECT * FROM deleted)
        SET @Operacion = 'DELETE';

    INSERT INTO Bitacora (Usuario, Operacion, ValoresAnteriores, ValoresNuevos, DireccionIP)
    SELECT
        SYSTEM_USER,
        @Operacion,
        (SELECT * FROM deleted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        (SELECT * FROM inserted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        CAST(CONNECTIONPROPERTY('client_net_address') AS VARCHAR(45));
END;
GO

/* ---------- LIMPIEZA DE CATEGORÍAS DUPLICADAS ----------
   No hace nada si no hay duplicados (base instalada desde cero).
   Sobrevive el menor IdCategoria activo por nombre; los productos
   que apuntaban a un duplicado se re-apuntan al sobreviviente. */
SET XACT_ABORT ON;
BEGIN TRANSACTION;

    ;WITH Superviviente AS (
        SELECT NombreCategoria,
               ISNULL(MIN(CASE WHEN Estado = 1 THEN IdCategoria END), MIN(IdCategoria)) AS IdCategoriaMin
        FROM Categorias
        GROUP BY NombreCategoria
    )
    UPDATE P
    SET P.IdCategoria = S.IdCategoriaMin
    FROM Productos P
    INNER JOIN Categorias C ON C.IdCategoria = P.IdCategoria
    INNER JOIN Superviviente S ON S.NombreCategoria = C.NombreCategoria
    WHERE P.IdCategoria <> S.IdCategoriaMin;

    ;WITH Superviviente AS (
        SELECT NombreCategoria,
               ISNULL(MIN(CASE WHEN Estado = 1 THEN IdCategoria END), MIN(IdCategoria)) AS IdCategoriaMin
        FROM Categorias
        GROUP BY NombreCategoria
    )
    DELETE C
    FROM Categorias C
    INNER JOIN Superviviente S ON S.NombreCategoria = C.NombreCategoria
    WHERE C.IdCategoria <> S.IdCategoriaMin;

COMMIT TRANSACTION;
GO

/* ---------- VERIFICACIÓN FINAL ---------- */
SELECT NombreCategoria, COUNT(*) AS TotalFilas, MIN(IdCategoria) AS IdCategoria
FROM Categorias
GROUP BY NombreCategoria
ORDER BY NombreCategoria;
GO
