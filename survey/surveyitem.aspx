<%@ Page Language="C#" AutoEventWireup="true" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string query = Request.Url.Query;
        string redirectUrl = "surveyitemnew.aspx" + query;
        Response.Redirect(redirectUrl, true);
    }
</script>
