#pragma checksum "C:\inetpub\wwwroot\LearnSite\teacher\coursetemplate.aspx.cs" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "CCCAE63135C9931FD2AF84BB8C3682AA"

#line 1 "C:\inetpub\wwwroot\LearnSite\teacher\coursetemplate.aspx.cs"
using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;

namespace LearnSite
{
    public partial class Teacher_coursetemplate : System.Web.UI.Page
    {
        private string XmlPath
        {
            get { return Server.MapPath("~/App_Data/coursetemplates.xml"); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                EnsureXml();
                BindTemplates();
            }
        }

        private void EnsureXml()
        {
            string appDataDir = Server.MapPath("~/App_Data/");
            if (!Directory.Exists(appDataDir))
                Directory.CreateDirectory(appDataDir);

            if (!File.Exists(XmlPath))
            {
                XmlDocument doc = new XmlDocument();
                doc.LoadXml("<?xml version=\"1.0\" encoding=\"utf-8\"?><Templates></Templates>");
                doc.Save(XmlPath);
                InitBuiltinTemplates();
            }
            else
            {
                // 检查是否有内置模板
                XmlDocument doc = new XmlDocument();
                doc.Load(XmlPath);
                if (doc.SelectNodes("//Template").Count == 0)
                {
                    InitBuiltinTemplates();
                }
            }
        }

        private void InitBuiltinTemplates()
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(XmlPath);

            // 新授课模板
            AddBuiltinTemplate(doc, "新授课学案模板",
                "<h2 style=\"text-align:center;color:#1e293b;\">【学案名称】</h2>" +
                "<hr/>" +
                "<h3>一、学习目标</h3>" +
                "<ol><li>知识与技能：</li><li>过程与方法：</li><li>情感态度与价值观：</li></ol>" +
                "<h3>二、学习重难点</h3>" +
                "<p><strong>重点：</strong></p><p><strong>难点：</strong></p>" +
                "<h3>三、课前预习</h3>" +
                "<p>请同学们预习以下内容：</p><ol><li></li></ol>" +
                "<h3>四、课堂探究</h3>" +
                "<h4>探究活动一：</h4><p></p>" +
                "<h4>探究活动二：</h4><p></p>" +
                "<h3>五、课堂练习</h3>" +
                "<ol><li></li></ol>" +
                "<h3>六、课堂小结</h3>" +
                "<p></p>" +
                "<h3>七、课后作业</h3>" +
                "<ol><li></li></ol>",
                "builtin");

            // 复习课模板
            AddBuiltinTemplate(doc, "复习课学案模板",
                "<h2 style=\"text-align:center;color:#1e293b;\">【复习课主题】</h2>" +
                "<hr/>" +
                "<h3>一、复习目标</h3>" +
                "<ol><li></li></ol>" +
                "<h3>二、知识梳理</h3>" +
                "<h4>知识点一：</h4><p></p>" +
                "<h4>知识点二：</h4><p></p>" +
                "<h4>知识点三：</h4><p></p>" +
                "<h3>三、典型例题</h3>" +
                "<h4>例题1：</h4><p></p><p><strong>解析：</strong></p>" +
                "<h4>例题2：</h4><p></p><p><strong>解析：</strong></p>" +
                "<h3>四、巩固练习</h3>" +
                "<ol><li></li></ol>" +
                "<h3>五、拓展提高</h3>" +
                "<ol><li></li></ol>" +
                "<h3>六、总结归纳</h3>" +
                "<p></p>",
                "builtin");

            // 实践课模板
            AddBuiltinTemplate(doc, "实践课学案模板",
                "<h2 style=\"text-align:center;color:#1e293b;\">【实践课主题】</h2>" +
                "<hr/>" +
                "<h3>一、实践目标</h3>" +
                "<ol><li></li></ol>" +
                "<h3>二、实践准备</h3>" +
                "<p><strong>工具与材料：</strong></p><ul><li></li></ul>" +
                "<p><strong>环境要求：</strong></p><p></p>" +
                "<h3>三、实践步骤</h3>" +
                "<h4>步骤一：</h4><p></p>" +
                "<h4>步骤二：</h4><p></p>" +
                "<h4>步骤三：</h4><p></p>" +
                "<h3>四、注意事项</h3>" +
                "<ul><li></li></ul>" +
                "<h3>五、成果展示</h3>" +
                "<p>请将你的实践成果记录在下方：</p><p></p>" +
                "<h3>六、实践反思</h3>" +
                "<p>通过本次实践，你有什么收获和体会？</p><p></p>",
                "builtin");

