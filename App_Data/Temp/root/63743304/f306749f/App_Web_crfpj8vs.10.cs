#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\teacher\knowledge.aspx.cs" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "B6F14AB9C884FFDEC7CCF1573D3A242C"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\teacher\knowledge.aspx.cs"
using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;

namespace LearnSite
{
    public partial class Teacher_knowledge : System.Web.UI.Page
    {

        private string XmlPath
        {
            get { return Server.MapPath("~/App_Data/knowledge.xml"); }
        }

        private string UploadDir
        {
            get { return Server.MapPath("~/knowledge/"); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                EnsureDirectories();
                BindFiles();
            }
        }

        private void EnsureDirectories()
        {
            string appDataDir = Server.MapPath("~/App_Data/");
            if (!Directory.Exists(appDataDir))
                Directory.CreateDirectory(appDataDir);
            if (!Directory.Exists(UploadDir))
                Directory.CreateDirectory(UploadDir);
            if (!File.Exists(XmlPath))
            {
                XmlDocument doc = new XmlDocument();
                doc.LoadXml("<?xml version=\"1.0\" encoding=\"utf-8\"?><KnowledgeBase></KnowledgeBase>");
                doc.Save(XmlPath);
            }
        }

        protected void Btnupload_Click(object sender, EventArgs e)
        {
            if (!FUknowledge.HasFile)
            {
                Labelmsg.Text = "请选择要上传的文件";
                return;
            }

            string title = Texttitle.Text.Trim();
            if (string.IsNullOrEmpty(title))
            {
                Labelmsg.Text = "请输入资料名称";
                return;
            }

            string category = DDLcategory.SelectedValue;
            string description = TxtDescription.Text.Trim(); // 获取说明文字

            // 允许的文件类型
            string[] allowedExts = {
                ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".xls", ".xlsx",
                ".txt", ".zip", ".rar", ".7z",
                ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp",
                ".mp4", ".mp3", ".wav", ".flv",
                ".html", ".htm", ".mht", ".swf", ".sb3", ".py"
            };

            string fileName = FUknowledge.FileName;
            string ext = Path.GetExtension(fileName).ToLower();

            if (Array.IndexOf(allowedExts, ext) == -1)
            {
                Labelmsg.Text = "不支持的文件格式：" + ext;
                return;
            }

            // 限制文件大小为 100MB
            if (FUknowledge.PostedFile.ContentLength > 100 * 1024 * 1024)
            {
                Labelmsg.Text = "文件大小不能超过 100MB";
                return;
            }

            try
            {
                EnsureDirectories();

                // 生成唯一文件名
                string savedName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Guid.NewGuid().ToString("N").Substring(0, 8) + ext;
                string savePath = Path.Combine(UploadDir, savedName);
                FUknowledge.SaveAs(savePath);

                // 写入 XML
                XmlDocument doc = new XmlDocument();
                doc.Load(XmlPath);

                XmlElement item = doc.CreateElement("Item");
                item.SetAttribute("id", Guid.NewGuid().ToString("N"));
                item.SetAttribute("title", title);
                item.SetAttribute("category", category);
                item.SetAttribute("description", description); // 保存说明文字
                item.SetAttribute("originalName", fileName);
                item.SetAttribute("savedName", savedName);
                item.SetAttribute("ext", ext);
                item.SetAttribute("size", FUknowledge.PostedFile.ContentLength.ToString());
                item.SetAttribute("uploadTime", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));

                // 获取教师名称
                string teacherName = "";
                try
                {
                    HttpCookie tc = Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
                    if (tc != null && !string.IsNullOrEmpty(tc.Value))
                    {
                        Type cookType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.TeaCook");
                        if (cookType != null)
                        {
                            object model = Activator.CreateInstance(cookType);
                            System.Reflection.MethodInfo toModel = cookType.GetMethod("ToModel",
                                System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                            if (toModel != null) toModel.Invoke(model, new object[] { tc.Value });
                            System.Reflection.PropertyInfo prop = cookType.GetProperty("Hname");
                            if (prop != null)
                            {
                                object val = prop.GetValue(model, null);
                                if (val != null) teacherName = val.ToString();
                            }
                        }
                    }
                }
                catch { }
                item.SetAttribute("uploader", teacherName);

                doc.DocumentElement.AppendChild(item);
                doc.Save(XmlPath);

                Labelmsg.Text = "上传成功！";
                Texttitle.Text = "";
                TxtDescription.Text = ""; // 清空说明文字
                BindFiles();
            }
            catch (Exception ex)
            {
                Labelmsg.Text = "上传失败：" + Server.HtmlEncode(ex.Message);
            }
        }

