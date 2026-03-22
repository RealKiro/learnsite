<%@ Page Language="C#" AutoEventWireup="true" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        // /student/index 入口页：检查学生登录 cookie，已登录跳转课程主页，否则返回登录页
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc == null || string.IsNullOrEmpty(sc.Value))
            {
                Response.Redirect("~/index.aspx", true);
                return;
            }
        }
        catch
        {
            // 若程序集未加载则直接跳转，由目标页处理鉴权
        }
        Response.Redirect("~/student/showmission.aspx", true);
    }
</script>
