<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" autoeventwireup="true" inherits="Teacher_helper, LearnSite" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>

<script runat="server">
    protected string GetServerHelpHtml()
    {
        try
        {
            string xmlPath = Server.MapPath("~/App_Data/helpcenter.xml");
            if (File.Exists(xmlPath))
            {
                XmlDocument doc = new XmlDocument();
                doc.Load(xmlPath);
                XmlNode node = doc.SelectSingleNode("//helpHtml");
                if (node != null) return node.InnerText;
            }
        }
        catch { }
        return "";
    }

    protected string GetServerLinksHtml()
    {
        try
        {
            string xmlPath = Server.MapPath("~/App_Data/helpcenter.xml");
            if (File.Exists(xmlPath))
            {
                XmlDocument doc = new XmlDocument();
                doc.Load(xmlPath);
                XmlNode node = doc.SelectSingleNode("//linksHtml");
                if (node != null) return node.InnerText;
            }
        }
        catch { }
        return "";
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .hp-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .hp-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .hp-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .hp-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .hp-title .hp-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#6366f1,#a78bfa);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .hp-title .hp-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .hp-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }

    .hp-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .hp-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .hp-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .hp-card-title svg { width: 18px; height: 18px; stroke: #6366f1; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .hp-card-desc { font-size: 12px; color: #94a3b8; margin-left: 26px; }
    .hp-card-body { padding: 20px 24px; }

    .hp-content { font-size: 14px; color: #334155; line-height: 2; }
    .hp-content a { color: #6366f1; text-decoration: none; font-weight: 500; }
    .hp-content a:hover { text-decoration: underline; }

    /* 工具链接网格 */
    .hp-tools {
        display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px;
    }
    .hp-tool {
        display: flex; align-items: center; gap: 10px; padding: 14px 16px;
        border: 1px solid #f1f5f9; border-radius: 10px; background: #fafbfc;
        text-decoration: none; transition: all .18s; cursor: pointer;
    }
    .hp-tool:hover { border-color: #c7d2fe; background: #eef2ff; box-shadow: 0 2px 8px rgba(99,102,241,.08); }
    .hp-tool img { width: 24px; height: 24px; border-radius: 4px; flex-shrink: 0; }
    .hp-tool-name { font-size: 13px; font-weight: 600; color: #334155; }

</style>

<div class="hp-page">
    <!-- 页面标题 -->
    <div class="hp-header">
        <div class="hp-title-wrap">
            <div class="hp-title">
                <span class="hp-icon">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                </span>
                帮助与资源
            </div>
        <div class="hp-subtitle">查看平台帮助信息、友情链接和内置工具入口</div>
        </div>
    </div>

    <!-- 帮助说明卡片 -->
    <div class="hp-card" id="hpCardHelp">
        <div class="hp-card-header">
            <div>
                <div class="hp-card-title">
                    <svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                    帮助说明
                </div>
                <div class="hp-card-desc">平台使用帮助与技术支持信息</div>
            </div>
        </div>
        <div class="hp-card-body hp-content" id="hpBodyHelp">
            <% string srvHelp = GetServerHelpHtml(); %>
            <% if (!string.IsNullOrEmpty(srvHelp)) { %>
            <%= srvHelp %>
            <% } else { %>
            1、安装和使用请先仔细阅读说明必读目录中的相关资料<br />
            2、LearnSite学习平台 QQ群5847120<br />
            3、Learnsite帮助网站：<a href="http://www.openlearnsite.com" target="_blank">www.openlearnsite.com</a>（上海 倪老师）
            <% } %>
        </div>
    </div>

    <!-- 友情链接卡片 -->
    <div class="hp-card" id="hpCardLinks">
        <div class="hp-card-header">
            <div>
                <div class="hp-card-title">
                    <svg viewBox="0 0 24 24"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>
                    友情链接
                </div>
                <div class="hp-card-desc">相关教育平台与社区资源</div>
            </div>
        </div>
        <div class="hp-card-body hp-content" id="hpBodyLinks">
            <% string srvLinks = GetServerLinksHtml(); %>
            <% if (!string.IsNullOrEmpty(srvLinks)) { %>
            <%= srvLinks %>
            <% } else { %>
            ITtools3信息技术教学辅助平台（温岭 陈老师）：QQ群号 176809529
            <% } %>
        </div>
    </div>

    <!-- 内置工具卡片 -->
    <div class="hp-card">
        <div class="hp-card-header">
            <div>
                <div class="hp-card-title">
                    <svg viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg>
                    内置工具
                </div>
                <div class="hp-card-desc">平台集成的各类教学工具快捷入口</div>
            </div>
        </div>
        <div class="hp-card-body">
            <div class="hp-tools">
                <a href="../scratch/index.html" target="_blank" class="hp-tool">
                    <img src="../images/program.png" alt="" />
                    <span class="hp-tool-name">积木编程</span>
                </a>
                <a href="../mxgraph/index.html" target="_blank" class="hp-tool">
                    <img src="../images/mxgraph.png" alt="" />
                    <span class="hp-tool-name">流程图</span>
                </a>
                <a href="../blockly/index.html" target="_blank" class="hp-tool">
                    <img src="../images/vote.png" alt="" />
                    <span class="hp-tool-name">Blockly游戏</span>
                </a>
                <a href="../pixelartmaker/index.html" target="_blank" class="hp-tool">
                    <img src="../images/pixel.png" alt="" />
                    <span class="hp-tool-name">像素画</span>
                </a>
                <a href="../python/index.aspx" target="_blank" class="hp-tool">
                    <img src="../images/python.png" alt="" />
                    <span class="hp-tool-name">Python绘图编程</span>
                </a>
                <a href="../plugins/excalidraw/index.html" target="_blank" class="hp-tool">
                    <img src="../images/excalidraw.png" alt="" />
                    <span class="hp-tool-name">手绘画布</span>
                </a>
                <a href="../luckysheetbottle/index.html" target="_blank" class="hp-tool">
                    <img src="../images/excel.png" alt="" />
                    <span class="hp-tool-name">在线协作表格</span>
                </a>
                <a href="../plugins/km/test.html" target="_blank" class="hp-tool">
                    <img src="../images/kitymind.png" alt="" />
                    <span class="hp-tool-name">在线思维导图</span>
                </a>
            </div>
        </div>
    </div>
</div>

</asp:Content>

