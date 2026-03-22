<%@ page title="" language="C#" masterpagefile="~/student/Scm.master" autoeventwireup="true" stylesheettheme="Student" inherits="Student_program, LearnSite" %>
<%@ import namespace="System.Data.SqlClient" %>
<%@ import namespace="System.Configuration" %>

<script runat="server">
    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCourseBanner();
        }
    }
    
    private void LoadCourseBanner()
    {
        try
        {
            string lid = Request.QueryString["lid"];
            if (string.IsNullOrEmpty(lid))
            {
                return;
            }
            
            string connectionString = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                
                // 通过 Listmenu 获取课程ID和背景图
                string sql = @"
                    SELECT L.Lcid, C.Cbanner
                    FROM Listmenu L
                    INNER JOIN Courses C ON L.Lcid = C.Cid
                    WHERE L.Lid = @Lid AND (C.Cdelete = 0 OR C.Cdelete IS NULL)
                ";
                
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", lid);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string bannerPath = reader["Cbanner"] != DBNull.Value ? reader["Cbanner"].ToString().Trim() : "";
                            if (!string.IsNullOrEmpty(bannerPath))
                            {
                                // 解析为可访问的URL
                                string resolvedUrl = bannerPath;
                                if (!resolvedUrl.StartsWith("http://") && !resolvedUrl.StartsWith("https://") && !resolvedUrl.StartsWith("/"))
                                {
                                    if (resolvedUrl.StartsWith("~/"))
                                        resolvedUrl = ResolveUrl(resolvedUrl);
                                    else
                                        resolvedUrl = ResolveUrl("~/" + resolvedUrl);
                                }
                                
                                // 方法1: 注入CSS到<head>中，用!important确保覆盖默认背景
                                ApplyBannerCSS(resolvedUrl);
                                
                                // 方法2: 通过反射设置母版页的 Cbanner
                                SetMasterBanner(resolvedUrl);
                                
                                // 方法3: 注册jQuery脚本，确保在master脚本之后执行
                                string safeUrl = resolvedUrl.Replace("'", "\\'")
                                                            .Replace("\"", "&quot;");
                                string jsCode = 
                                    "$(document).ready(function(){" +
                                    "$('.banner').css({" +
                                    "'background-image':'url(" + safeUrl + ")'," +
                                    "'background-size':'cover'," +
                                    "'background-position':'center center'," +
                                    "'background-repeat':'no-repeat'" +
                                    "});" +
                                    "});";
                                ClientScript.RegisterStartupScript(this.GetType(), "CourseBannerJS", jsCode, true);
                                
                                // 存储已解析的URL供内联JS备用
                                HdBannerPath.Value = resolvedUrl;
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadCourseBanner Error: " + ex.ToString());
        }
    }
    
    private void ApplyBannerCSS(string resolvedUrl)
    {
        try
        {
            string safeUrl = resolvedUrl.Replace("'", "\\'")
                                        .Replace("\"", "&quot;");
            string cssText = ".banner { background-image: url('" + safeUrl + "') !important; " +
                "background-size: cover !important; " +
                "background-position: center center !important; " +
                "background-repeat: no-repeat !important; }";
            
            System.Web.UI.HtmlControls.HtmlGenericControl style = 
                new System.Web.UI.HtmlControls.HtmlGenericControl("style");
            style.Attributes["type"] = "text/css";
            style.InnerHtml = cssText;
            Page.Header.Controls.Add(style);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("ApplyBannerCSS Error: " + ex.ToString());
        }
    }
    
    private void SetMasterBanner(string resolvedUrl)
    {
        try
        {
            if (this.Master == null) return;
            
            System.Type masterType = this.Master.GetType();
            
            // 先尝试字段
            System.Reflection.FieldInfo field = masterType.GetField("Cbanner",
                System.Reflection.BindingFlags.Public |
                System.Reflection.BindingFlags.NonPublic |
                System.Reflection.BindingFlags.Instance);
            if (field != null)
            {
                field.SetValue(this.Master, resolvedUrl);
                return;
            }
            
            // 再尝试属性
            System.Reflection.PropertyInfo prop = masterType.GetProperty("Cbanner",
                System.Reflection.BindingFlags.Public |
                System.Reflection.BindingFlags.NonPublic |
                System.Reflection.BindingFlags.Instance);
            if (prop != null && prop.CanWrite)
            {
                prop.SetValue(this.Master, resolvedUrl, null);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("SetMasterBanner Error: " + ex.ToString());
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" Runat="Server">
<style>
    /* ===== 现代清新主题 ===== */
    /* 设计理念：卡片式布局、柔和配色、精致细节 */

    * { box-sizing: border-box; margin: 0; padding: 0; }

    #showcontent, #showcontent * {
        box-sizing: border-box;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif;
    }

    /* ===== 页面入场动画 ===== */
    @keyframes pgSlideUp {
        from { opacity: 0; transform: translateY(16px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* ===== 课程标题横幅 ===== */
    .course-banner-section {
        width: 100%;
        margin-bottom: 0;
        position: relative;
        overflow: hidden;
        background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a78bfa 100%);
        box-shadow: none;
    }
    .course-banner-section::before {
        content: '';
        position: absolute;
        top: -40px; right: -40px;
        width: 160px; height: 160px;
        border-radius: 50%;
        background: rgba(255,255,255,.07);
    }
    .course-banner-section::after {
        content: '';
        position: absolute;
        bottom: -50px; left: 60px;
        width: 200px; height: 200px;
        border-radius: 50%;
        background: rgba(255,255,255,.04);
    }
    .course-banner-content {
        position: relative;
        z-index: 1;
        padding: 28px 36px;
        display: flex;
        align-items: center;
        gap: 16px;
        max-width: 1400px;
        margin: 0 auto;
    }
    .course-banner-img {
        display: none;
        width: 72px; height: 50px;
        object-fit: cover;
        border-radius: 8px;
        border: 2px solid rgba(255,255,255,.25);
        flex-shrink: 0;
    }
    .course-banner-img.visible { display: block; }
    .course-banner-title {
        font-size: 20px;
        font-weight: 700;
        color: #ffffff;
        line-height: 1.4;
        flex: 1;
        text-shadow: 0 1px 4px rgba(0,0,0,.1);
    }
    .course-banner-title label {
        color: #ffffff !important;
        font-size: 20px !important;
        font-weight: 700 !important;
        line-height: 1.4 !important;
    }

    /* ===== 主容器 ===== */
    body div#showcontent,
    div#showcontent,
    #showcontent {
        max-width: 1400px !important;
        margin: 0 auto !important;
        padding: 28px 32px !important;
        background: transparent !important;
        min-height: auto !important;
        min-width: 0 !important;
        display: flex !important;
        flex-direction: row !important;
        align-items: flex-start !important;
        gap: 28px !important;
        width: 100% !important;
        position: relative !important;
        animation: pgSlideUp .5s ease !important;
        font-size: 14px !important;
    }

    body div#showcontent .left,
    body div#showcontent .right,
    #showcontent .left,
    #showcontent .right {
        min-width: 0 !important;
        position: relative !important;
        float: none !important;
    }

    /* ===== 左侧内容区 ===== */
    body div#showcontent .left,
    #showcontent .left {
        flex: 1 1 0% !important;
        width: 0 !important;
        background: #ffffff;
        border-radius: 16px;
        padding: 0;
        border: 1px solid #e5e7eb;
        box-shadow: none;
        overflow: hidden;
        text-align: left !important;
    }

    #showcontent .left .missiontitle { display: none; }

    /* 任务标题 */
    #showcontent .missiontitle {
        margin: 0;
        padding: 20px 32px !important;
        background: linear-gradient(180deg, #fafbfc 0%, #f5f6f8 100%) !important;
        color: #1e293b !important;
        border-radius: 0 !important;
        border-bottom: 1px solid #e5e7eb;
    }
    #showcontent .missiontitle label,
    #showcontent .missiontitle * {
        color: #1e293b !important;
        font-size: 17px !important;
        font-weight: 600 !important;
    }

    /* ===== 课程内容区 ===== */
    #showcontent .coursecontent {
        background: #ffffff;
        padding: 40px 36px !important;
        margin: 0;
        line-height: 1.85;
        font-size: 15px;
        color: #374151;
        border: none;
        min-height: 400px;
    }
    #showcontent .coursecontent a {
        color: #6366f1;
        text-decoration: none;
        border-bottom: 1px solid rgba(99,102,241,.25);
        transition: all .2s ease;
        font-weight: 500;
    }
    #showcontent .coursecontent a:hover {
        color: #4f46e5;
        border-bottom-color: #4f46e5;
    }
    #showcontent .coursecontent code,
    #showcontent .coursecontent pre {
        background: #f8fafc;
        border-radius: 8px;
        padding: 14px 18px;
        border: 1px solid #e5e7eb;
        color: #334155;
        font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
        font-size: 13.5px;
    }
    #showcontent .coursecontent p {
        margin: 0 0 16px 0;
        color: #374151;
    }
    #showcontent .coursecontent p:last-child { margin-bottom: 0; }
    #showcontent .coursecontent img {
        max-width: 100%;
        height: auto;
        border-radius: 10px;
        margin: 24px 0;
        display: block;
        border: 1px solid #e5e7eb;
        transition: transform .3s ease, box-shadow .3s ease;
    }
    #showcontent .coursecontent img:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 24px rgba(0,0,0,.1);
    }
    #showcontent .coursecontent table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        margin: 24px 0;
        border-radius: 10px;
        overflow: hidden;
        border: 1px solid #e5e7eb;
    }
    #showcontent .coursecontent table td,
    #showcontent .coursecontent table th {
        padding: 12px 18px;
        text-align: left;
    }
    #showcontent .coursecontent table th {
        background: #f8fafc;
        color: #1e293b;
        font-weight: 600;
        font-size: 13px;
        border-bottom: 2px solid #e5e7eb;
    }
    #showcontent .coursecontent table td {
        background: #ffffff;
        color: #374151;
        border-top: 1px solid #f1f5f9;
    }
    #showcontent .coursecontent table tr:nth-child(even) td {
        background: #fafbfc;
    }
    #showcontent .coursecontent table tr:hover td {
        background: #eef2ff;
        transition: background .2s ease;
    }
    /* 内容排版增强 */
    #showcontent .coursecontent h1,
    #showcontent .coursecontent h2,
    #showcontent .coursecontent h3,
    #showcontent .coursecontent h4 {
        color: #1e293b;
        font-weight: 700;
        margin-top: 28px;
        margin-bottom: 14px;
        line-height: 1.35;
    }
    #showcontent .coursecontent ul,
    #showcontent .coursecontent ol {
        margin: 12px 0;
        padding-left: 28px;
    }
    #showcontent .coursecontent li {
        margin-bottom: 6px;
        line-height: 1.8;
    }

    /* ===== 右侧操作区 ===== */
    body div#showcontent .right,
    #showcontent .right {
        width: 300px !important;
        min-width: 300px !important;
        max-width: 300px !important;
        flex: 0 0 300px !important;
        background: #ffffff;
        border-radius: 16px;
        padding: 0 !important;
        border: 1px solid #e5e7eb;
        box-shadow: none;
        display: flex !important;
        flex-direction: column !important;
        position: relative;
        overflow: hidden !important;
        text-align: center !important;
    }

    /* 导航按钮区 */
    #showcontent .right .nav-buttons {
        display: flex !important;
        flex-direction: row !important;
        align-items: stretch !important;
        justify-content: center !important;
        padding: 16px 18px !important;
        gap: 10px !important;
        flex-wrap: nowrap;
        border-bottom: 1px solid #f1f5f9;
        background: linear-gradient(180deg, #fafbfc 0%, #ffffff 100%);
        border-radius: 16px 16px 0 0;
    }

    /* 导航按钮统一样式 */
    #showcontent .right .nav-buttons .sharedisk,
    #showcontent .right .nav-buttons a,
    #showcontent .right .nav-buttons a[href*="VoteLink"],
    #showcontent .right .nav-buttons a.txtszcenter {
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        border-radius: 8px !important;
        font-size: 13px !important;
        font-weight: 500 !important;
        font-family: -apple-system, 'Microsoft YaHei', sans-serif !important;
        text-align: center !important;
        text-decoration: none !important;
        cursor: pointer !important;
        background-image: none !important;
        line-height: 36px !important;
        padding: 0 !important;
        height: 36px !important;
        flex: 1 1 0% !important;
        width: 0 !important;
        border: 1px solid #e5e7eb !important;
        background: #ffffff !important;
        color: #374151 !important;
        transition: all .2s ease !important;
    }
    #showcontent .right .nav-buttons .sharedisk {
        background: #ffffff !important;
        color: #374151 !important;
        border-color: #e5e7eb !important;
        box-shadow: none !important;
    }
    #showcontent .right .nav-buttons .sharedisk:hover,
    #showcontent .right .nav-buttons a:hover,
    #showcontent .right .nav-buttons a[href*="VoteLink"]:hover,
    #showcontent .right .nav-buttons a.txtszcenter:hover {
        background: #f8fafc !important;
        border-color: #c7d2fe !important;
        color: #4f46e5 !important;
    }

    /* 作品展示区 */
    #showcontent .right > div:not(.nav-buttons) {
        background: #ffffff;
        padding: 24px 20px !important;
        margin: 0;
        border: none;
        width: 100% !important;
        min-width: 0;
        display: flex !important;
        flex-direction: column !important;
        align-items: center;
        text-align: center;
        gap: 8px;
    }

    /* 缩略图容器装饰 */
    .thumb-wrapper {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
        width: 160px;
        height: 160px;
        margin: 8px auto 12px;
        border-radius: 18px;
        background: linear-gradient(145deg, #f0f1ff 0%, #e8eaff 40%, #f5f3ff 100%);
        box-shadow: none;
        overflow: hidden;
        transition: transform .35s cubic-bezier(.4,0,.2,1), box-shadow .35s cubic-bezier(.4,0,.2,1);
    }
    .thumb-wrapper::before {
        content: '';
        position: absolute;
        top: -30px; right: -30px;
        width: 80px; height: 80px;
        border-radius: 50%;
        background: rgba(139,92,246,.06);
        pointer-events: none;
    }
    .thumb-wrapper::after {
        content: '';
        position: absolute;
        bottom: -20px; left: -20px;
        width: 60px; height: 60px;
        border-radius: 50%;
        background: rgba(99,102,241,.05);
        pointer-events: none;
    }
    .thumb-wrapper:hover {
        transform: translateY(-3px);
        box-shadow: none;
    }

    /* 缩略图 */
    #showcontent .right img[id$="Thumbnail"] {
        width: auto !important;
        max-width: 130px !important;
        max-height: 130px !important;
        height: auto !important;
        border-radius: 14px;
        margin: 0 !important;
        display: block;
        position: relative;
        z-index: 1;
        border: 2px solid rgba(255,255,255,.7);
        box-shadow: none;
        transition: transform .35s cubic-bezier(.4,0,.2,1), box-shadow .35s cubic-bezier(.4,0,.2,1);
        object-fit: contain;
        background: #ffffff;
    }
    .thumb-wrapper:hover img[id$="Thumbnail"] {
        transform: scale(1.06);
        box-shadow: none;
    }
    /* 无图片时的占位图标 */
    .thumb-placeholder {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 8px;
        color: #a5b4fc;
        font-size: 12px;
        font-weight: 500;
        z-index: 1;
        position: relative;
    }
    .thumb-placeholder svg {
        width: 40px; height: 40px;
        opacity: .5;
    }

    /* 作品标题 */
    #showcontent .right span[id$="Wtitle"],
    #showcontent .right label[id$="Wtitle"] {
        display: block !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        color: #1e293b !important;
        margin: 4px 0 10px 0 !important;
        padding: 4px 12px !important;
        background: linear-gradient(135deg, #f0f1ff 0%, #ede9fe 100%) !important;
        text-align: center !important;
        border: none !important;
        border-radius: 8px !important;
        width: auto !important;
        max-width: 100% !important;
        line-height: 1.5 !important;
        letter-spacing: .2px !important;
    }

    /* ===== 主按钮：开始创作/继续创作 ===== */
    #showcontent .right input[type="submit"][id$="BtnScratch"],
    #showcontent .right button[id$="BtnScratch"],
    #showcontent .right input[type="button"][id$="BtnScratch"] {
        width: 100% !important;
        max-width: 220px !important;
        padding: 10px 24px !important;
        background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%) !important;
        border: none !important;
        border-radius: 10px !important;
        color: #ffffff !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        font-family: -apple-system, 'Microsoft YaHei', sans-serif !important;
        cursor: pointer !important;
        transition: all .25s ease !important;
        margin: 4px auto 8px !important;
        line-height: 1.4 !important;
        display: block !important;
        height: auto !important;
        box-shadow: 0 3px 12px rgba(99,102,241,.3) !important;
        letter-spacing: .3px !important;
    }
    #showcontent .right input[type="submit"][id$="BtnScratch"]:hover,
    #showcontent .right button[id$="BtnScratch"]:hover,
    #showcontent .right input[type="button"][id$="BtnScratch"]:hover {
        background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%) !important;
        box-shadow: 0 6px 20px rgba(99,102,241,.4) !important;
        transform: translateY(-2px) !important;
    }
    #showcontent .right input[type="submit"][id$="BtnScratch"]:active,
    #showcontent .right button[id$="BtnScratch"]:active,
    #showcontent .right input[type="button"][id$="BtnScratch"]:active {
        transform: translateY(0) !important;
        box-shadow: 0 2px 8px rgba(99,102,241,.25) !important;
    }

    /* ===== 其他操作按钮 ===== */
    #showcontent .right > div:not(.nav-buttons) input[type="submit"]:not([id$="BtnScratch"]):not([title*="清除"]),
    #showcontent .right > div:not(.nav-buttons) button:not([id$="BtnScratch"]),
    #showcontent .right > div:not(.nav-buttons) input[type="button"]:not([id$="BtnScratch"]) {
        width: auto !important;
        max-width: 100% !important;
        padding: 7px 18px !important;
        background: #ffffff !important;
        border: 1px solid #e5e7eb !important;
        border-radius: 8px !important;
        color: #374151 !important;
        font-size: 13px !important;
        font-weight: 500 !important;
        font-family: -apple-system, 'Microsoft YaHei', sans-serif !important;
        cursor: pointer !important;
        transition: all .2s ease !important;
        margin: 0 auto 6px !important;
        display: inline-block !important;
        line-height: 1.4 !important;
        height: auto !important;
    }
    #showcontent .right > div:not(.nav-buttons) input[type="submit"]:not([id$="BtnScratch"]):not([title*="清除"]):hover,
    #showcontent .right > div:not(.nav-buttons) button:not([id$="BtnScratch"]):hover,
    #showcontent .right > div:not(.nav-buttons) input[type="button"]:not([id$="BtnScratch"]):hover {
        background: #f8fafc !important;
        border-color: #c7d2fe !important;
        color: #4f46e5 !important;
    }

    /* ===== 清除按钮 ===== */
    #showcontent .right input[type="submit"][title*="清除"] {
        width: auto !important;
        padding: 7px 18px !important;
        background: #fff !important;
        border: 1px solid #fecaca !important;
        border-radius: 8px !important;
        color: #dc2626 !important;
        font-size: 13px !important;
        font-weight: 500 !important;
        cursor: pointer !important;
        transition: all .2s ease !important;
        margin: 0 auto 6px !important;
        display: inline-block !important;
        line-height: 1.4 !important;
        height: auto !important;
    }
    #showcontent .right input[type="submit"][title*="清除"]:hover {
        background: #fef2f2 !important;
        border-color: #f87171 !important;
        color: #b91c1c !important;
    }

    #showcontent .right span[id$="Labelscratch"],
    #showcontent .right label[id$="Labelscratch"] { display: none !important; }

    /* ===== 提示消息 ===== */
    #showcontent .right span[id$="Labelmsg"],
    #showcontent .right label[id$="Labelmsg"] {
        padding: 10px 14px !important;
        background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%) !important;
        border-radius: 10px !important;
        color: #92400e !important;
        font-size: 12px !important;
        font-weight: 500 !important;
        text-align: center !important;
        margin: 8px 0 0 0 !important;
        border: 1px solid #fde68a !important;
        white-space: normal !important;
        word-wrap: break-word !important;
        line-height: 1.6 !important;
        width: 100% !important;
    }
    /* 无内容时彻底隐藏 */
    #showcontent .right span[id$="Labelmsg"]:empty,
    #showcontent .right label[id$="Labelmsg"]:empty,
    #showcontent .right span[id$="Labelmsg"].msg-hidden,
    #showcontent .right label[id$="Labelmsg"].msg-hidden {
        display: none !important;
        padding: 0 !important;
        margin: 0 !important;
        border: none !important;
        height: 0 !important;
        overflow: hidden !important;
    }

    /* ===== 成功图标 ===== */
    #showcontent .right img.ImagePass {
        display: block !important;
        margin: 10px auto !important;
        width: 52px !important;
        height: 52px !important;
        position: static !important;
        left: auto !important;
        top: auto !important;
        filter: drop-shadow(0 2px 6px rgba(16,185,129,.3));
    }

    #showcontent .right #pixelsmall,
    #showcontent .right div[id$="pixelsmall"] { margin: 6px 0 !important; text-align: center !important; color: #64748b !important; font-size: 12px !important; }
    #showcontent .right br { display: none !important; }
    #showcontent .right * { word-wrap: break-word; word-break: normal; }
    #showcontent .right label, #showcontent .right span, #showcontent .right div {
        white-space: normal !important;
        word-wrap: break-word !important;
    }

    #showcontent .courseother { display: none; }

    /* ===== 响应式设计 ===== */
    @media (max-width: 960px) {
        body div#showcontent,
        div#showcontent,
        #showcontent {
            flex-direction: column !important;
            padding: 20px 16px !important;
            gap: 20px !important;
        }
        body div#showcontent .right,
        #showcontent .right {
            width: 100% !important;
            min-width: 0 !important;
            max-width: 100% !important;
            flex: 0 0 auto !important;
            position: static !important;
            border-radius: 14px;
        }
        #showcontent .right .nav-buttons {
            border-radius: 14px 14px 0 0;
        }
        .course-banner-content { padding: 22px 20px; }
        .course-banner-title { font-size: 18px; }
        .course-banner-title label { font-size: 18px !important; }
    }

    @media (max-width: 600px) {
        #showcontent { padding: 12px !important; }
        #showcontent .coursecontent { padding: 24px 18px !important; font-size: 14px; }
        .course-banner-content { padding: 18px 16px; }
        .course-banner-title { font-size: 16px; }
        .course-banner-title label { font-size: 16px !important; }
        body div#showcontent .left,
        #showcontent .left { border-radius: 12px; }
        body div#showcontent .right,
        #showcontent .right { border-radius: 12px; }
    }
