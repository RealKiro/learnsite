<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" stylesheettheme="Teacher" autoeventwireup="true" inherits="Teacher_softcategory, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="Server">
<style>
    .sc-page { max-width: 1440px; width: 100%; margin: 0 auto; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif; }

    .sc-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #e8ecf1;
    }
    .sc-title-wrap { display: flex; flex-direction: column; gap: 6px; }
    .sc-title {
        font-size: 22px; font-weight: 700; color: #1e293b;
        display: flex; align-items: center; gap: 12px;
    }
    .sc-title .sc-icon {
        width: 40px; height: 40px; background: linear-gradient(135deg,#3b82f6,#60a5fa);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
    }
    .sc-title .sc-icon svg { width: 22px; height: 22px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sc-subtitle { font-size: 13px; color: #94a3b8; margin-left: 52px; }

    .sc-card {
        background: #fff; border-radius: 12px; border: 1px solid #e8ecf1;
        box-shadow: 0 1px 3px rgba(0,0,0,.04); margin-bottom: 20px; overflow: hidden;
    }
    .sc-card-header {
        padding: 16px 24px; border-bottom: 1px solid #f1f5f9;
        display: flex; align-items: center; justify-content: space-between;
        background: #fafbfc;
    }
    .sc-card-title { font-size: 15px; font-weight: 600; color: #334155; display: flex; align-items: center; gap: 8px; }
    .sc-card-title svg { width: 18px; height: 18px; stroke: #3b82f6; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .sc-card-body { padding: 0; }

    /* 表格美化 */
    .sc-card-body table { width: 100%; border-collapse: collapse; }
    .sc-card-body table th {
        background: #f8fafc; color: #64748b; font-weight: 600; font-size: 13px;
        letter-spacing: .3px; padding: 12px 16px;
        border-bottom: 2px solid #e8ecf1; text-align: left;
    }
    .sc-card-body table td {
        padding: 10px 16px; border-bottom: 1px solid #f1f5f9; font-size: 13px; color: #334155;
        transition: background .1s;
    }
    .sc-card-body table tr:hover td { background: #f8fafc; }
    .sc-card-body table tr:last-child td { border-bottom: none; }
    .sc-card-body table a { color: #3b82f6; text-decoration: none; font-weight: 500; transition: color .15s; }
    .sc-card-body table a:hover { color: #2563eb; text-decoration: underline; }
    .sc-card-body table img { vertical-align: middle; cursor: pointer; opacity: .7; transition: opacity .15s; }
    .sc-card-body table img:hover { opacity: 1; }
    .sc-card-body table input[type="text"] {
        padding: 6px 12px; border-radius: 6px; border: 1px solid #e2e8f0;
        font-size: 13px; color: #334155; background: #fffde7; outline: none;
        transition: border-color .15s;
    }
    .sc-card-body table input[type="text"]:focus {
        border-color: #60a5fa; box-shadow: 0 0 0 3px rgba(59,130,246,.1);
    }

    /* 添加区域 */
    .sc-add-area {
        display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
        padding: 20px 24px; border-top: 1px solid #f1f5f9; background: #fafbfc;
    }
    .sc-add-area label { 
        font-size: 14px; font-weight: 600; color: #334155; white-space: nowrap;
        display: flex; align-items: center; gap: 6px;
    }
    .sc-add-area label::before {
        content: ''; display: inline-block; width: 3px; height: 14px;
        background: linear-gradient(135deg,#3b82f6,#60a5fa); border-radius: 2px;
    }
    .sc-add-area input[type="text"] {
        padding: 10px 16px; border-radius: 8px; border: 1.5px solid #e2e8f0;
        font-size: 14px; color: #334155; background: #fff; outline: none;
        transition: all .2s; font-family: inherit; box-shadow: 0 1px 2px rgba(0,0,0,.04);
        min-width: 280px;
    }
    .sc-add-area input[type="text"]:hover {
        border-color: #cbd5e1; box-shadow: 0 2px 4px rgba(0,0,0,.06);
    }
    .sc-add-area input[type="text"]:focus {
        border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59,130,246,.12), 0 2px 8px rgba(59,130,246,.15);
        background: #fff;
    }
    .sc-add-area input[type="text"]::placeholder {
        color: #94a3b8; font-size: 13px;
    }

    .sc-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        padding: 8px 20px; border-radius: 8px; font-size: 13px; font-weight: 500;
        border: 1px solid #e2e8f0; background: #fff; color: #475569;
        cursor: pointer; transition: all .18s; font-family: inherit;
    }
    .sc-btn:hover { background: #f8fafc; border-color: #cbd5e1; }
    .sc-btn-primary {
        background: linear-gradient(135deg,#3b82f6,#60a5fa); color: #fff;
        border-color: #3b82f6; box-shadow: 0 2px 8px rgba(59,130,246,.2);
    }
    .sc-btn-primary:hover { background: linear-gradient(135deg,#2563eb,#3b82f6); border-color: #2563eb; box-shadow: 0 4px 12px rgba(59,130,246,.3); color: #fff; }

    .sc-tip {
        display: flex; align-items: center; gap: 8px;
        padding: 10px 16px; border-radius: 8px;
        background: #eff6ff; border: 1px solid #dbeafe; color: #1d4ed8;
        font-size: 12px; line-height: 1.5; margin-bottom: 20px;
    }
    .sc-tip svg { width: 16px; height: 16px; stroke: #3b82f6; fill: none; stroke-width: 2; flex-shrink: 0; }
</style>

<div class="sc-page">
    <!-- 页面标题 -->
    <div class="sc-header">
        <div class="sc-title-wrap">
            <div class="sc-title">
                <span class="sc-icon">
                    <svg viewBox="0 0 24 24"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
                </span>
                资源分类设置
            </div>
            <div class="sc-subtitle">管理自学资源的分类目录，支持增删改查和排序</div>
        </div>
    </div>

    <div class="sc-tip">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        使用「上」「下」按钮调整分类顺序，点击编辑图标修改分类名称，删除前请确保该分类下无资源
    </div>

    <!-- 分类列表卡片 -->
    <div class="sc-card">
        <div class="sc-card-header">
            <div class="sc-card-title">
                <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                分类列表
            </div>
        </div>
        <div class="sc-card-body">
            <asp:GridView ID="GVCategory" runat="server" SkinID="GridViewInfo" AutoGenerateColumns="False"
                DataKeyNames="Yid" Width="100%" CellPadding="0" Font-Size="9pt" OnRowCommand="GVCategory_RowCommand"
                EnableModelValidation="True" OnRowDataBound="GVCategory_RowDataBound" OnRowCancelingEdit="GVCategory_RowCancelingEdit"
                OnRowEditing="GVCategory_RowEditing" 
                OnRowUpdating="GVCategory_RowUpdating">
                <Columns>
                    <asp:TemplateField >
                        <ItemTemplate>
                            <asp:Label ID="LabelYid" runat="server" Text='<%# Bind("Yid") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle ForeColor="#EEEEEE" Width="20px" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="资源类别">
                        <ItemTemplate>
                            <asp:Label ID="LabelYtitle" runat="server" Text='<%# Bind("Ytitle") %>'></asp:Label>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="TBoxYtitle" runat="server" Text='<%# Bind("Ytitle") %>' Font-Size="9pt"
                                Width="200px" Height="12px" BackColor="#FFFFCC"></asp:TextBox>
                        </EditItemTemplate>
                        <ItemStyle HorizontalAlign="Left" Width="200px" />
                    </asp:TemplateField>
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="ImageBtnTop" runat="server" CausesValidation="False" CommandName="Top"
                                CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' Text="▲" ToolTip="向上移"
                                Font-Underline="False"></asp:LinkButton>
                        </ItemTemplate>
                        <ItemStyle Width="30px" HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="ImageBtnBottom" runat="server" CausesValidation="False" CommandName="Bottom"
                                CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' Text="▼" ToolTip="向下移"
                                Font-Underline="False"></asp:LinkButton>
                        </ItemTemplate>
                        <ItemStyle Width="30px" HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:ImageButton ID="ImageButton1" runat="server" CausesValidation="False" 
                                CommandName="Edit" ImageUrl="~/images/e.gif" Text="编辑" />
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:ImageButton ID="ImageButton1" runat="server" CausesValidation="True" 
                                CommandName="Update" ImageUrl="~/images/u.gif" Text="更新" />
                            &nbsp;<asp:ImageButton ID="ImageButton2" runat="server" CausesValidation="False" 
                                CommandName="Cancel" ImageUrl="~/images/c.gif" Text="取消" />
                        </EditItemTemplate>
                        <ItemStyle Width="60px" HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <ItemTemplate>
                            <asp:LinkButton ID="BtnDel" runat="server" CausesValidation="false" CommandName="Del" 
                            CommandArgument='<%# ((GridViewRow) Container).RowIndex %>' Text="删除"
                            OnClientClick="return confirm('确定要删除该分类吗？');" ForeColor="#ef4444"></asp:LinkButton>
                        </ItemTemplate>
                        <ItemStyle Width="50px" HorizontalAlign="Center" />
                    </asp:TemplateField>
                </Columns>
                <HeaderStyle Height="30px" />
                <RowStyle Height="36px" />
            </asp:GridView>
        </div>
        <!-- 添加分类 -->
        <div class="sc-add-area">
            <label>新增分类：</label>
            <asp:TextBox ID="TextBoxNewYtitle" runat="server" SkinID="TextBoxNormal" Width="220px"
                MaxLength="30" placeholder="请输入分类名称"></asp:TextBox>
            <asp:Button ID="Btnadd" runat="server" Text="添 加" OnClick="Btnadd_Click" CssClass="sc-btn sc-btn-primary" />
            <asp:Button ID="Btnreturn" runat="server" Text="返 回" OnClick="Btnreturn_Click" CssClass="sc-btn" />
        </div>
    </div>
</div>
</asp:Content>
