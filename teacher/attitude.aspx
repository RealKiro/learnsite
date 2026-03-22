<%@ page title="" language="C#" stylesheettheme="Teacher" validaterequest="false" autoeventwireup="true" inherits="Teacher_attitude, LearnSite" %>

<script runat="server">
    private string AttGetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        { try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { } }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        LoadAttitudeTypes();
    }

    private void LoadAttitudeTypes()
    {
        string cs = AttGetConnStr();
        if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                // Check if table exists
                using (System.Data.SqlClient.SqlCommand chk = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM sysobjects WHERE name='AttitudeType' AND xtype='U'", conn))
                {
                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                    if (exists == 0) return; // table not yet created, keep hardcoded defaults
                }
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT Tname, Tscore FROM AttitudeType WHERE ISNULL(Tactive,1)=1 ORDER BY Tsort, Tid", conn))
                {
                    System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader();
                    System.Collections.Generic.List<System.Web.UI.WebControls.ListItem> items =
                        new System.Collections.Generic.List<System.Web.UI.WebControls.ListItem>();
                    while (dr.Read())
                    {
                        string name = dr["Tname"] != DBNull.Value ? dr["Tname"].ToString() : "";
                        string score = dr["Tscore"] != DBNull.Value ? dr["Tscore"].ToString() : "0";
                        items.Add(new System.Web.UI.WebControls.ListItem(name, score));
                    }
                    dr.Close();
                    if (items.Count > 0)
                    {
                        RBLattitude.Items.Clear();
                        foreach (System.Web.UI.WebControls.ListItem item in items)
                            RBLattitude.Items.Add(item);
                    }
                }
            }
        }
        catch { } // fallback: keep hardcoded items if DB fails
    }
