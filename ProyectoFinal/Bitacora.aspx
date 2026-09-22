<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Bitacora.aspx.cs" Inherits="InventarioWeb.Bitacora" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bitácora de Auditoría - StockControl</title>
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
        .json-detalle { max-height: 320px; overflow-y: auto; background-color: #212529; color: #d1e7dd; font-size: 0.8rem; white-space: pre-wrap; word-break: break-all; }
        .ip-texto { font-family: monospace; font-size: 0.8rem; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid">
            <div class="row">

                <nav class="col-md-3 col-lg-2 d-md-block sidebar collapse p-3">
                    <h4 class="text-white text-center mb-4"><i class="fa-solid fa-boxes-stacked me-2"></i>StockControl</h4>
                    <ul class="nav nav-pills flex-column mb-auto">
                        <li class="nav-item mb-1">
                            <a href="Inventario.aspx" class="nav-link"><i class="fa-solid fa-box me-2"></i> Inventario</a>
                        </li>
                        <li class="nav-item mb-1">
                            <a href="Categoria.aspx" class="nav-link"><i class="fa-solid fa-list-check me-2"></i> Categorías</a>
                        </li>
                        <li class="nav-item mb-1">
                            <a href="Bitacora.aspx" class="nav-link active"><i class="fa-solid fa-clipboard-list me-2"></i> Bitácora / Auditoría</a>
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
                        <h1 class="h2">Bitácora de Eventos y Auditoría</h1>
                        <span class="text-muted small align-self-center">
                            <i class="fa-solid fa-circle-info me-1"></i>Últimos 100 movimientos registrados por el trigger de auditoría
                        </span>
                    </div>

                    <div class="card card-custom p-3">
                        <div class="table-responsive">
                            <asp:GridView ID="gvBitacora" runat="server" AutoGenerateColumns="False"
                                CssClass="table table-striped table-hover align-middle" GridLines="None"
                                EmptyDataText="No hay movimientos registrados en la bitácora.">
                                <Columns>
                                    <asp:BoundField DataField="IdBitacora" HeaderText="ID" ItemStyle-Width="60px" />
                                    <asp:TemplateField HeaderText="Fecha y Hora" ItemStyle-Width="170px">
                                        <ItemTemplate>
                                            <span class="text-secondary small">
                                                <i class="fa-regular fa-clock me-1"></i><%# Eval("Fecha", "{0:dd/MM/yyyy HH:mm:ss}") %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Usuario">
                                        <ItemTemplate>
                                            <span class="badge bg-secondary"><%# Eval("Usuario") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Operación" ItemStyle-Width="110px">
                                        <ItemTemplate>
                                            <span class='badge <%# ObtenerClaseOperacion(Eval("Operacion")) %>'><%# Eval("Operacion") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Dirección IP" ItemStyle-Width="130px">
                                        <ItemTemplate>
                                            <span class="text-secondary ip-texto"><%# Eval("DireccionIP") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Detalle" ItemStyle-Width="110px" ItemStyle-CssClass="text-center">
                                        <ItemTemplate>
                                            <button type="button" class="btn btn-sm btn-outline-primary btn-ver-detalle"
                                                data-bs-toggle="modal" data-bs-target="#modalDetalle"
                                                data-id='<%# Eval("IdBitacora") %>'
                                                data-usuario='<%# Server.HtmlEncode(Convert.ToString(Eval("Usuario"))) %>'
                                                data-fecha='<%# Eval("Fecha", "{0:dd/MM/yyyy HH:mm:ss}") %>'
                                                data-operacion='<%# Server.HtmlEncode(Convert.ToString(Eval("Operacion"))) %>'
                                                data-anteriores='<%# Server.HtmlEncode(Convert.ToString(Eval("ValoresAnteriores"))) %>'
                                                data-nuevos='<%# Server.HtmlEncode(Convert.ToString(Eval("ValoresNuevos"))) %>'>
                                                <i class="fa-solid fa-magnifying-glass me-1"></i>Ver
                                            </button>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </main>
            </div>
        </div>

        <div class="modal fade" id="modalDetalle" tabindex="-1" aria-labelledby="modalDetalleLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-scrollable">
                <div class="modal-content">
                    <div class="modal-header bg-dark text-white">
                        <h5 class="modal-title" id="modalDetalleLabel">
                            <i class="fa-solid fa-clipboard-list me-2"></i>Detalle del Evento
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row g-2 mb-3 small">
                            <div class="col-md-3"><strong>Registro:</strong> <span id="detId"></span></div>
                            <div class="col-md-5"><strong>Fecha:</strong> <span id="detFecha"></span></div>
                            <div class="col-md-4"><strong>Operación:</strong> <span id="detOperacion"></span></div>
                            <div class="col-md-6"><strong>Usuario:</strong> <span id="detUsuario"></span></div>
                        </div>
                        <label class="form-label fw-bold">Valores Anteriores</label>
                        <pre id="detAnteriores" class="json-detalle rounded p-2 mb-3"></pre>
                        <label class="form-label fw-bold">Valores Nuevos</label>
                        <pre id="detNuevos" class="json-detalle rounded p-2"></pre>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script>
        function formatearJson(texto) {
            if (!texto || texto === '-') return 'Sin datos';
            try { return JSON.stringify(JSON.parse(texto), null, 2); }
            catch (e) { return texto; }
        }

        document.getElementById('modalDetalle').addEventListener('show.bs.modal', function (evento) {
            var boton = evento.relatedTarget;
            if (!boton) return;
            var datos = boton.dataset;
            document.getElementById('detId').textContent = datos.id;
            document.getElementById('detFecha').textContent = datos.fecha;
            document.getElementById('detOperacion').textContent = datos.operacion;
            document.getElementById('detUsuario').textContent = datos.usuario;
            document.getElementById('detAnteriores').textContent = formatearJson(datos.anteriores);
            document.getElementById('detNuevos').textContent = formatearJson(datos.nuevos);
        });
    </script>
</body>
</html>
