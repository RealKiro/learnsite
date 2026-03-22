<%@ page title="" language="C#" masterpagefile="~/student/Stud.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_groupshare, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cphs" Runat="Server">
<style>
    .gs-page, .gs-page * { margin-right: unset !important; margin-left: unset !important; }
    .gs-page table { border-collapse: collapse !important; border-color: transparent !important; }
    .gs-page { width: 100%; max-width: 1200px; margin: 0 auto !important; font-family: 'Microsoft YaHei','Segoe UI',Arial,sans-serif !important; animation: gsFadeIn .4s ease; }
    @keyframes gsFadeIn { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }

    /* 左右布局 */
    .gs-layout { display: flex; gap: 20px; align-items: flex-start; }

    /* === 左侧面板 === */
    .gs-left { width: 280px; flex-shrink: 0; }
    .gs-nav-card { background: #fff; border-radius: 18px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; margin-bottom: 16px; }
    .gs-nav-head { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 24px 22px; position: relative; overflow: hidden; }
    .gs-nav-head::before { content: ''; position: absolute; top: -20px; right: -20px; width: 100px; height: 100px; border-radius: 50%; background: rgba(255,255,255,.08); }
    .gs-nav-head::after { content: ''; position: absolute; bottom: -30px; left: 10px; width: 60px; height: 60px; border-radius: 50%; background: rgba(255,255,255,.06); }
    .gs-nav-title { display: flex; align-items: center; gap: 12px; position: relative; z-index: 1; }
    .gs-nav-title-icon { width: 40px; height: 40px; background: rgba(255,255,255,.2); border-radius: 12px; display: flex !important; align-items: center; justify-content: center; backdrop-filter: blur(4px); flex-shrink: 0; }
    .gs-nav-title-icon svg { width: 20px; height: 20px; fill: none; stroke: #fff; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .gs-nav-head h3 { margin: 0; font-size: 17px; font-weight: 700; color: #fff; letter-spacing: .5px; }
    .gs-nav-head p { margin: 3px 0 0; font-size: 12px; color: rgba(255,255,255,.75); position: relative; z-index: 1; padding-left: 52px; }

    /* 导航按钮组 */
    .gs-nav-list { padding: 12px; }
    .gs-tab { display: flex !important; align-items: center; gap: 12px; padding: 14px 16px !important; border-radius: 12px !important; font-size: 14px !important; font-weight: 600 !important; cursor: pointer; transition: all .2s; border: none !important; background: transparent !important; color: #475569 !important; font-family: 'Microsoft YaHei',sans-serif !important; width: 100% !important; text-align: left !important; margin-bottom: 4px; }
    .gs-tab:hover { background: #f1f5f9 !important; color: #1e293b !important; }
    .gs-tab.gs-active { background: linear-gradient(135deg, #eef2ff, #e0e7ff) !important; color: #4338ca !important; box-shadow: 0 2px 8px rgba(99,102,241,.1); }
    .gs-tab-icon { width: 36px; height: 36px; border-radius: 10px; display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; transition: all .2s; }
    .gs-tab-icon svg { width: 18px; height: 18px; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .gs-tab-icon-teal { background: #ccfbf1; }
    .gs-tab-icon-teal svg { stroke: #0d9488; }
    .gs-tab-icon-blue { background: #dbeafe; }
    .gs-tab-icon-blue svg { stroke: #2563eb; }
    .gs-tab-icon-violet { background: #ede9fe; }
    .gs-tab-icon-violet svg { stroke: #7c3aed; }

    /* 网盘状态卡片 */
    .gs-stat-card { background: #fff; border-radius: 14px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04); padding: 16px 18px; }
    .gs-stat-head { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
    .gs-stat-icon { width: 32px; height: 32px; border-radius: 8px; background: linear-gradient(135deg, #d1fae5, #a7f3d0); display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; }
    .gs-stat-icon svg { width: 16px; height: 16px; fill: none; stroke: #059669; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .gs-stat-label { font-size: 12px; color: #6b7280; font-weight: 500; }
    .gs-stat-val { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #047857; font-weight: 600; padding: 8px 12px; background: #ecfdf5; border-radius: 8px; }
    .gs-stat-val img { width: 16px !important; height: 16px !important; }

    /* === 右侧内容区 === */
    .gs-right { flex: 1; min-width: 0; }
    .gs-main-card { background: #fff; border-radius: 18px; border: 1px solid #e5e7eb; box-shadow: 0 1px 3px rgba(0,0,0,.04), 0 4px 12px rgba(0,0,0,.02); overflow: hidden; }

    /* 上传区域 */
    .gs-upload-section { padding: 24px; border-bottom: 1px solid #f1f5f9; }
    .gs-upload-title { display: flex; align-items: center; gap: 10px; margin-bottom: 16px; font-size: 15px; font-weight: 700; color: #1e293b; }
    .gs-upload-title-icon { width: 32px; height: 32px; border-radius: 10px; background: linear-gradient(135deg, #c7d2fe, #a5b4fc); display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; }
    .gs-upload-title-icon svg { width: 16px; height: 16px; fill: none; stroke: #4338ca; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .gs-dropzone {
        border: 2px dashed #c7d2fe; border-radius: 16px; padding: 28px 20px;
        text-align: center; cursor: pointer; transition: all .25s;
        background: linear-gradient(135deg, #fafafe 0%, #f5f3ff 100%);
    }
    .gs-dropzone:hover { border-color: #818cf8; background: linear-gradient(135deg, #eef2ff 0%, #ede9fe 100%); transform: translateY(-2px); box-shadow: 0 8px 25px rgba(99,102,241,.1); }
    .gs-dz-icon { margin-bottom: 10px; }
    .gs-dz-icon svg { width: 40px; height: 40px; fill: none; stroke: #a5b4fc; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; transition: all .25s; }
    .gs-dropzone:hover .gs-dz-icon svg { stroke: #6366f1; transform: translateY(-3px); }
    .gs-dz-text { font-size: 14px; color: #4b5563; font-weight: 600; }
    .gs-dz-hint { font-size: 12px; color: #9ca3af; margin-top: 4px; }

    /* 文件列表 */
    .gs-files-section { padding: 24px; }
    .gs-files-title { display: flex; align-items: center; gap: 10px; margin-bottom: 16px; font-size: 15px; font-weight: 700; color: #1e293b; }
    .gs-files-title-icon { width: 32px; height: 32px; border-radius: 10px; background: linear-gradient(135deg, #bfdbfe, #93c5fd); display: flex !important; align-items: center; justify-content: center; flex-shrink: 0; }
    .gs-files-title-icon svg { width: 16px; height: 16px; fill: none; stroke: #1d4ed8; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .gs-files { margin: 0; }
    .gs-file-item { display: flex; align-items: center; gap: 12px; padding: 12px 16px; border-radius: 12px; border: 1px solid #f1f5f9; transition: all .15s; background: #fff; margin-bottom: 6px; }
    .gs-file-item:hover { background: #f8fafc; border-color: #e2e8f0; box-shadow: 0 2px 8px rgba(0,0,0,.04); transform: translateX(2px); }
    .gs-file-item img { width: 28px; height: 28px; object-fit: contain; flex-shrink: 0; }
    .gs-file-name { flex: 1; min-width: 0; }
    .gs-file-name a { color: #1e293b !important; text-decoration: none !important; font-size: 13.5px; font-weight: 500; transition: color .15s; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; display: block; }
    .gs-file-name a:hover { color: #4f46e5 !important; }
    .gs-file-meta { font-size: 11px; color: #94a3b8; white-space: nowrap; display: flex; gap: 10px; align-items: center; }
    .gs-file-del { opacity: 0; transition: opacity .15s; flex-shrink: 0; }
    .gs-file-item:hover .gs-file-del { opacity: 1; }
    .gs-file-del input[type="image"] { width: 16px !important; height: 16px !important; border: none !important; background: none !important; cursor: pointer; opacity: .4; transition: all .15s; vertical-align: middle !important; }
    .gs-file-del input[type="image"]:hover { opacity: 1; transform: scale(1.2); }
    .gs-file-empty { text-align: center; padding: 40px 20px; color: #94a3b8; font-size: 13px; }

    /* DataList 覆盖 */
    .gs-page .gs-files table { border: none !important; width: 100% !important; border-spacing: 0 !important; }
    .gs-page .gs-files table td { border: none !important; padding: 0 !important; background: none !important; vertical-align: top !important; }
    .gs-page .gs-files table tr { background: none !important; }
    .gs-page .dfile { border: none !important; width: 100% !important; text-align: left !important; }

    /* 原始元素隐藏重置 */
    .gs-page .disk { margin: 0 !important; width: 100% !important; background: none !important; font-size: inherit !important; text-align: left !important; }
    .gs-page .dhead { display: none !important; }
    .gs-page .dcontext { margin: 0 !important; padding: 0 !important; height: auto !important; overflow: visible !important; background: none !important; }
    .gs-page #dleft { display: none !important; }
    .gs-page .leftcss { display: none !important; }
    .gs-page .rightcss { float: none !important; width: 100% !important; }
    .gs-page #dright div { text-align: left !important; }
    .gs-page .gs-hide { display: none !important; }
</style>

<div class="gs-page">
<div class="gs-layout">
    <!-- 左侧导航面板 -->
    <div class="gs-left">
        <div class="gs-nav-card">
            <div class="gs-nav-head">
                <div class="gs-nav-title">
                    <span class="gs-nav-title-icon"><svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg></span>
                    <h3>我的网盘</h3>
                </div>
                <p>管理你的文件与资源</p>
            </div>
            <div class="gs-nav-list">
                <asp:Button ID="BtnTea" runat="server" BackColor="#CFE4D0" BorderStyle="None"
                    Font-Bold="False" Font-Size="9pt" onclick="BtnTea_Click" Text="公共资源" CssClass="gs-tab" />
                <asp:Button ID="BtnStu" runat="server" BackColor="#CFE4D0" BorderStyle="None"
                    Font-Bold="False" Font-Size="9pt" onclick="BtnStu_Click" Text="我的网盘" CssClass="gs-tab" />
                <asp:Button ID="BtnGroup" runat="server" BackColor="#CFE4D0" BorderStyle="None"
                    Font-Bold="False" Font-Size="9pt" onclick="BtnGroup_Click" Text="小组网盘" CssClass="gs-tab" />
                <asp:CheckBox ID="CkIsGroup" runat="server" Enabled="False" Visible="False" />
            </div>
        </div>
        <!-- 网盘状态 -->
        <div class="gs-stat-card">
            <div class="gs-stat-head">
                <span class="gs-stat-icon"><svg viewBox="0 0 24 24"><path d="M22 12H2"/><path d="M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z"/><line x1="6" y1="16" x2="6.01" y2="16"/><line x1="10" y1="16" x2="10.01" y2="16"/></svg></span>
                <span class="gs-stat-label">网盘状态</span>
            </div>
            <div class="gs-stat-val">
                <asp:Label ID="Labeltitle" runat="server" Font-Bold="True" Font-Size="10pt"></asp:Label>
                <asp:Label ID="Labeldisk" runat="server" Font-Size="9pt" ForeColor="#047857"></asp:Label>
                <asp:Image ID="Imagedisk" runat="server" Height="16px" Width="16px" ImageUrl="~/images/diskgreen.gif" />
            </div>
        </div>
    </div>

    <!-- 右侧内容区 -->
    <div class="gs-right">
        <div class="gs-main-card">
            <!-- 上传区 -->
            <div class="gs-upload-section">
                <div class="gs-upload-title">
                    <span class="gs-upload-title-icon"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg></span>
                    上传文件
                </div>
                <div id="file_area" class="gs-dropzone" title="请点击或拖放文件到这里">
                    <div class="gs-dz-icon"><svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg></div>
                    <div class="gs-dz-text">点击或拖放文件到此处上传</div>
                    <div class="gs-dz-hint">支持文档、图片、音视频等格式，单文件不超过 30MB</div>
                </div>
            </div>
            <!-- 文件列表 -->
            <div class="gs-files-section">
                <div class="gs-files-title">
                    <span class="gs-files-title-icon"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg></span>
                    文件列表
                </div>
                <div class="gs-files">
                    <asp:DataList ID="Dlfilelist" runat="server"
                        RepeatColumns="1" RepeatDirection="Horizontal" CellPadding="0"
                        CellSpacing="0" Width="100%"
                        HorizontalAlign="Center" onitemcommand="Dlfilelist_ItemCommand"
                        onitemdatabound="Dlfilelist_ItemDataBound">
                        <ItemTemplate>
                            <div class="gs-file-item">
                                <asp:Image ID="Imageext" runat="server" ImageUrl='<%# Eval("Kftpe") %>' />
                                <div class="gs-file-name">
                                    <asp:HyperLink ID="HLfname" runat="server" NavigateUrl='<%# Eval("Kfurl") %>' Target="_blank" Text='<%# Eval("KfnameShort") %>' Font-Underline="False"></asp:HyperLink>
                                </div>
                                <div class="gs-file-meta">
                                    <span><asp:Label ID="Labelfsize" runat="server" Text='<%# Eval("Kfsize") %>' ToolTip='<%# Eval("Kfdate") %>'></asp:Label></span>
                                    <span><asp:Label ID="Labelfdate" runat="server" Text='<%# Eval("Kfdate") %>'></asp:Label></span>
                                </div>
                                <div class="gs-file-del">
                                    <asp:ImageButton ID="ImgBtnDelete" runat="server" CommandArgument='<%# Eval("Kfurl") %>'
                                        CommandName="D" ImageUrl="~/images/delete.gif" ToolTip="删除" />
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:DataList>
                </div>
            </div>
        </div>
    </div>
</div>
</div>

<script src="../js/dropzone/dropzone-min.js" type="text/javascript"></script>
<script type="text/javascript">
    // 检查网盘开关状态
    (function() {
        fetch('CheckNetdiskStatus.ashx')
            .then(response => response.json())
            .then(data => {
                if (!data.enabled) {
                    // 禁用时显示灰色提示信息
                    var mainCard = document.querySelector('.gs-main-card');
                    if (mainCard) {
                        mainCard.innerHTML = '<div style="padding: 60px 20px; text-align: center;">' +
                            '<div style="width: 80px; height: 80px; margin: 0 auto 20px; background: #f3f4f6; border-radius: 50%; display: flex; align-items: center; justify-content: center;">' +
                            '<svg style="width: 40px; height: 40px; fill: none; stroke: #9ca3af; stroke-width: 2;" viewBox="0 0 24 24">' +
                            '<path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/>' +
                            '<line x1="2" y1="12" x2="22" y2="12"/>' +
                            '</svg>' +
                            '</div>' +
                            '<h3 style="font-size: 18px; color: #6b7280; margin-bottom: 10px;">网盘未开启</h3>' +
                            '<p style="font-size: 14px; color: #9ca3af;">教师暂未开启网盘功能，请联系教师开启后使用</p>' +
                            '</div>';
                    }
                    
                    // 禁用上传区域
                    var uploadSection = document.querySelector('.gs-upload-section');
                    if (uploadSection) {
                        uploadSection.style.display = 'none';
                    }
                    
                    // 禁用导航按钮
                    var navButtons = document.querySelectorAll('.gs-tab');
                    navButtons.forEach(function(btn) {
                        btn.disabled = true;
                        btn.style.opacity = '0.5';
                        btn.style.cursor = 'not-allowed';
                    });
                }
            })
            .catch(err => {
                console.error('检查网盘状态失败:', err);
                // 出错时允许继续访问
            });
    })();
    
    if (typeof Dropzone !== 'undefined') Dropzone.autoDiscover = false;

    var isgroup = "<%=isgroup %>";
    var iscommon = "<%=iscommon %>";
    var can = "<%=can %>";
    var urlstr = "uploadfile.ashx?isgroup=" + isgroup + "&iscommon=" + iscommon;

    console.log('GroupShare page loaded');
    console.log('  - isgroup:', isgroup);
    console.log('  - iscommon:', iscommon);
    console.log('  - can:', can);
    console.log('  - urlstr:', urlstr);

    // 高亮当前标签
    (function(){
        var btns = document.querySelectorAll('.gs-tab');
        console.log('Found buttons:', btns.length);
        btns.forEach(function(b){ b.classList.remove('gs-active'); });
        if(iscommon === "True") { if(btns[0]) btns[0].classList.add('gs-active'); }
        else if(isgroup === "True") { if(btns[2]) btns[2].classList.add('gs-active'); }
        else { if(btns[1]) btns[1].classList.add('gs-active'); }
    })();

    // 初始化 Dropzone 上传
    if (can === "True" && typeof Dropzone !== 'undefined') {
        console.log('Initializing Dropzone...');
        try {
            new Dropzone("#file_area", {
                url: urlstr,
                method: "POST",
                addRemoveLinks: true,
                maxFiles: 1,
                maxFilesize: 30,
                uploadMultiple: false,
                parallelUploads: 100,
                previewsContainer: false,
                clickable: ['#file_area', '.gs-dz-icon', '.gs-dz-text', '.gs-dz-hint'],
                success: function (file, response, e) {
                    console.log('Upload success:', response);
                    alert(response);
                    location.reload();
                },
                error: function(file, errorMessage) {
                    console.error('Upload error:', errorMessage);
                    alert('上传失败: ' + errorMessage);
                    this.removeFile(file);
                }
            });
            console.log('Dropzone initialized successfully');
        } catch(e) {
            console.error('Dropzone init error:', e);
        }
    } else {
        console.log('Dropzone not initialized. can=' + can + ', Dropzone=' + (typeof Dropzone));
        var el = document.getElementById('file_area');
        if(el) {
            el.title = '';
            el.style.cursor = 'not-allowed';
            el.style.opacity = '0.6';
        }
    }
    
    // 确保按钮可以点击
    document.addEventListener('DOMContentLoaded', function() {
        var buttons = document.querySelectorAll('.gs-tab');
        console.log('Setting up button click handlers for', buttons.length, 'buttons');
        buttons.forEach(function(btn, index) {
            console.log('Button', index, ':', btn.id, btn.textContent);
            // 确保按钮可以点击
            btn.style.pointerEvents = 'auto';
            btn.style.cursor = 'pointer';
            
            // 添加点击日志
            btn.addEventListener('click', function(e) {
                console.log('Button clicked:', this.id, this.textContent);
            });
        });
    });
</script>
</asp:Content>