        protected void DDLfilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindFiles();
        }

        private void BindFiles()
        {
            EnsureDirectories();

            XmlDocument doc = new XmlDocument();
            doc.Load(XmlPath);

            string filter = DDLfilter.SelectedValue;

            XmlNodeList nodes;
            if (string.IsNullOrEmpty(filter) || filter == "全部")
                nodes = doc.SelectNodes("//Item");
            else
                nodes = doc.SelectNodes("//Item[@category='" + filter.Replace("'", "") + "']");

            List<KnowledgeItem> items = new List<KnowledgeItem>();
            if (nodes != null)
            {
                for (int i = nodes.Count - 1; i >= 0; i--)
                {
                    XmlNode node = nodes[i];
                    KnowledgeItem ki = new KnowledgeItem();
                    ki.Id = GetAttr(node, "id");
                    ki.Title = GetAttr(node, "title");
                    ki.Category = GetAttr(node, "category");
                    ki.Description = GetAttr(node, "description"); // 读取说明文字
                    ki.OriginalName = GetAttr(node, "originalName");
                    ki.SavedName = GetAttr(node, "savedName");
                    ki.Ext = GetAttr(node, "ext");
                    ki.UploadTime = GetAttr(node, "uploadTime");
                    ki.Uploader = GetAttr(node, "uploader");

                    long sz = 0;
                    long.TryParse(GetAttr(node, "size"), out sz);
                    ki.Size = sz;
                    ki.SizeText = FormatSize(sz);

                    ki.DownloadUrl = ResolveUrl("~/knowledge/" + ki.SavedName);
                    ki.Index = items.Count + 1;
                    items.Add(ki);
                }
            }

            RptFiles.DataSource = items;
            RptFiles.DataBind();

            if (LabelCount != null)
                LabelCount.Text = items.Count.ToString();
        }

