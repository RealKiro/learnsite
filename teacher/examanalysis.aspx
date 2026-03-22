<%@ Page Title="" Language="C#" MasterPageFile="~/teacher/Teach.master" AutoEventWireup="true" CodeFile="examanalysis.aspx.cs" Inherits="teacher_examanalysis" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    /* ========== 页面容器 ========== */
    .ea-page { max-width: 1400px; margin: 0 auto; padding: 24px; font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif; }
    
    /* ========== 页面标题 ========== */
    .ea-header { margin-bottom: 28px; }
    .ea-title { font-size: 28px; font-weight: 700; color: #1e293b; margin: 0 0 8px 0; display: flex; align-items: center; gap: 12px; }
    .ea-title svg { width: 32px; height: 32px; stroke: #6366f1; fill: none; stroke-width: 2; }
    .ea-subtitle { font-size: 14px; color: #64748b; margin: 0; }
    
    /* ========== 筛选栏 ========== */
    .ea-filters { background: #fff; border-radius: 16px; padding: 20px 24px; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); border: 1px solid #e5e7eb; }
    .ea-filter-row { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
    .ea-filter-group { display: flex; align-items: center; gap: 10px; }
    .ea-filter-label { font-size: 14px; font-weight: 600; color: #475569; white-space: nowrap; }
    .ea-filter-select { padding: 8px 36px 8px 12px; border: 1.5px solid #e2e8f0; border-radius: 8px; font-size: 14px; color: #1e293b; background: #fff; cursor: pointer; transition: all .2s; appearance: none; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 12px center; min-width: 180px; }
    .ea-filter-select:hover { border-color: #6366f1; }
    .ea-filter-select:focus { outline: none; border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.1); }
    .ea-filter-btn { padding: 8px 20px; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: all .2s; display: inline-flex; align-items: center; gap: 6px; }
    .ea-filter-btn-primary { background: linear-gradient(135deg, #6366f1, #8b5cf6); color: #fff; box-shadow: 0 2px 8px rgba(99,102,241,.3); }
    .ea-filter-btn-primary:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(99,102,241,.4); }
    .ea-filter-btn svg { width: 16px; height: 16px; }
    
    /* ========== 统计卡片网格 ========== */
    .ea-stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; margin-bottom: 28px; }
    .ea-stat-card { background: #fff; border-radius: 14px; padding: 22px 24px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); transition: all .2s; position: relative; overflow: hidden; }
    .ea-stat-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px; background: linear-gradient(90deg, var(--card-color-1), var(--card-color-2)); }
    .ea-stat-card:hover { transform: translateY(-2px); box-shadow: 0 4px 16px rgba(0,0,0,.08); }
    .ea-stat-card-blue { --card-color-1: #3b82f6; --card-color-2: #2563eb; }
    .ea-stat-card-green { --card-color-1: #10b981; --card-color-2: #059669; }
    .ea-stat-card-purple { --card-color-1: #8b5cf6; --card-color-2: #7c3aed; }
    .ea-stat-card-orange { --card-color-1: #f59e0b; --card-color-2: #d97706; }
    .ea-stat-card-red { --card-color-1: #ef4444; --card-color-2: #dc2626; }
    .ea-stat-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
    .ea-stat-icon { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; }
    .ea-stat-icon svg { width: 22px; height: 22px; stroke-width: 2; }
    .ea-stat-icon-blue { background: linear-gradient(135deg, #dbeafe, #bfdbfe); }
    .ea-stat-icon-blue svg { stroke: #2563eb; }
    .ea-stat-icon-green { background: linear-gradient(135deg, #d1fae5, #a7f3d0); }
    .ea-stat-icon-green svg { stroke: #059669; }
    .ea-stat-icon-purple { background: linear-gradient(135deg, #e9d5ff, #d8b4fe); }
    .ea-stat-icon-purple svg { stroke: #7c3aed; }
    .ea-stat-icon-orange { background: linear-gradient(135deg, #fed7aa, #fdba74); }
    .ea-stat-icon-orange svg { stroke: #d97706; }
    .ea-stat-icon-red { background: linear-gradient(135deg, #fecaca, #fca5a5); }
    .ea-stat-icon-red svg { stroke: #dc2626; }
    .ea-stat-label { font-size: 13px; color: #64748b; font-weight: 500; margin-bottom: 6px; }
    .ea-stat-value { font-size: 32px; font-weight: 800; color: #1e293b; line-height: 1; }
    .ea-stat-unit { font-size: 16px; font-weight: 600; color: #64748b; margin-left: 4px; }
    
    /* ========== 题目分析表格 ========== */
    .ea-table-card { background: #fff; border-radius: 16px; padding: 24px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); }
    .ea-table-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 2px solid #f1f5f9; }
    .ea-table-title { font-size: 18px; font-weight: 700; color: #1e293b; display: flex; align-items: center; gap: 10px; }
    .ea-table-title svg { width: 22px; height: 22px; stroke: #6366f1; fill: none; stroke-width: 2; }
    .ea-table-info { font-size: 13px; color: #64748b; }
    
    .ea-table { width: 100%; border-collapse: separate; border-spacing: 0; }
    .ea-table thead th { background: linear-gradient(135deg, #f8fafc, #f1f5f9); padding: 14px 16px; text-align: left; font-size: 13px; font-weight: 700; color: #475569; border-bottom: 2px solid #e2e8f0; white-space: nowrap; }
    .ea-table thead th:first-child { border-radius: 10px 0 0 0; }
    .ea-table thead th:last-child { border-radius: 0 10px 0 0; }
    .ea-table tbody tr { transition: all .15s; }
    .ea-table tbody tr:hover { background: #f8fafc; }
    .ea-table tbody td { padding: 16px; border-bottom: 1px solid #f1f5f9; font-size: 14px; color: #334155; }
    .ea-table tbody tr:last-child td { border-bottom: none; }
    .ea-table tbody tr:last-child td:first-child { border-radius: 0 0 0 10px; }
    .ea-table tbody tr:last-child td:last-child { border-radius: 0 0 10px 0; }
    
    /* 题号列 */
    .ea-q-num { font-weight: 700; color: #6366f1; font-size: 15px; white-space: nowrap; }
    
    /* 题型标签 */
    .ea-q-type { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 600; }
    .ea-q-type-choice { background: #dbeafe; color: #1e40af; }
    .ea-q-type-multi { background: #fce7f3; color: #be185d; }
    .ea-q-type-judge { background: #ede9fe; color: #6d28d9; }
    .ea-q-type-fill { background: #fef3c7; color: #b45309; }
    .ea-q-type-essay { background: #d1fae5; color: #065f46; }
    .ea-q-type-coding { background: #fed7aa; color: #c2410c; }
    
    /* 题目内容 */
    .ea-q-content { max-width: 400px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: #475569; }
    
    /* 分数 */
    .ea-q-score { font-weight: 600; color: #1e293b; }
    
    /* 人数统计 */
    .ea-q-count { font-weight: 600; color: #475569; text-align: center; }
    
    /* 统计数据 */
    .ea-q-stats { display: flex; flex-direction: column; gap: 4px; }
    .ea-q-stat-row { display: flex; align-items: center; gap: 8px; font-size: 13px; }
    .ea-q-stat-label { color: #64748b; min-width: 60px; }
    .ea-q-stat-value { font-weight: 600; }
    .ea-q-stat-correct { color: #059669; }
    .ea-q-stat-wrong { color: #dc2626; }
    
    /* 进度条 */
    .ea-progress-bar { width: 100%; max-width: 200px; }
    .ea-progress-label { font-size: 12px; color: #64748b; margin-bottom: 4px; display: flex; justify-content: space-between; }
    .ea-progress-track { height: 8px; background: #f1f5f9; border-radius: 4px; overflow: hidden; position: relative; }
    .ea-progress-fill { height: 100%; border-radius: 4px; transition: width .3s ease; position: relative; }
    .ea-progress-fill-correct { background: linear-gradient(90deg, #10b981, #059669); }
    .ea-progress-fill-wrong { background: linear-gradient(90deg, #ef4444, #dc2626); }
    
    /* 空状态 */
    .ea-empty { text-align: center; padding: 60px 20px; }
    .ea-empty-icon { font-size: 64px; margin-bottom: 16px; opacity: 0.3; }
    .ea-empty-text { font-size: 16px; color: #64748b; margin-bottom: 8px; }
    .ea-empty-hint { font-size: 14px; color: #94a3b8; }
</style>

<div class="ea-page">
    <!-- 页面标题 -->
    <div class="ea-header">
        <h1 class="ea-title">
            <svg viewBox="0 0 24 24"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
            考试数据分析
        </h1>
        <p class="ea-subtitle">查看考试整体情况和每道题的答题统计</p>
    </div>
    
    <!-- 筛选栏 -->
    <div class="ea-filters">
        <div class="ea-filter-row">
            <div class="ea-filter-group">
                <label class="ea-filter-label">选择考试：</label>
                <asp:DropDownList ID="DDLExam" runat="server" CssClass="ea-filter-select" AutoPostBack="true" OnSelectedIndexChanged="DDLExam_SelectedIndexChanged">
                </asp:DropDownList>
            </div>
            
            <div class="ea-filter-group">
                <label class="ea-filter-label">筛选范围：</label>
                <asp:DropDownList ID="DDLScope" runat="server" CssClass="ea-filter-select" AutoPostBack="true" OnSelectedIndexChanged="DDLScope_SelectedIndexChanged">
                    <asp:ListItem Value="all" Selected="True">全部学生</asp:ListItem>
                    <asp:ListItem Value="grade">按年级</asp:ListItem>
                    <asp:ListItem Value="class">按班级</asp:ListItem>
                </asp:DropDownList>
            </div>
            
            <div class="ea-filter-group" id="gradeFilterGroup" runat="server" Visible="false">
                <label class="ea-filter-label">年级：</label>
                <asp:DropDownList ID="DDLGrade" runat="server" CssClass="ea-filter-select" AutoPostBack="true" OnSelectedIndexChanged="DDLGrade_SelectedIndexChanged">
                </asp:DropDownList>
            </div>
            
            <div class="ea-filter-group" id="classFilterGroup" runat="server" Visible="false">
                <label class="ea-filter-label">班级：</label>
                <asp:DropDownList ID="DDLClass" runat="server" CssClass="ea-filter-select" AutoPostBack="true" OnSelectedIndexChanged="DDLClass_SelectedIndexChanged">
                </asp:DropDownList>
            </div>
        </div>
    </div>
    
    <!-- 统计卡片 -->
    <asp:Panel ID="PanelStats" runat="server" Visible="false">
        <div class="ea-stats-grid">
            <div class="ea-stat-card ea-stat-card-blue">
                <div class="ea-stat-header">
                    <div class="ea-stat-icon ea-stat-icon-blue">
                        <svg viewBox="0 0 24 24" fill="none"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    </div>
                </div>
                <div class="ea-stat-label">参与人数</div>
                <div class="ea-stat-value">
                    <asp:Label ID="LblParticipants" runat="server" Text="0"></asp:Label>
                    <span class="ea-stat-unit">人</span>
                </div>
            </div>
            
            <div class="ea-stat-card ea-stat-card-purple">
                <div class="ea-stat-header">
                    <div class="ea-stat-icon ea-stat-icon-purple">
                        <svg viewBox="0 0 24 24" fill="none"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                    </div>
                </div>
                <div class="ea-stat-label">平均分</div>
                <div class="ea-stat-value">
                    <asp:Label ID="LblAvgScore" runat="server" Text="0"></asp:Label>
                    <span class="ea-stat-unit">分</span>
                </div>
            </div>
            
            <div class="ea-stat-card ea-stat-card-green">
                <div class="ea-stat-header">
                    <div class="ea-stat-icon ea-stat-icon-green">
                        <svg viewBox="0 0 24 24" fill="none"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    </div>
                </div>
                <div class="ea-stat-label">最高分</div>
                <div class="ea-stat-value">
                    <asp:Label ID="LblMaxScore" runat="server" Text="0"></asp:Label>
                    <span class="ea-stat-unit">分</span>
                </div>
            </div>
            
            <div class="ea-stat-card ea-stat-card-orange">
                <div class="ea-stat-header">
                    <div class="ea-stat-icon ea-stat-icon-orange">
                        <svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    </div>
                </div>
                <div class="ea-stat-label">最低分</div>
                <div class="ea-stat-value">
                    <asp:Label ID="LblMinScore" runat="server" Text="0"></asp:Label>
                    <span class="ea-stat-unit">分</span>
                </div>
            </div>
            
            <div class="ea-stat-card ea-stat-card-red">
                <div class="ea-stat-header">
                    <div class="ea-stat-icon ea-stat-icon-red">
                        <svg viewBox="0 0 24 24" fill="none"><path d="M18 20V10"/><path d="M12 20V4"/><path d="M6 20v-6"/></svg>
                    </div>
                </div>
                <div class="ea-stat-label">及格率</div>
                <div class="ea-stat-value">
                    <asp:Label ID="LblPassRate" runat="server" Text="0"></asp:Label>
                    <span class="ea-stat-unit">%</span>
                </div>
            </div>
        </div>
    </asp:Panel>
    
    <!-- 题目分析表格 -->
    <asp:Panel ID="PanelQuestions" runat="server" Visible="false">
        <div class="ea-table-card">
            <div class="ea-table-header">
                <div class="ea-table-title">
                    <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                    题目答题分析
                </div>
                <div class="ea-table-info">
                    共 <asp:Label ID="LblQuestionCount" runat="server" Text="0"></asp:Label> 道题目
                </div>
            </div>
            
            <asp:Repeater ID="RptQuestions" runat="server">
                <HeaderTemplate>
                    <table class="ea-table">
                        <thead>
                            <tr>
                                <th style="width: 60px;">题号</th>
                                <th style="width: 100px;">题型</th>
                                <th>题目内容</th>
                                <th style="width: 80px;">满分</th>
                                <th style="width: 100px;">平均分</th>
                                <th style="width: 100px;">正确人数</th>
                                <th style="width: 100px;">错误人数</th>
                                <th style="width: 200px;">正确率</th>
                                <th style="width: 200px;">错误率</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td class="ea-q-num">第<%# Container.ItemIndex + 1 %>题</td>
                        <td>
                            <span class='ea-q-type <%# GetTypeClass(Eval("Qtype").ToString()) %>'>
                                <%# GetTypeName(Eval("Qtype").ToString()) %>
                            </span>
                        </td>
                        <td class="ea-q-content" title='<%# Server.HtmlEncode(StripHtml(Eval("Qcontent").ToString())) %>'>
                            <%# Server.HtmlEncode(StripHtml(Eval("Qcontent").ToString())) %>
                        </td>
                        <td class="ea-q-score"><%# Eval("Qscore") %> 分</td>
                        <td class="ea-q-score"><%# Eval("AvgScore") %> 分</td>
                        <td class="ea-q-count"><%# Eval("CorrectCount") %> 人</td>
                        <td class="ea-q-count"><%# Eval("WrongCount") %> 人</td>
                        <td>
                            <div class="ea-progress-bar">
                                <div class="ea-progress-label">
                                    <span>正确</span>
                                    <span class="ea-q-stat-correct"><%# Eval("CorrectRate") %>%</span>
                                </div>
                                <div class="ea-progress-track">
                                    <div class="ea-progress-fill ea-progress-fill-correct" style='width: <%# Eval("CorrectRate") %>%;'></div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div class="ea-progress-bar">
                                <div class="ea-progress-label">
                                    <span>错误</span>
                                    <span class="ea-q-stat-wrong"><%# Eval("WrongRate") %>%</span>
                                </div>
                                <div class="ea-progress-track">
                                    <div class="ea-progress-fill ea-progress-fill-wrong" style='width: <%# Eval("WrongRate") %>%;'></div>
                                </div>
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    
    <!-- 空状态 -->
    <asp:Panel ID="PanelEmpty" runat="server" Visible="true">
        <div class="ea-empty">
            <div class="ea-empty-icon">📊</div>
            <div class="ea-empty-text">请选择一场考试查看分析数据</div>
            <div class="ea-empty-hint">在上方下拉框中选择已发布的考试</div>
        </div>
    </asp:Panel>
</div>

</asp:Content>
