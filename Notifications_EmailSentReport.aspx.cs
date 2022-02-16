using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.HtmlControls;
using Signify.Components;
using System.IO;
using System.Text.RegularExpressions;
using System.Data.Linq;
using System.Linq;
using SignifyTypeExtensions;
using SignifyHR.Helpers;
using System.ComponentModel;

namespace SignifyHR.Reports
{
    public partial class EmailSentReport : SignifyBase
    {
        const string EmailReportPreviewEmailUrl = "Notifications_EmailSentReport_PreviewEmail.aspx";
        const string ReportName = "E-mail Sent Report";
        const string ReportDesxcription = "This is a report to display a list of e-mails generated in the system.";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                dataBindModuleList();
                SetSearchCriteriaDefaultValues();
                lblPageDescription.Text = ReportDesxcription;
            }                      
        }

        private void SetSearchCriteriaDefaultValues()
        {
            ddlModule.SelectedIndex = 0;
            usrCreatedDateFrom.Value = Convert.ToString(DateTime.Now.AddMonths(-1));

            for (int i = 0; i < rblStatus.Items.Count; i++)
            {
                rblStatus.Items[i].Selected = true;
            }
        }

        private int PopulateData()
        {
            DataTable dt = SelectList(false);

            int rowNum = 0;
            int.TryParse(dt.Rows.Count.ToString(), out rowNum);

            if (dt.Rows.Count > 0)
            {                
                rptResults.DataSource = dt;
                rptResults.DataBind();
                divResults.Visible = true;
                divNoResults.Visible = false;
                btnExport.Enabled = true;
                if (dt.Rows.Count >= 500)
                {
                    lblPageDescription.Text = "Please note that only the first 500 records are displayed in the list below. " +
                        "Click on 'Export to Excel' to download a file of the latest 10000 records for your current search criteria. " +
                        "If the results you are looking for are not in the 10000 results, please narrow your search criteria by clicking on 'Change Search Criteria'.";
                }
                else
                {   
                    lblPageDescription.Text = "Search Results";
                }
            }
            else
            {
                rptResults.DataSource = null;
                rptResults.DataBind();
                divNoResults.Visible = true;
                divPageDescription.Visible = false;
                btnExport.Enabled = false;
            }
            return rowNum;
        }

        private DataTable SelectList(bool isExport)
        {
            SqlParameter[] parms = new SqlParameter[18];

            parms[0] = SQL.SQLParameter("@SchemaID", SqlDbType.Int, 4, SignifyControl.SchemaID);
            parms[1] = SQL.SQLParameter("@SysID", SqlDbType.Int, 4, SignifyControl.SystemID);
            parms[2] = SQL.SQLParameter("@ModuleName", SqlDbType.VarChar, 500, ddlModule.SelectedValue);
            parms[3] = SQL.SQLParameter("@TemplateName", SqlDbType.VarChar, 150, lTemplateName.Text);
            parms[4] = SQL.SQLParameter("@EmployeeNumber", SqlDbType.VarChar, 100, lEmpNumber.Text);
            parms[5] = SQL.SQLParameter("@NameANDSurname", SqlDbType.VarChar, 1000, lNameSurname.Text);
            parms[6] = SQL.SQLParameter("@CreatedDateFrom", SqlDbType.VarChar, 50, usrCreatedDateFrom.Value);
            parms[7] = SQL.SQLParameter("@CreatedDateTo", SqlDbType.VarChar, 50, usrCreatedDateTo.Value);
            parms[8] = SQL.SQLParameter("@EmailSent", SqlDbType.VarChar, 50, rblStatus.SelectedValue);
            parms[9] = SQL.SQLParameter("@DateTimeSentFrom", SqlDbType.VarChar, 50, usrSentDateFrom.Value);
            parms[10] = SQL.SQLParameter("@DateTimeSentTo", SqlDbType.VarChar, 50, usrSentDateTo.Value);
            parms[11] = SQL.SQLParameter("@FromEmailAddress", SqlDbType.VarChar, 150, lFromAddress.Text);
            parms[12] = SQL.SQLParameter("@ToEmailAddress", SqlDbType.VarChar, 2000, lToAddress.Text);
            parms[13] = SQL.SQLParameter("@CCEmailAddress", SqlDbType.VarChar, 2000, lCCAddress.Text);
            parms[14] = SQL.SQLParameter("@BCCEmailAddress", SqlDbType.VarChar, 2000, lBCCAddress.Text);
            parms[15] = SQL.SQLParameter("@Subject", SqlDbType.VarChar, 300, lSubject.Text);
            parms[16] = SQL.SQLParameter("@Body", SqlDbType.VarChar, 2000, lBody.Text);
            parms[17] = SQL.SQLParameter("@isExport", SqlDbType.Bit, isExport);

            return SQL.ExecuteDataTable("reportSelectNotificationEmailsToBeSentListAll", parms);
        }

        private void dataBindModuleList()
        {
            SqlParameter[] parms = new SqlParameter[2];

            parms[0] = SQL.SQLParameter("@SchemaID", SqlDbType.Int, SignifyControl.SchemaID);
            parms[1] = SQL.SQLParameter("@SysID", SqlDbType.Int, SignifyControl.SystemID);

            ddlModule.DataSource = SQL.ExecuteDataTable("reportCustomSelectNotificationTemplateModulesListAll", parms);
            ddlModule.DataBind();
            ddlModule.Items.Insert(0, new ListItem("All", ""));
        }

        protected void rptResults_ItemDataBound(Object sender, DataGridItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Header)
            {
                e.Item.Cells[0].Text = "Action";
                e.Item.Cells[e.Item.Cells.Count - 1].Attributes["align"] = "center";
            }
            else
            if (e.Item.ItemType == ListItemType.AlternatingItem || e.Item.ItemType == ListItemType.Item)
            {
                for (int i = 0; i < e.Item.Cells.Count; i++)
                {
                    if (i == 0)
                    {
                        LinkButton link = new LinkButton();

                        link.Text = "View e-mail";
                        link.Attributes["onclick"] = "return OpenWindow('" + EmailReportPreviewEmailUrl + "?ObjectID=" + e.Item.Cells[1].Text + "', 1200, 1200);";
                        link.Style.Add(HtmlTextWriterStyle.Cursor, "pointer");
                        e.Item.Cells[i].Text = "";
                        e.Item.Cells[i].Controls.Add(link);
                    }

                    e.Item.Cells[i].Attributes["valign"] = "top";
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            int rowNum = PopulateData();            
            SetReportFilterValues(rowNum);            
            pSearch.Visible = false;
            divButtons.Visible = true;
        }

        private void SetReportFilterValues(int rowNum = 0)
        {
            tFilterResults.Visible = true;
            lblCount.Text = rowNum.ToString();

            lSchema.Text = Convert.ToString(SignifyControl.SchemaID);
            lModule.Text = ddlModule.SelectedItem.Text;
            lTemplateName.Text = txtTemplateName.Text;
            lEmpNumber.Text = txtEmpNumber.Text;
            lNameSurname.Text = txtNameSurname.Text;

            if ((usrCreatedDateFrom.Value == "") && (usrCreatedDateTo.Value == ""))
                lCreatedDate.Text = "";
            else
            {
                string CreatedDateFrom;
                string CreatedDateTo;

                if (usrCreatedDateFrom.Value != "")
                    CreatedDateFrom = usrCreatedDateFrom.Value;
                else CreatedDateFrom = "1900/01/01";

                if (usrCreatedDateTo.Value != "")
                    CreatedDateTo = usrCreatedDateTo.Value;
                else CreatedDateTo = "9999/12/31";

                lCreatedDate.Text = CreatedDateFrom + " And " + CreatedDateTo;
            }                        

            if ((usrSentDateFrom.Value == "") && (usrSentDateTo.Value == ""))
                lSentDate.Text = "";
            else
            {
                string SentDateFrom;
                string SentDateTo;

                if (usrSentDateFrom.Value != "")
                    SentDateFrom = usrSentDateFrom.Value;
                else SentDateFrom = "1900/01/01";

                if (usrSentDateTo.Value != "")
                    SentDateTo = usrSentDateTo.Value;
                else SentDateTo = "9999/12/31";

                lSentDate.Text = SentDateFrom + " And " + SentDateTo;
            }                

            lFromAddress.Text = txtFromAddress.Text;
            lToAddress.Text = txtToAddress.Text;
            lCCAddress.Text = txtCCAddress.Text;
            lBCCAddress.Text = txtBCCAddress.Text;
            lSubject.Text = txtSubject.Text;
            lBody.Text = txtBody.Text;

            string statusList = "";
            for (int i = 0; i < rblStatus.Items.Count; i++)
            {
                if (rblStatus.Items[i].Selected)
                {
                    if (statusList == "")
                    {
                        statusList = rblStatus.Items[i].Text;
                    }
                    else
                    {
                        statusList = statusList + ", " + rblStatus.Items[i].Text;
                    }
                }
            }
            lSentStatus.Text = statusList;
            trCount.Visible = true;

            trModule.Visible = lModule.Text != "";
            trTemplateName.Visible = lTemplateName.Text != "";
            trEmpNumber.Visible = lEmpNumber.Text != "";
            trNameSurname.Visible = lNameSurname.Text != "";
            trSentStatus.Visible = lSentStatus.Text != "";
            trCreatedDate.Visible = lCreatedDate.Text != "";
            trSentDate.Visible = lSentDate.Text != "";
            trFromAddress.Visible = lFromAddress.Text != "";
            trToAddress.Visible = lToAddress.Text != "";
            trCCAddress.Visible = lCCAddress.Text != "";
            trBCCAddress.Visible = lBCCAddress.Text != "";
            trSubject.Visible = lSubject.Text != "";
            trBody.Visible = lBody.Text != "";
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            SetSearchCriteriaDefaultValues();            

            txtTemplateName.Text = "";
            txtEmpNumber.Text = "";
            txtNameSurname.Text = "";
            txtFromAddress.Text = "";
            txtToAddress.Text = "";
            txtCCAddress.Text = "";
            txtBCCAddress.Text = "";
            txtSubject.Text = "";
            txtBody.Text = "";
            usrCreatedDateTo.Value = "";
            usrSentDateFrom.Value = "";
            usrSentDateTo.Value = "";

        }

        protected void btnChangeSearchCriteria_Click(object sender, EventArgs e)
        {
            tFilterResults.Visible = false;
            pSearch.Visible = true;
            divNoResults.Visible = false;
            divResults.Visible = false;
            divPageDescription.Visible = true;
            lblPageDescription.Text = ReportDesxcription;
            divButtons.Visible = false;
            lblCount.Visible = false;
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            SetReportFilterValues();
            GenerateExcelReport(true);
        }

        public void GenerateExcelReport(bool isExport)
        {
            DataTable resultsTable = SelectList(isExport);
            var exporter = new ExcelXmlExporter(this.Response, ExcelXmlExporter.Mode.SpanHeaders);            

            var searchCriteria = new List<ExcelXmlExporter.SearchCriteria>();

                searchCriteria.Add(ExcelXmlExporter.SearchCriteria.Empty);
            if (lModule.Text != "")
                searchCriteria.Add(new ExcelXmlExporter.SearchCriteria(lblModule.Text, lModule.Text));
            if (lTemplateName.Text != "")
                searchCriteria.Add(new ExcelXmlExporter.SearchCriteria(lblTemplateName.Text, lTemplateName.Text));
            if (lEmpNumber.Text != "")
                searchCriteria.Add(new ExcelXmlExporter.SearchCriteria(lblEmpNumber.Text, lEmpNumber.Text));
            if (lNameSurname.Text != "")
                searchCriteria.Add(new ExcelXmlExporter.SearchCriteria(lblNameSurname.Text, lNameSurname.Text));
                searchCriteria.Add(new ExcelXmlExporter.SearchCriteria(lblSentStatus.Text, lSentStatus.Text));
            if (lCreatedDate.Text != "")
                searchCriteria.Add(new ExcelXmlExporter.SearchCriteria(lblCreatedDate.Text, lCreatedDate.Text));
            if (lSentDate.Text != "")
                searchCriteria.Add(new ExcelXmlExporter.SearchCriteria(lblSentDate.Text, lSentDate.Text));
            if (lFromAddress.Text != "")
                searchCriteria.Add(new ExcelXmlExporter.SearchCriteria(lblFromAddress.Text, lFromAddress.Text));
            if (lToAddress.Text != "")
                searchCriteria.Add(new ExcelXmlExporter.SearchCriteria(lblToAddress.Text, lToAddress.Text));
            if (lCCAddress.Text != "")
                searchCriteria.Add(new ExcelXmlExporter.SearchCriteria(lblCCAddress.Text, lCCAddress.Text));
            if (lBCCAddress.Text != "")
                searchCriteria.Add(new ExcelXmlExporter.SearchCriteria(lblBCCAddress.Text, lBCCAddress.Text));
            if (lSubject.Text != "")
                searchCriteria.Add(new ExcelXmlExporter.SearchCriteria(lblSubject.Text, lSubject.Text));
            if (lBody.Text != "")
                searchCriteria.Add(new ExcelXmlExporter.SearchCriteria(lblBody.Text, lBody.Text));
                searchCriteria.Add(ExcelXmlExporter.SearchCriteria.Empty);

            var preListContent = new ExcelXmlExporter.PreListContent
                (
                    ReportName,
                    searchCriteria.ToArray()
                );

            exporter.CompleteExport(String.Format(ReportName + "_{0}.xls", DateTime.Now.ToString("yyyy-MM-dd")), resultsTable, preListContent);
        }

        

    }
}