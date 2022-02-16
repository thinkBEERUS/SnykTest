<%@ Page Language="C#" AutoEventWireup="True" CodeFile="ReportTemplate.aspx.cs" Inherits="ReportTemplate" EnableEventValidation="false"  MasterPageFile="~/Layout/Masters/Bootstrap3Popup.master"%>

<%@ Register Assembly="SignifyControlLibrary" Namespace="SignifyControlLibrary" TagPrefix="signify" %>
<%@ Register Src="~/Framework/Common/UserControls_Btr3/usrExportDocuments_Btr3.ascx" TagName="usrExportDocuments" TagPrefix="usr" %>
<%@ Register Src="~/Framework/Common/UserControls_Btr3/usrCalendar_Btr3.ascx" TagPrefix="usr" TagName="usrCalendar" %>
<%@ Register Src="~/Framework/Reporting/Common/UserControls_Btr3/usrOrganisationLevels.ascx" TagName="usrOrganisationLevels" TagPrefix="usr" %>

<asp:Content ID="Content1" ContentPlaceHolderID="CustomStylesContentBootStrap" runat="Server">
    <style>
        .fa-chevron-up {
            transition: transform 0.2s;
        }
        .panel-heading.collapsed > .panel-title .fa-chevron-up {
            transform: rotateX(180deg);
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="BodyContentBootstrap" runat="Server">
    <div class="panel panel-default depth-2">
        <div class="panel-heading clickAble" data-toggle="collapse" href="#search" style="padding: 10px">
            <div class="panel-title">
                <span>Search</span>
                <i class="fa fa-chevron-up pull-right"></i>
            </div>
        </div>
        <div class="panel-collapse collapse in" id="search">
            <div class="panel-body">
                <div class="form-horizontal">
                    <div class="form-group">
                        <asp:Label runat="server" CssClass="control-label col-sm-1" style="margin-top: 6px;" AssociatedControlID="calFromDate" Text="From Date" />
                        <div class="col-sm-3" style="margin-top: 6px;">
                                <usr:usrCalendar ID="calFromDate" runat="server" ShowValidator="false" CssClass="" />
                        </div>
                        <div class="col-sm-3">
                            <input type="checkbox" class="form-check-input" id="cbSysTriggered" runat="server">
                            <label class="form-check-label" for="cbSysTriggered">System Triggered Email Templates</label>
                        </div>
                        <div class="col-sm-3">
                            <input type="checkbox" class="form-check-input" id="cbScheduled" runat="server">
                            <label class="form-check-label" for="cbScheduled">Scheduled Email Templates</label>
                        </div>
                        <div class="col-sm-3">
                            <input type="checkbox" class="form-check-input" id="cbChanges" runat="server">
                            <label class="form-check-label" for="cbChanges">Edited Templates</label>
                        </div>
                        <div class="col-sm-3">
                            <input type="checkbox" class="form-check-input" id="cbErrors" runat="server">
                            <label class="form-check-label" for="cbErrors">Notification Errors</label>
                        </div>
                    </div>                    
                </div>
                
                <div class="mt-4">
                    <asp:LinkButton ID="btnSearch" CssClass="btn btn-primary" runat="server" OnClick="btnSearch_Click">
                        <i class="fa fa-fw fa-search" runat="server"></i> Search
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnClearSearch" CssClass="btn btn-primary" runat="server" OnClick="btnClearSearch_Click">
                        <i class="fa fa-fw fa-repeat" runat="server"></i> Clear Search
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnExportToExcel" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" OnClientClick="hideGeneralLoadingIndicator">
                        <i class="fa fa-fw fa-download" runat="server"></i> Export to Excel
                    </asp:LinkButton>
                </div>
            </div>
        </div>
    </div>
    <div class="panel panel-default depth-2" runat="server" id="secTriggered">
        <div class="panel-heading clickAble" data-toggle="collapse" href="#pnlTriggered" style="padding: 10px">
            <div class="panel-title">
                <span>System Triggered</span>
                <i class="fa fa-chevron-up pull-right"></i>
            </div>
        </div>
        <div class="panel-collapse collapse in" id="pnlTriggered">
            <div class="panel-body">
                <signify:SignifyRepeater ID="rptTriggered" runat="server" OnPaging_Clicked="rptTriggered_Paging_Clicked" OnItemDataBound="rptTriggered_ItemDataBound" AllowPaging="false" PageSize="Twenty" ShowNoResultsFoundMessageAlert="True">
                    <HeaderTemplate>
                        <table class="table table-striped">
                            <thead>
                                <tr runat="server">
                                    <th>
                                        <asp:Label ID="lblTriggerName" runat="server" Text='Name' />
                                    </th>
                                    <th>
                                        <asp:Label ID="lblTriggerDescription" runat="server" Text='Description' />
                                    </th>
                                    <th>
                                        <asp:Label ID="lblTriggerEmailsSent" runat="server" Text='Emails Sent (default From Date past 7 days)' />
                                    </th>
                                    <th>
                                        <asp:Label ID="lblTriggerEmailLast" runat="server" Text='Last Email Sent' />
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr id="trList" runat="server" style="cursor: default">
                            <td>
                                <asp:Label ID="lblTmpName" runat="server" Text='<%#Bind("[Template Name]")%>' />
                            </td>
                            <td>
                                <asp:Label ID="lblTmpDescription" runat="server" Text='<%#Bind("Description")%>' />
                            </td>
                            <td>
                                <asp:Label ID="lblTmpEmailsSent" runat="server" Text='<%#Bind("EmailsSent")%>' />
                            </td>
                            <td>
                                <asp:Label ID="lblTmpEmailLast" runat="server" Text='<%#Bind("LastSent", "{0: dd/MM/yyyy}")%>' />
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </tbody>
                        </table>
                    </FooterTemplate>
                </signify:SignifyRepeater>
            </div>
        </div>
    </div>
    <div class="panel panel-default depth-2" runat="server" id="secScheduled">
        <div class="panel-heading clickAble" data-toggle="collapse" href="#pnlScheduled" style="padding: 10px">
            <div class="panel-title">
                <span>Scheduled</span>
                <i class="fa fa-chevron-up pull-right"></i>
            </div>
        </div>
        <div class="panel-collapse collapse in" id="pnlScheduled">
            <div class="panel-body">
                <signify:SignifyRepeater ID="rptScheduled" runat="server" AllowPaging="false" PageSize="Twenty" ShowNoResultsFoundMessageAlert="True">
                    <HeaderTemplate>
                        <table class="table table-striped">
                            <thead>
                                <tr runat="server">
                                    <th>
                                        <asp:Label ID="lblSchedTmpName" runat="server" Text='Name' />
                                    </th>
                                    <th>
                                        <asp:Label ID="lblSchedTmpDescript" runat="server" Text='Description' />
                                    </th>
                                    <th>
                                        <asp:Label ID="lblSchedTmpActive" runat="server" Text='Template Active' />
                                    </th>
                                    <th>
                                        <asp:Label ID="lblSchedTmpFreq" runat="server" Text='Sent' />
                                    </th>
                                    <th>
                                        <asp:Label ID="lblSchedTmpRecipients" runat="server" Text='Last Sent' />
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr id="tr1" runat="server" style="cursor: default">
                            <td>
                                <asp:Label ID="Label2" runat="server" Text='<%#Bind("[Template Name]") %>' />
                            </td>
                            <td>
                                <asp:Label ID="Label1" runat="server" Text='<%#Bind("Description") %>' />
                            </td>
                            <td>
                                <asp:Label ID="Label7" runat="server" Text='<%#Bind("TemplateActive") %>' />
                            </td>
                            <td>
                                <asp:Label ID="Label8" runat="server" Text='<%#Bind("EmailsSent") %>' />
                            </td>
                            <td>
                                <asp:Label ID="Label9" runat="server" Text='<%#Bind("LastSent", "{0: dd/MM/yyyy}") %>' />
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </tbody>
                        </table>
                    </FooterTemplate>
                </signify:SignifyRepeater>
            </div>
        </div>
    </div>
    <div class="panel panel-default depth-2" runat="server" id="secEdited">
        <div class="panel-heading clickAble" data-toggle="collapse" href="#pnlChanges" style="padding: 10px">
            <div class="panel-title">
                <span>Edited Templates</span>
                <i class="fa fa-chevron-up pull-right"></i>
            </div>
        </div>
        <div class="panel-collapse collapse in" id="pnlChanges">
            <div class="panel-body">
                <section>
                    <h4>System Triggered Changes</h4>
                    <p>
                        <signify:SignifyRepeater ID="rptTriggeredChanges" runat="server" AllowPaging="false" PageSize="Twenty" ShowNoResultsFoundMessageAlert="True">
                            <HeaderTemplate>
                                <table class="table table-striped">
                                    <thead>
                                        <tr runat="server">
                                            <th>
                                                <asp:Label ID="Label3" runat="server" Text='Name' />
                                            </th>
                                            <th>
                                                <asp:Label ID="Label10" runat="server" Text='Description' />
                                            </th>
                                            <th>
                                                <asp:Label ID="Label11" runat="server" Text='Template Status' />
                                            </th>
                                            <th>
                                                <asp:Label ID="Label13" runat="server" Text='Recipients' />
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr id="tr8" runat="server" style="cursor: default">
                                    <td>
                                        <asp:Label ID="Label14" runat="server" Text='<%#Bind("[Template Name]") %>' />
                                    </td>
                                    <td>
                                        <asp:Label ID="Label15" runat="server" Text='<%#Bind("Description") %>' />
                                    </td>
                                    <td>
                                        <asp:Label ID="Label16" runat="server" Text='<%#Bind("TemplateActive") %>' />
                                    </td>
                                    <td>
                                        <asp:Label ID="Label18" runat="server" Text='<%#Bind("Recipients") %>' />
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                </tbody>
                                </table>
                            </FooterTemplate>
                        </signify:SignifyRepeater>
                    </p>                    
                </section>
                <section>
                    <h4>System Scheduled Changes</h4>
                    <p>
                        <signify:SignifyRepeater ID="rptScheduledChanges" runat="server" AllowPaging="false" PageSize="Twenty" ShowNoResultsFoundMessageAlert="True">
                        <HeaderTemplate>
                            <table class="table table-striped">
                                <thead>
                                    <tr runat="server">
                                        <th>
                                            <asp:Label ID="Label23" runat="server" Text='Name' />
                                        </th>
                                        <th>
                                            <asp:Label ID="Label25" runat="server" Text='Description' />
                                        </th>
                                        <th>
                                            <asp:Label ID="Label26" runat="server" Text='Template Status' />
                                        </th>
                                        <th>
                                            <asp:Label ID="Label34" runat="server" Text='Schedule Status' />
                                        </th>
                                        <th>
                                            <asp:Label ID="Label27" runat="server" Text='Frequency' />
                                        </th>
                                        <th>
                                            <asp:Label ID="Label28" runat="server" Text='Recipients' />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr id="tr3" runat="server" style="cursor: default">
                                <td>
                                    <asp:Label ID="Label29" runat="server" Text='<%#Bind("[Template Name]") %>' />
                                </td>
                                <td>
                                    <asp:Label ID="Label30" runat="server" Text='<%#Bind("Description") %>' />
                                </td>
                                <td>
                                    <asp:Label ID="Label31" runat="server" Text='<%#Bind("TemplateActive") %>' />
                                </td>
                                <td>
                                    <asp:Label ID="Label35" runat="server" Text='<%#Bind("ScheduleActive") %>' />
                                </td>
                                <td>
                                    <asp:Label ID="Label32" runat="server" Text='<%#Bind("Frequency") %>' />
                                </td>
                                <td>
                                    <asp:Label ID="Label33" runat="server" Text='<%#Bind("Recipients") %>' />
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            </tbody>
                            </table>
                        </FooterTemplate>
                    </signify:SignifyRepeater>
                    </p>
                </section>                
            </div>
        </div>
    </div>
    <div class="panel panel-default depth-2" runat="server" id="secErrors">
        <div class="panel-heading clickAble" data-toggle="collapse" href="#pnlErrors" style="padding: 10px">
            <div class="panel-title">
                <span>Notification Errors</span>
                <i class="fa fa-chevron-up pull-right"></i>
            </div>
        </div>
        <div class="panel-collapse collapse in" id="pnlErrors">
            <div class="panel-body">
                <signify:SignifyRepeater ID="rptErrors" runat="server" AllowPaging="false" PageSize="Twenty" ShowNoResultsFoundMessageAlert="True">
                    <HeaderTemplate>
                        <table class="table table-striped">
                            <thead>
                                <tr runat="server">
                                    <th>
                                        <asp:Label ID="Label4" runat="server" Text='Name' />
                                    </th>
                                    <th>
                                        <asp:Label ID="Label5" runat="server" Text='Description' />
                                    </th>
                                    <th>
                                        <asp:Label ID="Label19" runat="server" Text='Recipients' />
                                    </th>
                                    <th>
                                        <asp:Label ID="Label20" runat="server" Text='Error' />
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr id="tr2" runat="server" style="cursor: default">
                            <td>
                                <asp:Label ID="Label6" runat="server" Text='<%#Bind("[Template Name]") %>' />
                            </td>
                            <td>
                                <asp:Label ID="Label21" runat="server" Text='<%#Bind("Description") %>' />
                            </td>
                            <td>
                                <asp:Label ID="Label24" runat="server" Text='<%#Bind("Recipients") %>' />
                            </td>
                            <td>
                                <asp:Label ID="Label22" runat="server" Text='<%#Bind("Error") %>' />
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </tbody>
                        </table>
                    </FooterTemplate>
                </signify:SignifyRepeater>
            </div>
        </div>
    </div>
    <asp:HiddenField ID="hfExample" runat="server" Value="0" />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptContentBootstrap" runat="Server">
    <script language="javascript" type="text/javascript">
        var backup = window.onbeforeunload; // Make a backup of the beforeunload event
        window.onbeforeunload = null; // Unbind the beforeunload event
        window.location = documentUrl; // Do the “redirect” if it’s a link
        window.setTimeout(function () {
            window.onbeforeunload = backup; // Restore the event asynchronously
        }, 500);
        function CloseWindow() {
            window.close();
            return false;
        }
    </script>
</asp:Content>
