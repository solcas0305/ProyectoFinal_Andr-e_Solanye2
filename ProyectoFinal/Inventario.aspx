<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Inventario.aspx.cs" Inherits="InventarioWeb.Inventario" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Control de Inventario</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        body { background-color: #f8f9fa; }
        .sidebar { min-height: 100vh; background-color: #212529; color: #fff; }
        .sidebar a { color: #adb5bd; text-decoration: none; display: block; padding: 10px 15px; border-radius: 6px; }
        .sidebar a:hover, .sidebar a.active { color: #fff; background-color: #0d6efd; }
        .product-img-preview { width: 48px; height: 48px; object-fit: cover; border-radius: 6px; }
        .card-custom { border: none; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.08); }
    </style>
</head>
<body>
   <form id="form1" runat="server" enctype="multipart/form-data">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="container-fluid">
            <div class="row">
         
                <nav class="col-md-3 col-lg-2 d-md-block sidebar collapse p-3">
                    <h4 class="text-white text-center mb-4"><i class="fa-solid fa-boxes-stacked me-2"></i>StockControl</h4>
                    <ul class="nav nav-pills flex-column mb-auto">
                        <li class="nav-item mb-1">
                            <a href="Inventario.aspx" class="nav-link active"><i class="fa-solid fa-box me-2"></i> Inventario</a>
                        </li>

                        <li class="nav-item mb-1">
                            <a href="Categoria.aspx" class="nav-link"><i class="fa-solid fa-list-check me-2"></i> Categorías</a>
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
                        <h1 class="h2">Gestión de Inventario</h1>
                        <asp:LinkButton ID="btnAbrirNuevo" runat="server" CssClass="btn btn-primary" OnClick="btnAbrirNuevo_Click">
                            <i class="fa-solid fa-plus me-1"></i> Nuevo Producto
                        </asp:LinkButton>
                    </div>

       
                    <div class="card card-custom p-3 mb-4">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <div class="input-group">
                                    <span class="input-group-text bg-white"><i class="fa-solid fa-magnifying-glass"></i></span>
                                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="form-control" 
                                        placeholder="Buscar por código o descripción..." 
                                        AutoPostBack="true" OnTextChanged="txtBuscar_TextChanged"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <asp:DropDownList ID="cmbCategoriaFiltro" runat="server" CssClass="form-select" 
                                    AutoPostBack="true" OnSelectedIndexChanged="cmbCategoriaFiltro_SelectedIndexChanged">
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-2">
                                <asp:LinkButton ID="btnLimpiar" runat="server" CssClass="btn btn-outline-secondary w-100" OnClick="btnLimpiar_Click">
                                    <i class="fa-solid fa-rotate-right me-1"></i> Limpiar
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>

                
                    <div class="card card-custom p-3">
                        <div class="table-responsive">
                            <asp:GridView ID="gvProductos" runat="server" AutoGenerateColumns="False" 
                                DataKeyNames="IdProducto" OnRowCommand="gvProductos_RowCommand"
                                CssClass="table table-hover align-middle" GridLines="None">
                                <Columns>
                                    <asp:TemplateField HeaderText="Imagen">
                                        <ItemTemplate>
                                            <img src='<%# string.IsNullOrEmpty(Eval("RutaImagen") as string) ? ResolveUrl("~/Content/sin-imagen.svg") : ResolveUrl("~/" + Eval("RutaImagen")) %>'
                                                onerror='this.onerror=null;this.src="<%# ResolveUrl("~/Content/sin-imagen.svg") %>";'
                                                class="product-img-preview" alt="Imagen Producto" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Código">
                                        <ItemTemplate>
                                            <strong><%# Eval("Codigo") %></strong>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="Descripcion" HeaderText="Descripción" />
                                    <asp:TemplateField HeaderText="Categoría">
                                        <ItemTemplate>
                                            <span class="badge bg-info text-dark"><%# Eval("NombreCategoria") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Stock">
                                        <ItemTemplate>
                                            <span class="badge bg-success"><%# Eval("Existencia") %> uds</span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="PrecioCompra" HeaderText="P. Compra" DataFormatString="{0:C}" />
                                    <asp:BoundField DataField="PrecioVenta" HeaderText="P. Venta" DataFormatString="{0:C}" />
                                    <asp:TemplateField HeaderText="Acciones" ItemStyle-CssClass="text-center">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("IdProducto") %>' CssClass="btn btn-sm btn-outline-warning me-1">
                                                <i class="fa-solid fa-pen"></i> Editar
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IdProducto") %>' CssClass="btn btn-sm btn-outline-danger" 
                                                OnClientClick="return confirm('¿Seguro que quieres eliminar el producto seleccionado?');">
                                                <i class="fa-solid fa-trash"></i> Eliminar
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </main>
            </div>
        </div>

    
        <div class="modal fade" id="modalProducto" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="modalProductoLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title" id="modalProductoLabel">
                            <i class="fa-solid fa-box me-2"></i>
                            <asp:Label ID="lblModalTitulo" runat="server" Text="Registrar Nuevo Producto"></asp:Label>
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <asp:HiddenField ID="hfIdProducto" runat="server" Value="0" />
                        <asp:Label ID="lblMensajeModal" runat="server" CssClass="alert alert-danger d-block" Visible="false"></asp:Label>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Código del Producto</label>
                                <asp:TextBox ID="txtCodigo" runat="server" CssClass="form-control" placeholder="Ej. PRD-001"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Categoría</label>
                                <asp:DropDownList ID="cmbCategoriaModal" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                            <div class="col-md-12">
                                <label class="form-label">Descripción</label>
                                <asp:TextBox ID="txtDescripcion" runat="server" CssClass="form-control" placeholder="Nombre o detalle del producto"></asp:TextBox>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Precio Compra</label>
                                <asp:TextBox ID="txtPrecioCompra" runat="server" CssClass="form-control" placeholder="0.00"></asp:TextBox>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Precio Venta</label>
                                <asp:TextBox ID="txtPrecioVenta" runat="server" CssClass="form-control" placeholder="0.00"></asp:TextBox>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Impuesto (%)</label>
                                <asp:TextBox ID="txtImpuesto" runat="server" CssClass="form-control" Text="15.00"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Existencia Inicial</label>
                                <asp:TextBox ID="txtExistencia" runat="server" CssClass="form-control" placeholder="0"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Imagen del Producto</label>
                                <asp:FileUpload ID="fuImagen" runat="server" CssClass="form-control" accept="image/*" />
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <asp:Button ID="btnGuardar" runat="server" Text="Guardar Producto" CssClass="btn btn-primary" OnClick="btnGuardar_Click" />
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>