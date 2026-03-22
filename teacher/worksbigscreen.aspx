<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Text" %>
<script runat="server">
    // ── 数据库连接 ───────────────────────────────────────────────────
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly
                .GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public |
                    System.Reflection.BindingFlags.NonPublic |
                    System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
            try { cs = System.Configuration.ConfigurationManager
                .ConnectionStrings["SqlServer"].ConnectionString; } catch { }
        if (!string.IsNullOrEmpty(cs) &&
            cs.ToLower().IndexOf("connect timeout") < 0 &&
            cs.ToLower().IndexOf("connection timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=8;";
        return cs;
    }

    // ── 页面数据 ─────────────────────────────────────────────────────
    private int  _grade, _cls, _cid;
    private string _courseTitle = "";
    private List<int>           _grades    = new List<int>();
    private List<int>           _classes   = new List<int>();
    private List<int[]>         _courses   = new List<int[]>(); // [cid, 0] + title in dict
    private Dictionary<int,string> _courseTitles = new Dictionary<int,string>();
    private List<string[]>      _students  = new List<string[]>(); // [snum, sname, sclass]
    private Dictionary<string,bool> _submitted = new Dictionary<string,bool>(StringComparer.OrdinalIgnoreCase);
    private int _total = 0, _submittedCount = 0, _notSubmitted = 0;
    private string _errMsg = "";
    private string _teacherName = "";
    private List<string[]> _listmenus = new List<string[]>(); // [lid, ltitle, ltype]

    protected void Page_Load(object sender, EventArgs e)
    {
        // 身份校验
        try
        {
            System.Web.HttpCookie tc = Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc == null || string.IsNullOrEmpty(tc.Value))
            { Response.Redirect("../teacher/login.aspx"); return; }
        }
        catch { }

        int.TryParse(Request.QueryString["grade"] ?? "", out _grade);
        int.TryParse(Request.QueryString["cls"]   ?? "", out _cls);
        int.TryParse(Request.QueryString["cid"]   ?? "", out _cid);

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) { _errMsg = "数据库连接失败"; return; }

        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // 年级列表
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT DISTINCT Sgrade FROM Students WHERE Sgrade>0 ORDER BY Sgrade", conn))
                {
                    cmd.CommandTimeout = 5;
                    using (SqlDataReader dr = cmd.ExecuteReader())
                        while (dr.Read()) _grades.Add(Convert.ToInt32(dr[0]));
                }

                if (_grade > 0)
                {
                    // 班级列表
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT DISTINCT Sclass FROM Students WHERE Sgrade=@g AND Sclass>0 ORDER BY Sclass", conn))
                    {
                        cmd.Parameters.AddWithValue("@g", _grade);
                        cmd.CommandTimeout = 5;
                        using (SqlDataReader dr = cmd.ExecuteReader())
                            while (dr.Read()) _classes.Add(Convert.ToInt32(dr[0]));
                    }

                    // 课程列表
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT Cid, ISNULL(Ctitle,N'(无标题)') FROM Courses WHERE Cobj=@g AND ISNULL(Cdelete,0)=0 ORDER BY Cid DESC", conn))
                    {
                        cmd.Parameters.AddWithValue("@g", _grade);
                        cmd.CommandTimeout = 5;
                        using (SqlDataReader dr = cmd.ExecuteReader())
                            while (dr.Read())
                            {
                                int cid = Convert.ToInt32(dr[0]);
                                string t = dr[1].ToString();
                                _courses.Add(new int[] { cid });
                                _courseTitles[cid] = t;
                            }
                    }

                    // 当前课程标题
                    if (_cid > 0 && _courseTitles.ContainsKey(_cid))
                        _courseTitle = _courseTitles[_cid];

                    // 课程教师 & 学案列表
                    if (_cid > 0)
                    {
                        // 教师姓名（优先显示昵称）
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT ISNULL(Hnick,Hname) FROM Teacher " +
                            "WHERE Hid=(SELECT TOP 1 Chid FROM Courses WHERE Cid=@cid)", conn))
                        {
                            cmd.Parameters.AddWithValue("@cid", _cid);
                            cmd.CommandTimeout = 5;
                            object r = cmd.ExecuteScalar();
                            if (r != null && r != DBNull.Value) _teacherName = r.ToString();
                        }
                        // 学案列表
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT Lid, ISNULL(Ltitle,N'(无标题)'), ISNULL(Ltype,0) " +
                            "FROM Listmenu WHERE Lcid=@cid AND ISNULL(Lshow,1)=1 ORDER BY Lsort, Lid", conn))
                        {
                            cmd.Parameters.AddWithValue("@cid", _cid);
                            cmd.CommandTimeout = 5;
                            using (SqlDataReader dr = cmd.ExecuteReader())
                                while (dr.Read())
                                    _listmenus.Add(new string[] {
                                        dr[0].ToString(), dr[1].ToString(), dr[2].ToString()
                                    });
                        }
                    }

                    // 学生列表
                    string stuSql = _cls > 0
                        ? "SELECT Snum, ISNULL(Sname,N''), Sclass FROM Students WHERE Sgrade=@g AND Sclass=@c ORDER BY Sclass, Snum"
                        : "SELECT Snum, ISNULL(Sname,N''), Sclass FROM Students WHERE Sgrade=@g ORDER BY Sclass, Snum";
                    using (SqlCommand cmd = new SqlCommand(stuSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@g", _grade);
                        if (_cls > 0) cmd.Parameters.AddWithValue("@c", _cls);
                        cmd.CommandTimeout = 8;
                        using (SqlDataReader dr = cmd.ExecuteReader())
                            while (dr.Read())
                                _students.Add(new string[] {
                                    dr[0].ToString(), dr[1].ToString(), dr[2].ToString()
                                });
                    }
                    _total = _students.Count;

                    // 已提交学生集合
                    if (_cid > 0)
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            @"SELECT DISTINCT Wnum FROM Works
                              WHERE Wlid IN (SELECT Lid FROM Listmenu WHERE Lcid=@cid)", conn))
                        {
                            cmd.Parameters.AddWithValue("@cid", _cid);
                            cmd.CommandTimeout = 8;
                            using (SqlDataReader dr = cmd.ExecuteReader())
                                while (dr.Read()) _submitted[dr[0].ToString()] = true;
                        }
                        // 只统计当前范围内学生的已交数
                        foreach (string[] s in _students)
                            if (_submitted.ContainsKey(s[0])) _submittedCount++;
                        _notSubmitted = _total - _submittedCount;
                    }
                }
            }
        }
        catch (Exception ex) { _errMsg = ex.Message; }
    }

    // 生成下拉跳转 URL
    private string GradeUrl(int g) { return "worksbigscreen.aspx?grade=" + g; }
    private string ClsUrl(int c)   { return "worksbigscreen.aspx?grade=" + _grade + "&cls=" + c; }
    private string CidUrl(int c)   { return "worksbigscreen.aspx?grade=" + _grade + (_cls>0?"&cls="+_cls:"") + "&cid=" + c; }

    private string Rate()
    {
        if (_total == 0) return "0";
        return Math.Round(_submittedCount * 100.0 / _total, 1).ToString("0.#");
    }
    private int RatePct()
    {
        if (_total == 0) return 0;
        int v = (int)Math.Round(_submittedCount * 100.0 / _total);
        return Math.Min(100, v);
    }

    private string HtmlEnc(string s) { return System.Web.HttpUtility.HtmlEncode(s ?? ""); }
    private string JsStr(string s)
    {
        return (s ?? "").Replace("\\","\\\\").Replace("'","\\'").Replace("\r","").Replace("\n","\\n");
    }
