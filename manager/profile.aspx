<%@ Page Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Configuration" %>

<script runat="server">
    private string GetConnStr()
    {
        // Use DbHelperSQL.connectionString from DLL (same as compiled pages)
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo connField = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (connField != null)
                {
                    string cs = connField.GetValue(null) as string;
                    if (!string.IsNullOrEmpty(cs)) return cs;
                }
            }
        }
        catch { }
        return ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
    }

    private static System.Reflection.BindingFlags allFlags =
        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic
        | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static;

    // Decrypt a cookie model (MngCook or TeaCook) and extract properties
    private object DecodeCookieModel(string typeName, string cookieValue)
    {
        System.Reflection.Assembly asm = typeof(LearnSite.Common.CookieHelp).Assembly;
        Type cookType = asm.GetType(typeName);
        if (cookType == null) return null;
        object model = Activator.CreateInstance(cookType);
        System.Reflection.MethodInfo toModel = cookType.GetMethod("ToModel", allFlags);
        if (toModel != null)
            toModel.Invoke(model, new object[] { cookieValue });
        return model;
    }

    private string GetCookProp(object model, string propName)
    {
        if (model == null) return "";
        System.Reflection.PropertyInfo prop = model.GetType().GetProperty(propName);
        if (prop == null) return "";
        object val = prop.GetValue(model, null);
        return val != null ? val.ToString() : "";
    }

    private int GetCookIntProp(object model, string propName)
    {
        string val = GetCookProp(model, propName);
        if (string.IsNullOrEmpty(val)) return 0;
        int result;
        if (int.TryParse(val, out result)) return result;
        return 0;
    }

    private int GetCurrentHid()
    {
        // 1. Decrypt manager cookie
        try
        {
            string mngName = LearnSite.Common.CookieHelp.mngCookieNname;
            HttpCookie mngCookie = Request.Cookies[mngName];
            if (mngCookie != null && !string.IsNullOrEmpty(mngCookie.Value))
            {
                object mcook = DecodeCookieModel("LearnSite.Model.MngCook", mngCookie.Value);
                int hid = GetCookIntProp(mcook, "Hid");
                if (hid > 0) return hid;
            }
        }
        catch { }

        // 2. Fallback: teacher cookie
        try
        {
            string teaName = LearnSite.Common.CookieHelp.teaCookieNname;
            HttpCookie teaCookie = Request.Cookies[teaName];
            if (teaCookie != null && !string.IsNullOrEmpty(teaCookie.Value))
            {
                object tcook = DecodeCookieModel("LearnSite.Model.TeaCook", teaCookie.Value);
                int hid = GetCookIntProp(tcook, "Hid");
                if (hid > 0) return hid;
            }
        }
        catch { }

        return 0;
    }

    // Filter out meaningless default values
    private bool IsValidNick(string nick)
    {
        if (string.IsNullOrEmpty(nick)) return false;
        string n = nick.Trim();
        if (n.Length == 0) return false;
        // Filter common default/placeholder values
        if (n == "\u672a\u767b\u5f55" || n == "\u672A\u767B\u5F55") return false; // "未登录"
        if (n == "null" || n == "undefined") return false;
        return true;
    }

    // Load basic user info from cookie model (no DB needed)
    private void LoadFromCookie()
    {
        try
        {
            string mngName = LearnSite.Common.CookieHelp.mngCookieNname;
            HttpCookie mngCookie = Request.Cookies[mngName];
            if (mngCookie != null && !string.IsNullOrEmpty(mngCookie.Value))
            {
                object mcook = DecodeCookieModel("LearnSite.Model.MngCook", mngCookie.Value);
                if (mcook != null)
                {
                    string name = GetCookProp(mcook, "Hname");
                    if (!string.IsNullOrEmpty(name)) currentHname = name;
                    string nick = GetCookProp(mcook, "Hnick");
                    if (IsValidNick(nick)) currentHnick = nick;
                }
            }
        }
        catch { }
    }

    private DataRow GetTeacherInfo(int hid)
    {
        using (SqlConnection conn = new SqlConnection(GetConnStr()))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand("SELECT Hid,Hname,Hnick,Hnote,Hemail,Havatar,Hpermiss FROM Teacher WHERE Hid=@hid", conn);
            cmd.Parameters.AddWithValue("@hid", hid);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            if (dt.Rows.Count > 0) return dt.Rows[0];
        }
        return null;
    }

    protected string currentAvatarUrl = "";
    protected string currentHname = "";
    protected string currentHnick = "";
    protected string currentHnote = "";
    protected string currentHemail = "";
    protected int currentHid = 0;
    protected bool dbAvailable = false;

    protected void Page_Load(object sender, EventArgs e)
    {
        currentHid = GetCurrentHid();
        // Always load cookie data (needed for avatar, name display on every request)
        if (currentHid > 0)
        {
            LoadFromCookie();
        }
        if (!IsPostBack)
        {
            if (currentHid > 0)
            {
                // Try to enhance with DB data
                LoadProfile(currentHid);
            }
            else
            {
                LabelMsg.ForeColor = System.Drawing.Color.Red;
                LabelMsg.Text = "&#x65E0;&#x6CD5;&#x83B7;&#x53D6;&#x7528;&#x6237;ID&#xFF0C;&#x8BF7;&#x91CD;&#x65B0;&#x767B;&#x5F55;&#x7BA1;&#x7406;&#x540E;&#x53F0;";
            }
        }
    }

    private void LoadProfile(int hid)
    {
        try
        {
            DataRow row = GetTeacherInfo(hid);
            if (row == null) return;
            dbAvailable = true;
            currentHname = row["Hname"] != DBNull.Value ? row["Hname"].ToString() : currentHname;
            currentHnick = row["Hnick"] != DBNull.Value ? row["Hnick"].ToString() : currentHnick;
            currentHnote = row["Hnote"] != DBNull.Value ? row["Hnote"].ToString() : "";
            currentHemail = row["Hemail"] != DBNull.Value ? row["Hemail"].ToString() : "";
            TextBoxNick.Text = currentHnick;
            string avatar = row["Havatar"] != DBNull.Value ? row["Havatar"].ToString() : "";
            if (!string.IsNullOrEmpty(avatar))
            {
                currentAvatarUrl = ResolveUrl(avatar) + "?t=" + DateTime.Now.Ticks;
            }
        }
        catch
        {
            // DB unavailable - cookie data already loaded, show warning
            dbAvailable = false;
        }
    }

    protected void BtnSaveNick_Click(object sender, EventArgs e)
    {
        int hid = GetCurrentHid();
        if (hid <= 0) return;
        try
        {
            using (SqlConnection conn = new SqlConnection(GetConnStr()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("UPDATE Teacher SET Hnick=@nick WHERE Hid=@hid", conn);
                cmd.Parameters.AddWithValue("@nick", TextBoxNick.Text.Trim());
                cmd.Parameters.AddWithValue("@hid", hid);
                cmd.ExecuteNonQuery();
            }
            LabelMsg.ForeColor = System.Drawing.Color.Green;
            LabelMsg.Text = "OK &#x2713;";
            LoadProfile(hid);
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "Save error: " + ex.Message;
        }
    }

    protected void BtnChangePwd_Click(object sender, EventArgs e)
    {
        int hid = GetCurrentHid();
        if (hid <= 0) return;
        string oldPwd = TextBoxOldPwd.Text.Trim();
        string newPwd = TextBoxNewPwd.Text.Trim();
        string confirmPwd = TextBoxConfirmPwd.Text.Trim();
        if (string.IsNullOrEmpty(oldPwd) || string.IsNullOrEmpty(newPwd))
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "Please fill all password fields";
            return;
        }
        if (newPwd != confirmPwd)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "New passwords do not match";
            return;
        }
        if (newPwd.Length < 3)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "Password too short (min 3)";
            return;
        }
        try
        {
            using (SqlConnection conn = new SqlConnection(GetConnStr()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("SELECT Hpwd FROM Teacher WHERE Hid=@hid", conn);
                cmd.Parameters.AddWithValue("@hid", hid);
                object result = cmd.ExecuteScalar();
                if (result == null || result.ToString() != oldPwd)
                {
                    LabelMsg.ForeColor = System.Drawing.Color.Red;
                    LabelMsg.Text = "Wrong old password";
                    return;
                }
                SqlCommand upd = new SqlCommand("UPDATE Teacher SET Hpwd=@pwd WHERE Hid=@hid", conn);
                upd.Parameters.AddWithValue("@pwd", newPwd);
                upd.Parameters.AddWithValue("@hid", hid);
                upd.ExecuteNonQuery();
            }
            TextBoxOldPwd.Text = "";
            TextBoxNewPwd.Text = "";
            TextBoxConfirmPwd.Text = "";
            LabelMsg.ForeColor = System.Drawing.Color.Green;
            LabelMsg.Text = "Password changed OK &#x2713;";
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "Error: " + ex.Message;
        }
    }

    protected string GetAvatarUrl()
    {
        return currentAvatarUrl;
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .pf-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .pf-hd{display:flex;align-items:center;gap:16px;margin-bottom:28px;}
    .pf-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#6366f1,#a78bfa);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(99,102,241,.25);flex-shrink:0;}
    .pf-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .pf-hd h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .pf-hd p{font-size:13px;color:#94a3b8;margin:0;}
    .pf-grid{display:grid;grid-template-columns:1fr 1fr;gap:20px;}
    .pf-grid .pf-full{grid-column:1/-1;}
    @media(max-width:860px){.pf-grid{grid-template-columns:1fr;}}
    .pf-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;}
    .pf-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);}
    .pf-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .pf-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .pf-card-hd .ci svg{width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.indigo{background:#eef2ff;} .ci.indigo svg{stroke:#6366f1;}
    .ci.emerald{background:#ecfdf5;} .ci.emerald svg{stroke:#10b981;}
    .ci.sky{background:#f0f9ff;} .ci.sky svg{stroke:#0ea5e9;}
    .ci.rose{background:#fff1f2;} .ci.rose svg{stroke:#f43f5e;}
    .pf-card-bd{padding:22px;}
    .pf-row{display:flex;align-items:center;padding:12px 0;border-bottom:1px solid #f8fafc;gap:14px;font-size:13.5px;}
    .pf-row:last-child{border-bottom:none;}
    .pf-label{min-width:90px;font-weight:500;color:#475569;flex-shrink:0;text-align:right;font-size:13px;}
    .pf-val{flex:1;display:flex;align-items:center;gap:10px;flex-wrap:wrap;}
    .pf-val-text{color:#1e293b;font-weight:500;}
    .pf-card input[type="text"],.pf-card input[type="password"]{height:36px;padding:0 14px;border:1.5px solid #e2e8f0;border-radius:9px;font-size:13.5px;font-family:inherit;outline:none;transition:border-color .2s,box-shadow .2s;background:#f8fafc;min-width:200px;}
    .pf-card input[type="text"]:focus,.pf-card input[type="password"]:focus{border-color:#6366f1;box-shadow:0 0 0 3px rgba(99,102,241,.08);background:#fff;}
    .btn-primary{display:inline-flex;align-items:center;justify-content:center;gap:6px;height:36px;padding:0 20px;background:linear-gradient(135deg,#6366f1,#7c3aed);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;box-shadow:0 2px 6px rgba(99,102,241,.3);}
    .btn-primary:hover{box-shadow:0 4px 14px rgba(99,102,241,.4);transform:translateY(-1px);}
    .avatar-center{text-align:center;padding:30px 22px;}
    .avatar-wrap{position:relative;display:inline-block;cursor:pointer;}
    .avatar-wrap input[type="file"]{display:none;}
    .avatar-img{width:120px;height:120px;border-radius:50%;object-fit:cover;border:3px solid #e2e8f0;overflow:hidden;}
    .avatar-img img{width:100%;height:100%;object-fit:cover;}
    .avatar-placeholder{width:120px;height:120px;border-radius:50%;background:linear-gradient(135deg,#6366f1,#a78bfa);display:flex;align-items:center;justify-content:center;color:#fff;font-size:40px;font-weight:700;}
    .avatar-overlay{position:absolute;inset:0;border-radius:50%;background:rgba(99,102,241,.75);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:4px;opacity:0;transition:opacity .25s;}
    .avatar-wrap:hover .avatar-overlay{opacity:1;}
    .avatar-overlay svg{width:24px;height:24px;stroke:#fff;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}
    .avatar-overlay span{font-size:12px;color:#fff;font-weight:500;}
    .avatar-name{margin-top:14px;font-size:18px;font-weight:700;color:#1e293b;}
    .avatar-role{font-size:13px;color:#94a3b8;margin-top:2px;}
    .avatar-toast{margin-top:10px;font-size:12px;min-height:18px;display:inline-flex;align-items:center;gap:5px;padding:2px 10px;border-radius:6px;}
    .avatar-toast.success{color:#059669;background:#ecfdf5;}
    .avatar-toast.error{color:#dc2626;background:#fef2f2;}
    .avatar-toast.loading{color:#6366f1;background:#eef2ff;}
    .pf-msg{text-align:center;padding:10px;font-size:13px;margin-top:8px;}
    .db-warn{background:#fef3c7;border:1px solid #fbbf24;border-radius:10px;padding:12px 18px;margin-bottom:18px;display:flex;align-items:center;gap:10px;font-size:13px;color:#92400e;}
    .db-warn svg{width:20px;height:20px;stroke:#f59e0b;fill:none;stroke-width:2;flex-shrink:0;}
</style>

<div class="pf-page">
    <% if (!dbAvailable && currentHid > 0) { %>
    <div class="db-warn">
        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        &#x6570;&#x636E;&#x5E93;&#x8FDE;&#x63A5;&#x4E0D;&#x53EF;&#x7528;&#xFF0C;&#x5F53;&#x524D;&#x663E;&#x793A;&#x7684;&#x662F;Cookie&#x4E2D;&#x7684;&#x57FA;&#x672C;&#x4FE1;&#x606F;&#x3002;&#x7F16;&#x8F91;&#x529F;&#x80FD;&#x9700;&#x8981;&#x6570;&#x636E;&#x5E93;&#x8FDE;&#x63A5;&#x6B63;&#x5E38;&#x540E;&#x624D;&#x80FD;&#x4F7F;&#x7528;&#x3002;
    </div>
    <% } %>
    <div class="pf-hd">
        <div class="pf-hd-icon"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
        <div><h1>&#x4E2A;&#x4EBA;&#x4E2D;&#x5FC3;</h1><p>&#x7BA1;&#x7406;&#x60A8;&#x7684;&#x4E2A;&#x4EBA;&#x8D44;&#x6599;&#x3001;&#x5934;&#x50CF;&#x548C;&#x8D26;&#x6237;&#x5B89;&#x5168;</p></div>
    </div>

    <div class="pf-grid">
    <div class="pf-card">
        <div class="pf-card-hd"><span class="ci indigo"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>&#x6211;&#x7684;&#x5934;&#x50CF;</div>
        <div class="avatar-center">
            <div class="avatar-wrap" id="avatarWrap">
                <input type="file" id="avatarFileInput" accept=".png,.jpg,.jpeg,.gif,.webp" />
                <div id="avatarDisplay">
                    <% if (!string.IsNullOrEmpty(currentAvatarUrl)) { %>
                        <div class="avatar-img"><img id="avatarImg" src="<%= currentAvatarUrl %>" /></div>
                    <% } else { %>
                        <div class="avatar-placeholder"><%= !string.IsNullOrEmpty(currentHname) ? currentHname.Substring(0,1) : "?" %></div>
                    <% } %>
                </div>
                <div class="avatar-overlay">
                    <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                    <span>&#x66F4;&#x6362;</span>
                </div>
            </div>
            <div class="avatar-name"><%= Server.HtmlEncode(currentHname) %></div>
            <div class="avatar-role"><%= !string.IsNullOrEmpty(currentHnick) ? Server.HtmlEncode(currentHnick) : "&#x7BA1;&#x7406;&#x5458;" %></div>
            <div class="avatar-toast" id="avatarToast"></div>
        </div>
    </div>

    <div class="pf-card">
        <div class="pf-card-hd"><span class="ci sky"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg></span>&#x57FA;&#x672C;&#x4FE1;&#x606F;</div>
        <div class="pf-card-bd">
            <div class="pf-row"><div class="pf-label">&#x7528;&#x6237;&#x540D;</div><div class="pf-val"><span class="pf-val-text"><%= Server.HtmlEncode(currentHname) %></span></div></div>
            <div class="pf-row"><div class="pf-label">&#x6635;&#x79F0;</div><div class="pf-val"><asp:TextBox ID="TextBoxNick" runat="server" Width="200px" /><asp:Button ID="BtnSaveNick" runat="server" Text="&#x4FDD;&#x5B58;" CssClass="btn-primary" OnClick="BtnSaveNick_Click" /></div></div>
            <div class="pf-row"><div class="pf-label">&#x5907;&#x6CE8;</div><div class="pf-val"><span style="color:#64748b;"><%= Server.HtmlEncode(currentHnote) %></span></div></div>
        </div>
    </div>

    <div class="pf-card">
        <div class="pf-card-hd"><span class="ci emerald"><svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg></span>&#x90AE;&#x7BB1;&#x7ED1;&#x5B9A;</div>
        <div class="pf-card-bd">
            <div class="pf-row">
                <div class="pf-label">&#x5F53;&#x524D;&#x90AE;&#x7BB1;</div>
                <div class="pf-val">
                    <span class="pf-val-text" id="currentEmailDisplay"><%= string.IsNullOrEmpty(currentHemail) ? "&#x672A;&#x7ED1;&#x5B9A;" : Server.HtmlEncode(currentHemail) %></span>
                    <button type="button" class="btn-primary" onclick="showEmailModal()">
                        <svg viewBox="0 0 24 24" width="14" height="14" style="stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                        <%= string.IsNullOrEmpty(currentHemail) ? "&#x7ED1;&#x5B9A;" : "&#x4FEE;&#x6539;" %>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="pf-card">
        <div class="pf-card-hd"><span class="ci rose"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>&#x4FEE;&#x6539;&#x5BC6;&#x7801;</div>
        <div class="pf-card-bd">
            <div class="pf-row"><div class="pf-label">&#x65E7;&#x5BC6;&#x7801;</div><div class="pf-val"><asp:TextBox ID="TextBoxOldPwd" runat="server" TextMode="Password" Width="200px" /></div></div>
            <div class="pf-row"><div class="pf-label">&#x65B0;&#x5BC6;&#x7801;</div><div class="pf-val"><asp:TextBox ID="TextBoxNewPwd" runat="server" TextMode="Password" Width="200px" /></div></div>
            <div class="pf-row"><div class="pf-label">&#x786E;&#x8BA4;</div><div class="pf-val"><asp:TextBox ID="TextBoxConfirmPwd" runat="server" TextMode="Password" Width="200px" /></div></div>
            <div style="padding:12px 0 0 104px;"><asp:Button ID="BtnChangePwd" runat="server" Text="&#x4FEE;&#x6539;&#x5BC6;&#x7801;" CssClass="btn-primary" OnClick="BtnChangePwd_Click" /></div>
        </div>
    </div>
    </div>

    <div class="pf-msg"><asp:Label ID="LabelMsg" runat="server"></asp:Label></div>
</div>

<!-- 邮箱绑定弹窗 -->
<div id="emailModal" class="email-modal" style="display:none;">
    <div class="email-modal-content">
        <div class="email-modal-header">
            <h3>绑定邮箱</h3>
            <button class="email-modal-close" onclick="closeEmailModal()">&times;</button>
        </div>
        <div class="email-modal-body">
            <div id="emailAlert" class="email-alert" style="display:none;"></div>
            
            <div class="email-form-group">
                <label>邮箱地址</label>
                <input type="email" id="emailInput" placeholder="请输入您的邮箱地址" />
            </div>
            
            <div class="email-form-group">
                <label>验证码</label>
                <div class="email-code-group">
                    <input type="text" id="emailCode" placeholder="请输入6位验证码" maxlength="6" />
                    <button type="button" id="sendEmailCodeBtn" onclick="sendEmailCode()">发送验证码</button>
                </div>
            </div>
            
            <button type="button" class="email-btn-primary" onclick="bindEmail()">确认绑定</button>
        </div>
    </div>
</div>

<style>
.email-modal {
    position: fixed;
    z-index: 9999;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    display: flex;
    align-items: center;
    justify-content: center;
}
.email-modal-content {
    background: #fff;
    border-radius: 16px;
    width: 90%;
    max-width: 500px;
    box-shadow: 0 20px 60px rgba(0,0,0,0.3);
    animation: slideIn 0.3s ease;
}
@keyframes slideIn {
    from { transform: translateY(-50px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}
.email-modal-header {
    padding: 20px 24px;
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.email-modal-header h3 {
    font-size: 20px;
    font-weight: 700;
    color: #1e293b;
    margin: 0;
}
.email-modal-close {
    width: 32px;
    height: 32px;
    border: none;
    background: #f1f5f9;
    border-radius: 8px;
    font-size: 24px;
    color: #64748b;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;
    line-height: 1;
}
.email-modal-close:hover {
    background: #e2e8f0;
    transform: rotate(90deg);
}
.email-modal-body {
    padding: 24px;
}
.email-alert {
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 16px;
    font-size: 14px;
}
.email-alert.success {
    background: #d1fae5;
    color: #065f46;
    border: 1px solid #10b981;
}
.email-alert.error {
    background: #fee2e2;
    color: #991b1b;
    border: 1px solid #ef4444;
}
.email-form-group {
    margin-bottom: 20px;
}
.email-form-group label {
    display: block;
    font-size: 14px;
    font-weight: 600;
    color: #475569;
    margin-bottom: 8px;
}
.email-form-group input[type="email"],
.email-form-group input[type="text"] {
    width: 100%;
    padding: 10px 14px;
    border: 1.5px solid #e2e8f0;
    border-radius: 8px;
    font-size: 14px;
    transition: all 0.2s;
}
.email-form-group input:focus {
    outline: none;
    border-color: #6366f1;
    box-shadow: 0 0 0 3px rgba(99,102,241,0.1);
}
.email-code-group {
    display: flex;
    gap: 10px;
}
.email-code-group input {
    flex: 1;
}
.email-code-group button {
    padding: 10px 20px;
    background: linear-gradient(135deg, #10b981, #059669);
    color: #fff;
    border: none;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    white-space: nowrap;
    transition: all 0.2s;
}
.email-code-group button:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(16,185,129,0.4);
}
.email-code-group button:disabled {
    background: #cbd5e1;
    cursor: not-allowed;
    transform: none;
}
.email-btn-primary {
    width: 100%;
    padding: 12px;
    background: linear-gradient(135deg, #6366f1, #8b5cf6);
    color: #fff;
    border: none;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
}
.email-btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(99,102,241,0.4);
}
</style>

<script type="text/javascript">
(function() {
    var uploadUrl = '<%= ResolveUrl("~/manager/uploadavatar.ashx") %>';
    var wrap = document.getElementById('avatarWrap');
    var input = document.getElementById('avatarFileInput');
    var toast = document.getElementById('avatarToast');
    if (!wrap || !input) return;
    wrap.onclick = function(e) { if (e.target !== input) input.click(); };
    input.onchange = function() { if (input.files && input.files.length > 0) uploadAvatar(input.files[0]); };
    function showToast(type, msg) {
        toast.className = 'avatar-toast ' + type;
        toast.innerHTML = msg;
        if (type === 'success') setTimeout(function() { toast.className='avatar-toast'; toast.innerHTML=''; }, 3000);
    }
    function uploadAvatar(file) {
        showToast('loading', 'Uploading...');
        var fd = new FormData();
        fd.append('file', file);
        var xhr; try{xhr=new XMLHttpRequest();}catch(e){try{xhr=new ActiveXObject("Microsoft.XMLHTTP");}catch(e2){return;}}
        xhr.open('POST', uploadUrl, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    try {
                        var r = eval('(' + xhr.responseText + ')');
                        if (r.success === 1) { showToast('success', r.message); if (r.url) { var d=document.getElementById('avatarDisplay'); d.innerHTML='<div class="avatar-img"><img src="'+r.url+'" /></div>'; } }
                        else showToast('error', r.message);
                    } catch(e) { showToast('error', 'Parse error'); }
                } else showToast('error', 'Network error');
            }
        };
        xhr.send(fd);
    }
})();

// 邮箱绑定功能
var emailCountdown = 60;
var emailCountdownTimer = null;

function showEmailModal() {
    document.getElementById('emailModal').style.display = 'flex';
    var currentEmail = document.getElementById('currentEmailDisplay').innerText;
    if (currentEmail && currentEmail !== '未绑定') {
        document.getElementById('emailInput').value = currentEmail;
    }
}

function closeEmailModal() {
    document.getElementById('emailModal').style.display = 'none';
    document.getElementById('emailInput').value = '';
    document.getElementById('emailCode').value = '';
    document.getElementById('emailAlert').style.display = 'none';
}

function showEmailAlert(message, type) {
    var alert = document.getElementById('emailAlert');
    alert.innerHTML = message;  // 改用 innerHTML 支持 HTML 内容
    alert.className = 'email-alert ' + type;
    alert.style.display = 'block';
    
    setTimeout(function() {
        alert.style.display = 'none';
    }, 8000);  // 延长到8秒，给用户更多时间看到链接
}

function sendEmailCode() {
    var email = document.getElementById('emailInput').value.trim();
    var btn = document.getElementById('sendEmailCodeBtn');
    
    if (!email) {
        showEmailAlert('请输入邮箱地址', 'error');
        return;
    }
    
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        showEmailAlert('请输入有效的邮箱地址', 'error');
        return;
    }
    
    if (btn.disabled) return;
    
    btn.disabled = true;
    btn.textContent = '发送中...';
    
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '<%= ResolveUrl("~/manager/bindemail.ashx") %>?action=sendcode&email=' + encodeURIComponent(email), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.success) {
                        showEmailAlert('验证码已发送到您的邮箱', 'success');
                        startEmailCountdown();
                    } else {
                        var msg = data.message || '发送失败';
                        // 翻译英文错误信息
                        if (msg === 'Not logged in') msg = '未登录';
                        else if (msg === 'Email required') msg = '邮箱地址不能为空';
                        else if (msg === 'Code sent') msg = '验证码已发送';
                        else if (msg.indexOf('Email send error') === 0) {
                            msg = '邮件发送失败：' + msg.replace('Email send error: ', '');
                            if (msg.indexOf('Config error') >= 0 || msg.indexOf('not configured') >= 0) {
                                msg += '<br><a href="/manager/emailsetting.aspx" target="_blank" style="color:#6366f1;text-decoration:underline;">点击配置邮箱服务</a>';
                            }
                        }
                        else if (msg.indexOf('Config error') >= 0 || msg.indexOf('not configured') >= 0) {
                            msg = '邮箱服务未配置<br><a href="/manager/emailsetting.aspx" target="_blank" style="color:#6366f1;text-decoration:underline;">点击前往配置</a>';
                        }
                        showEmailAlert(msg, 'error');
                        btn.disabled = false;
                        btn.textContent = '发送验证码';
                    }
                } catch(e) {
                    showEmailAlert('服务器响应错误', 'error');
                    btn.disabled = false;
                    btn.textContent = '发送验证码';
                }
            } else {
                showEmailAlert('网络错误，请稍后重试', 'error');
                btn.disabled = false;
                btn.textContent = '发送验证码';
            }
        }
    };
    xhr.send();
}

function startEmailCountdown() {
    var btn = document.getElementById('sendEmailCodeBtn');
    emailCountdown = 60;
    
    emailCountdownTimer = setInterval(function() {
        emailCountdown--;
        btn.textContent = emailCountdown + '秒后重发';
        
        if (emailCountdown <= 0) {
            clearInterval(emailCountdownTimer);
            btn.disabled = false;
            btn.textContent = '发送验证码';
        }
    }, 1000);
}

function bindEmail() {
    var email = document.getElementById('emailInput').value.trim();
    var code = document.getElementById('emailCode').value.trim();
    
    if (!email) {
        showEmailAlert('请输入邮箱地址', 'error');
        return;
    }
    
    if (!code || code.length !== 6) {
        showEmailAlert('请输入6位验证码', 'error');
        return;
    }
    
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '<%= ResolveUrl("~/manager/bindemail.ashx") %>?action=bind&email=' + encodeURIComponent(email) + '&code=' + encodeURIComponent(code), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.success) {
                        showEmailAlert('邮箱绑定成功！', 'success');
                        setTimeout(function() {
                            location.reload();
                        }, 1500);
                    } else {
                        var msg = data.message || '绑定失败';
                        if (msg === 'Not logged in') msg = '未登录';
                        else if (msg === 'Parameter error') msg = '参数错误';
                        else if (msg === 'Get code first') msg = '请先获取验证码';
                        else if (msg === 'Session error') msg = '会话错误';
                        else if (msg === 'Code expired') msg = '验证码已过期';
                        else if (msg === 'Code incorrect') msg = '验证码错误';
                        else if (msg === 'Database connection failed') msg = '数据库连接失败';
                        else if (msg === 'Bind failed') msg = '绑定失败';
                        else if (msg === 'Email bound') msg = '邮箱已绑定';
                        showEmailAlert(msg, 'error');
                    }
                } catch(e) {
                    showEmailAlert('服务器响应错误', 'error');
                }
            } else {
                showEmailAlert('网络错误，请稍后重试', 'error');
            }
        }
    };
    xhr.send();
}
</script>
</asp:Content>
