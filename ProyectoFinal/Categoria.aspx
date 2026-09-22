<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Categoria.aspx.cs" Inherits="InventarioWeb.Categorias" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Categorías - StockControl</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        body { background-color: #f8f9fa; }
        .sidebar { min-height: 100vh; background-color: #212529; color: #fff; }
        .sidebar a { color: #adb5bd; text-decoration: none; display: block; padding: 10px 15px; border-radius: 6px; }
        .sidebar a:hover, .sidebar a.active { color: #fff; background-color: #0d6efd; }
        .card-custom { border: none; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.08); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="container-fluid">
            <div class="row">
    
                <nav class="col-md-3 col-lg-2 d-md-block sidebar collapse p-3">
                    <h4 class="text-white text-center mb-4"><i class="fa-solid fa-boxes-stacked me-2"></i>StockControl</h4>
                    <ul class="nav nav-pills flex-column mb-auto">
                        <li class="nav-item mb-1">
                            <a href="Inventario.aspx" class="nav-link"><i class="fa-solid fa-box me-2"></i> Inventario</a>
                        </li>
                        <li class="nav-item mb-1">
                            <a href="Categoria.aspx" class="nav-link active"><i class="fa-solid fa-list-check me-2"></i> Categorías</a>
                        </li>
                        <li class="nav-item mb-1">
                            <a href="Bitacora.aspx" class="nav-link"><i class="fa-solid fa-clipboard-list me-2"></i> Bitácora / Auditoría</a>
                        </li>
                    </ul>
                    <hr>
                    <div class="text-center text-muted small mb-3">
                        Usuario: <strong><asp:Label ID="lblUsuarioSesion" runat="server"></asp:Label></strong>
                    </div>
                    <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesión" CssClass="btn btn-outline-danger w-100 btn-sm" OnClick="btnCerrarSesion_Click" />
                </nav>

   
                <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
                    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pb-2 mb-4 border-bottom">
                        <h1 class="h2">Gestión de Categorías</h1>
                        <asp:LinkButton ID="btnAbrirNuevo" runat="server" CssClass="btn btn-primary" OnClick="btnAbrirNuevo_Click">
                            <i class="fa-solid fa-plus me-1"></i> Nueva Categoría
                        </asp:LinkButton>
                    </div>

           
                    <div class="card card-custom p-3">
                        <asp:Label ID="lblExito" runat="server" CssClass="alert alert-success d-block" Visible="false"></asp:Label>
                        <div class="table-responsive">
                            <asp:GridView ID="gvCategorias" runat="server" AutoGenerateColumns="False" 
                                DataKeyNames="IdCategoria" CssClass="table table-hover align-middle" GridLines="None"
                                EmptyDataText="No hay categorías registradas.">
                                <Columns>
                                    <asp:BoundField DataField="IdCategoria" HeaderText="ID" ItemStyle-Width="100px" />
                                    <asp:TemplateField HeaderText="Nombre Categoría">
                                        <ItemTemplate>
                                            <span class="fw-bold"><%# Eval("NombreCategoria") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </main>
            </div>
        </div>


        <div class="modal fade" id="modalCategoria" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="modalCategoriaLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title" id="modalCategoriaLabel">
                            <i class="fa-solid fa-list-check me-2"></i> Registrar Nueva Categoría
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <asp:Label ID="lblMensajeModal" runat="server" CssClass="alert alert-danger d-block" Visible="false"></asp:Label>
                        <div class="mb-3">
                            <label class="form-label">Nombre de la Categoría</label>
                            <asp:TextBox ID="txtNombreCategoria" runat="server" CssClass="form-control" placeholder="Ej. Lácteos, Granos Básicos, Bebidas..."></asp:TextBox>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <asp:Button ID="btnGuardarCategoria" runat="server" Text="Guardar" CssClass="btn btn-primary" OnClick="btnGuardarCategoria_Click" />
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>