        protected void RptFiles_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteFile")
            {
                string id = e.CommandArgument.ToString();
                try
                {
                    XmlDocument doc = new XmlDocument();
                    doc.Load(XmlPath);

                    XmlNode node = doc.SelectSingleNode("//Item[@id='" + id.Replace("'", "") + "']");
                    if (node != null)
                    {
                        string savedName = GetAttr(node, "savedName");
                        string filePath = Path.Combine(UploadDir, savedName);
                        if (File.Exists(filePath))
                        {
                            try { File.Delete(filePath); } catch { }
                        }
                        node.ParentNode.RemoveChild(node);
                        doc.Save(XmlPath);
                        Labelmsg.Text = "已删除";
                    }
                }
                catch (Exception ex)
                {
                    Labelmsg.Text = "删除失败：" + Server.HtmlEncode(ex.Message);
                }
                BindFiles();
            }
        }

        private string GetAttr(XmlNode node, string name)
        {
            if (node.Attributes[name] != null)
                return node.Attributes[name].Value;
            return "";
        }

        private string FormatSize(long bytes)
        {
            if (bytes < 1024) return bytes + " B";
            if (bytes < 1024 * 1024) return (bytes / 1024.0).ToString("F1") + " KB";
            if (bytes < 1024 * 1024 * 1024) return (bytes / (1024.0 * 1024)).ToString("F1") + " MB";
            return (bytes / (1024.0 * 1024 * 1024)).ToString("F2") + " GB";
        }

        protected string GetCategoryBadgeClass(string category)
        {
            switch (category)
            {
                case "电子课本": return "kb-badge-book";
                case "教案": return "kb-badge-plan";
                case "课件": return "kb-badge-slide";
                case "试卷": return "kb-badge-exam";
                case "素材": return "kb-badge-media";
                default: return "kb-badge-other";
            }
        }

        protected string GetFileIcon(string ext)
        {
            ext = (ext ?? "").ToLower();
            if (ext == ".pdf")
                return "<svg viewBox='0 0 24 24'><path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/><polyline points='14 2 14 8 20 8'/><path d='M10 12h4'/><path d='M10 16h4'/></svg>";
            if (ext == ".doc" || ext == ".docx")
                return "<svg viewBox='0 0 24 24'><path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/><polyline points='14 2 14 8 20 8'/><line x1='16' y1='13' x2='8' y2='13'/><line x1='16' y1='17' x2='8' y2='17'/><polyline points='10 9 9 9 8 9'/></svg>";
            if (ext == ".ppt" || ext == ".pptx")
                return "<svg viewBox='0 0 24 24'><rect x='2' y='3' width='20' height='14' rx='2' ry='2'/><line x1='8' y1='21' x2='16' y2='21'/><line x1='12' y1='17' x2='12' y2='21'/></svg>";
            if (ext == ".xls" || ext == ".xlsx")
                return "<svg viewBox='0 0 24 24'><rect x='3' y='3' width='18' height='18' rx='2' ry='2'/><line x1='3' y1='9' x2='21' y2='9'/><line x1='3' y1='15' x2='21' y2='15'/><line x1='9' y1='3' x2='9' y2='21'/><line x1='15' y1='3' x2='15' y2='21'/></svg>";
            if (ext == ".mp4" || ext == ".flv")
                return "<svg viewBox='0 0 24 24'><polygon points='23 7 16 12 23 17 23 7'/><rect x='1' y='5' width='15' height='14' rx='2' ry='2'/></svg>";
            if (ext == ".mp3" || ext == ".wav")
                return "<svg viewBox='0 0 24 24'><path d='M9 18V5l12-2v13'/><circle cx='6' cy='18' r='3'/><circle cx='18' cy='16' r='3'/></svg>";
            if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".gif" || ext == ".bmp" || ext == ".webp")
                return "<svg viewBox='0 0 24 24'><rect x='3' y='3' width='18' height='18' rx='2' ry='2'/><circle cx='8.5' cy='8.5' r='1.5'/><polyline points='21 15 16 10 5 21'/></svg>";
            if (ext == ".zip" || ext == ".rar" || ext == ".7z")
                return "<svg viewBox='0 0 24 24'><path d='M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z'/></svg>";
            // 默认文件图标
            return "<svg viewBox='0 0 24 24'><path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/><polyline points='14 2 14 8 20 8'/></svg>";
        }
    }

    public class KnowledgeItem
    {
        private string _id;
        private string _title;
        private string _category;
        private string _description;
        private string _originalName;
        private string _savedName;
        private string _ext;
        private long _size;
        private string _sizeText;
        private string _uploadTime;
        private string _uploader;
        private string _downloadUrl;
        private int _index;

        public string Id { get { return _id; } set { _id = value; } }
        public string Title { get { return _title; } set { _title = value; } }
        public string Category { get { return _category; } set { _category = value; } }
        public string Description { get { return _description; } set { _description = value; } }
        public string OriginalName { get { return _originalName; } set { _originalName = value; } }
        public string SavedName { get { return _savedName; } set { _savedName = value; } }
        public string Ext { get { return _ext; } set { _ext = value; } }
        public long Size { get { return _size; } set { _size = value; } }
        public string SizeText { get { return _sizeText; } set { _sizeText = value; } }
        public string UploadTime { get { return _uploadTime; } set { _uploadTime = value; } }
        public string Uploader { get { return _uploader; } set { _uploader = value; } }
        public string DownloadUrl { get { return _downloadUrl; } set { _downloadUrl = value; } }
        public int Index { get { return _index; } set { _index = value; } }
    }
}


#line default
#line hidden