</style>
<script type="text/javascript">
    // 拦截并移除"活动还未开始"的提示 - 必须在页面最早期执行
    (function() {
        var originalAlert = window.alert;
        window.alert = function(message) {
            // 如果消息包含"活动还未开始"或"请仔细听讲"，则阻止显示
            if (typeof message === 'string' && 
                (message.indexOf('活动还未开始') !== -1 || 
                 message.indexOf('请仔细听讲') !== -1 ||
                 message.indexOf('技术关键点') !== -1)) {
                console.log('已拦截活动提示:', message);
                return; // 不显示alert
            }
            // 其他alert正常显示
            originalAlert.call(window, message);
        };
    })();
    
    // 设置课程封面图到master页的.banner区域（内联备用方案）
    (function() {
        var bannerUrl = '<%= HdBannerPath.Value %>';
        if (bannerUrl && bannerUrl.trim() !== '') {
            bannerUrl = bannerUrl.trim();
            // 立即设置（不等DOMContentLoaded，因为.banner在master页已渲染）
            var bannerDiv = document.querySelector('.banner');
            if (bannerDiv) {
                bannerDiv.style.cssText += 
                    'background-image: url(' + bannerUrl + ') !important;' +
                    'background-size: cover !important;' +
                    'background-position: center center !important;' +
                    'background-repeat: no-repeat !important;';
            }
            // DOMContentLoaded 再次确认
            document.addEventListener('DOMContentLoaded', function() {
                var bd = document.querySelector('.banner');
                if (bd) {
                    bd.style.cssText += 
                        'background-image: url(' + bannerUrl + ') !important;' +
                        'background-size: cover !important;' +
                        'background-position: center center !important;' +
                        'background-repeat: no-repeat !important;';
                }
            });
        }
    })();

    // 隐藏无内容的 Labelmsg
    document.addEventListener('DOMContentLoaded', function() {
        var msgs = document.querySelectorAll('span[id$="Labelmsg"], label[id$="Labelmsg"]');
        for (var i = 0; i < msgs.length; i++) {
            var txt = (msgs[i].textContent || msgs[i].innerText || '').replace(/[\s\u00a0]/g, '');
            if (!txt) {
                msgs[i].classList.add('msg-hidden');
            }
        }
    });
