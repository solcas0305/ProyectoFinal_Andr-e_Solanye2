using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

public class Conexion
{
    private static string cadena = ConfigurationManager.ConnectionStrings["CadenaConexion"].ConnectionString;

    public static SqlConnection ObtenerConexion()
    {
        return new SqlConnection(cadena);
    }

    private static bool EjecutarNonQuery(SqlConnection con, SqlCommand cmd)
    {
        con.Open();
        cmd.ExecuteNonQuery();
        using (SqlCommand filas = new SqlCommand("SELECT @@ROWCOUNT", con))
        {
            return Convert.ToInt32(filas.ExecuteScalar()) > 0;
        }
    }

    public static DataTable ValidarUsuario(string username, string password)
    {
        using (SqlConnection con = ObtenerConexion())
        {
            using (SqlCommand cmd = new SqlCommand("sp_ValidarUsuario", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Username", username);
                cmd.Parameters.AddWithValue("@Password", password);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
    }

    public static DataTable ObtenerProductos()
    {
        using (SqlConnection con = ObtenerConexion())
        {
            using (SqlCommand cmd = new SqlCommand("sp_ListarProductos", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
    }

    public static DataTable BuscarProductos(string texto, int idCategoria)
    {
        using (SqlConnection con = ObtenerConexion())
        {
            using (SqlCommand cmd = new SqlCommand("sp_BuscarProductos", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Texto", string.IsNullOrEmpty(texto) ? (object)DBNull.Value : texto);
                cmd.Parameters.AddWithValue("@IdCategoria", idCategoria);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
    }

    public static bool InsertarProducto(string codigo, string descripcion, decimal precioCompra, decimal precioVenta, decimal impuesto, int existencia, int idCategoria, string rutaImagen)
    {
        using (SqlConnection con = ObtenerConexion())
        {
            using (SqlCommand cmd = new SqlCommand("sp_InsertarProducto", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Codigo", codigo);
                cmd.Parameters.AddWithValue("@Descripcion", descripcion);
                cmd.Parameters.AddWithValue("@PrecioCompra", precioCompra);
                cmd.Parameters.AddWithValue("@PrecioVenta", precioVenta);
                cmd.Parameters.AddWithValue("@Impuesto", impuesto);
                cmd.Parameters.AddWithValue("@Existencia", existencia);
                cmd.Parameters.AddWithValue("@IdCategoria", idCategoria);
                cmd.Parameters.AddWithValue("@RutaImagen", rutaImagen);

                return EjecutarNonQuery(con, cmd);
            }
        }
    }

    public static bool EliminarProducto(int idProducto)
    {
        using (SqlConnection con = ObtenerConexion())
        {
            using (SqlCommand cmd = new SqlCommand("sp_EliminarProducto", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@IdProducto", idProducto);

                return EjecutarNonQuery(con, cmd);
            }
        }
    }

    public static DataRow ObtenerProducto(int idProducto)
    {
        using (SqlConnection con = ObtenerConexion())
        {
            using (SqlCommand cmd = new SqlCommand("sp_ObtenerProducto", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@IdProducto", idProducto);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt.Rows.Count > 0 ? dt.Rows[0] : null;
            }
        }
    }

    public static bool ActualizarProducto(int idProducto, string codigo, string descripcion, decimal precioCompra, decimal precioVenta, decimal impuesto, int existencia, int idCategoria, string rutaImagen)
    {
        using (SqlConnection con = ObtenerConexion())
        {
            using (SqlCommand cmd = new SqlCommand("sp_ActualizarProducto", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@IdProducto", idProducto);
                cmd.Parameters.AddWithValue("@Codigo", codigo);
                cmd.Parameters.AddWithValue("@Descripcion", descripcion);
                cmd.Parameters.AddWithValue("@PrecioCompra", precioCompra);
                cmd.Parameters.AddWithValue("@PrecioVenta", precioVenta);
                cmd.Parameters.AddWithValue("@Impuesto", impuesto);
                cmd.Parameters.AddWithValue("@Existencia", existencia);
                cmd.Parameters.AddWithValue("@IdCategoria", idCategoria);
                cmd.Parameters.AddWithValue("@RutaImagen", string.IsNullOrEmpty(rutaImagen) ? (object)DBNull.Value : rutaImagen);

                return EjecutarNonQuery(con, cmd);
            }
        }
    }

    public static DataTable ObtenerCategorias()
    {
        using (SqlConnection con = ObtenerConexion())
        {
            using (SqlCommand cmd = new SqlCommand("sp_ListarCategorias", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
    }

    public static bool InsertarCategoria(string nombreCategoria)
    {
        using (SqlConnection con = ObtenerConexion())
        {
            using (SqlCommand cmd = new SqlCommand("sp_InsertarCategoria", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@NombreCategoria", nombreCategoria);

                return EjecutarNonQuery(con, cmd);
            }
        }
    }

    public static DataTable ObtenerBitacora()
    {
        using (SqlConnection con = ObtenerConexion())
        {
            using (SqlCommand cmd = new SqlCommand("sp_ListarBitacora", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
    }
}