<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_masterwork, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .mk-page, .mk-page * { margin-right: unset !important; margin-left: unset !important; }
    .mk-page table { border-collapse: collapse !important; border-color: transparent !important; }
    .mk-page { width: 100%; max-width: 1400px; margin: 0 auto !important; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important; animation: mkFadeIn .4s ease; }
    @keyframes mkFadeIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }
    .mk-grid { display: grid; grid-template-columns: 1fr 280px; gap: 22px; align-items: start; }

    /* 卡片通用 */
    .mk-card { background: #fff !important; border-radius: 16px; border: 1px solid #e5e7eb !important; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); margin-bottom: 22px; overflow: hidden; }
    .mk-card-head { padding: 16px 22px; border-bottom: 1px solid #f1f5f9 !important; display: flex !important; align-items: center; gap: 12px; background: #fff !important; }
    .mk-card-head .mk-head-icon { width: 36px; height: 36px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; }
    .mk-head-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .mk-head-icon-orange { background: linear-gradient(135deg, #ffedd5, #fed7aa) !important; }
    .mk-head-icon-orange svg { stroke: #ea580c !important; }
    .mk-head-icon-blue { background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important; }
    .mk-head-icon-blue svg { stroke: #2563eb !important; }
    .mk-card-head h3 { font-size: 15px !important; font-weight: 700; color: #1e293b !important; margin: 0 !important; flex: 1; }
    .mk-card-body { padding: 20px 22px; }

    /* 作品网格 DataList */
    .mk-card-body table { border: none !important; }
    .mk-card-body td { border: none !important; padding: 6px !important; vertical-align: top !important; }

    /* 单个作品卡片 */
    .mk-work { margin: 0; padding: 12px 8px 10px; border-radius: 14px; border: 1.5px solid #f1f5f9 !important; background: #fff !important; text-align: center; width: 120px; transition: all .18s; font-family: 'Microsoft YaHei',sans-serif !important; cursor: pointer; }
    .mk-work:hover { border-color: #fdba74 !important; box-shadow: 0 6px 20px rgba(234,88,12,.1); transform: translateY(-3px); }
    .mk-work img { width: 80px !important; height: 80px !important; border-radius: 12px !important; object-fit: cover; border: 2px solid #f8fafc; margin-bottom: 8px; transition: border-color .15s; }
    .mk-work:hover img { border-color: #fed7aa; }
    .mk-work a { display: block; font-size: 12px !important; font-weight: 600; color: #1e293b !important; text-decoration: none !important; margin-bottom: 4px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 110px; transition: color .15s; }
    .mk-work:hover a { color: #ea580c !important; }
    .mk-work .mk-work-class { display: block; font-size: 11px; color: #94a3b8; }

    /* 提示信息 + 分页 */
    .mk-msg { padding: 10px 0 0; font-size: 13px; color: #64748b; }
    .mk-pager { padding: 12px 0 4px; font-size: 13px; color: #64748b; }
    .mk-pager a { color: #ea580c !important; text-decoration: none !important; padding: 4px 10px; border-radius: 6px; transition: all .12s; font-size: 13px; }
    .mk-pager a:hover { background: #fff7ed !important; }

    /* 侧边栏 */
    .mk-sidebar { position: sticky; top: 20px; }
    .mk-filter { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; margin-bottom: 14px; font-size: 13px; color: #475569; }
    .mk-filter-label { font-size: 12px; color: #94a3b8; font-weight: 500; }
    .mk-page select { padding: 6px 12px !important; border-radius: 8px !important; border: 1.5px solid #e2e8f0 !important; font-size: 12px !important; color: #334155 !important; background: #fff !important; font-family: 'Microsoft YaHei',sans-serif !important; outline: none; cursor: pointer; transition: border-color .15s; }
    .mk-page select:focus { border-color: #2563eb !important; }

    /* 侧边栏课节表格 */
    .mk-sidebar .mk-card-body table { width: 100% !important; border-collapse: collapse !important; border-spacing: 0 !important; }
    .mk-sidebar .mk-card-body table th { padding: 10px 12px !important; font-size: 12px !important; font-weight: 600 !important; color: #64748b !important; text-align: left !important; background-color: #f8fafc !important; border-bottom: 2px solid #e8ecf1 !important; border-top: none !important; border-left: none !important; border-right: none !important; font-family: 'Microsoft YaHei',sans-serif !important; white-space: nowrap !important; }
    .mk-sidebar .mk-card-body table td { padding: 9px 12px !important; font-size: 12px !important; color: #334155 !important; border-bottom: 1px solid #f1f5f9 !important; border-top: none !important; border-left: none !important; border-right: none !important; background-color: #fff !important; font-family: 'Microsoft YaHei',sans-serif !important; vertical-align: middle !important; }
    .mk-sidebar .mk-card-body table tr { background-color: #fff !important; transition: all .12s; }
    .mk-sidebar .mk-card-body table tr:hover td { background-color: #f8faff !important; }
    .mk-sidebar .mk-card-body table tr:last-child td { border-bottom: none !important; }
    .mk-sidebar .mk-card-body a.shorttitle { color: #334155 !important; text-decoration: none !important; transition: color .12s; font-size: 12px !important; }
    .mk-sidebar .mk-card-body a.shorttitle:hover { color: #2563eb !important; }

    /* 覆盖主题样式 */
    .mk-page #showcontent { min-width: unset !important; padding: 0 !important; margin: 0 !important; font-family: 'Microsoft YaHei',sans-serif !important; font-size: 13px !important; }
    .mk-page .leftmaster { float: none !important; width: 100% !important; text-align: left !important; overflow: visible !important; }
    .mk-page .rightmaster { position: static !important; float: none !important; width: 100% !important; text-align: left !important; overflow: visible !important; }
    .mk-page .divgood { border: none !important; background: none !important; width: auto !important; }
</style>

<div class="mk-page">
<div id="showcontent">
<div class="mk-grid">
    <!-- 左侧主内容 -->
    <div class="leftmaster">
        <div class="mk-card">
            <div class="mk-card-head">
                <span class="mk-head-icon mk-head-icon-orange"><svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></span>
                <h3>推荐作品展示区</h3>
            </div>
            <div class="mk-card-body">
                <asp:DataList ID="DLworks" runat="server" CellPadding="3" CellSpacing="3" 
                    RepeatColumns="6" RepeatDirection="Horizontal"
                    onitemdatabound="DLworks_ItemDataBound" 
                    onitemcommand="DLworks_ItemCommand">
                    <ItemTemplate>
                        <div class="divgood mk-work">
                            <asp:Image ID="Image1" runat="server" />
                            <asp:LinkButton ID="lBtnSname" runat="server" CommandArgument='<%# Eval("Wurl") %>' CommandName="S" 
                                ToolTip="瞧瞧我的作品！" Text='<%# Eval("Wname") %>'></asp:LinkButton>
                            <asp:Label ID="Labelgrade" runat="server" Text='<%# Eval("Wgrade") %>'></asp:Label>
                            <asp:Label ID="Labelclass" runat="server" Text='<%# Eval("Wclass") %>'></asp:Label>班
                            <asp:Label ID="Labeltype" runat="server" Text='<%# Eval("Wtype") %>' Visible="False"></asp:Label>
                            <asp:Label ID="LabelWid" runat="server" Text='<%# Eval("wid") %>' Visible="False"></asp:Label>
                        </div>
                    </ItemTemplate>
                </asp:DataList>
                <div class="mk-msg"><asp:Label ID="Labelmsg" runat="server"></asp:Label></div>
                <div class="mk-pager"><asp:Literal ID="Literal1" runat="server"></asp:Literal></div>
            </div>
        </div>
    </div>

    <!-- 右侧边栏 -->
    <div class="mk-sidebar rightmaster">
        <div class="mk-card">
            <div class="mk-card-head">
                <span class="mk-head-icon mk-head-icon-blue"><svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg></span>
                <h3>优秀作品库</h3>
            </div>
            <div class="mk-card-body">
                <div class="mk-filter">
                    <asp:DropDownList ID="DDLgrade" runat="server" AutoPostBack="True" 
                        onselectedindexchanged="DDLgrade_SelectedIndexChanged">
                    </asp:DropDownList>
                    <span>年级</span>
                    <span>第</span>
                    <asp:DropDownList ID="DDLterm" runat="server" AutoPostBack="True" 
                        onselectedindexchanged="DDLterm_SelectedIndexChanged">
                        <asp:ListItem>1</asp:ListItem>
                        <asp:ListItem>2</asp:ListItem>
                    </asp:DropDownList>
                    <span>学期</span>
                </div>
                <asp:GridView ID="GVcourse" runat="server" AutoGenerateColumns="False" 
                    CellPadding="2" SkinID="GridViewMission" Width="100%" 
                    DataKeyNames="cid" CellSpacing="3" EnableModelValidation="True" 
                    onrowdatabound="GVcourse_RowDataBound">
                    <Columns>
                        <asp:BoundField DataField="Cks" HeaderText="◆">
                            <ItemStyle Width="12px" />
                        </asp:BoundField>
                        <asp:TemplateField HeaderText="课节名称">
                            <ItemTemplate>
                                <asp:HyperLink ID="HyperLink1" runat="server" ToolTip='<%# Eval("ctitle") %>' CssClass="shorttitle"></asp:HyperLink>
                            </ItemTemplate>
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </asp:TemplateField>
                        <asp:TemplateField Visible="False">
                            <ItemTemplate>
                                <asp:Label ID="LabelCid" runat="server" Text='<%# Bind("cid") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</div>
</div>
</div>
</asp:Content>