</script>
<!-- 课程标题区域 -->
<div class="course-banner-section" id="CourseBannerSection" runat="server">
    <div class="course-banner-content">
        <div class="course-banner-title">
            <asp:Label ID="LabelMtitle" runat="server"></asp:Label>
        </div>
    </div>
</div>

<div id="showcontent">
<div class="left">
   <div class="courseother">
        <asp:Label ID="LabelSnum" runat="server" Visible="False"></asp:Label>
            <asp:Label ID="LabelMid" runat="server" Visible="False"></asp:Label>            
            <asp:Label ID="LabelUploadType" runat="server" Visible="False"></asp:Label>
			<asp:Label ID="LabelMcid" runat="server" Visible="False"></asp:Label>
        <asp:Label ID="LabelMsort" runat="server" Visible="False"></asp:Label>
        <asp:CheckBox ID="CheckBack" runat="server" Visible="False" />
        <asp:CheckBox ID="CheckBlock" runat="server" Visible="False" />
        <asp:CheckBox ID="CheckBlockpy" runat="server" Visible="False" />
			<asp:Label ID="LabelLid" runat="server" Visible="False"></asp:Label>
			<asp:Label ID="LabelLtype" runat="server" Visible="False"></asp:Label>
			<asp:HiddenField ID="HdBannerPath" runat="server" />
   </div>   
    <div id="Mcontent" class="coursecontent" runat="server">
		</div>
