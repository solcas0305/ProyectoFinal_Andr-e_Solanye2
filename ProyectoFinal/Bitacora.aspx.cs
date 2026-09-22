using System;
using System.Data;

namespace InventarioWeb
{
    public partial class Bitacora : System.Web.UI.Page
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
                CargarBitacora();
            }
        }

        private void CargarBitacora()
        {
            DataTable dt = Conexion.ObtenerBitacora();
            gvBitacora.DataSource = dt;
            gvBitacora.DataBind();
        }

        protected string ObtenerClaseOperacion(object operacion)
        {
            switch (Convert.ToString(operacion).ToUpperInvariant())
            {
                case "INSERT": return "bg-success";
                case "UPDATE": return "bg-warning text-dark";
                case "DELETE": return "bg-danger";
                default: return "bg-secondary";
            }
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}