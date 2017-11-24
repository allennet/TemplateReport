using ENLReport_WordDemo.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;

namespace ENLReport_WordDemo
{
    public partial class WordDemo : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsPostBack)
            {
                RadEditor1.Content = @"Contexts{#C_年龄_Age#}dfdsfdssfsdfs{#C_姓名_Name#}dkjfsfjsdkfjksdljffffffffffffffffffff<table style='width: 842px; height: 44px;'><colgroup><col /><col /><col /><col /></colgroup><tbody><tr><td>&nbsp;[#T_英语_Score_English#]</td><td>[#T_数学_Score_Math#]&nbsp;</td><td>&nbsp;[#T_语文_Score_Chinese#]</td><td>[#T_体育_Score_Sport#]&nbsp;</td></tr></tbody></table>fffffffffkskldf";
                RadEditor1.DisableFilter(EditorFilters.IndentHTMLContent);
            }

            //select the Home tab by default
            RadEditor1.RibbonBar.SelectedTabIndex = 1;
            //handle postbacks from the export commands
            try
            {
                string evtArg = Request["__EVENTARGUMENT"];
                switch (evtArg)
                {
                    case "SaveAsDocx":
                        RadEditor1.ExportToDocx();
                        break;
                    case "SaveAsRtf":
                        RadEditor1.ExportToRtf();
                        break;
                    case "SaveAsPDF":
                        RadEditor1.ExportToPdf();
                        break;
                    case "SaveAsMarkdown":
                        RadEditor1.ExportToMarkdown();
                        break;
                    default:
                        break;
                }
            }
            catch (Exception ex)
            {
                RadNotification1.Show("There was an error during the export operation. Try simplifying the content and removing images/lists.");
            }
        }

        protected void RadAsyncUpload1_FileUploaded(object sender, FileUploadedEventArgs e)
        {
            //the maximum allowed file inputs is one, so there should be no multiple files uploaded

            //see what is the uploaded file extension and attempt to import it accordingly
            try
            {
                string fileExt = e.File.GetExtension();
                switch (fileExt)
                {
                    case ".doc":
                    case ".docx":
                        RadEditor1.LoadDocxContent(e.File.InputStream);
                        break;
                    case ".rtf":
                        RadEditor1.LoadRtfContent(e.File.InputStream);
                        break;
                    case ".txt":
                    case ".html":
                    case ".htm":
                        using (StreamReader sr = new StreamReader(e.File.InputStream))
                        {
                            RadEditor1.Content = sr.ReadToEnd();
                        }
                        break;
                    case ".md":
                        using (StreamReader sr = new StreamReader(e.File.InputStream))
                        {
                            RadEditor1.Content = sr.ReadToEnd();
                            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "importMarkdownScript", "TelerikDemo.setMarkdownContent();", true);
                        }
                        break;
                    default:
                        RadNotification1.Show("The selected file is invalid. Please upload an MS Word document with an extension .doc, .docx or .rtf, or a .txt/.html file with HTML content!");
                        break;
                }
            }
            catch (Exception ex)
            {
                RadNotification1.Show("There was an error during the import operation. Try simplifying the content.");
            }
        }

        protected void sd_Click(object sender, EventArgs e)
        {
            string text = RadEditor1.Content;

            var list = "{\"Name\":\"李明\",\"Age\":\"17\",\"Score\":[{\"English\":\"80\",\"Math\":\"90\",\"Chinese\":\"65\",\"Sport\":\"90\"},{\"English\":\"70\",\"Math\":\"80\",\"Chinese\":\"78\",\"Sport\":\"99\"}]}";

            EditorHtmlConverter converter = new EditorHtmlConverter();
            string htmlStr = converter.ConvertHtml(list, text);
            RadEditor1.Content = htmlStr;
            //RadEditor1.ExportToDocx();
            //RadEditor editor = new RadEditor();
            //editor.Content = htmlStr;
            //editor.ExportToDocx();
            return;


        }
    }
}