<%@ Page Title="" Language="C#" MasterPageFile="~/profile/Pf.master" AutoEventWireup="true" %>

<script runat="server">
    protected int mySid = 0;
    protected int myTerm = 1;
    protected int myGscore = 0;
    protected int myGrade = 0;
    protected int myClass = 0;
    protected string myGroupLevelName = "见习组员";
    protected string myGroupLevelIcon = "🌱";
    protected int myGroupLevelNum = 1;
    protected int myNextLevelScore = 10;
    protected double myProgress = 0;
    protected System.Data.DataTable dtRanking = null;

    // 等级阈值（优先从XML配置读取，否则使用默认值）
    private int[] thresholds;
    private string[] levelNames;
    private string[] levelIcons;
    private string[] levelColors;

    private void LoadLevelConfig()
    {
        // 默认值
        int[] defThresholds = { 0, 10, 30, 60, 100, 150 };
        string[] defNames = { "见习组员", "初级组员", "中级组员", "高级组员", "资深组员", "明星组员" };
        string[] defIcons = { "🌱", "🌿", "⭐", "🌟", "💎", "👑" };
        string[] defColors = { "#94a3b8", "#10b981", "#f59e0b", "#f97316", "#8b5cf6", "#ec4899" };

        try
        {
            string xmlPath = Server.MapPath("~/App_Data/grouplevel.xml");
            if (System.IO.File.Exists(xmlPath))
            {
                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                doc.Load(xmlPath);
                System.Xml.XmlNodeList nodes = doc.SelectNodes("//levels/level");
                if (nodes != null && nodes.Count > 0)
                {
                    System.Collections.Generic.List<int> t = new System.Collections.Generic.List<int>();
                    System.Collections.Generic.List<string> n = new System.Collections.Generic.List<string>();
                    System.Collections.Generic.List<string> ic = new System.Collections.Generic.List<string>();
                    System.Collections.Generic.List<string> c = new System.Collections.Generic.List<string>();
                    foreach (System.Xml.XmlNode node in nodes)
                    {
                        t.Add(node.Attributes["threshold"] != null ? int.Parse(node.Attributes["threshold"].Value) : 0);
                        n.Add(node.Attributes["name"] != null ? node.Attributes["name"].Value : "");
                        ic.Add(node.Attributes["icon"] != null ? node.Attributes["icon"].Value : "");
                        c.Add(node.Attributes["color"] != null ? node.Attributes["color"].Value : "#94a3b8");
                    }
                    thresholds = t.ToArray();
                    levelNames = n.ToArray();
                    levelIcons = ic.ToArray();
                    levelColors = c.ToArray();
                    return;
                }
            }
        }
        catch { }

        thresholds = defThresholds;
        levelNames = defNames;
        levelIcons = defIcons;
        levelColors = defColors;
    }

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo connField = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (connField != null)
                    cs = connField.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; }
            catch { }
        }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }

    private string GetProp(object model, string propName)
    {
        if (model == null) return "";
        System.Reflection.PropertyInfo p = model.GetType().GetProperty(propName);
        if (p == null) return "";
        object v = p.GetValue(model, null);
        if (v == null) return "";
        string s = v.ToString();
        if (s.Contains("%")) { try { s = HttpUtility.UrlDecode(s, System.Text.Encoding.UTF8); } catch { } }
        return s;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // 从Cookie获取学生信息
        try
        {
            HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc != null && !string.IsNullOrEmpty(sc.Value))
            {
                string cookieVal = sc.Value;
                if (cookieVal.Contains("%")) { try { cookieVal = HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); } catch { } }
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
                        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { cookieVal });
                    string sidStr = GetProp(m, "Sid");
                    if (!string.IsNullOrEmpty(sidStr)) int.TryParse(sidStr, out mySid);
                    string gradeStr = GetProp(m, "Sgrade");
                    if (!string.IsNullOrEmpty(gradeStr)) int.TryParse(gradeStr, out myGrade);
                    string classStr = GetProp(m, "Sclass");
                    if (!string.IsNullOrEmpty(classStr)) int.TryParse(classStr, out myClass);
                }
            }
        }
        catch { }

        LoadLevelConfig();

        // 读取当前学期
        try
        {
            string xmlPath = Server.MapPath("~/website.xml");
            if (System.IO.File.Exists(xmlPath))
            {
                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                doc.Load(xmlPath);
                System.Xml.XmlNode termNode = doc.SelectSingleNode("//website/add[@key='Term']");
                if (termNode != null && termNode.Attributes["value"] != null)
                    int.TryParse(termNode.Attributes["value"].Value, out myTerm);
            }
        }
        catch { }

        LoadData();
    }

    private void LoadData()
    {
        if (mySid <= 0) return;
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return;

        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();

                // 从 GroupWork + Signin 重新计算当前学生的小组学分
                try
                {
                    using (System.Data.SqlClient.SqlCommand updateCmd = new System.Data.SqlClient.SqlCommand(
                        @"UPDATE Students SET Sgscore = ISNULL((
                            SELECT SUM(ISNULL(Gscore,0)) FROM GroupWork WHERE Gterm=@term AND Gstudents LIKE '%' + Students.Snum + '%'
                          ), 0) + ISNULL((
                            SELECT SUM(ISNULL(Qgscore,0)) FROM Signin WHERE Qnum = Students.Snum
                          ), 0) WHERE Sid=@sid", conn))
                    {
                        updateCmd.Parameters.AddWithValue("@sid", mySid);
                        updateCmd.Parameters.AddWithValue("@term", myTerm);
                        updateCmd.CommandTimeout = 5;
                        updateCmd.ExecuteNonQuery();
                    }
                }
                catch { }

                // 获取自己的小组学分
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(Sgscore,0) FROM Students WHERE Sid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", mySid);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        myGscore = Convert.ToInt32(result);
                }

                // 计算等级
                ComputeLevel();

                // 获取同班同学排名
                if (myGrade > 0 && myClass > 0)
                {
                    // 先更新整个班级的小组学分
                    try
                    {
                        using (System.Data.SqlClient.SqlCommand updateAllCmd = new System.Data.SqlClient.SqlCommand(
                            @"UPDATE Students SET Sgscore = ISNULL((
                                SELECT SUM(ISNULL(Gscore,0)) FROM GroupWork WHERE Gterm=@term AND Gstudents LIKE '%' + Students.Snum + '%'
                              ), 0) + ISNULL((
                                SELECT SUM(ISNULL(Qgscore,0)) FROM Signin WHERE Qnum = Students.Snum
                              ), 0) WHERE Sgrade=@grade AND Sclass=@class", conn))
                        {
                            updateAllCmd.Parameters.AddWithValue("@grade", myGrade);
                            updateAllCmd.Parameters.AddWithValue("@class", myClass);
                            updateAllCmd.Parameters.AddWithValue("@term", myTerm);
                            updateAllCmd.CommandTimeout = 10;
                            updateAllCmd.ExecuteNonQuery();
                        }
                    }
                    catch { }

                    using (System.Data.SqlClient.SqlCommand cmd2 = new System.Data.SqlClient.SqlCommand(
                        "SELECT Sid, Sname, ISNULL(Sgscore,0) AS Sgscore, Sgtitle FROM Students WHERE Sgrade=@grade AND Sclass=@class ORDER BY Sgscore DESC, Sname", conn))
                    {
                        cmd2.Parameters.AddWithValue("@grade", myGrade);
                        cmd2.Parameters.AddWithValue("@class", myClass);
                        System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(cmd2);
                        dtRanking = new System.Data.DataTable();
                        da.Fill(dtRanking);
                    }
                }
            }
        }
        catch { }
    }

    private void ComputeLevel()
    {
        for (int i = thresholds.Length - 1; i >= 0; i--)
        {
            if (myGscore >= thresholds[i])
            {
                myGroupLevelNum = i + 1;
                myGroupLevelName = levelNames[i];
                myGroupLevelIcon = levelIcons[i];
                if (i < thresholds.Length - 1)
                {
                    myNextLevelScore = thresholds[i + 1];
                    myProgress = (double)(myGscore - thresholds[i]) / (thresholds[i + 1] - thresholds[i]) * 100;
                }
                else
                {
                    myNextLevelScore = 0;
                    myProgress = 100;
                }
                break;
            }
        }
    }

    protected bool IsImageIcon(string icon)
    {
        if (string.IsNullOrEmpty(icon)) return false;
        return icon.IndexOf('/') >= 0 || icon.IndexOf(".png") >= 0 || icon.IndexOf(".jpg") >= 0 || icon.IndexOf(".gif") >= 0 || icon.IndexOf(".svg") >= 0 || icon.IndexOf(".webp") >= 0;
    }

    protected string RenderIcon(string icon, int size)
    {
        if (IsImageIcon(icon))
            return "<img src=\"" + Server.HtmlEncode(icon) + "\" style=\"width:" + size + "px;height:" + size + "px;object-fit:contain;vertical-align:middle;\" />";
        return Server.HtmlEncode(icon);
    }

    protected string GetLevelForScore(int score)
    {
        for (int i = thresholds.Length - 1; i >= 0; i--)
        {
            if (score >= thresholds[i])
                return RenderIcon(levelIcons[i], 18) + " Lv." + (i + 1);
        }
        return RenderIcon(levelIcons[0], 18) + " Lv.1";
    }

    protected string GetRankMedal(int rank)
    {
        if (rank == 1) return "🥇";
        if (rank == 2) return "🥈";
        if (rank == 3) return "🥉";
        return rank.ToString();
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" runat="Server">
<style>
    .gl-page { animation: glFade .4s ease; }
    @keyframes glFade { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    .gl-card { background: #fff; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; margin-bottom: 20px; }

    /* 当前等级卡片 */
    .gl-hero {
        background: linear-gradient(135deg, #059669 0%, #10b981 50%, #34d399 100%);
        border-radius: 16px; padding: 28px 32px; margin-bottom: 20px; color: #fff;
        position: relative; overflow: hidden;
    }
    .gl-hero::before { content: ''; position: absolute; top: -50px; right: -30px; width: 160px; height: 160px; border-radius: 50%; background: rgba(255,255,255,.08); }
    .gl-hero::after { content: ''; position: absolute; bottom: -30px; left: 20%; width: 100px; height: 100px; border-radius: 50%; background: rgba(255,255,255,.05); }
    .gl-hero-top { display: flex; align-items: center; gap: 16px; margin-bottom: 20px; position: relative; z-index: 1; }
    .gl-hero-icon { font-size: 40px; line-height: 1; }
    .gl-hero-icon img { width: 44px; height: 44px; object-fit: contain; vertical-align: middle; }
    .gl-hero-info h2 { font-size: 22px; font-weight: 800; margin: 0 0 4px; }
    .gl-hero-info p { font-size: 13px; opacity: .85; margin: 0; }
    .gl-progress-wrap { position: relative; z-index: 1; }
    .gl-progress-labels { display: flex; justify-content: space-between; font-size: 12px; margin-bottom: 8px; opacity: .9; }
    .gl-progress-bar { height: 10px; background: rgba(255,255,255,.2); border-radius: 10px; overflow: hidden; }
    .gl-progress-fill { height: 100%; background: rgba(255,255,255,.85); border-radius: 10px; transition: width .6s ease; }

    /* 等级说明 */
    .gl-levels-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 10px; }
    .gl-levels-head svg { width: 18px; height: 18px; fill: none; stroke: #10b981; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .gl-levels-head h3 { font-size: 15px; font-weight: 700; color: #1e293b; margin: 0; }
    .gl-levels-body { padding: 20px 24px; }
    .gl-level-list { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 12px; }
    .gl-level-item {
        padding: 14px 16px; border-radius: 12px; border: 1.5px solid #e5e7eb;
        text-align: center; transition: all .15s;
    }
    .gl-level-item:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,.06); }
    .gl-level-item.gl-current { border-color: #10b981; background: #ecfdf5; }
    .gl-level-icon { font-size: 28px; margin-bottom: 6px; }
    .gl-level-icon img { width: 32px; height: 32px; object-fit: contain; vertical-align: middle; }
    .gl-level-name { font-size: 13px; font-weight: 700; color: #1e293b; margin-bottom: 2px; }
    .gl-level-score { font-size: 11px; color: #94a3b8; }

    /* 排名表格 */
    .gl-rank-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 10px; }
    .gl-rank-head svg { width: 18px; height: 18px; fill: none; stroke: #f59e0b; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .gl-rank-head h3 { font-size: 15px; font-weight: 700; color: #1e293b; margin: 0; }
    .gl-rank-body { padding: 0; }
    .gl-rank-table { width: 100%; border-collapse: collapse; }
    .gl-rank-table th {
        padding: 12px 16px; font-size: 11px; font-weight: 600; color: #94a3b8;
        text-align: left; background: #f8fafc; border-bottom: 1px solid #e8ecf1;
        text-transform: uppercase; letter-spacing: .5px;
    }
    .gl-rank-table td {
        padding: 12px 16px; font-size: 13px; color: #334155;
        border-bottom: 1px solid #f1f5f9; vertical-align: middle;
    }
    .gl-rank-table tr:last-child td { border-bottom: none; }
    .gl-rank-table tr:hover td { background: #f0fdf4; }
    .gl-rank-table tr.gl-rank-me td { background: #ecfdf5; font-weight: 600; }
    .gl-rank-num { text-align: center; width: 50px; font-size: 16px; }
    .gl-rank-name { font-weight: 600; color: #1e293b; }
    .gl-rank-group { font-size: 12px; color: #64748b; }
    .gl-rank-score { font-weight: 700; color: #059669; }
    .gl-rank-level { font-size: 12px; }

    .gl-empty { padding: 40px 20px; text-align: center; color: #94a3b8; font-size: 14px; }
</style>

<div class="gl-page">
    <!-- 当前等级 -->
    <div class="gl-hero">
        <div class="gl-hero-top">
            <div class="gl-hero-icon"><%= RenderIcon(myGroupLevelIcon, 44) %></div>
            <div class="gl-hero-info">
                <h2>Lv.<%= myGroupLevelNum %> <%= myGroupLevelName %></h2>
                <p>小组学分：<strong><%= myGscore %></strong> 分</p>
            </div>
        </div>
        <div class="gl-progress-wrap">
            <div class="gl-progress-labels">
                <span>当前 <%= myGscore %> 分</span>
                <% if (myNextLevelScore > 0) { %>
                <span>下一级 <%= myNextLevelScore %> 分（还差 <%= myNextLevelScore - myGscore %> 分）</span>
                <% } else { %>
                <span>已达最高等级</span>
                <% } %>
            </div>
            <div class="gl-progress-bar">
                <div class="gl-progress-fill" style="width:<%= myProgress.ToString("F0") %>%"></div>
            </div>
        </div>
    </div>

    <!-- 等级说明 -->
    <div class="gl-card">
        <div class="gl-levels-head">
            <svg viewBox="0 0 24 24"><path d="M12 20V10"/><path d="M18 20V4"/><path d="M6 20v-4"/></svg>
            <h3>小组等级说明</h3>
        </div>
        <div class="gl-levels-body">
            <div class="gl-level-list">
                <% for (int li = 0; li < levelNames.Length; li++) { %>
                <div class="gl-level-item <%= myGroupLevelNum==(li+1)?"gl-current":"" %>">
                    <div class="gl-level-icon"><%= RenderIcon(levelIcons[li], 32) %></div>
                    <div class="gl-level-name">Lv.<%= li+1 %> <%= levelNames[li] %></div>
                    <div class="gl-level-score"><%= thresholds[li] %> 分起</div>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- 班级排名 -->
    <div class="gl-card">
        <div class="gl-rank-head">
            <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
            <h3>班级小组学分排名</h3>
        </div>
        <div class="gl-rank-body">
            <% if (dtRanking != null && dtRanking.Rows.Count > 0) { %>
            <table class="gl-rank-table">
                <thead>
                    <tr><th style="width:50px;text-align:center">排名</th><th>姓名</th><th>小组</th><th>学分</th><th>等级</th></tr>
                </thead>
                <tbody>
                <% int rank = 0;
                   foreach (System.Data.DataRow row in dtRanking.Rows) {
                       rank++;
                       int sid = Convert.ToInt32(row["Sid"]);
                       string sname = row["Sname"] == DBNull.Value ? "" : row["Sname"].ToString();
                       int gscore = row["Sgscore"] == DBNull.Value ? 0 : Convert.ToInt32(row["Sgscore"]);
                       string sgtitle = row["Sgtitle"] == DBNull.Value ? "" : row["Sgtitle"].ToString();
                       bool isMe = (sid == mySid);
                %>
                    <tr class="<%= isMe ? "gl-rank-me" : "" %>">
                        <td class="gl-rank-num"><%= GetRankMedal(rank) %></td>
                        <td class="gl-rank-name"><%= Server.HtmlEncode(sname) %><%= isMe ? " (我)" : "" %></td>
                        <td class="gl-rank-group"><%= Server.HtmlEncode(sgtitle) %></td>
                        <td class="gl-rank-score"><%= gscore %></td>
                        <td class="gl-rank-level"><%= GetLevelForScore(gscore) %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            <% } else { %>
            <div class="gl-empty">暂无排名数据</div>
            <% } %>
        </div>
    </div>
    </div>
<script type="text/javascript">
(function(){
    function isImgPath(s) {
        if (!s) return false;
        return s.indexOf('/') >= 0 && /\.(png|jpg|jpeg|gif|svg|webp)/i.test(s);
    }
    function escA(s) {
        return s.replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }
    function fixIcon(el, size) {
        if (!el || el.querySelector('img')) return;
        var t = (el.textContent||'').replace(/^\s+|\s+$/g,'');
        if (/^<img\s/i.test(t)) { el.innerHTML = t; if (el.querySelector('img')) return; }
        if (isImgPath(t)) {
            el.innerHTML = '<img src="'+escA(t)+'" style="width:'+size+'px;height:'+size+'px;object-fit:contain;vertical-align:middle;" />';
        }
    }
    function fixCell(el) {
        if (!el || el.querySelector('img')) return;
        var t = (el.textContent||'').replace(/^\s+|\s+$/g,'');
        if (/^<img\s/i.test(t)) { el.innerHTML = t; if (el.querySelector('img')) return; }
        var m = t.match(/^([^\s]+\.(?:png|jpg|jpeg|gif|svg|webp))\s*(.*)/i);
        if (m && m[1].indexOf('/') >= 0) {
            el.innerHTML = '<img src="'+escA(m[1])+'" style="width:18px;height:18px;object-fit:contain;vertical-align:middle;" /> '+escA(m[2]);
        }
    }
    var h = document.querySelectorAll('.gl-hero-icon');
    for (var i=0;i<h.length;i++) fixIcon(h[i],44);
    var ic = document.querySelectorAll('.gl-level-icon');
    for (var i=0;i<ic.length;i++) fixIcon(ic[i],32);
    var c = document.querySelectorAll('.gl-rank-level');
    for (var i=0;i<c.length;i++) fixCell(c[i]);
})();
</script>
</asp:Content>