</script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
        font-family: 'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;
        background: linear-gradient(180deg, #f0f2f8 0%, #e8eaf6 100%);
        color: #1e293b; min-height: 100vh;
        overflow: hidden;
    }
    #form1 { width: 100%; }

    .att-wrap {
        width: 100%; max-width: 100%; margin: 0; padding: 0;
        min-height: 100vh; display: flex; flex-direction: column;
    }

    /* === 顶部横幅 === */
    .att-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 20px 28px; text-align: center; color: #fff;
        position: relative; overflow: hidden; flex-shrink: 0;
    }
    .att-header::before {
        content: ''; position: absolute; top: -50%; right: -20%;
        width: 200px; height: 200px; border-radius: 50%;
        background: rgba(255,255,255,.06);
    }
    .att-header::after {
        content: ''; position: absolute; bottom: -40%; left: -10%;
        width: 160px; height: 160px; border-radius: 50%;
        background: rgba(255,255,255,.04);
    }
    .att-header-title {
        font-size: 16px; font-weight: 600; position: relative; z-index: 1;
        letter-spacing: 1px;
    }
    .att-header-title .att-name {
        color: #fbbf24; font-weight: 800; font-size: 18px;
        margin: 0 6px; text-shadow: 0 1px 4px rgba(0,0,0,.15);
    }

    /* === 主体 === */
    .att-body {
        background: #fff; padding: 28px 32px 30px;
        flex: 1; display: flex; flex-direction: column;
        min-height: 620px;
    }

    /* === 区域标题 === */
    .att-section-title {
        font-size: 13px; font-weight: 700; color: #6366f1;
        margin-bottom: 12px; display: flex; align-items: center; gap: 8px;
        letter-spacing: .5px;
    }
    .att-section-title svg {
        width: 16px; height: 16px; stroke: #6366f1; fill: none;
        stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }

    /* === 评分选择 === */
    .att-score-row {
        display: flex; align-items: center; justify-content: center;
        gap: 14px; margin-bottom: 24px;
        padding: 16px 20px; border-radius: 12px;
        background: linear-gradient(135deg, #f8f9ff 0%, #eef2ff 100%);
        border: 1.5px solid #e0e7ff;
    }
    .att-score-label { font-size: 14px; font-weight: 700; color: #374151; }
    .att-score-row select {
        height: 40px; border-radius: 10px; border: 2px solid #c7d2fe;
        background: #fff; color: #4f46e5; font-size: 16px; font-weight: 700;
        padding: 0 18px; outline: none; cursor: pointer; min-width: 80px;
        text-align: center; transition: all .2s;
    }
    .att-score-row select:focus {
        border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.15);
    }

    /* === 快捷评语（表格布局） === */
    .att-tags { margin-bottom: 24px; }

    /* RadioButtonList 生成的 table 样式 */
    .att-tags table {
        width: 100% !important; border-collapse: separate !important;
        border-spacing: 10px !important; table-layout: fixed !important;
    }
    .att-tags table td {
        padding: 0 !important; vertical-align: top !important;
    }
    .att-tags table td label {
        display: flex !important; align-items: center; gap: 10px;
        padding: 15px 16px; border-radius: 12px; cursor: pointer;
        border: 1.5px solid #e5e7eb; background: #fafbfc;
        font-size: 13px; font-weight: 500; color: #475569;
        transition: all .2s ease; user-select: none;
        width: 100% !important; height: auto !important;
    }
    .att-tags table td label:hover {
        border-color: #a5b4fc; background: #eef2ff;
        transform: translateY(-1px); box-shadow: 0 2px 8px rgba(99,102,241,.1);
    }
    .att-tags table input[type="radio"] {
        display: none !important;
    }
    /* 选中状态 */
    .att-tags table td label:has(input:checked) {
        border-color: #6366f1; background: linear-gradient(135deg, #eef2ff, #e8ecff);
        color: #4338ca; font-weight: 600;
        box-shadow: 0 2px 12px rgba(99,102,241,.15);
    }
    /* 正面评语标记 */
    .att-tags table td[data-positive="1"] label { border-left: 3px solid #10b981; }
    .att-tags table td[data-positive="1"] label:has(input:checked) {
        border-color: #10b981; background: linear-gradient(135deg, #ecfdf5, #d1fae5);
        color: #047857;
    }
    /* 负面评语标记 */
    .att-tags table td[data-positive="0"] label { border-left: 3px solid #f59e0b; }
    .att-tags table td[data-positive="0"] label:has(input:checked) {
        border-color: #f59e0b; background: linear-gradient(135deg, #fffbeb, #fef3c7);
        color: #92400e;
    }

    /* === 自定义评语 === */
    .att-custom { margin-bottom: 20px; flex: 1; display: flex; flex-direction: column; }
    .att-custom textarea {
        width: 100% !important; min-height: 120px !important; border-radius: 12px !important;
        border: 1.5px solid #e5e7eb !important; background: #fafbfc !important;
        padding: 14px 16px !important; font-size: 13px !important; color: #334155 !important;
        font-family: inherit !important; resize: vertical !important; outline: none !important;
        transition: all .2s !important; flex: 1;
    }
    .att-custom textarea:focus {
        border-color: #6366f1 !important; background: #fff !important;
        box-shadow: 0 0 0 3px rgba(99,102,241,.1) !important;
    }

    /* === 消息 === */
    .att-msg {
        text-align: center; min-height: 22px; margin-bottom: 12px;
        font-size: 13px; color: #ef4444; font-weight: 500;
    }

    /* === 确定按钮 === */
    .att-actions { text-align: center; flex-shrink: 0; }
    .att-actions input[type="submit"] {
        display: inline-flex !important; align-items: center; justify-content: center;
        height: 44px !important; min-width: 180px !important; padding: 0 32px !important;
        border-radius: 12px !important; border: none !important;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
        color: #fff !important; font-size: 15px !important; font-weight: 700 !important;
        letter-spacing: 3px !important; cursor: pointer !important;
        box-shadow: 0 4px 16px rgba(102,126,234,.3) !important;
        transition: all .25s !important;
        -webkit-appearance: none !important; appearance: none !important;
        font-family: inherit !important;
    }
    .att-actions input[type="submit"]:hover {
        background: linear-gradient(135deg, #5a67d8 0%, #6b3fa0 100%) !important;
        transform: translateY(-2px) !important;
        box-shadow: 0 6px 24px rgba(102,126,234,.4) !important;
    }
    .att-actions input[type="submit"]:active {
        transform: translateY(0) !important;
    }

    @media (max-width: 760px) {
        .att-body {
            min-height: auto;
            padding: 20px 18px 22px;
        }
        .att-tags table {
            border-spacing: 8px !important;
        }
        .att-tags table td label {
            padding: 12px 13px;
        }
        .att-custom textarea {
            min-height: 92px !important;
        }
    }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div class="att-wrap">
        <div class="att-header">
            <div class="att-header-title">
                对 <span class="att-name"><asp:Label ID="Labelname" runat="server" Font-Bold="True"></asp:Label></span> 同学评分
            </div>
        </div>
        <div class="att-body">
            <div class="att-score-row">
                <span class="att-score-label">选择评分</span>
                <asp:DropDownList ID="DDLatt" runat="server" Font-Size="9pt">
                    <asp:ListItem>5</asp:ListItem>
                    <asp:ListItem>4</asp:ListItem>
                    <asp:ListItem>3</asp:ListItem>
                    <asp:ListItem>2</asp:ListItem>
                    <asp:ListItem>1</asp:ListItem>
                    <asp:ListItem>0</asp:ListItem>
                    <asp:ListItem>-1</asp:ListItem>
                    <asp:ListItem>-2</asp:ListItem>
                    <asp:ListItem>-3</asp:ListItem>
                    <asp:ListItem>-4</asp:ListItem>
                    <asp:ListItem>-5</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="att-section-title">
                <svg viewBox="0 0 24 24"><path d="M20.59 13.41l-7.17 7.17a2 2 0 01-2.83 0L2 12V2h10l8.59 8.59a2 2 0 010 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>
                快捷评语
            </div>
            <div class="att-tags">
                <asp:RadioButtonList ID="RBLattitude" runat="server" 
                    onselectedindexchanged="RBLattitude_SelectedIndexChanged" 
                    Width="100%" RepeatColumns="2" AutoPostBack="True" RepeatLayout="Table">
                    <asp:ListItem Value="2">乐于助人</asp:ListItem>
                    <asp:ListItem Value="1">表现优秀</asp:ListItem>
                    <asp:ListItem Value="-1">有开小差</asp:ListItem>
                    <asp:ListItem Value="-2">乱扔垃圾</asp:ListItem>
                    <asp:ListItem Value="-3">上课迟到</asp:ListItem>
                    <asp:ListItem Value="-4">损坏公物</asp:ListItem>
                </asp:RadioButtonList>
            </div>
            <div class="att-section-title">
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                自定义课堂评语
            </div>
            <div class="att-custom">
                <asp:TextBox ID="TextBox2" runat="server" Height="70px" ToolTip="填写好自定义评语后，请手动选择上面的评分！" 
                    Width="100%" TextMode="MultiLine"></asp:TextBox>
            </div>
            <div class="att-msg"><asp:Label ID="Labelmsg" runat="server"></asp:Label></div>
            <div class="att-actions">
                <asp:Button ID="Btnattitude" runat="server" Text="确认评分" 
                    onclick="Btnattitude_Click" SkinID="BtnNormal" />
            </div>
        </div>
    </div>
    </form>
    <script type="text/javascript">
    // 为正面/负面评语标签所在的 td 添加 data-positive 属性
    (function(){
        var cells = document.querySelectorAll('.att-tags table td');
        for(var i=0;i<cells.length;i++){
            var radio = cells[i].querySelector('input[type="radio"]');
            if(radio){
                var val = parseInt(radio.value,10);
                cells[i].setAttribute('data-positive', val > 0 ? '1' : '0');
            }
        }
    })();

    (function () {
        var hasNotified = false;
        var msgEl = document.getElementById('<%= Labelmsg.ClientID %>');

        function notifyParentAndClose() {
            if (hasNotified || !msgEl) return;
            var text = msgEl.innerText || msgEl.textContent || '';
            if (text.indexOf('成功') === -1) return;
            hasNotified = true;

            try {
                if (window.parent) {
                    window.parent.__attitudeScoreChanged = true;
                }
            } catch (e) { }

            setTimeout(function () {
                try {
                    if (window.parent && window.parent.TINY && window.parent.TINY.box) {
                        window.parent.TINY.box.hide();
                    }
                } catch (e) { }
            }, 700);
        }

        if (msgEl) {
            notifyParentAndClose();
            if (window.MutationObserver) {
                var observer = new MutationObserver(function () {
                    notifyParentAndClose();
                });
                observer.observe(msgEl, { childList: true, subtree: true, characterData: true });
            }
        }
    })();
    </script>
</body>
</html>

