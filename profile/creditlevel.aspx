<%@ Page Title="" Language="C#" MasterPageFile="~/profile/Pf.master" AutoEventWireup="true" %>

<script runat="server">
    protected int mySid = 0;
    protected int myAllscore = 0;
    protected int myGrade = 0;
    protected int myClass = 0;
    protected string myCreditLevelName = "学习新手";
    protected string myCreditLevelIcon = "🌱";
    protected int myCreditLevelNum = 1;
    protected int myNextLevelScore = 20;
    protected double myProgress = 0;
    protected System.Data.DataTable dtRanking = null;

    // 学分等级阈值（优先从XML配置读取，否则使用默认值）
    private int[] thresholds;
    private string[] levelNames;
    private string[] levelIcons;

    private void LoadLevelConfig()
    {
        int[] defThresholds = { 0, 20, 50, 100, 200, 350 };
        string[] defNames = { "学习新手", "勤奋学生", "优秀学子", "学习达人", "学习精英", "学习大师" };
        string[] defIcons = { "🌱", "🌿", "🌳", "🌟", "🏆", "👑" };

        try
        {
            string xmlPath = Server.MapPath("~/App_Data/creditlevel.xml");
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
                    foreach (System.Xml.XmlNode node in nodes)
                    {
                        t.Add(node.Attributes["threshold"] != null ? int.Parse(node.Attributes["threshold"].Value) : 0);
                        n.Add(node.Attributes["name"] != null ? node.Attributes["name"].Value : "");
                        ic.Add(node.Attributes["icon"] != null ? node.Attributes["icon"].Value : "");
                    }
                    thresholds = t.ToArray();
                    levelNames = n.ToArray();
                    levelIcons = ic.ToArray();
                    return;
                }
            }
        }
        catch { }

        thresholds = defThresholds;
        levelNames = defNames;
        levelIcons = defIcons;
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

                // 先更新总学分：Sallscore = Sscore + Swscore + Stscore + Sgscore + Spscore + Slearnscore + 其他学分
                try
                {
                    using (System.Data.SqlClient.SqlCommand updateCmd = new System.Data.SqlClient.SqlCommand(
                        @"UPDATE Students SET Sallscore = 
                            ISNULL(Sscore, 0) + ISNULL(Swscore, 0) + ISNULL(Stscore, 0) + 
                            ISNULL(Sgscore, 0) + ISNULL(Spscore, 0) + ISNULL(Squiz, 0) + 
                            ISNULL(Sattitude, 0) + ISNULL(Svscore, 0) + ISNULL(Stxtform, 0) + 
                            ISNULL(Sidle, 0) + ISNULL(Schinese, 0) + ISNULL(Sfscore, 0) + 
                            ISNULL(Slearnscore, 0)
                          WHERE Sid=@sid", conn))
                    {
                        updateCmd.Parameters.AddWithValue("@sid", mySid);
                        updateCmd.CommandTimeout = 5;
                        updateCmd.ExecuteNonQuery();
                    }
                }
                catch { }

                // 获取自己的总学分
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(Sallscore,0) FROM Students WHERE Sid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", mySid);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        myAllscore = Convert.ToInt32(result);
                }

                ComputeLevel();

                // 获取同班同学学分排名
                if (myGrade > 0 && myClass > 0)
                {
                    // 先更新整个班级的总学分
                    try
                    {
                        using (System.Data.SqlClient.SqlCommand updateAllCmd = new System.Data.SqlClient.SqlCommand(
                            @"UPDATE Students SET Sallscore = 
                                ISNULL(Sscore, 0) + ISNULL(Swscore, 0) + ISNULL(Stscore, 0) + 
                                ISNULL(Sgscore, 0) + ISNULL(Spscore, 0) + ISNULL(Squiz, 0) + 
                                ISNULL(Sattitude, 0) + ISNULL(Svscore, 0) + ISNULL(Stxtform, 0) + 
                                ISNULL(Sidle, 0) + ISNULL(Schinese, 0) + ISNULL(Sfscore, 0) + 
                                ISNULL(Slearnscore, 0)
                              WHERE Sgrade=@grade AND Sclass=@class", conn))
                        {
                            updateAllCmd.Parameters.AddWithValue("@grade", myGrade);
                            updateAllCmd.Parameters.AddWithValue("@class", myClass);
                            updateAllCmd.CommandTimeout = 10;
                            updateAllCmd.ExecuteNonQuery();
                        }
                    }
                    catch { }

                    using (System.Data.SqlClient.SqlCommand cmd2 = new System.Data.SqlClient.SqlCommand(
                        "SELECT Sid, Sname, ISNULL(Sallscore,0) AS Sallscore, ISNULL(Sscore,0) AS Sscore, ISNULL(Swscore,0) AS Swscore, ISNULL(Stscore,0) AS Stscore, ISNULL(Slearnscore,0) AS Slearnscore FROM Students WHERE Sgrade=@grade AND Sclass=@class ORDER BY Sallscore DESC, Sname", conn))
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
            if (myAllscore >= thresholds[i])
            {
                myCreditLevelNum = i + 1;
                myCreditLevelName = levelNames[i];
                myCreditLevelIcon = levelIcons[i];
                if (i < thresholds.Length - 1)
                {
                    myNextLevelScore = thresholds[i + 1];
                    myProgress = (double)(myAllscore - thresholds[i]) / (thresholds[i + 1] - thresholds[i]) * 100;
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
    .cl-page { animation: clFade .4s ease; }
    @keyframes clFade { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    .cl-card { background: #fff; border-radius: 16px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; margin-bottom: 20px; }

    /* 当前等级卡片 */
    .cl-hero {
        background: linear-gradient(135deg, #d97706 0%, #f59e0b 50%, #fbbf24 100%);
        border-radius: 16px; padding: 28px 32px; margin-bottom: 20px; color: #fff;
        position: relative; overflow: hidden;
    }
    .cl-hero::before { content: ''; position: absolute; top: -50px; right: -30px; width: 160px; height: 160px; border-radius: 50%; background: rgba(255,255,255,.08); }
    .cl-hero::after { content: ''; position: absolute; bottom: -30px; left: 20%; width: 100px; height: 100px; border-radius: 50%; background: rgba(255,255,255,.05); }
    .cl-hero-top { display: flex; align-items: center; gap: 16px; margin-bottom: 20px; position: relative; z-index: 1; }
    .cl-hero-icon { font-size: 40px; line-height: 1; }
    .cl-hero-icon img { width: 44px; height: 44px; object-fit: contain; vertical-align: middle; }
    .cl-hero-info h2 { font-size: 22px; font-weight: 800; margin: 0 0 4px; }
    .cl-hero-info p { font-size: 13px; opacity: .9; margin: 0; }
    .cl-progress-wrap { position: relative; z-index: 1; }
    .cl-progress-labels { display: flex; justify-content: space-between; font-size: 12px; margin-bottom: 8px; opacity: .9; }
    .cl-progress-bar { height: 10px; background: rgba(255,255,255,.2); border-radius: 10px; overflow: hidden; }
    .cl-progress-fill { height: 100%; background: rgba(255,255,255,.85); border-radius: 10px; transition: width .6s ease; }

    /* 等级说明 */
    .cl-levels-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 10px; }
    .cl-levels-head svg { width: 18px; height: 18px; fill: none; stroke: #d97706; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .cl-levels-head h3 { font-size: 15px; font-weight: 700; color: #1e293b; margin: 0; }
    .cl-levels-body { padding: 20px 24px; }
    .cl-level-list { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 12px; }
    .cl-level-item {
        padding: 14px 16px; border-radius: 12px; border: 1.5px solid #e5e7eb;
        text-align: center; transition: all .15s;
    }
    .cl-level-item:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,.06); }
    .cl-level-item.cl-current { border-color: #f59e0b; background: #fffbeb; }
    .cl-level-icon { font-size: 28px; margin-bottom: 6px; }
    .cl-level-icon img { width: 32px; height: 32px; object-fit: contain; vertical-align: middle; }
    .cl-level-name { font-size: 13px; font-weight: 700; color: #1e293b; margin-bottom: 2px; }
    .cl-level-score { font-size: 11px; color: #94a3b8; }

    /* 排名表格 */
    .cl-rank-head { padding: 18px 24px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 10px; }
    .cl-rank-head svg { width: 18px; height: 18px; fill: none; stroke: #6366f1; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .cl-rank-head h3 { font-size: 15px; font-weight: 700; color: #1e293b; margin: 0; }
    .cl-rank-body { padding: 0; }
    .cl-rank-table { width: 100%; border-collapse: collapse; }
    .cl-rank-table th {
        padding: 12px 16px; font-size: 11px; font-weight: 600; color: #94a3b8;
        text-align: left; background: #f8fafc; border-bottom: 1px solid #e8ecf1;
        text-transform: uppercase; letter-spacing: .5px;
    }
    .cl-rank-table td {
        padding: 12px 16px; font-size: 13px; color: #334155;
        border-bottom: 1px solid #f1f5f9; vertical-align: middle;
    }
    .cl-rank-table tr:last-child td { border-bottom: none; }
    .cl-rank-table tr:hover td { background: #fffbeb; }
    .cl-rank-table tr.cl-rank-me td { background: #fef3c7; font-weight: 600; }
    .cl-rank-num { text-align: center; width: 50px; font-size: 16px; }
    .cl-rank-name { font-weight: 600; color: #1e293b; }
    .cl-rank-score { font-weight: 700; color: #d97706; }
    .cl-rank-detail { font-size: 11px; color: #94a3b8; }
    .cl-rank-level { font-size: 12px; }

    .cl-empty { padding: 40px 20px; text-align: center; color: #94a3b8; font-size: 14px; }
</style>

<div class="cl-page">
    <!-- 当前等级 -->
    <div class="cl-hero">
        <div class="cl-hero-top">
            <div class="cl-hero-icon"><%= RenderIcon(myCreditLevelIcon, 44) %></div>
            <div class="cl-hero-info">
                <h2>Lv.<%= myCreditLevelNum %> <%= myCreditLevelName %></h2>
                <p>总学分：<strong><%= myAllscore %></strong> 分</p>
            </div>
        </div>
        <div class="cl-progress-wrap">
            <div class="cl-progress-labels">
                <span>当前 <%= myAllscore %> 分</span>
                <% if (myNextLevelScore > 0) { %>
                <span>下一级 <%= myNextLevelScore %> 分（还差 <%= myNextLevelScore - myAllscore %> 分）</span>
                <% } else { %>
                <span>已达最高等级</span>
                <% } %>
            </div>
            <div class="cl-progress-bar">
                <div class="cl-progress-fill" style="width:<%= myProgress.ToString("F0") %>%"></div>
            </div>
        </div>
    </div>

    <!-- 等级说明 -->
    <div class="cl-card">
        <div class="cl-levels-head">
            <svg viewBox="0 0 24 24"><path d="M12 20V10"/><path d="M18 20V4"/><path d="M6 20v-4"/></svg>
            <h3>学分等级说明</h3>
        </div>
        <div class="cl-levels-body">
            <div class="cl-level-list">
                <% for (int li = 0; li < levelNames.Length; li++) { %>
                <div class="cl-level-item <%= myCreditLevelNum==(li+1)?"cl-current":"" %>">
                    <div class="cl-level-icon"><%= RenderIcon(levelIcons[li], 32) %></div>
                    <div class="cl-level-name">Lv.<%= li+1 %> <%= levelNames[li] %></div>
                    <div class="cl-level-score"><%= thresholds[li] %> 分起</div>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- 班级排名 -->
    <div class="cl-card">
        <div class="cl-rank-head">
            <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
            <h3>班级学分排名</h3>
        </div>
        <div class="cl-rank-body">
            <% if (dtRanking != null && dtRanking.Rows.Count > 0) { %>
            <table class="cl-rank-table">
                <thead>
                    <tr><th style="width:50px;text-align:center">排名</th><th>姓名</th><th>总学分</th><th>学分构成</th><th>等级</th></tr>
                </thead>
                <tbody>
                <% int rank = 0;
                   foreach (System.Data.DataRow row in dtRanking.Rows) {
                       rank++;
                       int sid = Convert.ToInt32(row["Sid"]);
                       string sname = row["Sname"] == DBNull.Value ? "" : row["Sname"].ToString();
                       int allscore = row["Sallscore"] == DBNull.Value ? 0 : Convert.ToInt32(row["Sallscore"]);
                       int sscore = row["Sscore"] == DBNull.Value ? 0 : Convert.ToInt32(row["Sscore"]);
                       int swscore = row["Swscore"] == DBNull.Value ? 0 : Convert.ToInt32(row["Swscore"]);
                       int stscore = row["Stscore"] == DBNull.Value ? 0 : Convert.ToInt32(row["Stscore"]);
                       int slearnscore = row["Slearnscore"] == DBNull.Value ? 0 : Convert.ToInt32(row["Slearnscore"]);
                       bool isMe = (sid == mySid);
                %>
                    <tr class="<%= isMe ? "cl-rank-me" : "" %>">
                        <td class="cl-rank-num"><%= GetRankMedal(rank) %></td>
                        <td class="cl-rank-name"><%= Server.HtmlEncode(sname) %><%= isMe ? " (我)" : "" %></td>
                        <td class="cl-rank-score"><%= allscore %></td>
                        <td class="cl-rank-detail">课堂:<%= sscore %> 作品:<%= swscore %> 打字:<%= stscore %> 学习:<%= slearnscore %></td>
                        <td class="cl-rank-level"><%= GetLevelForScore(allscore) %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            <% } else { %>
            <div class="cl-empty">暂无排名数据</div>
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
    var h = document.querySelectorAll('.cl-hero-icon');
    for (var i=0;i<h.length;i++) fixIcon(h[i],44);
    var ic = document.querySelectorAll('.cl-level-icon');
    for (var i=0;i<ic.length;i++) fixIcon(ic[i],32);
    var c = document.querySelectorAll('.cl-rank-level');
    for (var i=0;i<c.length;i++) fixCell(c[i]);
})();
</script>
</asp:Content>