</div>
<div class="right">
    <link href="../kindeditor/themes/me/me.css" rel="stylesheet" type="text/css" />
    <script charset="utf-8" src="../kindeditor/kindeditor-min.js" type="text/javascript"></script>
		<script charset="utf-8" src="../kindeditor/lang/zh_CN.js" type="text/javascript"></script>
    
    <div class="nav-buttons">
        <input type="button" class="sharedisk" id="share" value="我的网盘" onclick="showShare()" />
        <asp:HyperLink ID="VoteLink" runat="server" Target="_blank" 
            CssClass="txtszcenter" SkinID="HyperLinkPink">作品</asp:HyperLink>
    </div>
     
        <div>
        <div class="thumb-wrapper">
            <asp:Image ID="Thumbnail" runat="server" style="max-width:160px; max-height:240px;"/>
        </div>
        <div id="pixelsmall" runat="server"></div>
        <asp:Label ID="Wtitle" runat="server"></asp:Label>
        
            <asp:Button ID="BtnScratch" runat="server" Font-Bold="True" 
                onclick="BtnScratch_Click" SkinID="buttonSkinPink" Text="开始创作" />
        
            <asp:Label ID="Labelscratch" runat="server" ForeColor="#0066FF"></asp:Label>
        
            <asp:Button ID="BtnBegin" runat="server" Font-Bold="True" 
                onclick="BtnBegin_Click" SkinID="buttonSkinPink" Text="开关指令" />
        
            <asp:Button ID="ButtonClear" runat="server" Font-Bold="True" 
                 SkinID="buttonSkinPink" Text="清除提交" ToolTip="清除模拟学生提交的本项作品" 
                onclick="ButtonClear_Click" />
        
        <asp:Label ID="Labelmsg" runat="server" SkinID="LabelMsgRed"></asp:Label>
        
            <asp:Image ID="ImagePass" CssClass="ImagePass" runat="server" ImageUrl="~/images/sucessed.png" 
            Visible="False" />
    </div>       
</div>   
</div>
</asp:Content>
