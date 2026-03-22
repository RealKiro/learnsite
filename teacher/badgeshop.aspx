<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" %>

<script runat="server">
    protected int myHid = 0;
    protected string pageMsg = "";

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

    private void LoadTeacher()
    {
        try
        {
            HttpCookie tc = Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
            if (tc != null && !string.IsNullOrEmpty(tc.Value))
            {
                Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.TeaCook");
                if (ct != null)
                {
                    object m = Activator.CreateInstance(ct);
                    System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                        System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Static);
                    if (mi != null) mi.Invoke(m, new object[] { tc.Value });
                    System.Reflection.PropertyInfo p = ct.GetProperty("Hid");
                    if (p != null) { object v = p.GetValue(m, null); if (v != null) int.TryParse(v.ToString(), out myHid); }
                }
            }
        }
        catch { }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadTeacher();
        if (!IsPostBack) LoadItems();
    }

    protected void BtnEdit_Click(object sender, EventArgs e)
    {
        int editId = 0;
        int.TryParse(HiddenEditId.Value, out editId);
        if (editId <= 0) { pageMsg = "无效的商品ID"; LoadItems(); return; }

        string name = TxtEditName.Text.Trim();
        if (string.IsNullOrEmpty(name)) { pageMsg = "请输入商品名称"; LoadEditItem(editId); return; }
        
        int cost = 0; int.TryParse(TxtEditCost.Text.Trim(), out cost);
        int stock = -1; if (!string.IsNullOrEmpty(TxtEditStock.Text.Trim())) int.TryParse(TxtEditStock.Text.Trim(), out stock);
        
        string iconPath = TxtEditIcon.Text.Trim();
        
        // 处理图片上传
        if (FileUploadEditIcon.HasFile)
        {
            try
            {
                string fileName = FileUploadEditIcon.FileName;
                string fileExt = System.IO.Path.GetExtension(fileName).ToLower();
                
                if (fileExt != ".jpg" && fileExt != ".jpeg" && fileExt != ".png" && fileExt != ".gif")
                {
                    pageMsg = "只支持 JPG、PNG、GIF 格式的图片";
                    LoadEditItem(editId);
                    return;
                }
                
                if (FileUploadEditIcon.PostedFile.ContentLength > 2 * 1024 * 1024)
                {
                    pageMsg = "图片大小不能超过 2MB";
                    LoadEditItem(editId);
                    return;
                }
                
                string newFileName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Guid.NewGuid().ToString("N").Substring(0, 8) + fileExt;
                string uploadFolder = Server.MapPath("~/images/shop/");
                
                if (!System.IO.Directory.Exists(uploadFolder))
                {
                    System.IO.Directory.CreateDirectory(uploadFolder);
                }
                
                string filePath = System.IO.Path.Combine(uploadFolder, newFileName);
                FileUploadEditIcon.SaveAs(filePath);
                iconPath = "~/images/shop/" + newFileName;
            }
            catch (Exception ex)
            {
                pageMsg = "图片上传失败: " + ex.Message;
                LoadEditItem(editId);
                return;
            }
        }
        
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "UPDATE BadgeShopItem SET Sname=@name,Sdesc=@desc,Sicon=@icon,Scost=@cost,Sstock=@stock WHERE Sid=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@desc", TxtEditDesc.Text.Trim());
                    cmd.Parameters.AddWithValue("@icon", iconPath);
                    cmd.Parameters.AddWithValue("@cost", cost);
                    cmd.Parameters.AddWithValue("@stock", stock);
                    cmd.Parameters.AddWithValue("@id", editId);
                    cmd.ExecuteNonQuery();
                }
            }
            pageMsg = "修改成功";
            PanelEdit.Visible = false;
            HiddenEditId.Value = "";
        }
        catch (Exception ex) { pageMsg = "修改失败: " + ex.Message; }
        LoadItems();
    }

    protected void BtnCancelEdit_Click(object sender, EventArgs e)
    {
        PanelEdit.Visible = false;
        HiddenEditId.Value = "";
        LoadItems();
    }

    private void LoadEditItem(int id)
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT Sname,Sdesc,Sicon,Scost,Sstock FROM BadgeShopItem WHERE Sid=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        TxtEditName.Text = dr["Sname"] == DBNull.Value ? "" : dr["Sname"].ToString();
                        TxtEditDesc.Text = dr["Sdesc"] == DBNull.Value ? "" : dr["Sdesc"].ToString();
                        TxtEditIcon.Text = dr["Sicon"] == DBNull.Value ? "" : dr["Sicon"].ToString();
                        TxtEditCost.Text = dr["Scost"] == DBNull.Value ? "0" : dr["Scost"].ToString();
                        int stock = dr["Sstock"] == DBNull.Value ? -1 : Convert.ToInt32(dr["Sstock"]);
                        TxtEditStock.Text = stock.ToString();
                        PanelEdit.Visible = true;
                        HiddenEditId.Value = id.ToString();
                    }
                    dr.Close();
                }
            }
        }
        catch { }
        LoadItems();
    }

    private void LoadItems()
    {
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                System.Data.SqlClient.SqlDataAdapter da = new System.Data.SqlClient.SqlDataAdapter(
                    "SELECT Sid,Sname,Sdesc,Sicon,Scost,Sstock,Sactive,Sdate FROM BadgeShopItem ORDER BY Sid", conn);
                System.Data.DataTable dt = new System.Data.DataTable();
                da.Fill(dt);
                RptItems.DataSource = dt;
                RptItems.DataBind();
            }
        }
        catch { }
    }

    protected void BtnAdd_Click(object sender, EventArgs e)
    {
        string name = TxtName.Text.Trim();
        if (string.IsNullOrEmpty(name)) { pageMsg = "请输入商品名称"; LoadItems(); return; }
        int cost = 0; int.TryParse(TxtCost.Text.Trim(), out cost);
        int stock = -1; if (!string.IsNullOrEmpty(TxtStock.Text.Trim())) int.TryParse(TxtStock.Text.Trim(), out stock);
        
        // 处理图片上传
        string iconPath = TxtIcon.Text.Trim();
        if (FileUploadIcon.HasFile)
        {
            try
            {
                string fileName = FileUploadIcon.FileName;
                string fileExt = System.IO.Path.GetExtension(fileName).ToLower();
                
                // 验证文件类型
                if (fileExt != ".jpg" && fileExt != ".jpeg" && fileExt != ".png" && fileExt != ".gif")
                {
                    pageMsg = "只支持 JPG、PNG、GIF 格式的图片";
                    LoadItems();
                    return;
                }
                
                // 验证文件大小（限制为2MB）
                if (FileUploadIcon.PostedFile.ContentLength > 2 * 1024 * 1024)
                {
                    pageMsg = "图片大小不能超过 2MB";
                    LoadItems();
                    return;
                }
                
                // 生成唯一文件名
                string newFileName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Guid.NewGuid().ToString("N").Substring(0, 8) + fileExt;
                string uploadFolder = Server.MapPath("~/images/shop/");
                
                // 确保目录存在
                if (!System.IO.Directory.Exists(uploadFolder))
                {
                    System.IO.Directory.CreateDirectory(uploadFolder);
                }
                
                string filePath = System.IO.Path.Combine(uploadFolder, newFileName);
                FileUploadIcon.SaveAs(filePath);
                
                // 保存相对路径到数据库
                iconPath = "~/images/shop/" + newFileName;
            }
            catch (Exception ex)
            {
                pageMsg = "图片上传失败: " + ex.Message;
                LoadItems();
                return;
            }
        }
        
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "INSERT INTO BadgeShopItem(Sname,Sdesc,Sicon,Scost,Sstock,Shid,Sdate,Sactive) VALUES(@name,@desc,@icon,@cost,@stock,@hid,GETDATE(),1)", conn))
                {
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@desc", TxtDesc.Text.Trim());
                    cmd.Parameters.AddWithValue("@icon", iconPath);
                    cmd.Parameters.AddWithValue("@cost", cost);
                    cmd.Parameters.AddWithValue("@stock", stock);
                    cmd.Parameters.AddWithValue("@hid", myHid);
                    cmd.ExecuteNonQuery();
                }
            }
            TxtName.Text = ""; TxtDesc.Text = ""; TxtIcon.Text = ""; TxtCost.Text = ""; TxtStock.Text = "";
            pageMsg = "添加成功";
        }
        catch (Exception ex) { pageMsg = "添加失败: " + ex.Message; }
        LoadItems();
    }

    protected void RptItems_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
    {
        int id = 0; int.TryParse(e.CommandArgument.ToString(), out id);
        if (id <= 0) return;
        string cs = GetConnStr(); if (string.IsNullOrEmpty(cs)) return;

        if (e.CommandName == "Edit")
        {
            LoadEditItem(id);
            return;
        }
        else if (e.CommandName == "Del")
        {
            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
                {
                    conn.Open();
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("DELETE FROM BadgeShopItem WHERE Sid=@id", conn))
                    { cmd.Parameters.AddWithValue("@id", id); cmd.ExecuteNonQuery(); }
                }
                pageMsg = "已删除";
            }
            catch (Exception ex) { pageMsg = "删除失败: " + ex.Message; }
        }
        else if (e.CommandName == "Toggle")
        {
            try
            {
                using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
                {
                    conn.Open();
                    using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                        "UPDATE BadgeShopItem SET Sactive=CASE WHEN ISNULL(Sactive,1)=1 THEN 0 ELSE 1 END WHERE Sid=@id", conn))
                    { cmd.Parameters.AddWithValue("@id", id); cmd.ExecuteNonQuery(); }
                }
            }
            catch { }
        }
        LoadItems();
    }

    protected string FormatStock(object stockObj)
    {
        if (stockObj == DBNull.Value) return "无限";
        int s = Convert.ToInt32(stockObj);
        return s < 0 ? "无限" : s.ToString();
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .bsp-page { max-width: 1600px; width: 100%; margin: 0 auto; }
    .bsp-header { margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1; }
    .bsp-title { font-size: 22px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 12px; }
    .bsp-title .bsp-icon { width: 40px; height: 40px; background: linear-gradient(135deg,#ec4899,#f472b6); border-radius: 10px; display: flex; align-items: center; justify-content: center; }
    .bsp-title .bsp-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .bsp-subtitle { font-size: 13px; color: #94a3b8; margin-top: 6px; margin-left: 52px; }
    .bsp-card { background: #fff; border-radius: 12px; border: 1px solid #e8ecf1; box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden; }
    .bsp-card-head { padding: 16px 24px; border-bottom: 1px solid #f1f5f9; background: #fafbfc; font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .bsp-card-head svg { width: 18px; height: 18px; stroke: #ec4899; fill: none; stroke-width: 2; }
    .bsp-table { width: 100%; border-collapse: collapse; }
    .bsp-table th { background: #f8fafc; color: #64748b; font-weight: 600; font-size: 12px; padding: 12px 16px; border-bottom: 2px solid #e8ecf1; text-align: left; }
    .bsp-table td { padding: 12px 16px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #334155; }
    .bsp-table tr:hover td { background: #fdf2f8; }
    .bsp-table tr:last-child td { border-bottom: none; }
    .bsp-status { display: inline-flex; padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; }
    .bsp-status-on { background: #dcfce7; color: #16a34a; }
    .bsp-status-off { background: #fee2e2; color: #dc2626; }
    .bsp-cost { font-weight: 700; color: #ec4899; }
    .bsp-add-area { padding: 24px; background: #fafbfc; border-top: 1px solid #f1f5f9; }
    .bsp-add-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px; }
    .bsp-form-group { display: flex; flex-direction: column; gap: 6px; }
    .bsp-form-group label { font-size: 12px; font-weight: 600; color: #64748b; }
    .bsp-form-group input, .bsp-form-group textarea { padding: 8px 14px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 13px; color: #334155; background: #fff; outline: none; font-family: inherit; }
    .bsp-form-group input:focus, .bsp-form-group textarea:focus { border-color: #ec4899; box-shadow: 0 0 0 3px rgba(236,72,153,.1); }
    .bsp-file-upload { padding: 8px 14px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 13px; color: #334155; background: #fff; width: 100%; cursor: pointer; }
    .bsp-file-upload::-webkit-file-upload-button { padding: 6px 12px; border-radius: 6px; border: 1px solid #e2e8f0; background: #f8fafc; color: #475569; font-size: 12px; cursor: pointer; margin-right: 10px; }
    .bsp-file-upload::-webkit-file-upload-button:hover { background: #f1f5f9; }
    .bsp-btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 20px; border-radius: 8px; font-size: 13px; font-weight: 500; border: 1px solid #e2e8f0; background: #fff; color: #475569; cursor: pointer; transition: all .18s; font-family: inherit; }
    .bsp-btn:hover { background: #f8fafc; }
    .bsp-btn-primary { background: linear-gradient(135deg,#ec4899,#f472b6); color: #fff; border-color: #ec4899; }
    .bsp-btn-primary:hover { background: linear-gradient(135deg,#db2777,#ec4899); }
    .bsp-btn-sm { padding: 4px 12px; font-size: 12px; border-radius: 6px; }
    .bsp-btn-edit { color: #3b82f6; border-color: #bfdbfe; }
    .bsp-btn-edit:hover { background: #eff6ff; }
    .bsp-btn-danger { color: #ef4444; border-color: #fecaca; }
    .bsp-btn-danger:hover { background: #fef2f2; }
    .bsp-msg { padding: 10px 16px; border-radius: 8px; background: #fdf2f8; border: 1px solid #fbcfe8; color: #9d174d; font-size: 13px; margin-bottom: 16px; }
    .bsp-empty { padding: 40px 20px; text-align: center; color: #94a3b8; font-size: 14px; }
    .bsp-actions { display: flex; gap: 6px; }
</style>

<div class="bsp-page">
    <div class="bsp-header">
        <div class="bsp-title">
            <span class="bsp-icon"><svg viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 01-8 0"/></svg></span>
            徽章商城设置
        </div>
        <div class="bsp-subtitle">管理兑换商城的奖品项目，设置名称、积分消耗和库存</div>
    </div>

    <% if (!string.IsNullOrEmpty(pageMsg)) { %>
    <div class="bsp-msg"><%= Server.HtmlEncode(pageMsg) %></div>
    <% } %>

    <!-- 编辑商品面板 -->
    <asp:Panel ID="PanelEdit" runat="server" Visible="false">
        <div class="bsp-card" style="border: 2px solid #ec4899; box-shadow: 0 4px 12px rgba(236,72,153,.15);">
            <div class="bsp-card-head" style="background: linear-gradient(135deg,#fdf2f8,#fce7f3);">
                <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                编辑商品
            </div>
            <div class="bsp-add-area" style="border-top: none;">
                <asp:HiddenField ID="HiddenEditId" runat="server" />
                <div class="bsp-add-grid">
                    <div class="bsp-form-group">
                        <label>商品名称 *</label>
                        <asp:TextBox ID="TxtEditName" runat="server" MaxLength="100" placeholder="如：免作业卡" />
                    </div>
                    <div class="bsp-form-group">
                        <label>所需积分 *</label>
                        <asp:TextBox ID="TxtEditCost" runat="server" MaxLength="10" placeholder="如：50" />
                    </div>
                    <div class="bsp-form-group">
                        <label>库存（-1=无限）</label>
                        <asp:TextBox ID="TxtEditStock" runat="server" MaxLength="10" placeholder="-1 表示无限" />
                    </div>
                    <div class="bsp-form-group">
                        <label>图标URL（可选）</label>
                        <asp:TextBox ID="TxtEditIcon" runat="server" MaxLength="500" placeholder="如：../images/shop/card.png" />
                        <div id="editIconPreview" style="margin-top:8px;display:none;">
                            <small style="color:#64748b;font-size:11px;">当前图标：</small>
                            <img id="editIconImg" src="" alt="图标预览" style="max-width:60px;max-height:60px;margin-top:4px;border-radius:6px;border:1px solid #e2e8f0;" />
                        </div>
                    </div>
                    <div class="bsp-form-group">
                        <label>或上传新图片（JPG/PNG/GIF，最大2MB）</label>
                        <asp:FileUpload ID="FileUploadEditIcon" runat="server" CssClass="bsp-file-upload" accept="image/*" />
                        <small style="color:#94a3b8;font-size:11px;margin-top:4px;">上传新图片将替换原图片</small>
                    </div>
                </div>
                <div class="bsp-form-group" style="margin-bottom:16px;">
                    <label>描述（可选）</label>
                    <asp:TextBox ID="TxtEditDesc" runat="server" MaxLength="500" TextMode="MultiLine" Rows="2" placeholder="商品描述" />
                </div>
                <div style="display:flex;gap:10px;">
                    <asp:Button ID="BtnEdit" runat="server" Text="保 存 修 改" OnClick="BtnEdit_Click" CssClass="bsp-btn bsp-btn-primary" />
                    <asp:Button ID="BtnCancelEdit" runat="server" Text="取 消" OnClick="BtnCancelEdit_Click" CssClass="bsp-btn" />
                </div>
            </div>
        </div>
    </asp:Panel>

    <div class="bsp-card">
        <div class="bsp-card-head">
            <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
            商品列表
        </div>
        <div>
            <asp:Repeater ID="RptItems" runat="server" OnItemCommand="RptItems_ItemCommand">
                <HeaderTemplate>
                    <table class="bsp-table">
                    <thead><tr><th>ID</th><th>名称</th><th>描述</th><th>所需积分</th><th>库存</th><th>状态</th><th>操作</th></tr></thead>
                    <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("Sid") %></td>
                        <td><strong><%# Server.HtmlEncode(Eval("Sname") == DBNull.Value ? "" : Eval("Sname").ToString()) %></strong></td>
                        <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"><%# Server.HtmlEncode(Eval("Sdesc") == DBNull.Value ? "" : Eval("Sdesc").ToString()) %></td>
                        <td><span class="bsp-cost"><%# Eval("Scost") == DBNull.Value ? 0 : Eval("Scost") %></span></td>
                        <td><%# FormatStock(Eval("Sstock")) %></td>
                        <td><span class='<%# Convert.ToBoolean(Eval("Sactive") == DBNull.Value ? true : Eval("Sactive")) ? "bsp-status bsp-status-on" : "bsp-status bsp-status-off" %>'><%# Convert.ToBoolean(Eval("Sactive") == DBNull.Value ? true : Eval("Sactive")) ? "上架" : "下架" %></span></td>
                        <td>
                            <div class="bsp-actions">
                                <asp:Button runat="server" Text="编辑" CssClass="bsp-btn bsp-btn-sm bsp-btn-edit"
                                    CommandName="Edit" CommandArgument='<%# Eval("Sid") %>' />
                                <asp:Button runat="server" Text="切换" CssClass="bsp-btn bsp-btn-sm"
                                    CommandName="Toggle" CommandArgument='<%# Eval("Sid") %>' />
                                <asp:Button runat="server" Text="删除" CssClass="bsp-btn bsp-btn-sm bsp-btn-danger"
                                    CommandName="Del" CommandArgument='<%# Eval("Sid") %>'
                                    OnClientClick="return confirm('确定要删除该商品吗？');" />
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody></table>
                </FooterTemplate>
            </asp:Repeater>
            <asp:Panel ID="PnlEmpty" runat="server" Visible="false">
                <div class="bsp-empty">暂无商品，请在下方添加</div>
            </asp:Panel>
        </div>

        <div class="bsp-add-area">
            <h4 style="font-size:14px;font-weight:600;color:#334155;margin:0 0 16px;">添加新商品</h4>
            <div class="bsp-add-grid">
                <div class="bsp-form-group">
                    <label>商品名称 *</label>
                    <asp:TextBox ID="TxtName" runat="server" MaxLength="100" placeholder="如：免作业卡" />
                </div>
                <div class="bsp-form-group">
                    <label>所需积分 *</label>
                    <asp:TextBox ID="TxtCost" runat="server" MaxLength="10" placeholder="如：50" />
                </div>
                <div class="bsp-form-group">
                    <label>库存（-1=无限）</label>
                    <asp:TextBox ID="TxtStock" runat="server" MaxLength="10" placeholder="-1 表示无限" />
                </div>
                <div class="bsp-form-group">
                    <label>图标URL（可选）</label>
                    <asp:TextBox ID="TxtIcon" runat="server" MaxLength="500" placeholder="如：../images/shop/card.png" />
                </div>
                <div class="bsp-form-group">
                    <label>或上传图片（JPG/PNG/GIF，最大2MB）</label>
                    <asp:FileUpload ID="FileUploadIcon" runat="server" CssClass="bsp-file-upload" accept="image/*" />
                    <small style="color:#94a3b8;font-size:11px;margin-top:4px;">上传图片将自动保存到 /images/shop/ 目录</small>
                </div>
            </div>
            <div class="bsp-form-group" style="margin-bottom:16px;">
                <label>描述（可选）</label>
                <asp:TextBox ID="TxtDesc" runat="server" MaxLength="500" TextMode="MultiLine" Rows="2" placeholder="商品描述" />
            </div>
            <asp:Button ID="BtnAdd" runat="server" Text="添 加 商 品" OnClick="BtnAdd_Click" CssClass="bsp-btn bsp-btn-primary" />
        </div>
    </div>
</div>

<script type="text/javascript">
    (function(){
        var tbl = document.querySelector('.bsp-table');
        if (!tbl || tbl.querySelectorAll('tbody tr').length === 0) {
            var empty = document.querySelector('.bsp-empty');
            if (empty) empty.parentElement.style.display = 'block';
            if (tbl) tbl.style.display = 'none';
        }
        
        // 显示编辑图标预览
        var editIconInput = document.getElementById('<%= TxtEditIcon.ClientID %>');
        if (editIconInput && editIconInput.value) {
            var preview = document.getElementById('editIconPreview');
            var img = document.getElementById('editIconImg');
            if (preview && img) {
                var iconPath = editIconInput.value;
                // 处理相对路径
                if (iconPath.indexOf('~/') === 0) {
                    iconPath = iconPath.replace('~/', '../');
                }
                img.src = iconPath;
                img.onerror = function() { preview.style.display = 'none'; };
                img.onload = function() { preview.style.display = 'block'; };
            }
        }
        
        // 如果编辑面板可见，滚动到编辑面板
        var editPanel = document.getElementById('<%= PanelEdit.ClientID %>');
        if (editPanel && editPanel.style.display !== 'none') {
            setTimeout(function() {
                editPanel.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }, 100);
        }
    })();
</script>
</asp:Content>