</script><!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>作业提交大屏</title>
<style>
  *,*::before,*::after { box-sizing: border-box; margin: 0; padding: 0; }
  html, body { height: 100%; background: #f1f5f9; color: #1e293b;
    font-family: 'Microsoft YaHei', 'PingFang SC', sans-serif; }

  /* ── 顶部栏 ── */
  .bs-header {
    display: flex; align-items: center; gap: 18px; flex-wrap: wrap;
    padding: 14px 28px;
    background: #fff;
    border-bottom: 1px solid #e2e8f0;
    box-shadow: 0 1px 4px rgba(0,0,0,0.06);
    position: sticky; top: 0; z-index: 100;
  }
  .bs-logo { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
  .bs-logo-icon {
    width: 38px; height: 38px; border-radius: 10px;
    background: linear-gradient(135deg, #6366f1, #818cf8);
    display: flex; align-items: center; justify-content: center; flex-shrink: 0;
  }
  .bs-logo-icon svg { width: 18px; height: 18px; stroke: #fff; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
  .bs-title { font-size: 17px; font-weight: 700; color: #1e293b; white-space: nowrap; }
  .bs-subtitle { font-size: 11px; color: #94a3b8; margin-top: 1px; }

  .bs-dropdowns { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; flex: 1; }
  .bs-ddl-group { display: flex; align-items: center; gap: 5px; }
  .bs-ddl-label { font-size: 12px; color: #64748b; font-weight: 500; white-space: nowrap; }
  .bs-ddl-group select {
    height: 32px; padding: 0 10px;
    border: 1px solid #d1d5db; border-radius: 7px;
    background: #fff; color: #334155; font-size: 13px;
    cursor: pointer; outline: none; transition: border-color .18s, box-shadow .18s;
    min-width: 88px;
  }
  .bs-ddl-group select:hover { border-color: #818cf8; }
  .bs-ddl-group select:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.12); }

  /* ── 右侧信息区 ── */
  .bs-header-right { margin-left: auto; display: flex; align-items: center; gap: 16px; flex-shrink: 0; }
  .bs-clock {
    display: flex; flex-direction: column; align-items: flex-end; gap: 1px;
  }
  .bs-clock-time {
    font-size: 15px; font-weight: 700; color: #334155; font-variant-numeric: tabular-nums;
    letter-spacing: 0.5px;
  }
  .bs-clock-label { font-size: 10px; color: #94a3b8; }

  /* ── 倒计时圆环 ── */
  .bs-countdown {
    position: relative; width: 52px; height: 52px;
    cursor: pointer; flex-shrink: 0; user-select: none;
  }
  .bs-countdown:hover .countdown-arc { stroke: #4f46e5; }
  .bs-countdown:hover .countdown-num { color: #4f46e5; }
  .countdown-svg {
    width: 52px; height: 52px;
    transform: rotate(-90deg);
    display: block;
  }
  .countdown-track {
    fill: none; stroke: #e2e8f0; stroke-width: 3.5;
  }
  .countdown-arc {
    fill: none; stroke: #6366f1; stroke-width: 3.5;
    stroke-linecap: round;
    stroke-dasharray: 119.38;
    stroke-dashoffset: 0;
    transition: stroke-dashoffset 1s linear, stroke .15s;
  }
  .countdown-center {
    position: absolute; inset: 0;
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    gap: 0;
  }
  .countdown-num {
    font-size: 14px; font-weight: 800; color: #6366f1; line-height: 1;
    font-variant-numeric: tabular-nums; transition: color .15s;
  }
  .countdown-hint { font-size: 8px; color: #94a3b8; margin-top: 1px; }

  /* ── 课程信息横幅 ── */
  .bs-info-banner {
    display: flex; align-items: flex-start; flex-wrap: wrap; gap: 0;
    background: #faf5ff; border-bottom: 1px solid #e9d5ff;
    padding: 8px 28px;
  }
  .info-item {
    display: flex; align-items: flex-start; gap: 8px;
    padding: 5px 20px 5px 0; border-right: 1px solid #e9d5ff;
    margin-right: 20px;
  }
  .info-item:last-child { border-right: none; }
  .info-icon {
    width: 28px; height: 28px; border-radius: 7px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center;
    background: #ede9fe;
  }
  .info-icon svg { width: 14px; height: 14px; stroke: #7c3aed; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
  .info-label { font-size: 10px; color: #94a3b8; margin-bottom: 2px; }
  .info-value { font-size: 13px; font-weight: 700; color: #4c1d95; max-width: 320px;
    overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .info-lm-tags { display: flex; flex-wrap: wrap; gap: 4px; max-width: 600px; }
  .lm-tag {
    display: inline-flex; align-items: center; gap: 4px;
    padding: 2px 8px; border-radius: 5px; font-size: 11px; font-weight: 600;
    background: #ede9fe; border: 1px solid #ddd6fe; color: #5b21b6; white-space: nowrap;
  }
  .lm-tag::before { content: ''; display: inline-block; width: 5px; height: 5px;
    border-radius: 50%; background: #7c3aed; flex-shrink: 0; }

  /* ── 统计卡片 ── */
  .bs-stats { display: flex; gap: 14px; padding: 18px 28px 0; flex-wrap: wrap; }
  .bs-stat-card {
    flex: 1; min-width: 155px;
    background: #fff; border: 1px solid #e2e8f0;
    border-radius: 14px; padding: 16px 20px;
    display: flex; align-items: center; gap: 14px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    position: relative; overflow: hidden;
  }
  .bs-stat-card::after {
    content: ''; position: absolute; left: 0; top: 0; bottom: 0;
    width: 4px; border-radius: 14px 0 0 14px;
    background: var(--accent-color);
  }
  .bs-stat-card.card-s   { --accent-color: #10b981; }
  .bs-stat-card.card-ns  { --accent-color: #ef4444; }
  .bs-stat-card.card-total { --accent-color: #38bdf8; }
  .bs-stat-icon {
    width: 42px; height: 42px; border-radius: 10px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center;
  }
  .bs-stat-icon svg { width: 20px; height: 20px; stroke: #fff; fill: none;
    stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
  .card-s     .bs-stat-icon { background: linear-gradient(135deg, #059669, #10b981); }
  .card-ns    .bs-stat-icon { background: linear-gradient(135deg, #dc2626, #ef4444); }
  .card-total .bs-stat-icon { background: linear-gradient(135deg, #0284c7, #38bdf8); }
  .bs-stat-body { flex: 1; min-width: 0; }
  .bs-stat-label { font-size: 11px; color: #94a3b8; font-weight: 500; margin-bottom: 4px; text-transform: uppercase; letter-spacing: 0.3px; }
  .bs-stat-value { font-size: 30px; font-weight: 800; line-height: 1; color: #1e293b;
    font-variant-numeric: tabular-nums; }
  .card-s  .bs-stat-value { color: #059669; }
  .card-ns .bs-stat-value { color: #dc2626; }
  .bs-stat-unit { font-size: 13px; color: #94a3b8; font-weight: 500; margin-left: 2px; }

  /* 进度条卡片 */
  .card-progress {
    flex: 2; min-width: 260px;
    background: #fff; border: 1px solid #e2e8f0;
    border-radius: 14px; padding: 16px 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  }
  .prog-label { font-size: 12px; color: #64748b; font-weight: 600; margin-bottom: 10px;
    display: flex; justify-content: space-between; align-items: center; }
  .prog-label span { font-size: 20px; font-weight: 800; color: #1e293b; }
  .prog-track { height: 10px; background: #f1f5f9; border-radius: 5px; overflow: hidden; }
  .prog-fill {
    height: 100%; border-radius: 5px;
    background: linear-gradient(90deg, #059669, #10b981);
    transition: width .6s cubic-bezier(.4,0,.2,1);
  }
  .prog-fill.prog-warn { background: linear-gradient(90deg, #d97706, #f59e0b); }
  .prog-fill.prog-low  { background: linear-gradient(90deg, #dc2626, #ef4444); }
  .prog-info { font-size: 11px; color: #94a3b8; margin-top: 7px;
    display: flex; justify-content: space-between; }

  /* ── 空状态 / 提示 ── */
  .bs-hint {
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    gap: 14px; padding: 60px 28px; text-align: center;
  }
  .bs-hint svg { width: 52px; height: 52px; stroke: #cbd5e1; fill: none;
    stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }
  .bs-hint-title { font-size: 18px; color: #64748b; font-weight: 600; }
  .bs-hint-desc  { font-size: 13px; color: #94a3b8; }

  /* ── 学生卡片网格 ── */
  .bs-grid-section { padding: 18px 28px 28px; }
  .bs-grid-bar {
    display: flex; align-items: center; gap: 12px; margin-bottom: 14px; flex-wrap: wrap;
  }
  .bs-grid-bar h3 { font-size: 13px; font-weight: 600; color: #64748b; }
  .bs-legend { display: flex; align-items: center; gap: 12px; font-size: 12px; color: #94a3b8; margin-left: auto; }
  .bs-legend-dot { width: 9px; height: 9px; border-radius: 50%; display: inline-block; }
  .ld-s  { background: #10b981; }
  .ld-ns { background: #cbd5e1; }

  .bs-grid { display: flex; flex-wrap: wrap; gap: 8px; }

  .stu-card {
    width: 96px; padding: 10px 8px 8px; border-radius: 10px;
    border: 1.5px solid #e2e8f0; text-align: center;
    background: #fff;
    transition: transform .18s, box-shadow .18s;
    cursor: default; position: relative;
    box-shadow: 0 1px 2px rgba(0,0,0,0.04);
  }
  .stu-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }

  .stu-card.sc-s {
    background: #f0fdf4; border-color: #86efac;
    box-shadow: 0 1px 3px rgba(16,185,129,0.08);
  }
  .stu-card.sc-ns {
    background: #f8fafc; border-color: #e2e8f0;
  }
  .stu-card.sc-nodata {
    background: #f8fafc; border-color: #e2e8f0; opacity: .85;
  }

  .stu-avatar {
    width: 36px; height: 36px; border-radius: 50%; margin: 0 auto 6px;
    display: flex; align-items: center; justify-content: center;
    font-size: 15px; font-weight: 700; line-height: 1;
  }
  .sc-s  .stu-avatar { background: #dcfce7; color: #16a34a; }
  .sc-ns .stu-avatar { background: #f1f5f9; color: #94a3b8; }
  .sc-nodata .stu-avatar { background: #f1f5f9; color: #94a3b8; }

  .stu-name {
    font-size: 12px; font-weight: 600; color: #1e293b;
    overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
    max-width: 80px; margin: 0 auto;
  }
  .sc-ns .stu-name, .sc-nodata .stu-name { color: #64748b; }

  .stu-class { font-size: 10px; color: #94a3b8; margin-top: 2px; }
  .sc-s .stu-class { color: #22c55e; }

  .stu-badge {
    position: absolute; top: 5px; right: 6px;
    width: 15px; height: 15px; border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
  }
  .sc-s  .stu-badge { background: #16a34a; }
  .sc-ns .stu-badge { background: #e2e8f0; }
  .stu-badge svg { width: 8px; height: 8px; stroke: #fff; fill: none;
    stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; }
  .sc-ns .stu-badge svg { stroke: #94a3b8; }

  /* ── 错误信息 ── */
  .bs-err { padding: 24px 28px; color: #ef4444; font-size: 14px; }

  /* ── 布局骨架 ── */
  body { display: flex; flex-direction: column; min-height: 100vh; }
  .bs-body { display: flex; flex-direction: column; flex: 1; }
  .bs-scroll { flex: 1; overflow-y: auto; }
</style>
</head>
<body>

<div class="bs-body">
<!-- ── 顶部栏 ─────────────────────────────────────────────────── -->
<div class="bs-header">
  <div class="bs-logo">
    <div class="bs-logo-icon">
      <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
    </div>
    <div>
      <div class="bs-title">作业提交大屏</div>
      <div class="bs-subtitle">学生作业统计实时展示</div>
    </div>
  </div>

  <div class="bs-dropdowns">
    <!-- 年级下拉 -->
    <div class="bs-ddl-group">
      <span class="bs-ddl-label">年级</span>
      <select id="selGrade" onchange="navGrade(this.value)">
        <option value="">-- 请选择 --</option>
        <%  foreach (int g in _grades) { %>
        <option value="<%=g%>" <%=(_grade==g?"selected":"")%>><%=g%>年级</option>
        <% } %>
      </select>
    </div>

    <% if (_grade > 0 && _classes.Count > 0) { %>
    <!-- 班级下拉 -->
    <div class="bs-ddl-group">
      <span class="bs-ddl-label">班级</span>
      <select id="selCls" onchange="navCls(this.value)">
        <option value="">全部班级</option>
        <% foreach (int c in _classes) { %>
        <option value="<%=c%>" <%=(_cls==c?"selected":"")%>><%=c%>班</option>
        <% } %>
      </select>
    </div>
    <% } %>

    <% if (_grade > 0 && _courses.Count > 0) { %>
    <!-- 课程下拉 -->
    <div class="bs-ddl-group">
      <span class="bs-ddl-label">课程</span>
      <select id="selCid" onchange="navCid(this.value)">
        <option value="">-- 请选择课程 --</option>
        <% foreach (int[] c in _courses) { int cid = c[0]; %>
        <option value="<%=cid%>" <%=(_cid==cid?"selected":"")%>><%=HtmlEnc(_courseTitles.ContainsKey(cid)?_courseTitles[cid]:"")%></option>
        <% } %>
      </select>
    </div>
    <% } %>
  </div>

  <div class="bs-header-right">
    <div class="bs-clock">
      <span class="bs-clock-time" id="clockSpan"></span>
      <span class="bs-clock-label">当前时间</span>
    </div>
    <!-- 倒计时圆环 — r=19 周长≈119.38 -->
    <div class="bs-countdown" id="countdownBtn" onclick="manualRefresh()" title="30秒自动刷新，点击立即刷新">
      <svg class="countdown-svg" viewBox="0 0 52 52">
        <circle class="countdown-track" cx="26" cy="26" r="19"/>
        <circle class="countdown-arc" cx="26" cy="26" r="19" id="progressCircle"
          style="stroke-dasharray:119.38;stroke-dashoffset:0;"/>
      </svg>
      <div class="countdown-center">
        <span class="countdown-num" id="countdownNum">30</span>
        <span class="countdown-hint">秒</span>
      </div>
    </div>
  </div>
</div>

<% if (_cid > 0) { %>
<!-- ── 课程信息横幅 ────────────────────────────────────────────── -->
<div class="bs-info-banner">
  <% if (!string.IsNullOrEmpty(_courseTitle)) { %>
  <div class="info-item">
    <div class="info-icon"><svg viewBox="0 0 24 24"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg></div>
    <div>
      <div class="info-label">课程名称</div>
      <div class="info-value"><%=HtmlEnc(_courseTitle)%></div>
    </div>
  </div>
  <% } %>
  <% if (!string.IsNullOrEmpty(_teacherName)) { %>
  <div class="info-item">
    <div class="info-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
    <div>
      <div class="info-label">任课教师</div>
      <div class="info-value"><%=HtmlEnc(_teacherName)%></div>
    </div>
  </div>
  <% } %>
  <% if (_listmenus.Count > 0) { %>
  <div class="info-item">
    <div class="info-icon"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg></div>
    <div>
      <div class="info-label">学案（共<%=_listmenus.Count%>个）</div>
      <div class="info-lm-tags">
        <% foreach (string[] lm in _listmenus) { %>
        <span class="lm-tag"><%=HtmlEnc(lm[1])%></span>
        <% } %>
      </div>
    </div>
  </div>
  <% } %>
</div>
<% } %>

<div class="bs-scroll">
  <% if (!string.IsNullOrEmpty(_errMsg)) { %>
  <div class="bs-err">错误：<%=HtmlEnc(_errMsg)%></div>
  <% } else if (_grade <= 0) { %>

  <!-- 未选年级提示 -->
  <div class="bs-hint">
    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <div class="bs-hint-title">请选择年级</div>
    <div class="bs-hint-desc">在顶部选择年级，可进一步筛选班级和课程</div>
  </div>

  <% } else { %>

  <!-- ── 统计卡片 ── -->
  <% if (_cid > 0) { %>
  <div class="bs-stats">
    <div class="bs-stat-card card-total">
      <div class="bs-stat-icon"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
      <div class="bs-stat-body">
        <div class="bs-stat-label">应交人数</div>
        <div class="bs-stat-value"><%=_total%><span class="bs-stat-unit">人</span></div>
      </div>
    </div>
    <div class="bs-stat-card card-s">
      <div class="bs-stat-icon"><svg viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div>
      <div class="bs-stat-body">
        <div class="bs-stat-label">已交人数</div>
        <div class="bs-stat-value"><%=_submittedCount%><span class="bs-stat-unit">人</span></div>
      </div>
    </div>
    <div class="bs-stat-card card-ns">
      <div class="bs-stat-icon"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg></div>
      <div class="bs-stat-body">
        <div class="bs-stat-label">未交人数</div>
        <div class="bs-stat-value"><%=_notSubmitted%><span class="bs-stat-unit">人</span></div>
      </div>
    </div>
    <div class="card-progress">
      <div class="prog-label">提交进度<span><%=Rate()%>%</span></div>
      <div class="prog-track">
        <div class="prog-fill <%=(RatePct()<40?"prog-low":RatePct()<70?"prog-warn":"")%>" style="width:<%=RatePct()%>%;"></div>
      </div>
      <div class="prog-info"><%=_submittedCount%> / <%=_total%> 人已提交</div>
    </div>
  </div>
  <% } else { %>
  <!-- 未选课程时，只显示简要提示 -->
  <div style="padding:14px 28px 0;font-size:13px;color:#64748b;">
    共 <strong style="color:#334155;"><%=_total%></strong> 名学生
    <% if (_cls>0) { %>（<%=_cls%>班）<% } %>
    &nbsp;·&nbsp; 请在顶部选择课程以查看提交情况
  </div>
  <% } %>

  <!-- ── 学生卡片网格 ── -->
  <div class="bs-grid-section">
    <div class="bs-grid-bar">
      <h3>学生列表（<%=_total%>人）
        <% if(_cls>0){%>· <%=_cls%>班<% } %>
        <% if(!string.IsNullOrEmpty(_courseTitle)){%>· <%=HtmlEnc(_courseTitle)%><% } %>
      </h3>
      <% if (_cid > 0) { %>
      <div class="bs-legend">
        <span><span class="bs-legend-dot ld-s"></span> 已提交</span>
        <span><span class="bs-legend-dot ld-ns"></span> 未提交</span>
      </div>
      <% } %>
    </div>

    <% if (_students.Count == 0) { %>
    <div class="bs-hint">
      <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
      <div class="bs-hint-title">暂无学生数据</div>
      <div class="bs-hint-desc">该年级/班级下没有学生记录</div>
    </div>
    <% } else { %>
    <div class="bs-grid">
      <% foreach (string[] s in _students) {
           string snum = s[0], sname = s[1], scls = s[2];
           bool submitted = (_cid > 0) && _submitted.ContainsKey(snum);
           bool nodata    = (_cid <= 0);
           string cardCls = nodata ? "sc-nodata" : (submitted ? "sc-s" : "sc-ns");
           string firstChar = sname.Length > 0 ? sname.Substring(0,1) : "?";
      %>
      <div class="stu-card <%=cardCls%>" title="<%=HtmlEnc(sname)%>（<%=scls%>班）<%=(submitted?" · 已提交":"")%>">
        <% if (_cid > 0) { %>
        <div class="stu-badge">
          <% if (submitted) { %><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
          <% } else { %><svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg><% } %>
        </div>
        <% } %>
        <div class="stu-avatar"><%=HtmlEnc(firstChar)%></div>
        <div class="stu-name"><%=HtmlEnc(sname)%></div>
        <div class="stu-class"><%=scls%>班</div>
      </div>
      <% } %>
    </div>
    <% } %>
  </div>

  <% } // end if grade>0 %>
</div><!-- .bs-scroll -->
</div><!-- .bs-body -->

<script>
// ── 导航 ─────────────────────────────────────────────────────────────
var _grade = <%=_grade%>, _cls = <%=_cls%>, _cid = <%=_cid%>;
function navGrade(g) { location.href = 'worksbigscreen.aspx?grade=' + encodeURIComponent(g); }
function navCls(c)   { location.href = 'worksbigscreen.aspx?grade=' + _grade + (c?'&cls='+c:''); }
function navCid(c)   { location.href = 'worksbigscreen.aspx?grade=' + _grade + (_cls?'&cls='+_cls:'') + (c?'&cid='+c:''); }

// ── 自动刷新（30秒）────────────────────────────────────────────────
var REFRESH_SEC = 30;
var _remain = REFRESH_SEC;
var _timer = null;
var _circle = document.getElementById('progressCircle');
var _numEl  = document.getElementById('countdownNum');
var _CIRC   = 119.38; // 2π×19

function updateProgress() {
  // 圆弧从满到空：offset 从 0 → _CIRC
  var offset = _CIRC * (1 - _remain / REFRESH_SEC);
  if (_circle) _circle.style.strokeDashoffset = offset.toFixed(2);
  if (_numEl)  _numEl.textContent = _remain;
  // 颜色：剩余 ≤8 秒变橙，≤3 秒变红
  var color = _remain <= 3 ? '#ef4444' : _remain <= 8 ? '#f59e0b' : '#6366f1';
  if (_circle) _circle.style.stroke = color;
  if (_numEl)  _numEl.style.color   = color;
}
function startRefresh() {
  clearInterval(_timer);
  _remain = REFRESH_SEC;
  updateProgress();
  _timer = setInterval(function () {
    _remain--;
    updateProgress();
    if (_remain <= 0) { clearInterval(_timer); location.reload(); }
  }, 1000);
}
function manualRefresh() { clearInterval(_timer); location.reload(); }
startRefresh();

// ── 时钟 ─────────────────────────────────────────────────────────────
function updateClock() {
  var d = new Date();
  var hh = d.getHours().toString().padStart(2,'0');
  var mm = d.getMinutes().toString().padStart(2,'0');
  var ss = d.getSeconds().toString().padStart(2,'0');
  var clk = document.getElementById('clockSpan');
  if (clk) clk.textContent = hh + ':' + mm + ':' + ss;
}
updateClock();
setInterval(updateClock, 1000);
</script>
</body>
</html>
