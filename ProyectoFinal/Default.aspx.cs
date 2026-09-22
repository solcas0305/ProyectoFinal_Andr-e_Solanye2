using System;
using System.Web.UI;

namespace ProyectoFinal
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Redirect(Session["NombreUsuario"] != null ? "Inventario.aspx" : "Login.aspx");
        }
    }
}
