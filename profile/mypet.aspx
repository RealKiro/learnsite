<%@ Page Title="" Language="C#" MasterPageFile="~/profile/Pf.master" AutoEventWireup="true" %>

<script runat="server">
    protected int pSid = 0;
    protected int pAvailablePoints = 0;

    private string GetConnStr()
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
        LoadStudent();
        LoadPoints();
    }

    protected string GetPetImagesJson()
    {
        string[] petIds = { "cat", "dog", "rabbit", "fox", "panda", "frog", "tiger", "bird" };
        string[] exts   = { ".png", ".jpg", ".jpeg", ".gif", ".webp" };
        System.Text.StringBuilder sb = new System.Text.StringBuilder("{");
        bool firstPet = true;
        foreach (string petId in petIds)
        {
            System.Text.StringBuilder tierParts = new System.Text.StringBuilder();
            bool firstTier = true;
        for (int tier = 0; tier <= 4; tier++)
            {
                foreach (string ext in exts)
                {
                    string fname = petId + "_lv" + tier.ToString() + ext;
                    string fpath = Server.MapPath("~/images/pets/" + fname);
                    if (System.IO.File.Exists(fpath))
                    {
                        string url = ResolveUrl("~/images/pets/" + fname)
                                     + "?v=" + System.IO.File.GetLastWriteTime(fpath).Ticks.ToString();
                        if (!firstTier) tierParts.Append(",");
                        tierParts.Append("\"" + tier.ToString() + "\":\"" + url + "\"");
                        firstTier = false;
                        break;
                    }
                }
            }
            if (tierParts.Length > 0)
            {
                if (!firstPet) sb.Append(",");
                sb.Append("\"" + petId + "\":{" + tierParts.ToString() + "}");
                firstPet = false;
            }
        }
        sb.Append("}");
        return sb.ToString();
    }

    protected string GetPetStagesJson()
    {
        string fpath = Server.MapPath("~/App_Data/petstages.json");
        try {
            if (System.IO.File.Exists(fpath))
                return System.IO.File.ReadAllText(fpath, System.Text.Encoding.UTF8);
        } catch {}
        return "{\"stageExp\":[100,200,300,400,500,600,700]}";
    }

    protected string GetCostumeSettingsJson()
    {
        string fpath = Server.MapPath("~/App_Data/petcostumes.json");
        try {
            if (System.IO.File.Exists(fpath))
                return System.IO.File.ReadAllText(fpath, System.Text.Encoding.UTF8);
        } catch {}
        return "{\"costumes\":[]}";
    }

    protected string GetCostumeImagesJson()
    {
        string[] ids  = { "costume_sunglasses","costume_hat","costume_bow","costume_star","costume_ghost","costume_crown","costume_wings" };
        string[] exts = { ".png",".jpg",".jpeg",".gif",".webp" };
        System.Text.StringBuilder sb = new System.Text.StringBuilder("{");
        bool first = true;
        foreach (string id in ids)
        {
            foreach (string ext in exts)
            {
                string fpath = Server.MapPath("~/images/costumes/" + id + ext);
                if (System.IO.File.Exists(fpath))
                {
                    string url = ResolveUrl("~/images/costumes/" + id + ext)
                                 + "?v=" + System.IO.File.GetLastWriteTime(fpath).Ticks.ToString();
                    if (!first) sb.Append(",");
                    sb.Append("\"" + id + "\":\"" + url + "\"");
                    first = false;
                    break;
                }
            }
        }
        sb.Append("}");
        return sb.ToString();
    }

    private void LoadStudent()
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
                    if (!string.IsNullOrEmpty(sidStr)) int.TryParse(sidStr, out pSid);
                }
            }
        }
        catch { }
    }

    private void LoadPoints()
    {
        if (pSid <= 0) return;
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                int total = 0, used = 0;
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(Sallscore, 0) FROM Students WHERE Sid=@sid", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", pSid);
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) total = Convert.ToInt32(r);
                }
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT ISNULL(SUM(ISNULL(Epoints,0)),0) FROM BadgeExchange WHERE Esid=@sid AND Estatus IN (0,1)", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", pSid);
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) used = Convert.ToInt32(r);
                }
                pAvailablePoints = total - used;
                if (pAvailablePoints < 0) pAvailablePoints = 0;
            }
        }
        catch { }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cstu" runat="Server">
