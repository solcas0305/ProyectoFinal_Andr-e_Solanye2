using System;
using System.Data;
using System.Web;

namespace InventarioWeb
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {

                if (Request.Cookies["RecordarUsuario"] != null)
                {
                    txtUsuario.Text = Request.Cookies["RecordarUsuario"].Value;
                    chkRecordar.Checked = true;
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string usuario = txtUsuario.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(usuario) || string.IsNullOrEmpty(password))
            {
                lblError.Text = "Por favor complete todos los campos.";
                lblError.Visible = true;
                return;
            }

            DataTable dt = Conexion.ValidarUsuario(usuario, password);

            if (dt.Rows.Count > 0)
            {
                Session["UsuarioID"] = dt.Rows[0]["IdUsuario"].ToString();
                Session["NombreUsuario"] = dt.Rows[0]["NombreCompleto"].ToString();
                Session["Rol"] = dt.Rows[0]["NombreRol"].ToString();

                if (chkRecordar.Checked)
                {
                    HttpCookie cookieUser = new HttpCookie("RecordarUsuario", usuario);
                    cookieUser.Expires = DateTime.Now.AddDays(7); 
                    Response.Cookies.Add(cookieUser);
                }
                else
                {
                    if (Request.Cookies["RecordarUsuario"] != null)
                    {
                        HttpCookie cookieUser = new HttpCookie("RecordarUsuario");
                        cookieUser.Expires = DateTime.Now.AddDays(-1);
                        Response.Cookies.Add(cookieUser);
                    }
                }
                Response.Redirect("Inventario.aspx");
            }
            else
            {
                lblError.Text = "Usuario o contraseña incorrectos.";
                lblError.Visible = true;
            }
        }
    }
}