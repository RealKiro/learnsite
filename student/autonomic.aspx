<%@ page language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_autonomic, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" runat="Server">
<style>
.auto-page { width: 100%; max-width: 1400px; margin: 0 auto; padding: 20px; font-family: 'Microsoft YaHei',Arial,sans-serif; }
.auto-header { text-align: center; margin-bottom: 32px; padding-bottom: 24px; border-bottom: 2px solid #f1f5f9; }
.auto-header h1 { font-size: 28px; font-weight: 700; color: #1e293b; margin: 0 0 8px 0; }
.auto-header p { font-size: 14px; color: #64748b; margin: 0; }

.auto-layout { display: grid; grid-template-columns: 1fr 380px; gap: 24px; align-items: start; }

.auto-card { background: #fff; border-radius: 12px; border: 1px solid #e5e7eb; box-shadow: 0 2px 8px rgba(0,0,0,.08); margin-bottom: 20px; overflow: hidden; }
.auto-card-header { display: flex; align-items: center; gap: 12px; padding: 18px 24px; border-bottom: 2px solid #f1f5f9; background: linear-gradient(to bottom, #fafbfc, #fff); }
.auto-card-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; }
.auto-card-icon svg { width: 20px; height: 20px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.auto-icon-blue { background: linear-gradient(135deg, #dbeafe, #bfdbfe); }
.auto-icon-blue svg { stroke: #2563eb; }
.auto-icon-green { background: linear-gradient(135deg, #dcfce7, #bbf7d0); }
.auto-icon-green svg { stroke: #16a34a; }
.auto-card-title { font-size: 16px; font-weight: 700; color: #1e293b; margin: 0; flex: 1; }
.auto-card-body { padding: 24px; }

.auto-category { margin-bottom: 32px; }
.auto-category-title { display: flex; align-items: center; gap: 10px; font-size: 18px; font-weight: 700; color: #1e293b; margin-bottom: 16px; padding-bottom: 12px; border-bottom: 2px solid #f1f5f9; }
.auto-category-title img { width: 24px; height: 24px; }

.auto-work-list { list-style: none; padding: 0; margin: 0; }
.auto-work-item { padding: 14px 16px; border-bottom: 1px solid #f1f5f9; transition: all .15s; }
.auto-work-item:hover { background: #f8fafc; margin: 0 -16px; padding: 14px 32px; }
.auto-work-item:last-child { border-bottom: none; }
.auto-work-item a { color: #2563eb; text-decoration: none; font-size: 15px; font-weight: 500; line-height: 1.6; display: flex; align-items: center; gap: 8px; }
.auto-work-item a:hover { color: #1d4ed8; }
.auto-work-item a::before { content: '📄'; font-size: 16px; }

.auto-my-works { position: sticky; top: 20px; }
.auto-my-item { padding: 12px 0; border-bottom: 1px solid #f1f5f9; transition: all .15s; }
.auto-my-item:hover { background: #f0fdf4; margin: 0 -16px; padding: 12px 16px; }
.auto-my-item:last-child { border-bottom: none; }
.auto-my-item a { color: #16a34a; text-decoration: none; font-size: 14px; font-weight: 500; line-height: 1.6; display: block; }
.auto-my-item a:hover { color: #15803d; text-decoration: underline; }

.auto-empty { text-align: center; padding: 40px 20px; color: #94a3b8; font-size: 14px; }

@media (max-width: 1024px) {
    .auto-layout { grid-template-columns: 1fr; }
    .auto-my-works { position: relative; top: 0; }
}
</style>

<div class="auto-page">
    <div class="auto-header">
        <h1>🎨 作品园</h1>
        <p>展示和分享学生的优秀作品</p>
    </div>
    
    <div class="auto-layout">
        <!-- 左侧：所有作品分类 -->
        <div class="auto-main">
            <asp:DataList ID="DLCategory" runat="server" RepeatColumns="1" 
                RepeatDirection="Horizontal" Width="100%" 
                DataKeyField="yid" OnItemDataBound="DLCategory_ItemDataBound">
                <ItemTemplate>
                    <div class="auto-card">
                        <div class="auto-card-body">
                            <div class="auto-category-title">
                                <img alt="" src="../images/filetype/read.gif" />
                                <asp:HyperLink ID="HLYtitle" runat="server" Text='<%# Eval("Ytitle") %>'></asp:HyperLink>
                            </div>
                            <ul class="auto-work-list">
                                <%# ListNews(Eval("yid"), 10, "auto-work-item", 50) %>
                            </ul>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
        
        <!-- 右侧：我的作品 -->
        <div class="auto-my-works">
            <div class="auto-card">
                <div class="auto-card-header">
                    <div class="auto-card-icon auto-icon-green">
                        <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    </div>
                    <h3 class="auto-card-title">我的作品</h3>
                </div>
                <div class="auto-card-body">
                    <asp:Repeater ID="RepMy" runat="server">
                        <ItemTemplate>
                            <div class="auto-my-item">
                                <a href='<%# GetdownUrl(Eval("Aurl").ToString()) %>' target="_blank">
                                    <%# Eval("Ftitle") %>
                                </a>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="PanelNoWorks" runat="server" Visible="false">
                        <div class="auto-empty">暂无作品</div>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>
</div>
</asp:Content>