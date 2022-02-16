using System.Data;
using System.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using CarlosAg.ExcelXmlWriter;
using Signify.Components;
using Signify.Framework.Configuration;
using System.Web.UI.HtmlControls;
using SignifyHR.Helpers;
using SignifyHR.Domain;
using SignifyTypeExtensions;
using SignifyHR.Models;


public partial class ReportTemplate : SignifyBase
{
    #region Export Types / Values

    const string msWordExportValue = "Word";
    const string msExcelExportValue = "Excel";
    const string pdfExportValue = "PDF";

    #endregion

    private DateTime fromDate = SystemStandards.LowDate;
    private int triggered = 0;
    private int scheduled = 0;
    private int changes = 0;
    private int errors = 0;

    #region Page load and related methods


    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            HidePanels();
        }
        SetPopupSettings();
    }

    private void HidePanels()
    {
        secTriggered.Attributes["style"] = secScheduled.Attributes["style"] = secEdited.Attributes["style"] = secErrors.Attributes["style"] = "display:none";
    }

    private void ShowPanels()
    {
        SetSelectedTables();
        secTriggered.Attributes["style"] = triggered == 1 ? "" : "display:none";
        secScheduled.Attributes["style"] = scheduled == 1 ? "" : "display:none";
        secEdited.Attributes["style"] = changes == 1 ? "" : "display:none";
        secErrors.Attributes["style"] = errors == 1 ? "" : "display:none";
    }

    private void SetPopupSettings()
    {
        var popupSettings = new PopupSettings
        {
            MasterPage = (Layout_Bootstrap3Popup_master)this.Page.Master,
            PageHeading = "Client Mail Health Check Report",
            PageDescription = "Full report regarding the client’s email distribution.",
        };
        popupSettings.SetupMasterPage();
    }   

    #endregion

    protected void SelectData()
    {
        DataSet ds = GetData();

        int count = 0;
        foreach (DataTable dt in ds.Tables)
        {
            if (count < ds.Tables.Count)
            {
                if (cbSysTriggered.Checked && count == 0)
                {
                        rptTriggered.DataSource = dt.Rows.Count > 0 ? dt : null;
                        rptTriggered.DataBind();
                }
                else if (cbScheduled.Checked && count == 1)
                {
                        rptScheduled.DataSource = dt.Rows.Count > 0 ? dt : null;
                        rptScheduled.DataBind();
                }
                else if (cbChanges.Checked && (count == 2 || count == 3))
                {
                    if (count == 2)
                    {
                        rptTriggeredChanges.DataSource = dt.Rows.Count > 0 ? dt : null;
                        rptTriggeredChanges.DataBind();
                    }
                    if (count == 3)
                    {
                        rptScheduledChanges.DataSource = dt.Rows.Count > 0 ? dt : null;
                        rptScheduledChanges.DataBind();
                    }
                }
                else if (cbErrors.Checked && count == 4)
                {
                        rptErrors.DataSource = dt.Rows.Count > 0 ? dt : null;
                        rptErrors.DataBind();
                }
                count++;
            }
        }
    }

    #region Repeater events

    protected void rptTriggered_Paging_Clicked(object sender, EventArgs e)
    {
        //SelectData();
    }


    protected void rptTriggered_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        //if (e.Item.ItemType == ListItemType.AlternatingItem || e.Item.ItemType == ListItemType.Item)
        //{
        //    Label lblExample = ((Label)e.Item.FindControl("lblExample"));
        //}
    }

    #endregion

    #region Button Click events

    protected void btnClearSearch_Click(object sender, EventArgs e)
    {
        Response.Redirect(HttpContext.Current.Request.Url.AbsoluteUri);
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        //ccSignifyRepeater.ResetPageCounter();
        SelectData();
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        var searchParms = new List<ExcelExportSearchCriteria>
        {
            new ExcelExportSearchCriteria { Title = "", Value = "" }
        };

        ExcelExportUtilities.ExportResults("Client Mail Health Check Report", DateTime.Now.ToShortDateString() + "Export", GetExportData(), searchParms.ToArray());

        Response.Redirect(HttpContext.Current.Request.Url.AbsoluteUri);
    }

    #endregion


    override protected void OnInit(EventArgs e)
    {
        base.OnInit(e);
    }

    public DataSet GetExportData()
    {
        SetSelectedTables();
        List<SqlParameter> parms = new List<SqlParameter>
        {
            SQL.SQLParameter("@Email", SqlDbType.Int, 0),
            SQL.SQLParameter("@FromDate", SqlDbType.DateTime, GetSelectedDate()),
            SQL.SQLParameter("@Triggered", SqlDbType.Int, triggered),
            SQL.SQLParameter("@Scheduled", SqlDbType.Int, scheduled),
            SQL.SQLParameter("@Changes", SqlDbType.Int, changes),
            SQL.SQLParameter("@Errors", SqlDbType.Int, errors)
        };
        return SQL.ExecuteDataSet("ntfClientHealthCheckData", parms.ToArray());
    }

    public DataSet GetData()
    {
        List<SqlParameter> parms = GetSQLParameters();
        return SQL.ExecuteDataSet("ntfClientHealthCheckData", parms.ToArray());
    }

    private DateTime GetSelectedDate()
    {
        if (calFromDate.Value != "")
            fromDate = calFromDate.Value_Date;
        return fromDate;
    }

    private void SetSelectedTables()
    {
        if (cbSysTriggered.Checked)
            this.triggered = 1;
        if (cbScheduled.Checked)
            this.scheduled = 1;
        if (cbChanges.Checked)
            this.changes = 1;
        if (cbErrors.Checked)
            this.errors = 1;
    }

    private List<SqlParameter> GetSQLParameters()
    {
        SetSelectedTables();
        List<SqlParameter> parms = new List<SqlParameter>
        {
            SQL.SQLParameter("@Email", SqlDbType.Int, 0),
            SQL.SQLParameter("@FromDate", SqlDbType.DateTime, GetSelectedDate()),
            SQL.SQLParameter("@Triggered", SqlDbType.Int, 1),
            SQL.SQLParameter("@Scheduled", SqlDbType.Int, 1),
            SQL.SQLParameter("@Changes", SqlDbType.Int, 1),
            SQL.SQLParameter("@Errors", SqlDbType.Int, 1)
        };
        ShowPanels();
        return parms;
    }
}
