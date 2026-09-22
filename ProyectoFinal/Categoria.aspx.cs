using System;
using System.Data;
using System.Web.UI;

namespace InventarioWeb
{
    public partial class Categorias : System.Web.UI.Page
    {
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
            }
        }

        private void CargarCategorias()
        {
            DataTable dt = Conexion.ObtenerCategorias();
            gvCategorias.DataSource = dt;
            gvCategorias.DataBind();
        }

        protected void btnAbrirNuevo_Click(object sender, EventArgs e)
        {
            txtNombreCategoria.Text = string.Empty;
            lblMensajeModal.Visible = false;
            lblExito.Visible = false;
            MostrarModal();
        }

        protected void btnGuardarCategoria_Click(object sender, EventArgs e)
        {
            string nombre = txtNombreCategoria.Text.Trim();

            if (string.IsNullOrEmpty(nombre))
            {
                MostrarErrorModal("Por favor ingrese el nombre de la categoría.");
                return;
            }

            if (nombre.Length > 100)
            {
                MostrarErrorModal("El nombre de la categoría no puede superar los 100 caracteres.");
                return;
            }

            if (YaExisteCategoria(nombre))
            {
                MostrarErrorModal("Ya existe una categoría activa con el nombre \"" + nombre + "\".");
                return;
            }

            if (!Conexion.InsertarCategoria(nombre))
            {
                MostrarErrorModal("No se pudo registrar la categoría. Intente nuevamente.");
                return;
            }

            CargarCategorias();
            lblMensajeModal.Visible = false;
            lblExito.Text = "La categoría \"" + nombre + "\" se registró correctamente.";
            lblExito.Visible = true;
            ScriptManager.RegisterStartupScript(this, GetType(), "HidePop", "var myModal = bootstrap.Modal.getInstance(document.getElementById('modalCategoria')); if(myModal) myModal.hide();", true);
        }

        private bool YaExisteCategoria(string nombre)
        {
            foreach (DataRow fila in Conexion.ObtenerCategorias().Rows)
            {
                if (string.Equals(Convert.ToString(fila["NombreCategoria"]).Trim(), nombre, StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }
            }

            return false;
        }

        private void MostrarModal()
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "Pop", "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalCategoria')).show();", true);
        }

        private void MostrarErrorModal(string mensaje)
        {
            lblMensajeModal.Text = mensaje;
            lblMensajeModal.Visible = true;
            lblExito.Visible = false;
            MostrarModal();
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
