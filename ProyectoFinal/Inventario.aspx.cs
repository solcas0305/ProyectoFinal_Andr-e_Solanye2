using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace InventarioWeb
{
    public partial class Inventario : System.Web.UI.Page
    {
        private static readonly HashSet<string> ExtensionesImagenPermitidas =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase) { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp" };

        protected void Page_Load(object sender, EventArgs e)
        {

            if (Session["NombreUsuario"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblUsuarioSesion.Text = Session["NombreUsuario"].ToString();
                CargarCategorias();
                CargarProductos();
            }
        }


        private void CargarCategorias()
        {
            DataTable dt = Conexion.ObtenerCategorias();

            cmbCategoriaFiltro.DataSource = dt;
            cmbCategoriaFiltro.DataTextField = "NombreCategoria";
            cmbCategoriaFiltro.DataValueField = "IdCategoria";
            cmbCategoriaFiltro.DataBind();
            cmbCategoriaFiltro.Items.Insert(0, new ListItem("-- Todas las Categorías --", "0"));

            cmbCategoriaModal.DataSource = dt;
            cmbCategoriaModal.DataTextField = "NombreCategoria";
            cmbCategoriaModal.DataValueField = "IdCategoria";
            cmbCategoriaModal.DataBind();
            cmbCategoriaModal.Items.Insert(0, new ListItem("-- Seleccione Categoría --", "0"));
        }

        private void CargarProductos()
        {
            int idCategoriaFiltro;
            if (!int.TryParse(cmbCategoriaFiltro.SelectedValue, out idCategoriaFiltro))
            {
                idCategoriaFiltro = 0;
            }

            DataTable dt = Conexion.BuscarProductos(txtBuscar.Text.Trim(), idCategoriaFiltro);
            gvProductos.DataSource = dt;
            gvProductos.DataBind();
        }



        protected void txtBuscar_TextChanged(object sender, EventArgs e)
        {
            CargarProductos();
        }

        protected void cmbCategoriaFiltro_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarProductos();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtBuscar.Text = string.Empty;
            cmbCategoriaFiltro.SelectedValue = "0";
            CargarProductos();
        }



        protected void btnAbrirNuevo_Click(object sender, EventArgs e)
        {
            LimpiarFormularioModal();
            lblModalTitulo.Text = "Registrar Nuevo Producto";
            MostrarModal();
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            int idProducto;
            int.TryParse(hfIdProducto.Value, out idProducto);

            string codigo = txtCodigo.Text.Trim();
            string descripcion = txtDescripcion.Text.Trim();

            if (string.IsNullOrEmpty(codigo) || string.IsNullOrEmpty(descripcion))
            {
                MostrarErrorModal("El código y la descripción del producto son obligatorios.");
                return;
            }

            int idCategoria;
            if (!int.TryParse(cmbCategoriaModal.SelectedValue, out idCategoria) || idCategoria <= 0)
            {
                MostrarErrorModal("Debe seleccionar una categoría para el producto.");
                return;
            }

            decimal precioCompra, precioVenta, impuesto;
            int existencia;

            if (!TryLeerDecimal(txtPrecioCompra.Text, out precioCompra) ||
                !TryLeerDecimal(txtPrecioVenta.Text, out precioVenta) ||
                !TryLeerDecimal(txtImpuesto.Text, out impuesto) ||
                !int.TryParse(txtExistencia.Text.Trim(), out existencia) ||
                existencia < 0)
            {
                MostrarErrorModal("Revise los campos numéricos: precios, impuesto y existencia deben ser números válidos.");
                return;
            }

            string rutaImagen = string.Empty;

            if (fuImagen.HasFile)
            {
                string extension = Path.GetExtension(fuImagen.FileName);

                if (!ExtensionesImagenPermitidas.Contains(extension))
                {
                    MostrarErrorModal("El archivo seleccionado no es una imagen válida. Formatos permitidos: JPG, JPEG, PNG, GIF, WEBP y BMP.");
                    return;
                }

                string nombreArchivo = Guid.NewGuid().ToString("N") + extension.ToLowerInvariant();
                string carpetaDestino = Server.MapPath("~/Imagenes/");

                if (!Directory.Exists(carpetaDestino))
                {
                    Directory.CreateDirectory(carpetaDestino);
                }

                fuImagen.SaveAs(carpetaDestino + nombreArchivo);
                rutaImagen = "Imagenes/" + nombreArchivo;
            }

            try
            {
                bool resultado = idProducto > 0
                    ? Conexion.ActualizarProducto(idProducto, codigo, descripcion, precioCompra, precioVenta, impuesto, existencia, idCategoria, rutaImagen)
                    : Conexion.InsertarProducto(codigo, descripcion, precioCompra, precioVenta, impuesto, existencia, idCategoria, rutaImagen);

                if (!resultado)
                {
                    MostrarErrorModal("No se pudo guardar el producto. Verifique los datos ingresados.");
                    return;
                }
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2627 || ex.Number == 2601)
                {
                    MostrarErrorModal("Ya existe un producto registrado con el código \"" + codigo + "\".");
                    return;
                }

                throw;
            }

            CargarProductos();
            ScriptManager.RegisterStartupScript(this, GetType(), "HidePop", "var myModal = bootstrap.Modal.getInstance(document.getElementById('modalProducto')); if(myModal) myModal.hide();", true);
        }


        protected void gvProductos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int idProducto;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out idProducto))
            {
                return;
            }

            if (e.CommandName == "Eliminar")
            {
                Conexion.EliminarProducto(idProducto);
                CargarProductos();
            }
            else if (e.CommandName == "Editar")
            {
                DataRow producto = Conexion.ObtenerProducto(idProducto);

                if (producto == null)
                {
                    CargarProductos();
                    return;
                }

                hfIdProducto.Value = idProducto.ToString();
                lblModalTitulo.Text = "Editar Producto";
                lblMensajeModal.Visible = false;

                txtCodigo.Text = Convert.ToString(producto["Codigo"]);
                txtDescripcion.Text = Convert.ToString(producto["Descripcion"]);
                txtPrecioCompra.Text = FormatearDecimal(producto["PrecioCompra"]);
                txtPrecioVenta.Text = FormatearDecimal(producto["PrecioVenta"]);
                txtImpuesto.Text = FormatearDecimal(producto["Impuesto"]);
                txtExistencia.Text = Convert.ToString(producto["Existencia"]);
                cmbCategoriaModal.SelectedValue = Convert.ToString(producto["IdCategoria"]);

                MostrarModal();
            }
        }

        private void LimpiarFormularioModal()
        {
            hfIdProducto.Value = "0";
            lblMensajeModal.Visible = false;
            txtCodigo.Text = string.Empty;
            txtDescripcion.Text = string.Empty;
            txtPrecioCompra.Text = string.Empty;
            txtPrecioVenta.Text = string.Empty;
            txtImpuesto.Text = "15.00";
            txtExistencia.Text = string.Empty;
            cmbCategoriaModal.SelectedValue = "0";
        }

        private void MostrarModal()
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "Pop", "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalProducto')).show();", true);
        }

        private void MostrarErrorModal(string mensaje)
        {
            lblMensajeModal.Text = mensaje;
            lblMensajeModal.Visible = true;
            MostrarModal();
        }

        private static bool TryLeerDecimal(string valor, out decimal resultado)
        {
            return decimal.TryParse((valor ?? string.Empty).Trim(), NumberStyles.Number, CultureInfo.CurrentCulture, out resultado);
        }

        private static string FormatearDecimal(object valor)
        {
            if (valor == null || valor == DBNull.Value)
            {
                return "0";
            }

            return Convert.ToDecimal(valor).ToString("0.##", CultureInfo.InvariantCulture);
        }


        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
