using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace LearnSite
{
    public partial class Teacher_programshow : System.Web.UI.Page
    {
        // ===== 控件声明（必须与 aspx 文件中的控件类型完全匹配）=====
        // 重要：所有控件类型必须与 ASPX 文件中的声明完全一致
        
        // 新版控件
        protected global::System.Web.UI.WebControls.Label LabelMtitle;
        protected global::System.Web.UI.WebControls.Label LabelMdate;
        protected global::System.Web.UI.WebControls.Image ImageType;
        protected global::System.Web.UI.WebControls.Label LabelMfiletype;
        protected global::System.Web.UI.WebControls.HyperLink Hlexample;
        protected global::System.Web.UI.WebControls.HyperLink HLMgid;
        protected global::System.Web.UI.WebControls.CheckBox CheckPublish;
        protected global::System.Web.UI.WebControls.CheckBox CheckMicoWorld;
        
        // BtnEdit 与 aspx 中的控件类型保持一致（ImageButton）
        protected global::System.Web.UI.WebControls.ImageButton BtnEdit;
        protected global::System.Web.UI.WebControls.LinkButton LinkBtn;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl Mcontent;
        
        // 旧版控件（隐藏区域）
        protected global::System.Web.UI.WebControls.Label LabelMtitle_old;
        protected global::System.Web.UI.WebControls.Label LabelMdate_old;
        protected global::System.Web.UI.WebControls.Image ImageType_old;
        protected global::System.Web.UI.WebControls.Label LabelMfiletype_old;
        protected global::System.Web.UI.WebControls.HyperLink Hlexample_old;
        protected global::System.Web.UI.WebControls.CheckBox CheckPublish_old;
        protected global::System.Web.UI.WebControls.CheckBox CheckMicoWorld_old;
        protected global::System.Web.UI.WebControls.HyperLink HLMgid_old;
        protected global::System.Web.UI.WebControls.LinkButton LinkBtn_old;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl Mcontent_old;
        
        protected void Page_Load(object sender, EventArgs e)
        {
            // 页面加载逻辑
        }
        
        protected void BtnEdit_Click(object sender, EventArgs e)
        {
            // 编辑按钮点击事件处理
            Response.Redirect("programedit.aspx?mid=" + Request.QueryString["mid"]);
        }
        
        protected void LinkBtn_Click(object sender, EventArgs e)
        {
            // 返回按钮点击事件处理
            Response.Redirect("course.aspx");
        }
    }
}
