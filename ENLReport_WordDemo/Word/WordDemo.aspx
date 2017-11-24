<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WordDemo.aspx.cs" Inherits="ENLReport_WordDemo.WordDemo" %>

<%--<%@ Register TagPrefix="qsf" Namespace="Telerik.QuickStart" %>--%>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link href="styles.css" rel="stylesheet" /> 
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager runat="server" ID="RadScriptManager1" />
        <telerik:RadSkinManager ID="RadSkinManager1" runat="server" ShowChooser="true" />
        <script type="text/javascript" src="scripts.js"></script>
        <script type="text/javascript">
            TelerikDemo.rwUploadId = "<%=RadWindow1.ClientID%>";
            TelerikDemo.rnMessagesId = "<%=RadNotification1.ClientID%>";
            TelerikDemo.reId = "<%=RadEditor1.ClientID%>";
        </script>
        <div class="red-container no-bg">
            <telerik:RadEditor RenderMode="Lightweight" runat="server" ID="RadEditor1" ToolbarMode="RibbonBar" Width="80%" Height="800px"
                EnableTrackChanges="True" EnableComments="True" ToolsFile="word-like-tools.xml"
                ContentFilters="PdfExportFilter, DefaultFilters" SkinID="WordLikeExperience"
                OnClientLoad="TelerikDemo.toggleTrackChanges" EditModes="Design, Preview" SpellCheckSettings-AjaxUrl="/Telerik.Web.UI.SpellCheckHandler.axd" DialogHandlerUrl="~/Telerik.Web.UI.DialogHandler.axd" ExternalDialogsPath="~/RadEditorDialogs/" Language="zh-CN">
                <SpellCheckSettings AjaxUrl="/Telerik.Web.UI.SpellCheckHandler.axd" />
                <TrackChangesSettings CanAcceptTrackChanges="true" Author="John Smith" />
                <ExportSettings OpenInNewWindow="true" FileName="RadEditor-Export"></ExportSettings>
                <Content>
                </Content>

                <ImageManager
                    ViewPaths="~/Editor/images/UserDir/Marketing,~/Editor/images/UserDir/PublicRelations"
                    UploadPaths="~/Editor/images/UserDir/Marketing,~/Editor/images/UserDir/PublicRelations"
                    DeletePaths="~/Editor/images/UserDir/Marketing,~/Editor/images/UserDir/PublicRelations" />
            </telerik:RadEditor>
        </div>
        <telerik:RadWindow RenderMode="Lightweight" ID="RadWindow1" runat="server" Title="Upload File" Behaviors="Close, Move" VisibleStatusbar="false" AutoSize="true">
            <ContentTemplate>
                <div style="width: 50%">
                    Upload a DOCX, DOC or RTF file to load its content for editing. You can also use plain text (.txt) or HTML (.htm, .html) files and content.<br />
                    <telerik:RadAsyncUpload RenderMode="Lightweight" runat="server" ID="RadAsyncUpload1" AllowedFileExtensions="doc,docx,rtf,txt,htm,html,md" MaxFileInputsCount="1"
                        OnClientValidationFailed="TelerikDemo.OnClientValidationFailed" OnClientFileUploaded="TelerikDemo.uploadFile"
                        OnFileUploaded="RadAsyncUpload1_FileUploaded" Width="100%">
                    </telerik:RadAsyncUpload>
                </div>
            </ContentTemplate>
        </telerik:RadWindow>
        <telerik:RadNotification RenderMode="Lightweight" ID="RadNotification1" runat="server" Width="350px" Height="150px" Title="An error occured" TitleIcon="warning"
            ContentIcon="info" Position="Center" AutoCloseDelay="5000" EnableRoundedCorners="true" EnableShadow="true">
        </telerik:RadNotification>
        <a  id="Pointer" href="#">点击</a>
        <asp:Button runat="server" Text="点击" Width="217px" ID="sd" OnClick="sd_Click" />
    </form>
    <script src="../Scripts/jquery-1.10.2.min.js"></script>
    <script type="text/javascript">
        function ApplyBold() {
            var editor = $find("<%=RadEditor1.ClientID%>"); //return a reference to RadEditor
            var oDocument = editor.get_contentArea(); //get a reference to the editor's document
            alert(oDocument.innerHTML);
            //oDocument.execCommand("Bold", false, null);
        }
        $(function () {
            $("#Pointer").click(function () {
                ApplyBold();
            });
        })
    </script>
</body>

</html>