            // 信息科技课模板
            AddBuiltinTemplate(doc, "信息科技课学案模板",
                "<h2 style=\"text-align:center;color:#1e293b;\">【课题名称】</h2>" +
                "<hr/>" +
                "<h3>一、学习目标</h3>" +
                "<ol><li>了解：</li><li>掌握：</li><li>能够：</li></ol>" +
                "<h3>二、知识讲解</h3>" +
                "<h4>1. 基本概念</h4><p></p>" +
                "<h4>2. 操作方法</h4><p></p>" +
                "<h3>三、操作任务</h3>" +
                "<h4>任务一：基础操作</h4>" +
                "<p><strong>要求：</strong></p><ol><li></li></ol>" +
                "<h4>任务二：进阶操作</h4>" +
                "<p><strong>要求：</strong></p><ol><li></li></ol>" +
                "<h4>任务三：创意拓展（选做）</h4>" +
                "<p><strong>要求：</strong></p><ol><li></li></ol>" +
                "<h3>四、学习评价</h3>" +
                "<p>请对自己本节课的学习情况进行评价：</p>" +
                "<ul><li>基础操作完成情况：☆☆☆☆☆</li>" +
                "<li>进阶操作完成情况：☆☆☆☆☆</li>" +
                "<li>创意拓展完成情况：☆☆☆☆☆</li></ul>" +
                "<h3>五、课堂小结</h3><p></p>",
                "builtin");

            doc.Save(XmlPath);
        }

