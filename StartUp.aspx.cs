using System;
using Signify.Components;

public partial class StartUp : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Redirect("ReportTemplate.aspx");
    }
}
