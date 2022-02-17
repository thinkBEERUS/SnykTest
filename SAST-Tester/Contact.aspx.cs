using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SAST_Tester
{
    public partial class Contact : Page
    {
        private string name;
        private void SetName(string name)
        {
            name = name;
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            SetName("Helloooo Pieter");
        }
    }
}