        private void AddBuiltinTemplate(XmlDocument doc, string name, string content, string type)
        {
            XmlElement tpl = doc.CreateElement("Template");
            tpl.SetAttribute("id", Guid.NewGuid().ToString("N"));
            tpl.SetAttribute("name", name);
            tpl.SetAttribute("type", type);
            tpl.SetAttribute("createTime", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
            tpl.SetAttribute("creator", "系统");

            XmlCDataSection cdata = doc.CreateCDataSection(content);
            tpl.AppendChild(cdata);

            doc.DocumentElement.AppendChild(tpl);
        }

        protected void BtnCreate_Click(object sender, EventArgs e)
        {
            string name = TxtName.Text.Trim();
            string content = TxtContent.Text.Trim();

            if (string.IsNullOrEmpty(name))
            {
                LabelMsg.Text = "请输入模板名称";
                return;
            }
            if (string.IsNullOrEmpty(content))
            {
                LabelMsg.Text = "请输入模板内容";
                return;
            }

            try
            {
                EnsureXml();
                XmlDocument doc = new XmlDocument();
                doc.Load(XmlPath);

                XmlElement tpl = doc.CreateElement("Template");
                tpl.SetAttribute("id", Guid.NewGuid().ToString("N"));
                tpl.SetAttribute("name", name);
                tpl.SetAttribute("type", "create");
                tpl.SetAttribute("createTime", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                tpl.SetAttribute("creator", GetTeacherName());

                XmlCDataSection cdata = doc.CreateCDataSection(content);
                tpl.AppendChild(cdata);

                doc.DocumentElement.AppendChild(tpl);
                doc.Save(XmlPath);

                LabelMsg.Text = "模板创建成功！";
                TxtName.Text = "";
                TxtContent.Text = "";
                BindTemplates();
            }
            catch (Exception ex)
            {
                LabelMsg.Text = "创建失败：" + Server.HtmlEncode(ex.Message);
            }
        }

        protected void BtnUpload_Click(object sender, EventArgs e)
        {
            if (!FUtemplate.HasFile)
            {
                LabelMsg.Text = "请选择要上传的文件";
                return;
            }

            string name = TxtUploadName.Text.Trim();
            if (string.IsNullOrEmpty(name))
            {
                LabelMsg.Text = "请输入模板名称";
                return;
            }

            string fileName = FUtemplate.FileName;
            string ext = Path.GetExtension(fileName).ToLower();

            if (ext != ".html" && ext != ".htm" && ext != ".txt" && ext != ".xls" && ext != ".xlsx")
            {
                LabelMsg.Text = "仅支持 HTML、HTM、TXT、XLS、XLSX 格式";
                return;
            }

            if (FUtemplate.PostedFile.ContentLength > 2 * 1024 * 1024)
            {
                LabelMsg.Text = "文件大小不能超过 2MB";
                return;
            }

            try
            {
                string content = "";

                // Excel 文件：从客户端 SheetJS 解析的 HiddenField 读取 HTML
                if (ext == ".xls" || ext == ".xlsx")
                {
                    content = HiddenExcelHtml.Value;
                    if (string.IsNullOrEmpty(content))
                    {
                        LabelMsg.Text = "Excel 解析失败，请确保浏览器已加载完成后再点击上传";
                        return;
                    }
                }
                else
                {
                    using (StreamReader reader = new StreamReader(FUtemplate.PostedFile.InputStream, System.Text.Encoding.UTF8))
                    {
                        content = reader.ReadToEnd();
                    }
                }

                // 如果是完整HTML，提取body内容
                if (content.IndexOf("<body", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    int bodyStart = content.IndexOf("<body", StringComparison.OrdinalIgnoreCase);
                    int bodyTagEnd = content.IndexOf('>', bodyStart);
                    int bodyEnd = content.IndexOf("</body>", StringComparison.OrdinalIgnoreCase);
                    if (bodyTagEnd >= 0 && bodyEnd > bodyTagEnd)
                    {
                        content = content.Substring(bodyTagEnd + 1, bodyEnd - bodyTagEnd - 1).Trim();
                    }
                }

                EnsureXml();
                XmlDocument doc = new XmlDocument();
                doc.Load(XmlPath);

                XmlElement tpl = doc.CreateElement("Template");
                tpl.SetAttribute("id", Guid.NewGuid().ToString("N"));
                tpl.SetAttribute("name", name);
                tpl.SetAttribute("type", "upload");
                tpl.SetAttribute("createTime", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                tpl.SetAttribute("creator", GetTeacherName());

                XmlCDataSection cdata = doc.CreateCDataSection(content);
                tpl.AppendChild(cdata);

                doc.DocumentElement.AppendChild(tpl);
                doc.Save(XmlPath);

                LabelMsg.Text = "模板上传成功！";
                TxtUploadName.Text = "";
                BindTemplates();
            }
            catch (Exception ex)
            {
                LabelMsg.Text = "上传失败：" + Server.HtmlEncode(ex.Message);
            }
        }

        protected void RptTemplates_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteTemplate")
            {
                string id = e.CommandArgument.ToString();
                try
                {
                    XmlDocument doc = new XmlDocument();
                    doc.Load(XmlPath);

                    XmlNode node = doc.SelectSingleNode("//Template[@id='" + id.Replace("'", "") + "']");
                    if (node != null)
                    {
                        node.ParentNode.RemoveChild(node);
                        doc.Save(XmlPath);
                        LabelMsg.Text = "模板已删除";
                    }
                }
                catch (Exception ex)
                {
                    LabelMsg.Text = "删除失败：" + Server.HtmlEncode(ex.Message);
                }
                BindTemplates();
            }
        }

        private void BindTemplates()
        {
            EnsureXml();
            XmlDocument doc = new XmlDocument();
            doc.Load(XmlPath);

            XmlNodeList nodes = doc.SelectNodes("//Template");

            List<TemplateItem> items = new List<TemplateItem>();
            if (nodes != null)
            {
                for (int i = 0; i < nodes.Count; i++)
                {
                    XmlNode node = nodes[i];
                    TemplateItem ti = new TemplateItem();
                    ti.Id = GetAttr(node, "id");
                    ti.Name = GetAttr(node, "name");
                    ti.Type = GetAttr(node, "type");
                    ti.CreateTime = GetAttr(node, "createTime");
                    ti.Creator = GetAttr(node, "creator");
                    ti.Content = node.InnerText;
                    ti.Index = i + 1;

                    // 类型显示
                    switch (ti.Type)
                    {
                        case "builtin": ti.TypeText = "内置"; ti.TypeClass = "tpl-badge-builtin"; break;
                        case "create": ti.TypeText = "创建"; ti.TypeClass = "tpl-badge-create"; break;
                        case "upload": ti.TypeText = "上传"; ti.TypeClass = "tpl-badge-upload"; break;
                        default: ti.TypeText = "其他"; ti.TypeClass = "tpl-badge-other"; break;
                    }

                    items.Add(ti);
                }
            }

            RptTemplates.DataSource = items;
            RptTemplates.DataBind();

            LabelCount.Text = items.Count.ToString();
        }

        private string GetAttr(XmlNode node, string name)
        {
            if (node.Attributes[name] != null)
                return node.Attributes[name].Value;
            return "";
        }

        private string GetTeacherName()
        {
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
                            if (val != null) return val.ToString();
                        }
                    }
                }
            }
            catch { }
            return "";
        }
    }

    public class TemplateItem
    {
        private string _id;
        private string _name;
        private string _type;
        private string _typeText;
        private string _typeClass;
        private string _createTime;
        private string _creator;
        private string _content;
        private int _index;

        public string Id { get { return _id; } set { _id = value; } }
        public string Name { get { return _name; } set { _name = value; } }
        public string Type { get { return _type; } set { _type = value; } }
        public string TypeText { get { return _typeText; } set { _typeText = value; } }
        public string TypeClass { get { return _typeClass; } set { _typeClass = value; } }
        public string CreateTime { get { return _createTime; } set { _createTime = value; } }
        public string Creator { get { return _creator; } set { _creator = value; } }
        public string Content { get { return _content; } set { _content = value; } }
        public int Index { get { return _index; } set { _index = value; } }

        /// <summary>
        /// Content 的 Base64 编码，用于安全嵌入 HTML 属性
        /// </summary>
        public string ContentBase64
        {
            get
            {
                if (string.IsNullOrEmpty(_content)) return "";
                return Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(_content));
            }
        }
    }
}


#line default
#line hidden