<style>
    .petp-page { animation: petpFade .35s ease; }
    @keyframes petpFade { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    .petp-head {
        background: linear-gradient(135deg,#6366f1,#8b5cf6,#ec4899);
        border-radius: 16px; padding: 24px 28px; color: #fff;
        box-shadow: 0 8px 28px rgba(99,102,241,.25);
        margin-bottom: 18px;
    }
    .petp-head-title { font-size: 22px; font-weight: 800; margin-bottom: 6px; }
    .petp-head-sub { font-size: 13px; opacity: .88; }
    .petp-points {
        margin-top: 14px; display: inline-flex; align-items: center; gap: 8px;
        background: rgba(255,255,255,.18); border: 1px solid rgba(255,255,255,.3);
        padding: 7px 14px; border-radius: 999px; font-size: 13px; font-weight: 600;
    }

    .petp-grid { display: grid; grid-template-columns: 1.2fr .8fr; gap: 16px; margin-bottom: 18px; }
    .petp-card {
        background: #fff; border-radius: 14px; border: 1px solid #e5e7eb;
        box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden;
    }
    .petp-card-hd {
        padding: 14px 18px; border-bottom: 1px solid #f1f5f9;
        font-size: 14px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 8px;
        background: #fafbfc;
    }
    .petp-card-hd svg { width: 16px; height: 16px; stroke: #6366f1; fill: none; stroke-width: 2; }
    .petp-card-bd { padding: 18px; }

    .petp-tabs { display: flex; gap: 6px; margin-bottom: 16px; flex-wrap: wrap; }
    .petp-tab {
        border: 1px solid #e5e7eb; background: #fff; color: #64748b;
        font-size: 13px; font-weight: 600; border-radius: 10px; padding: 8px 14px; cursor: pointer;
        transition: all .15s;
    }
    .petp-tab:hover { border-color: #c7d2fe; color: #4f46e5; background: #f8faff; }
    .petp-tab.active { background: #eef2ff; border-color: #c7d2fe; color: #4f46e5; }
    .petp-panel { display: none; }
    .petp-panel.active { display: block; }

    .petp-empty {
        text-align: center; padding: 32px 16px; border: 1px dashed #dbe2ea; border-radius: 12px; background: #fbfdff;
    }
    .petp-empty .e1 { width: 48px; height: 48px; margin: 0 auto 8px; color: #6366f1; }
    .petp-empty .e1 svg { width: 100%; height: 100%; stroke: currentColor; fill: none; stroke-width: 2; }
    .petp-empty .e2 { font-size: 14px; color: #64748b; margin-bottom: 12px; }

    .petp-adopt-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
    .petp-adopt-item {
        border: 1px solid #e5e7eb; border-radius: 10px; padding: 12px 8px; text-align: center; cursor: pointer;
        transition: all .15s; background: #fff;
    }
    .petp-adopt-item:hover { border-color: #c7d2fe; transform: translateY(-1px); box-shadow: 0 3px 10px rgba(99,102,241,.1); }
    .petp-adopt-emoji { width: 34px; height: 34px; margin: 0 auto 8px; color: #6366f1; }
    .petp-adopt-emoji svg { width: 100%; height: 100%; stroke: currentColor; fill: none; stroke-width: 2; }
    .petp-adopt-name { font-size: 12px; color: #334155; font-weight: 600; }

    .petp-main { display: grid; grid-template-columns: 240px 1fr; gap: 16px; }
    .petp-petbox {
        border-radius: 12px; border: 1px solid #e5e7eb; background: #fff; padding: 14px; text-align: center;
    }
    .petp-pet-emoji { width: 90px; height: 90px; margin: 10px auto; position: relative; color: #6366f1; }
    .petp-pet-emoji .pet-base-svg { width: 100%; height: 100%; stroke: currentColor; fill: none; stroke-width: 2; }
    .petp-pet-emoji .pet-wear-svg { width: 34px; height: 34px; position: absolute; right: -4px; top: -4px; color: #ec4899; }
    .petp-pet-emoji .pet-wear-svg svg { width: 100%; height: 100%; stroke: currentColor; fill: none; stroke-width: 2; }
    .petp-pet-name { font-size: 18px; font-weight: 700; color: #1e293b; }
    .petp-level { margin-top: 6px; font-size: 12px; color: #6366f1; font-weight: 700; }
    .petp-exp { margin-top: 8px; }
    .petp-exp-bar { height: 8px; background: #eef2f7; border-radius: 999px; overflow: hidden; }
    .petp-exp-fill { height: 100%; background: linear-gradient(90deg,#f59e0b,#fbbf24); }
    .petp-exp-text { margin-top: 5px; font-size: 11px; color: #94a3b8; }

    .petp-stats { display: grid; gap: 10px; }
    .petp-stat { display: grid; grid-template-columns: 44px 1fr 34px; align-items: center; gap: 8px; }
    .petp-stat .lbl { font-size: 12px; color: #64748b; }
    .petp-stat .bar { height: 8px; background: #eef2f7; border-radius: 999px; overflow: hidden; }
    .petp-stat .fill { height: 100%; }
    .petp-stat .v { text-align: right; font-size: 12px; color: #334155; font-weight: 700; }
    .f-hp { background: linear-gradient(90deg,#10b981,#34d399); }
    .f-clean { background: linear-gradient(90deg,#06b6d4,#22d3ee); }
    .f-mood { background: linear-gradient(90deg,#8b5cf6,#a78bfa); }
    .f-food { background: linear-gradient(90deg,#f59e0b,#fbbf24); }

    .petp-actions { display: grid; grid-template-columns: repeat(4,1fr); gap: 8px; margin-top: 12px; }
    .petp-btn {
        border: 1px solid #e5e7eb; background: #fff; color: #475569; border-radius: 10px; padding: 8px 10px;
        font-size: 12px; font-weight: 600; cursor: pointer; transition: all .15s;
    }
    .petp-btn:hover { border-color: #c7d2fe; color: #4f46e5; background: #f8faff; }
    .petp-btn.main { background: linear-gradient(135deg,#6366f1,#818cf8); border-color: transparent; color: #fff; }
    .petp-btn.main:hover { box-shadow: 0 3px 10px rgba(99,102,241,.3); }
    .petp-btn svg { width: 13px; height: 13px; stroke: currentColor; fill: none; stroke-width: 2; vertical-align: middle; margin-right: 3px; }
    .petp-cost { font-size: 10px; opacity: .68; margin-left: 3px; font-weight: 500; }

    .petp-shop-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 10px; }
    .petp-item {
        border: 1px solid #e5e7eb; border-radius: 10px; padding: 12px; background: #fff; transition: all .15s;
    }
    .petp-item:hover { border-color: #c7d2fe; box-shadow: 0 3px 10px rgba(99,102,241,.08); }
    .petp-item-top { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
    .petp-item-icon { width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center; justify-content: center; background: #f8fafc; color:#6366f1; }
    .petp-item-icon svg { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; }
    .petp-item-name { font-size: 13px; font-weight: 700; color: #1e293b; }
    .petp-item-desc { font-size: 12px; color: #64748b; min-height: 32px; }
    .petp-item-bottom { margin-top: 8px; display: flex; align-items: center; justify-content: space-between; }
    .petp-price { font-size: 12px; font-weight: 700; color: #ec4899; }

    .petp-bag-list { display: grid; gap: 8px; }
    .petp-bag-row {
        border: 1px solid #e5e7eb; border-radius: 10px; padding: 10px 12px;
        display: flex; align-items: center; justify-content: space-between; gap: 10px;
    }
    .petp-bag-left { display: flex; align-items: center; gap: 8px; }
    .petp-bag-name { font-size: 13px; font-weight: 700; color: #334155; }
    .petp-bag-qty { font-size: 12px; color: #94a3b8; }

    /* === 换装专区 === */
    .petp-cst-layout { display: grid; grid-template-columns: 210px 1fr; gap: 16px; align-items: start; }
    .petp-preview-bd { display: flex; flex-direction: column; align-items: center; gap: 12px; padding: 20px 16px; }
    .petp-preview-fig {
        width: 124px; height: 124px; position: relative;
        background: linear-gradient(135deg, #f0f2ff, #ede9fe);
        border-radius: 20px; border: 2px solid #e0e4ff;
        display: flex; align-items: center; justify-content: center;
    }
    .petp-preview-fig .pet-base { width: 84px; height: 84px; color: #6366f1; }
    .petp-preview-fig .pet-base svg { width: 100%; height: 100%; stroke: currentColor; fill: none; stroke-width: 2; }
    .petp-preview-fig .pet-base img { width: 100%; height: 100%; object-fit: contain; border-radius: 10px; }
    .pet-cst-badge {
        position: absolute; top: -8px; right: -8px;
        width: 38px; height: 38px; border-radius: 50%;
        background: linear-gradient(135deg, #ec4899, #f472b6);
        display: flex; align-items: center; justify-content: center;
        box-shadow: 0 2px 10px rgba(236,72,153,.4); border: 2px solid #fff; color: #fff;
    }
    .pet-cst-badge svg { width: 18px; height: 18px; stroke: currentColor; fill: none; stroke-width: 2; }
    .petp-wear-lbl { font-size: 11px; color: #94a3b8; font-weight: 600; letter-spacing: .5px; }
    .petp-wear-name {
        font-size: 13px; font-weight: 700; color: #4f46e5;
        padding: 5px 14px; border-radius: 999px; width: 100%; text-align: center;
        background: #eef2ff; border: 1px solid #e0e7ff;
    }
    .petp-no-wear { font-size: 12px; color: #94a3b8; text-align: center; padding: 4px 0; }
    .petp-undress-btn {
        width: 100%; height: 36px; border-radius: 10px;
        border: 1.5px dashed #fca5a5; background: #fff5f5; color: #ef4444;
        font-size: 12px; font-weight: 600; cursor: pointer; font-family: inherit; transition: all .15s;
    }
    .petp-undress-btn:hover { background: #fee2e2; border-color: #ef4444; border-style: solid; }
    /* 衣橱网格 */
    .petp-wdrobe-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 10px; }
    .petp-cst-card {
        border-radius: 12px; border: 1.5px solid #e5e7eb; background: #fff;
        padding: 16px 10px 12px; text-align: center; cursor: pointer;
        transition: all .18s; position: relative; overflow: hidden;
    }
    .petp-cst-card:hover:not(.locked) { border-color: #c7d2fe; transform: translateY(-2px); box-shadow: 0 4px 14px rgba(99,102,241,.1); }
    .petp-cst-card.equipped {
        border-color: #6366f1; background: linear-gradient(160deg,#eef2ff 0%,#ede9fe 100%);
        box-shadow: 0 4px 16px rgba(99,102,241,.15);
    }
    .petp-cst-card.locked { background: #f8fafc; border-color: #e2e8f0; cursor: not-allowed; opacity: .6; }
    .petp-cst-ico {
        width: 48px; height: 48px; border-radius: 14px; margin: 0 auto 10px;
        display: flex; align-items: center; justify-content: center;
        background: #f1f5ff; color: #6366f1;
    }
    .petp-cst-ico svg { width: 24px; height: 24px; stroke: currentColor; fill: none; stroke-width: 2; }
    .petp-cst-card.equipped .petp-cst-ico { background: linear-gradient(135deg,#6366f1,#818cf8); color: #fff; box-shadow: 0 2px 10px rgba(99,102,241,.3); }
    .petp-cst-name { font-size: 12px; font-weight: 700; color: #1e293b; margin-bottom: 7px; }
    .petp-cst-status { font-size: 11px; padding: 3px 10px; border-radius: 999px; font-weight: 600; display: inline-block; }
    .petp-cst-status.s-on  { background: #eef2ff; color: #4f46e5; }
    .petp-cst-status.s-have{ background: #f0fdf4; color: #166534; }
    .petp-cst-status.s-buy { background: #fef3c7; color: #92400e; }
    .petp-cst-status.s-lock{ background: #f1f5f9; color: #94a3b8; }
    .petp-cst-lock-ico { position: absolute; top: 7px; right: 7px; width: 14px; height: 14px; color: #cbd5e1; }
    .petp-cst-lock-ico svg { width: 100%; height: 100%; stroke: currentColor; fill: none; stroke-width: 2; }
    /* 背包中装扮行 */
    .petp-bag-row.cst-row     { background: #f8f4ff; border-color: #e9d5ff; }
    .petp-bag-row.cst-row.on  { background: #f0ebff; border-color: #c4b5fd; }
    .petp-btn-equip { background: linear-gradient(135deg,#8b5cf6,#a78bfa) !important; border-color: transparent !important; color: #fff !important; }
    .petp-btn-equip:hover { box-shadow: 0 3px 10px rgba(139,92,246,.3) !important; }

    .petp-log { max-height: 250px; overflow-y: auto; display: grid; gap: 8px; }
    .petp-log-item { font-size: 12px; color: #475569; padding: 8px 10px; border-radius: 8px; background: #f8fafc; border: 1px solid #eef2f7; }
    .petp-log-item span { color: #94a3b8; margin-right: 6px; }

    /* === Popup Notification === */
    .petp-noti-overlay {
        position: fixed; top: 0; right: 0; bottom: 0; left: 0;
        width: 100vw; height: 100vh; z-index: 99998;
        background: rgba(0,0,0,.32); backdrop-filter: blur(2px);
        display: flex; align-items: center; justify-content: center;
        opacity: 0; pointer-events: none; transition: opacity .22s ease;
    }
    .petp-noti-overlay.show { opacity: 1; pointer-events: auto; }
    .petp-noti {
        width: 300px; max-width: 88vw;
        background: #fff; border-radius: 16px;
        box-shadow: 0 20px 60px rgba(0,0,0,.22);
        padding: 32px 24px 24px; text-align: center;
        transform: scale(.85);
        transition: transform .25s cubic-bezier(.34,1.4,.64,1);
    }
    .petp-noti-overlay.show .petp-noti { transform: scale(1); }
    .petp-noti.ok  { border-top: 4px solid #22c55e; }
    .petp-noti.err { border-top: 4px solid #ef4444; }
    .petp-noti-ico {
        width: 52px; height: 52px; border-radius: 50%;
        margin: 0 auto 14px; display: flex; align-items: center; justify-content: center;
    }
    .petp-noti.ok  .petp-noti-ico { background: #dcfce7; }
    .petp-noti.err .petp-noti-ico { background: #fee2e2; }
    .petp-noti-ico svg { width: 26px; height: 26px; fill: none; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; }
    .petp-noti.ok  .petp-noti-ico svg { stroke: #16a34a; }
    .petp-noti.err .petp-noti-ico svg { stroke: #dc2626; }
    .petp-noti-title { text-align: center; font-size: 16px; font-weight: 700; margin-bottom: 8px; }
    .petp-noti.ok  .petp-noti-title { color: #166534; }
    .petp-noti.err .petp-noti-title { color: #991b1b; }
    .petp-noti-msg {
        text-align: center; font-size: 14px; color: #475569;
        line-height: 1.6; margin-bottom: 16px;
        word-break: break-word; white-space: pre-line;
        max-height: 140px; overflow-y: auto;
    }
    .petp-noti-bar { height: 4px; background: #f1f5f9; border-radius: 999px; overflow: hidden; margin-bottom: 14px; }
    .petp-noti-bar-fill { height: 100%; border-radius: 999px; width: 100%; }
    .petp-noti.ok  .petp-noti-bar-fill { background: #22c55e; }
    .petp-noti.err .petp-noti-bar-fill { background: #ef4444; }
    .petp-noti-btn {
        display: block; width: 100%; padding: 10px; border-radius: 10px;
        border: none; font-size: 14px; font-weight: 600;
        cursor: pointer; font-family: inherit; transition: all .15s;
    }
    .petp-noti.ok  .petp-noti-btn { background: #f0fdf4; color: #166534; }
    .petp-noti.ok  .petp-noti-btn:hover { background: #dcfce7; }
    .petp-noti.err .petp-noti-btn { background: #fff1f2; color: #991b1b; }
    .petp-noti.err .petp-noti-btn:hover { background: #fee2e2; }

    @media (max-width: 1100px) {
        .petp-grid { grid-template-columns: 1fr; }
        .petp-main { grid-template-columns: 1fr; }
        .petp-shop-grid { grid-template-columns: repeat(2,1fr); }
        .petp-cst-layout { grid-template-columns: 1fr; }
        .petp-wdrobe-grid { grid-template-columns: repeat(3,1fr); }
        .petp-adopt-grid { grid-template-columns: repeat(3,1fr); }
    }
    @media (max-width: 680px) {
        .petp-shop-grid { grid-template-columns: 1fr; }
        .petp-cst-layout { grid-template-columns: 1fr; }
        .petp-wdrobe-grid, .petp-adopt-grid { grid-template-columns: repeat(2,1fr); }
        .petp-actions { grid-template-columns: repeat(2,1fr); }
    }

    /* 宠物毕业界面 */
    .petp-grad-wrap { text-align: center; padding: 16px 12px; }
    .petp-grad-badge {
        display: inline-block;
        background: linear-gradient(135deg, #f59e0b, #fbbf24);
        color: #fff; font-weight: 800; font-size: 16px;
        padding: 6px 20px; border-radius: 999px; margin-bottom: 12px;
        box-shadow: 0 4px 14px rgba(245,158,11,.35);
    }
    .petp-grad-stats {
        display: flex; gap: 8px; justify-content: center; flex-wrap: wrap; margin: 10px 0;
    }
    .grad-stat {
        background: #f0fdf4; border: 1px solid #bbf7d0; color: #166534;
        font-size: 12px; padding: 4px 10px; border-radius: 6px; font-weight: 600;
    }
    .petp-grad-card-info {
        margin: 10px auto; font-size: 13px; color: #475569;
        background: #fef3c7; border: 1px solid #fde68a;
        padding: 8px 16px; border-radius: 8px;
        display: inline-flex; align-items: center; gap: 10px;
    }
    .petp-grad-desc { font-size: 12px; color: #64748b; margin: 8px 0; line-height: 1.6; }
</style>

<div class="petp-page">
    <div class="petp-head">
        <div class="petp-head-title">宠物乐园</div>
        <div class="petp-head-sub">领取你的专属宠物，使用学分兑换道具喂养升级；达到成长等级后可解锁换装。</div>
        <div class="petp-points"><svg viewBox="0 0 24 24" style="width:14px;height:14px;stroke:#fff;fill:none;stroke-width:2;"><polygon points="6 3 2 9 12 21 22 9 18 3 6 3"/><polyline points="2 9 22 9"/><path d="M12 21L8 9l4-6 4 6-4 12z"/></svg> 当前可用学分：<strong id="petpPoints"><%= pAvailablePoints %></strong> &nbsp;&nbsp;🎴 宠物卡片：<strong id="petCardCount">0</strong> 张</div>
    </div>

    <div class="petp-tabs">
        <button type="button" class="petp-tab active" onclick="petpTab(0)"><svg viewBox="0 0 24 24" style="width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2;vertical-align:middle;margin-right:4px;"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>我的宠物</button>
        <button type="button" class="petp-tab" onclick="petpTab(1)"><svg viewBox="0 0 24 24" style="width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2;vertical-align:middle;margin-right:4px;"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>宠物商店</button>
        <button type="button" class="petp-tab" onclick="petpTab(2)"><svg viewBox="0 0 24 24" style="width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2;vertical-align:middle;margin-right:4px;"><path d="M20 7h-9"/><path d="M14 17H5"/><circle cx="17" cy="17" r="3"/><circle cx="7" cy="7" r="3"/></svg>我的背包</button>
        <button type="button" class="petp-tab" onclick="petpTab(3)"><svg viewBox="0 0 24 24" style="width:14px;height:14px;stroke:currentColor;fill:none;stroke-width:2;vertical-align:middle;margin-right:4px;"><circle cx="12" cy="8" r="6"/><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/></svg>宠物换装</button>
    </div>

    <div id="petpP0" class="petp-panel active">
        <div class="petp-grid">
            <div class="petp-card">
                <div class="petp-card-hd">
                    <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                    我的宠物
                </div>
                <div class="petp-card-bd" id="petMain"></div>
            </div>
            <div class="petp-card">
                <div class="petp-card-hd">
                    <svg viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
                    成长日志
                </div>
                <div class="petp-card-bd">
                    <div class="petp-log" id="petLog"></div>
                    <div style="margin-top:10px;">
                        <button type="button" class="petp-btn" onclick="claimTeacherReward()"><svg viewBox="0 0 24 24" style="width:13px;height:13px;stroke:currentColor;fill:none;stroke-width:2;vertical-align:middle;margin-right:3px;"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>领取教师任务奖励</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="petpP1" class="petp-panel">
        <div class="petp-card">
            <div class="petp-card-hd">
                <svg viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                宠物学分商城
            </div>
            <div class="petp-card-bd">
                <div class="petp-shop-grid" id="shopGrid"></div>
            </div>
        </div>
    </div>

    <div id="petpP2" class="petp-panel">
        <div class="petp-card">
            <div class="petp-card-hd">
                <svg viewBox="0 0 24 24"><path d="M20 7h-9"/><path d="M14 17H5"/><circle cx="17" cy="17" r="3"/><circle cx="7" cy="7" r="3"/></svg>
                我的背包
            </div>
            <div class="petp-card-bd">
                <div class="petp-bag-list" id="bagList"></div>
            </div>
        </div>
    </div>

    <div id="petpP3" class="petp-panel">
        <div class="petp-cst-layout">
            <div class="petp-card">
                <div class="petp-card-hd">
                    <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                    穿戴预览
                </div>
                <div class="petp-preview-bd" id="cstPreviewArea">
                    <div class="petp-no-wear">请先领取宠物</div>
                </div>
            </div>
            <div class="petp-card">
                <div class="petp-card-hd">
                    <svg viewBox="0 0 24 24"><path d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/></svg>
                    我的衣橱
                    <span style="font-size:11px;font-weight:400;color:#94a3b8;margin-left:6px;">（成长 Lv2 解锁换装）</span>
                </div>
                <div class="petp-card-bd">
                    <div class="petp-wdrobe-grid" id="costumeGrid"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<div id="petpNotiOverlay" class="petp-noti-overlay" onclick="if(event.target===this)closeNoti()">
    <div id="petpNoti" class="petp-noti">
        <div class="petp-noti-ico" id="petpNotiIco"></div>
        <div class="petp-noti-title" id="petpNotiTitle"></div>
        <div class="petp-noti-msg" id="petpNotiMsg"></div>
        <div class="petp-noti-bar"><div class="petp-noti-bar-fill" id="petpNotiBarFill"></div></div>
        <button class="petp-noti-btn" onclick="closeNoti()">确认</button>
    </div>
</div>

<script type="text/javascript">
var SID = <%= pSid %>;
var INIT_POINTS = <%= pAvailablePoints %>;
var PET_IMGS = <%=GetPetImagesJson()%>;
var PET_STAGES = <%=GetPetStagesJson()%>;
var COSTUME_CFG = <%=GetCostumeSettingsJson()%>;
var COSTUME_IMG = <%=GetCostumeImagesJson()%>;
var K_PET = "ls_my_pet_" + SID;
var K_BAG
var K_LOG = "ls_my_pet_log_" + SID;
var K_PTS = "ls_my_pet_points_" + SID;
var K_REWARD_DAY = "ls_my_pet_reward_day_" + SID;
var K_CARDS   = "ls_pet_cards_" + SID;
var K_OWN_CST = "ls_my_pet_cst_" + SID;

var PETS = [
    { id:"cat", iconKey:"pet_cat", name:"奶糖喵" },
    { id:"dog", iconKey:"pet_dog", name:"旺福汪" },
    { id:"rabbit", iconKey:"pet_rabbit", name:"跳跳兔" },
    { id:"fox", iconKey:"pet_fox", name:"小橘狐" },
    { id:"panda", iconKey:"pet_panda", name:"团团熊" },
    { id:"frog", iconKey:"pet_frog", name:"呱呱蛙" },
    { id:"tiger", iconKey:"pet_tiger", name:"虎仔" },
    { id:"bird", iconKey:"pet_bird", name:"圆圆企鹅" }
];

var SHOP = [
    { id:"snack",  iconKey:"item_snack", name:"宠物零食", desc:"恢复饱食+18，心情+6",  cost:5,  type:"consumable" },
    { id:"toy",    iconKey:"item_toy", name:"宠物玩具", desc:"恢复心情+20，经验+8",  cost:10, type:"consumable" },
    { id:"gourmet",iconKey:"item_gourmet", name:"宠物食物", desc:"恢复饱食+30，健康+10", cost:15, type:"consumable" },
    { id:"cleaner",iconKey:"item_cleaner", name:"清洁套装", desc:"恢复清洁+30，健康+6",  cost:8,  type:"consumable" },
    { id:"potion", iconKey:"item_potion", name:"强化药水", desc:"经验+25，健康+8",      cost:20, type:"consumable" },
    { id:"gem",    iconKey:"item_gem", name:"经验宝石", desc:"经验+45",              cost:25, type:"consumable" },
    { id:"costume_sunglasses", iconKey:"costume_sunglasses", name:"酷炫墨镜", desc:"成长Lv2解锁换装", cost:30, type:"costume", needLv:2 },
    { id:"costume_hat",        iconKey:"costume_hat", name:"绅士礼帽", desc:"成长Lv2解锁换装", cost:40, type:"costume", needLv:2 },
    { id:"costume_bow",        iconKey:"costume_bow", name:"元气蝴蝶结", desc:"成长Lv2解锁换装", cost:35, type:"costume", needLv:2 },
    { id:"costume_star",       iconKey:"costume_star", name:"流星披风", desc:"成长Lv3解锁换装", cost:50, type:"costume", needLv:3 },
    { id:"costume_ghost",      iconKey:"costume_ghost", name:"南瓜幽灵", desc:"成长Lv3解锁换装", cost:60, type:"costume", needLv:3 },
    { id:"costume_crown",      iconKey:"costume_crown", name:"王者皇冠", desc:"成长Lv4解锁换装", cost:80, type:"costume", needLv:4 },
    { id:"costume_wings",      iconKey:"costume_wings", name:"天使翅膊", desc:"成长Lv4解锁换装", cost:100,type:"costume", needLv:4 }
];
// Apply teacher costume settings (override name/cost/needLv in SHOP)
(function applyCostumeSettings() {
    if (!COSTUME_CFG || !Array.isArray(COSTUME_CFG.costumes)) return;
    for (var ci = 0; ci < COSTUME_CFG.costumes.length; ci++) {
        var cfg = COSTUME_CFG.costumes[ci];
        if (!cfg || !cfg.id) continue;
        for (var si = 0; si < SHOP.length; si++) {
            if (SHOP[si].id === cfg.id) {
                if (cfg.name)   SHOP[si].name   = cfg.name;
                if (cfg.cost > 0) SHOP[si].cost = cfg.cost;
                if (cfg.needLv) { SHOP[si].needLv = cfg.needLv; SHOP[si].desc = "成长Lv" + cfg.needLv + "解锁换装"; }
                break;
            }
        }
    }
})();
function svgBtn(p) { return '<svg viewBox="0 0 24 24">' + p + '</svg>'; }
function getLevelTier(level) {
    if (level <= 0) return 0;
    if (level <= 1) return 1;
    if (level <= 3) return 2;
    if (level <= 6) return 3;
    return 4;
}
function getPetImg(petId, level) {
    var tier = getLevelTier(typeof level === 'number' ? level : 1);
    while (tier >= 0) {
        if (PET_IMGS && PET_IMGS[petId] && PET_IMGS[petId][tier]) return PET_IMGS[petId][tier];
        tier--;
    }
    return null;
}
function JGet(k, d){ try { var v = localStorage.getItem(k); return v ? JSON.parse(v) : d; } catch(e){ return d; } }
function JSet(k, v){ try { localStorage.setItem(k, JSON.stringify(v)); } catch(e){} }
function clamp(v){ return Math.max(0, Math.min(100, v)); }
function iconSvg(k) {
    switch (k) {
        case "pet_cat": return '<svg viewBox="0 0 24 24"><path d="M4 16a8 8 0 0 0 16 0"/><path d="M7 9l2-3 3 2 3-2 2 3"/><circle cx="9" cy="14" r="1"/><circle cx="15" cy="14" r="1"/></svg>';
        case "pet_dog": return '<svg viewBox="0 0 24 24"><path d="M5 10l-2-2m16 2l2-2"/><rect x="6" y="8" width="12" height="10" rx="5"/><circle cx="10" cy="13" r="1"/><circle cx="14" cy="13" r="1"/></svg>';
        case "pet_rabbit": return '<svg viewBox="0 0 24 24"><path d="M9 8V3m6 5V3"/><circle cx="12" cy="14" r="6"/><circle cx="10" cy="14" r="1"/><circle cx="14" cy="14" r="1"/></svg>';
        case "pet_fox": return '<svg viewBox="0 0 24 24"><path d="M4 10l4-4 4 3 4-3 4 4-2 8H6z"/><circle cx="10" cy="14" r="1"/><circle cx="14" cy="14" r="1"/></svg>';
        case "pet_panda": return '<svg viewBox="0 0 24 24"><circle cx="12" cy="13" r="6"/><circle cx="8" cy="7" r="2"/><circle cx="16" cy="7" r="2"/><circle cx="10" cy="13" r="1"/><circle cx="14" cy="13" r="1"/></svg>';
        case "pet_frog": return '<svg viewBox="0 0 24 24"><circle cx="8" cy="9" r="2"/><circle cx="16" cy="9" r="2"/><rect x="5" y="10" width="14" height="8" rx="4"/><circle cx="10" cy="14" r="1"/><circle cx="14" cy="14" r="1"/></svg>';
        case "pet_tiger": return '<svg viewBox="0 0 24 24"><circle cx="12" cy="13" r="6"/><path d="M9 10l-2-2m8 2l2-2"/><path d="M9 16l1-2m4 2l-1-2"/></svg>';
        case "pet_bird": return '<svg viewBox="0 0 24 24"><circle cx="11" cy="13" r="5"/><path d="M16 13h4l-2 2"/><path d="M9 9l-1-2m4 2l1-2"/></svg>';
        case "item_snack": return '<svg viewBox="0 0 24 24"><rect x="5" y="7" width="14" height="10" rx="2"/><circle cx="10" cy="12" r="1"/><circle cx="14" cy="12" r="1"/></svg>';
        case "item_toy": return '<svg viewBox="0 0 24 24"><circle cx="8" cy="12" r="3"/><circle cx="16" cy="12" r="3"/><path d="M11 12h2"/></svg>';
        case "item_gourmet": return '<svg viewBox="0 0 24 24"><path d="M7 4v8m3-8v8"/><path d="M14 4h3a2 2 0 0 1 0 4h-3z"/><path d="M12 20c0-4 4-5 5-8"/></svg>';
        case "item_cleaner": return '<svg viewBox="0 0 24 24"><path d="M9 3h6"/><path d="M10 3v4h4V3"/><rect x="8" y="7" width="8" height="14" rx="2"/></svg>';
        case "item_potion": return '<svg viewBox="0 0 24 24"><path d="M10 2h4"/><path d="M10 2v5l-4 7a5 5 0 0 0 4 8h4a5 5 0 0 0 4-8l-4-7V2"/></svg>';
        case "item_gem": return '<svg viewBox="0 0 24 24"><polygon points="6 3 2 9 12 21 22 9 18 3 6 3"/><polyline points="2 9 22 9"/></svg>';
        case "costume_sunglasses": return '<svg viewBox="0 0 24 24"><rect x="3" y="9" width="7" height="4" rx="1"/><rect x="14" y="9" width="7" height="4" rx="1"/><path d="M10 11h4"/></svg>';
        case "costume_hat": return '<svg viewBox="0 0 24 24"><path d="M5 18h14"/><path d="M7 18l2-8h6l2 8"/><path d="M10 10V7h4v3"/></svg>';
        case "costume_bow": return '<svg viewBox="0 0 24 24"><path d="M12 12l-6-4a3 3 0 1 0 0 8z"/><path d="M12 12l6-4a3 3 0 1 1 0 8z"/><circle cx="12" cy="12" r="1.5"/></svg>';
        case "costume_star": return '<svg viewBox="0 0 24 24"><polygon points="12 3 15 9 22 10 17 14 18 21 12 18 6 21 7 14 2 10 9 9 12 3"/></svg>';
        case "costume_ghost": return '<svg viewBox="0 0 24 24"><path d="M5 18V9a7 7 0 0 1 14 0v9l-3-2-2 2-2-2-2 2-2-2z"/><circle cx="10" cy="10" r="1"/><circle cx="14" cy="10" r="1"/></svg>';
        case "costume_crown": return '<svg viewBox="0 0 24 24"><path d="M3 18h18l-2-8-4 3-3-5-3 5-4-3z"/></svg>';
        case "costume_wings": return '<svg viewBox="0 0 24 24"><path d="M12 13c-2-4-6-6-9-6 0 4 2 8 7 9"/><path d="M12 13c2-4 6-6 9-6 0 4-2 8-7 9"/><path d="M12 13v7"/></svg>';
        default: return '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 8v4l3 3"/></svg>';
    }
}
function getCostIco(cid, iconKey) {
    if (COSTUME_IMG && COSTUME_IMG[cid])
        return '<img src="' + esc(COSTUME_IMG[cid]) + '" style="width:100%;height:100%;object-fit:contain;border-radius:6px;" alt="">';
    return iconSvg(iconKey);
}

function todayKey() {
    var d = new Date();
    var m = String(d.getMonth()+1).padStart(2,'0');
    var day = String(d.getDate()).padStart(2,'0');
    return d.getFullYear() + "-" + m + "-" + day;
}

function getPoints() {
    var p = JGet(K_PTS, null);
    if (p === null || typeof p !== "number") {
        p = INIT_POINTS || 0;
        JSet(K_PTS, p);
    }
    return p;
}
function setPoints(v) {
    if (v < 0) v = 0;
    JSet(K_PTS, v);
    var el = document.getElementById("petpPoints");
    if (el) el.textContent = v;
}
function updateCardBadge() {
    var cards = JGet(K_CARDS, []);
    var count = Array.isArray(cards) ? cards.length : 0;
    var el = document.getElementById('petCardCount');
    if (el) el.textContent = count;
}

/* === 装扮永久所有权 === */
function getOwnedCostumes() { return JGet(K_OWN_CST, []); }
function ownCostume(id) {
    var own = getOwnedCostumes();
    if (own.indexOf(id) < 0) { own.push(id); JSet(K_OWN_CST, own); }
}
function hasCostume(id) { return getOwnedCostumes().indexOf(id) >= 0; }
function isCST(id) {
    for (var i=0;i<SHOP.length;i++) if (SHOP[i].id===id && SHOP[i].type==='costume') return true;
    return false;
}
// 迁移旧数据：将 K_BAG 中残留的装扮项移至 K_OWN_CST
function migrateCstFromBag() {
    var bag = JGet(K_BAG, {}), changed = false;
    for (var k in bag) {
        if (bag.hasOwnProperty(k) && bag[k] > 0 && isCST(k)) {
            ownCostume(k); delete bag[k]; changed = true;
        }
    }
    if (changed) JSet(K_BAG, bag);
}
function undress() {
    var p = getPet(); if (!p || !p.wear) return;
    var n = ''; for (var i=0;i<SHOP.length;i++) if (SHOP[i].id===p.wear) { n=SHOP[i].name; break; }
    p.wear = ''; p.wearIconKey = '';
    savePet(p); logPush('取下装扮' + (n ? '：'+n : '')); renderAll();
}
function renderCstPreview() {
    var el = document.getElementById('cstPreviewArea'); if (!el) return;
    var p = getPet();
    if (!p) { el.innerHTML = '<div class="petp-no-wear">请先领取宠物</div>'; return; }
    var _pi = getPetImg(p.id, p.level);
    var baseHtml = _pi
        ? '<img src="' + esc(_pi) + '" style="width:100%;height:100%;object-fit:contain;border-radius:10px;" alt="">'
        : iconSvg(p.iconKey || ('pet_' + p.id));
    var badgeHtml = p.wear ? '<div class="pet-cst-badge">' + iconSvg(p.wearIconKey || p.wear) + '</div>' : '';
    var wearName = '';
    if (p.wear) { for (var j=0;j<SHOP.length;j++) if (SHOP[j].id===p.wear) { wearName=SHOP[j].name; break; } }
    el.innerHTML =
        '<div class="petp-preview-fig"><div class="pet-base">' + baseHtml + '</div>' + badgeHtml + '</div>'
        + '<div class="petp-wear-lbl">当前装扮</div>'
        + (p.wear
            ? '<div class="petp-wear-name">' + esc(wearName) + '</div>'
              + '<button type="button" class="petp-undress-btn" onclick="undress()">✕ 取下装扮</button>'
            : '<div class="petp-no-wear">未装扮 &middot; 去衣橱选择</div>');
}

function getPet() {
    return JGet(K_PET, null);
}
function savePet(p) {
    JSet(K_PET, p);
}

function petNeedExp(lv) {
    if (PET_STAGES && Array.isArray(PET_STAGES.stageExp)) {
        var idx = lv - 1;
        if (idx >= 0) {
            var val = PET_STAGES.stageExp[Math.min(idx, PET_STAGES.stageExp.length - 1)];
            if (val > 0) return val;
        }
    }
    return lv * 100;
}
function addExp(p, val) {
    p.exp += val;
    var up = 0;
    while (p.exp >= petNeedExp(p.level)) {
        p.exp -= petNeedExp(p.level);
        p.level++;
        up++;
    }
    if (up > 0) logPush("宠物升级到 Lv." + p.level + "！");
}

function logPush(msg) {
    var logs = JGet(K_LOG, []);
    logs.unshift({ t:new Date().toLocaleString("zh-CN"), m:msg });
    if (logs.length > 80) logs = logs.slice(0,80);
    JSet(K_LOG, logs);
    renderLogs();
}

function renderLogs() {
    var logs = JGet(K_LOG, []);
    var el = document.getElementById("petLog");
    if (!el) return;
    if (!logs.length) {
        el.innerHTML = '<div class="petp-log-item"><span>提示</span>还没有日志，先去领取宠物吧。</div>';
        return;
    }
    el.innerHTML = logs.map(function(x){
        return '<div class="petp-log-item"><span>' + esc(x.t) + '</span>' + esc(x.m) + '</div>';
    }).join('');
}

function renderMain() {
    var box = document.getElementById("petMain");
    var p = getPet();
    if (!p) {
        box.innerHTML =
            '<div class="petp-empty">'
          + '  <div class="e1"><svg viewBox="0 0 24 24"><circle cx="7" cy="8" r="2"/><circle cx="12" cy="6" r="2"/><circle cx="17" cy="8" r="2"/><path d="M6 16c0-3 3-5 6-5s6 2 6 5-3 4-6 4-6-1-6-4z"/></svg></div>'
          + '  <div class="e2">你还没有宠物，先领取一个吧</div>'
          + '  <div class="petp-adopt-grid" id="adoptGrid"></div>'
          + '</div>';
        var ag = document.getElementById("adoptGrid");
        ag.innerHTML = PETS.map(function(x){
            var _ai = getPetImg(x.id, 0);
            var _aico = _ai
                ? '<img src="' + esc(_ai) + '" style="width:100%;height:100%;object-fit:contain;border-radius:6px;" alt="">'
                : iconSvg(x.iconKey);
            return '<div class="petp-adopt-item" onclick="adoptPet(\'' + x.id + '\')">'
                + '<div class="petp-adopt-emoji">' + _aico + '</div>'
                + '<div class="petp-adopt-name">' + esc(x.name) + '</div>'
                + '</div>';
        }).join('');
        return;
    }

    // 毕业检测：全属性满尽第一次自动生成卡片
    if (p.hp >= 100 && p.clean >= 100 && p.mood >= 100 && p.food >= 100 && !p.graduated) {
        var gCards = JGet(K_CARDS, []);
        gCards.push({ petId: p.id, petName: p.name, level: p.level, iconKey: p.iconKey, graduatedAt: new Date().toISOString() });
        JSet(K_CARDS, gCards);
        p.graduated = true;
        savePet(p);
        logPush('🎓 ' + p.name + ' 荣耀毕业！全属性满値，获得宠物卡片 × 1');
        updateCardBadge();
        toast('恭喜！' + p.name + ' 全属性满値，已毕业！获得宠物卡片 × 1');
    }
    if (p.graduated) { renderGraduated(p, box); return; }

    var expNeed = petNeedExp(p.level);
    var expPct = Math.min(100, Math.floor((p.exp / expNeed) * 100));
    var _pImg = getPetImg(p.id, p.level);
    var petIcon = _pImg
        ? '<img src="' + esc(_pImg) + '" style="width:100%;height:100%;object-fit:contain;border-radius:8px;" alt="">'
        : iconSvg(p.iconKey || ("pet_" + p.id));
    var wear = p.wear ? ('<div class="pet-wear-svg">' + iconSvg(p.wearIconKey || p.wear) + '</div>') : '';
    var lvText = p.level <= 1 ? "基础阶段（仅喂食+清洁）" : "成长阶段（换装已解锁）";
    box.innerHTML =
        '<div class="petp-main">'
      + '  <div class="petp-petbox">'
      + '    <div class="petp-pet-emoji"><div class="pet-base-svg">' + petIcon + '</div>' + wear + '</div>'
      + '    <div class="petp-pet-name">' + esc(p.name) + '</div>'
      + '    <div class="petp-level">Lv.' + p.level + ' · ' + lvText + '</div>'
      + '    <div class="petp-exp">'
      + '      <div class="petp-exp-bar"><div class="petp-exp-fill" style="width:' + expPct + '%"></div></div>'
      + '      <div class="petp-exp-text">EXP ' + p.exp + ' / ' + expNeed + '</div>'
      + '    </div>'
      + '  </div>'
      + '  <div>'
      + '    <div class="petp-stats">'
      + statRow("健康", p.hp, "f-hp")
      + statRow("清洁", p.clean, "f-clean")
      + statRow("心情", p.mood, "f-mood")
      + statRow("饱食", p.food, "f-food")
      + '    </div>'
      + '    <div class="petp-actions">'
      + '      <button type="button" class="petp-btn main" onclick="petAction(\'feed\')">'
          + svgBtn('<path d="M12 2c-2 4-7 5-7 10a7 7 0 0 0 14 0c0-5-5-6-7-10z"/>') + '投喂<span class="petp-cost">-1学分</span></button>'
      + '      <button type="button" class="petp-btn main" onclick="petAction(\'clean\')">'
          + svgBtn('<path d="M12 2v4m-6 2H2m20 0h-4m-2-5l-3 3M7 7L4 4m13 13l3 3M7 17l-3 3"/><circle cx="12" cy="13" r="5"/>') + '清洁<span class="petp-cost">-1学分</span></button>'
      + '      <button type="button" class="petp-btn" onclick="petAction(\'play\')" ' + (p.level<=1 ? 'disabled' : '') + '>'
          + svgBtn('<rect x="2" y="7" width="20" height="13" rx="2"/><path d="M16 7V5a4 4 0 0 0-8 0v2"/>') + '互动<span class="petp-cost">-1学分</span></button>'
      + '      <button type="button" class="petp-btn" onclick="renamePet()">'
          + svgBtn('<path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"/>') + '改名<span class="petp-cost">-1学分</span></button>'
      + '    </div>'
      + '  </div>'
      + '</div>';
}

function renderGraduated(p, box) {
    var _pImg = getPetImg(p.id, p.level);
    var petIcon = _pImg
        ? '<img src="' + esc(_pImg) + '" style="width:100%;height:100%;object-fit:contain;border-radius:8px;" alt="">'
        : iconSvg(p.iconKey || ('pet_' + p.id));
    var cards = JGet(K_CARDS, []);
    var cardCount = Array.isArray(cards) ? cards.length : 0;
    box.innerHTML =
        '<div class="petp-grad-wrap">'
      + '  <div class="petp-grad-badge">🎓 已毕业</div>'
      + '  <div class="petp-petbox" style="margin:10px auto;max-width:200px;">'
      + '    <div class="petp-pet-emoji"><div class="pet-base-svg">' + petIcon + '</div></div>'
      + '    <div class="petp-pet-name">' + esc(p.name) + '</div>'
      + '    <div class="petp-level">✨ Lv.' + p.level + ' · 全属性满値</div>'
      + '  </div>'
      + '  <div class="petp-grad-stats">'
      + '    <span class="grad-stat">❤️ 健康 100</span>'
      + '    <span class="grad-stat">🪴 清洁 100</span>'
      + '    <span class="grad-stat">😊 心情 100</span>'
      + '    <span class="grad-stat">🥩 饱食 100</span>'
      + '  </div>'
      + '  <div class="petp-grad-card-info">'
      + '    🎴 已拥有宠物卡片：<strong>' + cardCount + '</strong> 张 &nbsp;'
      + '    <a href="badgeshop.aspx" class="petp-btn" style="font-size:12px;padding:4px 14px;text-decoration:none;display:inline-flex;align-items:center;">去兑换商城</a>'
      + '  </div>'
      + '  <div class="petp-grad-desc">全属性满値！这只宠物已完成成长旅程。<br>可送它去新家，再领取一只新宠物继续培养。</div>'
      + '  <div style="margin-top:12px;">'
      + '    <button type="button" class="petp-btn main" onclick="releasePet()">🏠 送去新家（领取新宠物）</button>'
      + '  </div>'
      + '</div>';
}

function releasePet() {
    var p = getPet();
    if (!p) return;
    if (!p.graduated) { toast('宠物尚未毕业，无法释放', true); return; }
    if (!confirm('确定要送「' + (p.name || '宠物') + '」去新家吗？宠物卡片已保留，可在兑换商城使用。')) return;
    JSet(K_PET, null);
    JSet(K_BAG, {});
    logPush('送走了已毕业的宠物：' + (p.name || '宠物'));
    renderAll();
    toast('宠物已送去新家，你可以领取新宠物了！');
}

function statRow(lbl, v, cls) {
    return '<div class="petp-stat">'
        + '<div class="lbl">' + lbl + '</div>'
        + '<div class="bar"><div class="fill ' + cls + '" style="width:' + v + '%"></div></div>'
        + '<div class="v">' + v + '</div>'
        + '</div>';
}

function adoptPet(id) {
    var p = null;
    for (var i=0;i<PETS.length;i++) if (PETS[i].id===id) p = PETS[i];
    if (!p) return;
    var pet = {
        id: p.id, name: p.name, iconKey: p.iconKey,
        level: 1, exp: 0, hp: 80, clean: 75, mood: 70, food: 70,
        wear: "", wearIconKey: ""
    };
    savePet(pet);
    JSet(K_BAG, {});
    logPush("领养了新宠物：" + p.name);
    renderAll();
    toast("宠物领取成功！");
}

function petAction(a) {
    var p = getPet();
    if (!p) { toast("请先领取宠物", true); return; }
    var pts = getPoints();
    if (pts < 1) { toast("学分不足，操作需要 1 学分", true); return; }
    if (a==="feed") {
        p.food = clamp(p.food + 20);
        p.mood = clamp(p.mood + 6);
        addExp(p, 1);
        setPoints(pts - 1);
        logPush("投喂宠物（-1学分），饱食与心情提升，EXP+1");
    } else if (a==="clean") {
        p.clean = clamp(p.clean + 22);
        p.hp = clamp(p.hp + 6);
        addExp(p, 1);
        setPoints(pts - 1);
        logPush("给宠物做了清洁（-1学分），清洁与健康提升，EXP+1");
    } else if (a==="play") {
        if (p.level <= 1) { toast("基础等级未解锁互动功能", true); return; }
        p.mood = clamp(p.mood + 18);
        p.food = clamp(p.food - 6);
        addExp(p, 1);
        setPoints(pts - 1);
        logPush("和宠物互动玩耗（-1学分），心情大幅提升，EXP+1");
    }
    savePet(p);
    renderAll();
}

function renamePet() {
    var p = getPet();
    if (!p) return;
    var pts = getPoints();
    if (pts < 1) { toast("学分不足，改名需要 1 学分", true); return; }
    var n = prompt("输入新的宠物名字（1-12字）", p.name || "");
    if (n === null) return;
    n = (n || "").trim();
    if (!n) { toast("名字不能为空", true); return; }
    if (n.length > 12) n = n.substring(0,12);
    p.name = n;
    savePet(p);
    setPoints(pts - 1);
    logPush("宠物改名为：" + n + "（-1学分）");
    renderAll();
}

function renderShop() {
    var el = document.getElementById("shopGrid");
    if (!el) return;
    el.innerHTML = SHOP.map(function(i){
        return '<div class="petp-item">'
            + '<div class="petp-item-top"><div class="petp-item-icon">' + (i.type === 'costume' ? getCostIco(i.id, i.iconKey) : iconSvg(i.iconKey)) + '</div><div class="petp-item-name">' + esc(i.name) + '</div></div>'
            + '<div class="petp-item-desc">' + esc(i.desc) + '</div>'
            + '<div class="petp-item-bottom">'
            + '  <div class="petp-price">' + i.cost + ' 学分</div>'
            + '  <button type="button" class="petp-btn" onclick="buyItem(\'' + i.id + '\')">兑换</button>'
            + '</div>'
            + '</div>';
    }).join('');
}

function buyItem(itemId) {
    var p = getPet();
    if (!p) { toast("请先领取宠物", true); return; }
    var item = null;
    for (var i=0;i<SHOP.length;i++) if (SHOP[i].id===itemId) item=SHOP[i];
    if (!item) return;

    var form = new FormData();
    form.append("item", itemId);
    form.append("qty", "1");
    fetch("petbuy.ashx", { method:"POST", body:form, credentials:"same-origin" })
        .then(function(r){ return r.json(); })
        .then(function(res){
            if (!res || !res.success) {
                toast((res && res.msg) ? res.msg : "兑换失败", true);
                return;
            }
            setPoints(res.available || 0);
            if (item.type === "costume") {
                ownCostume(itemId); // 装扮为永久解锁，不放入消耗背包
            } else {
                var bag = JGet(K_BAG, {});
                bag[itemId] = (bag[itemId] || 0) + 1;
                JSet(K_BAG, bag);
            }
            logPush("兑换道具：" + item.name + "（-" + item.cost + "学分）");
            renderBag();
            renderCostumes();
            renderCstPreview();
            toast("兑换成功：" + item.name);
        })
        .catch(function(){ toast("网络错误，兑换失败", true); });
}

function renderBag() {
    var p = getPet();
    var el = document.getElementById("bagList");
    if (!el) return;
    if (!p) { el.innerHTML = '<div class="petp-empty"><div class="e2">请先领取宠物</div></div>'; return; }
    var bag = JGet(K_BAG, {});
    // 消耗品：K_BAG 中非装扮项
    var consumeKeys = Object.keys(bag).filter(function(k){ return (bag[k]||0) > 0 && !isCST(k); });
    // 已拥有装扮：K_OWN_CST
    var ownCST = getOwnedCostumes();
    if (!consumeKeys.length && !ownCST.length) {
        el.innerHTML = '<div class="petp-empty"><div class="e2">背包空空的，去商城兑换道具吧</div></div>';
        return;
    }
    var html = '';
    html += consumeKeys.map(function(k){
        var item = null;
        for (var i=0;i<SHOP.length;i++) if (SHOP[i].id===k) item=SHOP[i];
        if (!item) return '';
        return '<div class="petp-bag-row">'
            + '<div class="petp-bag-left"><div class="petp-item-icon">' + iconSvg(item.iconKey) + '</div>'
            + '<div><div class="petp-bag-name">' + esc(item.name) + '</div><div class="petp-bag-qty">数量：' + bag[k] + '</div></div></div>'
            + '<button type="button" class="petp-btn" onclick="useItem(\'' + k + '\')">使用</button>'
            + '</div>';
    }).join('');
    if (ownCST.length) {
        if (consumeKeys.length) html += '<div style="margin:12px 0 8px;font-size:12px;font-weight:700;color:#6d28d9;display:flex;align-items:center;gap:6px;"><svg viewBox="0 0 24 24" style="width:13px;height:13px;stroke:currentColor;fill:none;stroke-width:2;"><path d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/></svg>已拥有的装扮</div>';
        html += ownCST.map(function(cid){
            var item = null;
            for (var i=0;i<SHOP.length;i++) if (SHOP[i].id===cid) item=SHOP[i];
            if (!item) return '';
            var on = p.wear === cid;
            return '<div class="petp-bag-row cst-row' + (on ? ' on' : '') + '">'
                + '<div class="petp-bag-left"><div class="petp-item-icon" style="background:#f5f0ff;color:#8b5cf6;">' + getCostIco(item.id, item.iconKey) + '</div>'
                + '<div><div class="petp-bag-name">' + esc(item.name) + '</div>'
                + '<div class="petp-bag-qty">' + (on ? '<span style="color:#6d28d9;font-weight:700;">✓ 穿戴中</span>' : item.desc) + '</div></div></div>'
                + '<button type="button" class="petp-btn ' + (on ? '' : 'petp-btn-equip') + '" onclick="' + (on ? 'undress()' : 'dress(\'' + cid + '\')') + '">' + (on ? '取下' : '换上') + '</button>'
                + '</div>';
        }).join('');
    }
    el.innerHTML = html;
}

function useItem(itemId) {
    var p = getPet();
    if (!p) return;
    var item = null;
    for (var i=0;i<SHOP.length;i++) if (SHOP[i].id===itemId) item=SHOP[i];
    if (!item) return;
    // 装扮项交由 dress()/undress() 处理，不消耗
    if (item.type === "costume") {
        if (!hasCostume(itemId)) { toast("未拥有该装扮，请先在商城兑换", true); return; }
        if (p.wear === item.id) { undress(); return; }
        dress(itemId); return;
    }
    var bag = JGet(K_BAG, {});
    if (!bag[itemId] || bag[itemId] <= 0) { toast("该道具数量不足", true); return; }
    if (itemId === "snack") { p.food = clamp(p.food + 18); p.mood = clamp(p.mood + 6); addExp(p, 6); }
    if (itemId === "toy") { p.mood = clamp(p.mood + 20); addExp(p, 8); }
    if (itemId === "gourmet") { p.food = clamp(p.food + 30); p.hp = clamp(p.hp + 10); addExp(p, 10); }
    if (itemId === "cleaner") { p.clean = clamp(p.clean + 30); p.hp = clamp(p.hp + 6); addExp(p, 8); }
    if (itemId === "potion") { p.hp = clamp(p.hp + 8); addExp(p, 25); }
    if (itemId === "gem") { addExp(p, 45); }
    bag[itemId] = bag[itemId] - 1;
    if (bag[itemId] <= 0) delete bag[itemId];
    JSet(K_BAG, bag);
    savePet(p);
    logPush("使用道具：" + item.name);
    renderAll();
}

function renderCostumes() {
    var p = getPet();
    var el = document.getElementById("costumeGrid");
    if (!el) return;
    if (!p) {
        el.innerHTML = '<div class="petp-empty" style="grid-column:1/-1"><div class="e2">请先领取宠物</div></div>';
        return;
    }
    var arr = SHOP.filter(function(x){ return x.type === "costume"; });
    el.innerHTML = arr.map(function(c){
        var owned  = hasCostume(c.id);
        var locked = p.level < (c.needLv || 2);
        var active = p.wear === c.id;
        var statusHtml, clickAttr, cardCls;
        if (active) {
            statusHtml = '<span class="petp-cst-status s-on">✓ 已穿戴</span>';
            clickAttr  = ' onclick="undress()"';
            cardCls    = 'equipped';
        } else if (owned && !locked) {
            statusHtml = '<span class="petp-cst-status s-have">已拥有 &middot; 点击换上</span>';
            clickAttr  = ' onclick="dress(\'' + c.id + '\')"';
            cardCls    = '';
        } else if (locked) {
            statusHtml = '<span class="petp-cst-status s-lock">需 Lv.' + c.needLv + '</span>';
            clickAttr  = '';
            cardCls    = 'locked';
        } else {
            statusHtml = '<span class="petp-cst-status s-buy">' + c.cost + ' 学分兑换</span>';
            clickAttr  = '';
            cardCls    = '';
        }
        return '<div class="petp-cst-card ' + cardCls + '"' + clickAttr + '>'
            + (locked ? '<div class="petp-cst-lock-ico"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></div>' : '')
            + '<div class="petp-cst-ico">' + getCostIco(c.id, c.iconKey) + '</div>'
            + '<div class="petp-cst-name">' + esc(c.name) + '</div>'
            + statusHtml
            + (!locked && !owned ? '<div style="font-size:10px;color:#94a3b8;margin-top:4px;">去商城兑换</div>' : '')
            + '</div>';
    }).join('');
}

function dress(costumeId) {
    var p = getPet();
    if (!p) return;
    var item = null;
    for (var i=0;i<SHOP.length;i++) if (SHOP[i].id===costumeId) item=SHOP[i];
    if (!item) return;
    if (p.level < (item.needLv || 2)) { toast("宠物等级不足，需 Lv." + item.needLv, true); return; }
    if (!hasCostume(costumeId)) { toast("未拥有该装扮，请先在商城兑换", true); return; }
    if (p.wear === costumeId) { undress(); return; }
    p.wear = item.id; p.wearIconKey = item.iconKey;
    savePet(p);
    logPush("切换装扮：" + item.name);
    renderAll();
}

function claimTeacherReward() {
    var p = getPet();
    if (!p) { toast("请先领取宠物", true); return; }
    var t = todayKey();
    var got = localStorage.getItem(K_REWARD_DAY);
    if (got === t) { toast("今天已领取过奖励", true); return; }
    var rewardExp = 0;
    try {
        // 读取教师端宠物规则（班级宠物规则），估算学生奖励
        var rules = JSON.parse(localStorage.getItem("ls_pet_rules_v1") || "[]");
        if (rules && rules.length) {
            for (var i=0;i<rules.length;i++) {
                if (rules[i].enabled && Number(rules[i].value) > 0) rewardExp += Math.min(6, Number(rules[i].value));
            }
            rewardExp = Math.min(80, Math.max(8, rewardExp));
        } else {
            rewardExp = 12;
        }
    } catch(e) { rewardExp = 12; }

    addExp(p, rewardExp);
    p.mood = clamp(p.mood + 8);
    p.hp = clamp(p.hp + 5);
    savePet(p);
    localStorage.setItem(K_REWARD_DAY, t);
    logPush("领取教师规则奖励：EXP +" + rewardExp);
    renderAll();
    toast("已领取今日教师奖励！");
}

function petpTab(i) {
    var tabs = document.querySelectorAll(".petp-tab");
    var ps = document.querySelectorAll(".petp-panel");
    for (var x=0;x<tabs.length;x++) tabs[x].classList.toggle("active", x===i);
    for (var y=0;y<ps.length;y++) ps[y].classList.toggle("active", y===i);
}

function esc(s){ return String(s||"").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;"); }
var _petpNotiT = null;
function toast(msg, err) {
    var overlay = document.getElementById('petpNotiOverlay');
    var popup   = document.getElementById('petpNoti');
    // Ensure overlay is at document.body level and force full-viewport inline styles
    if (overlay) {
        if (overlay.parentNode !== document.body) document.body.appendChild(overlay);
        overlay.style.setProperty('position','fixed','important');
        overlay.style.setProperty('top','0','important');
        overlay.style.setProperty('left','0','important');
        overlay.style.setProperty('right','0','important');
        overlay.style.setProperty('bottom','0','important');
        overlay.style.setProperty('width','100vw','important');
        overlay.style.setProperty('height','100vh','important');
        overlay.style.setProperty('display','flex','important');
        overlay.style.setProperty('align-items','center','important');
        overlay.style.setProperty('justify-content','center','important');
    }
    var icoEl   = document.getElementById('petpNotiIco');
    var titleEl = document.getElementById('petpNotiTitle');
    var msgEl   = document.getElementById('petpNotiMsg');
    var barFill = document.getElementById('petpNotiBarFill');
    if (!popup) return;
    var cls = err ? 'err' : 'ok';
    if (icoEl) icoEl.innerHTML = err
        ? '<svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>'
        : '<svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>';
    if (titleEl) titleEl.textContent = err ? '\u64cd\u4f5c\u5931\u8d25' : '\u64cd\u4f5c\u6210\u529f';
    if (msgEl) msgEl.textContent = msg || '';
    if (barFill) {
        barFill.style.transition = 'none';
        barFill.style.width = '100%';
        barFill.offsetWidth;
        barFill.style.transition = 'width 2.8s linear';
        barFill.style.width = '0%';
    }
    popup.className = 'petp-noti ' + cls;
    if (overlay) overlay.className = 'petp-noti-overlay show';
    clearTimeout(_petpNotiT);
    _petpNotiT = setTimeout(function() { closeNoti(); }, 2800);
}
function closeNoti() {
    var overlay = document.getElementById('petpNotiOverlay');
    clearTimeout(_petpNotiT);
    if (overlay) overlay.className = 'petp-noti-overlay';
}

function renderAll() {
    renderMain();
    renderShop();
    renderBag();
    renderCostumes();
    renderCstPreview();
    renderLogs();
    setPoints(getPoints());
    updateCardBadge();
}

document.addEventListener("DOMContentLoaded", function(){
    if (SID <= 0) {
        toast("未检测到登录身份，请重新登录", true);
    }
    migrateCstFromBag(); // 迁移旧数据
    renderAll();
});
</script>
</asp:Content>
