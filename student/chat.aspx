<%@ page language="C#" autoeventwireup="true" inherits="student_chat, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>在线讨论</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" type="text/css" href="../code/imgchat/chat.css?v=20260212g" />
    <script type="text/javascript" src="../code/jquery.min.js"></script>
    <script type="text/javascript" src="../code/imgchat/fcup.min.js"></script>
    <script type="text/javascript" src="../code/imgchat/jquery.lineProgressbar.js"></script>
    <link rel="stylesheet" type="text/css" href="../code/imgchat/jquery.lineProgressbar.css" />
    <style>
    /* ===== 全局重置 ===== */
    * { margin:0; padding:0; border:none; box-sizing:border-box; }
    ul { list-style:none; } a { text-decoration:none; color:#6366f1; } a:hover { text-decoration:none; color:#4f46e5; }
    html,body { height:100%; width:100%; overflow:hidden; margin:0; padding:0; }
    body { font-family:'Microsoft YaHei','Segoe UI',system-ui,sans-serif; font-size:14px; text-align:left;
        background:#fff; margin:0; padding:0; position:relative; }
    img { max-height:200px; }

    /* ===== 主布局 - 100%撑满iframe ===== */
    .content { width:100%; height:100%; margin:0; padding:0; text-align:center; position:relative; }
    .chatBox { width:100%; height:100%; margin:0; background:#fff; border-radius:0;
        box-shadow:none; overflow:hidden; display:flex; animation:chatIn .35s ease; position:relative; }
    @keyframes chatIn { from{opacity:0} to{opacity:1} }

    /* ===== 左侧聊天区 ===== */
    .chatLeft { flex:1; display:flex; flex-direction:column; border-right:1px solid #f1f5f9; min-width:0; overflow:hidden; }
    .chat01 { flex:1; display:flex; flex-direction:column; min-height:0; overflow:hidden; }
    .chat01_title { padding:14px 20px; background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);
        position:relative; overflow:hidden; height:auto; flex-shrink:0; display:flex; align-items:center; justify-content:space-between; }
    .chat01_title::before { content:''; position:absolute; top:-20px; right:-10px; width:80px; height:80px;
        border-radius:50%; background:rgba(255,255,255,.08); }
    .talkTo { display:flex; align-items:center; margin:0; padding:0; flex:1; }
    .talkTo li { background:none!important; padding:0!important; margin:0!important; line-height:normal!important; float:none; list-style:none; }
    .talkTo li a { background:none!important; padding:0!important; font-size:15px!important; font-weight:700;
        color:#fff!important; text-decoration:none!important; display:flex; align-items:center; gap:8px; height:auto; }
    .talkTo li a::before { content:'\1F4AC'; font-size:18px; }

    /* ===== 消息区 - flex自适应填满 ===== */
    .chat01_content { flex:1; overflow-x:hidden; overflow-y:auto; padding:14px 18px;
        background:#fafbff; min-height:0; position:relative; }
    .message_box { display:none; min-height:0; } .message_box.mes { display:block!important; width:100%; }
    .message { clear:both; padding:8px 0; position:relative; margin:0 0 2px; }
    .message .user-logo { float:left; width:36px; height:36px; border-radius:10px; object-fit:cover; resize:none; }
    .message .wrap-text { background:#fff; border-radius:0 12px 12px 12px; padding:10px 14px; margin-left:8px;
        display:inline-block; max-width:420px; box-shadow:0 1px 4px rgba(0,0,0,.04);
        border:1px solid #f1f5f9; overflow:hidden; resize:none; float:left; width:auto; }
    .message .wrap-text div { margin:4px 0 0; word-break:break-all; word-wrap:break-word;text-align: left;
        height:auto; overflow:hidden; white-space:pre-wrap; font-size:13px; line-height:1.6; color:#334155; }
    .message .wrap-text div img { max-height:160px; border-radius:8px; margin:4px 0; }
    .message h5 { color:#6366f1; font-weight:700; }
    .message .name { color:#6366f1; font-weight:700; font-size:12px; }
    .message .time { color:#94a3b8; margin-left:8px; font-size:11px; font-weight:400; }
    .message .wrap-ri { float:right; width:100px; overflow:hidden; resize:none; }
    .message .wrap-ri div { text-align:right; color:#94a3b8; height:18px; line-height:18px;
        overflow:hidden; clear:both; position:absolute; bottom:10px; right:5px; }
    .message .wrap-ri div span { display:inline-block; line-height:18px; vertical-align:bottom; zoom:1; }

    /* ===== 工具栏 + 输入区 + 发送栏 ===== */
    .chat02 { display:flex; flex-direction:column; flex-shrink:0; min-height:0; background:#fff; }
    .chat02_title { padding:0 14px; height:36px; background:#fff; border-top:1px solid #f1f5f9;
        border-bottom:1px solid #f1f5f9; position:relative; display:flex; align-items:center; flex-shrink:0; }
    .chat02_title_btn { cursor:pointer; display:inline-flex; align-items:center; justify-content:center;
        width:30px; height:30px; border-radius:8px; margin:0 2px; transition:background .15s;
        background:transparent!important; background-image:none!important; font-size:16px; color:#94a3b8; float:left; }
    .chat02_title_btn:hover { background:#f1f5f9!important; color:#6366f1; }
    .ctb01 { background:none!important; margin-left:4px!important; } .ctb01::after { content:'\1F642'; font-size:17px; }
    .ctb011 { background:none!important; background-position:unset!important; } .ctb011::after { content:'\2728'; font-size:17px; }
    .ctb02 { background:none!important; background-position:unset!important; position:relative; overflow:hidden; } .ctb02::after { content:'\1F5BC'; font-size:17px; pointer-events:none; }
    .chat02_title_t { background:none!important; cursor:pointer; position:absolute; top:50%; right:14px;
        transform:translateY(-50%); display:flex; align-items:center; gap:5px; padding:3px 8px;
        border-radius:6px; font-size:11px; color:#94a3b8; transition:all .15s; height:auto; width:auto; }
    .chat02_title_t::before { content:'\1F4CB'; font-size:13px; }
    .chat02_title_t:hover { background:#f1f5f9; color:#6366f1; }
    .chat02_title_t a { color:#94a3b8!important; font-size:11px; text-decoration:none!important; }
    .chat02_content { padding:8px 14px; background:#fff; overflow-x:hidden; margin-left:0; flex-shrink:0; position:relative; }
    .chat02_content .attach_icon { position:absolute; right:18px; top:50%; transform:translateY(-50%); 
        cursor:pointer; width:24px; height:24px; display:flex; align-items:center; justify-content:center;
        color:#94a3b8; font-size:16px; transition:all .15s; z-index:5; text-decoration:none; }
    .chat02_content .attach_icon::before { content:'\1F4CB'; font-size:16px; }
    .chat02_content .attach_icon:hover { color:#6366f1; }
    .textarea { outline:none; width:100%; height:68px; overflow-y:auto; font-size:13px; line-height:1.6;
        color:#334155; padding:2px 380px 2px 0; text-align:left; }
    .textarea:empty::before { content:'\8F93\5165\6D88\606F\FF0CCtrl+Enter \53D1\9001...'; color:#cbd5e1; pointer-events:none; }
    .textarea:focus:empty::before { content:''; }
    .textarea img { max-height:100px; border-radius:6px; }
    .chat02_bar { background:#fff; height:44px; position:relative; border-top:1px solid #f8fafc;
        padding:0 14px; display:flex; align-items:center; justify-content:flex-end; flex-shrink:0; }
    .chat02_bar ul { height:100%; display:flex; align-items:center; width:100%; position:relative; }
    .chat02_bar li { position:absolute; top:50%; transform:translateY(-50%); }
    .chat02_bar li button { width:72px!important; height:30px!important; min-width:0!important; max-width:72px!important;
        background:linear-gradient(135deg,#6366f1,#818cf8)!important;
        color:#fff!important; font-weight:600; border:none!important; border-radius:8px; cursor:pointer;
        transition:all .2s; box-shadow:0 2px 8px rgba(99,102,241,.2); font-size:0!important;
        padding:0!important; line-height:30px!important; text-align:center; display:inline-flex!important;
        align-items:center; justify-content:center; }
    .chat02_bar li button::after { content:'\53D1\9001'; font-size:12px; font-weight:600; letter-spacing:3px;
        color:#fff; display:inline; }
    .chat02_bar li button:hover { background:linear-gradient(135deg,#4f46e5,#6366f1)!important;
        box-shadow:0 4px 12px rgba(99,102,241,.3); transform:translateY(-1px); }

    /* ===== 右侧成员栏 ===== */
    .chatRight { width:176px; display:flex; flex-direction:column; background:#fafbff; flex-shrink:0; overflow:hidden; }
    .chat03 { display:flex; flex-direction:column; min-height:0; overflow:hidden; }
    .chat03:first-child { flex:1; min-height:0; }
    .chat03_title { padding:12px 14px; background:#fff; border-bottom:1px solid #f1f5f9; position:relative; height:auto; flex-shrink:0; display:flex; align-items:center; }
    .chat03_title_t { background:none!important; cursor:pointer; position:static; display:flex;
        align-items:center; gap:6px; padding:0; height:auto; width:auto;
        font-size:12px; font-weight:700; color:#1e293b; left:auto; top:auto; }
    .chat03_title_t::before { content:'\1F465'; font-size:14px; }
    .chat03_title_f { background:none!important; cursor:pointer; position:static; display:flex;
        align-items:center; gap:6px; padding:0; height:auto; width:auto;
        font-size:12px; font-weight:700; color:#1e293b; left:auto; top:auto; }
    .chat03_title_f::before { content:'\1F4C2'; font-size:14px; }
    .chat03_content { text-align:left; font-size:12px; color:#333; margin:0; padding:6px; flex:1; overflow-y:auto; min-height:0; }
    .chat03_content ul { overflow-y:auto; margin:0; padding:0; }
    .chat03_content ul li { position:relative; padding:7px 10px; border-radius:10px; margin-bottom:3px;
        display:flex; align-items:center; gap:8px; transition:all .2s; cursor:pointer; height:auto; }
    .chat03_content ul li:hover, .chat03_content ul li.hover { background:#eef2ff; }
    .chat03_content ul li.choosed { background:#e0e7ff; }

    /* -- 头像状态指示灯 -- */
    .chat03_content ul li label { display:block; position:absolute; width:11px; height:11px;
        left:34px; bottom:6px; border-radius:50%!important; border:2px solid #fff; z-index:2; transition:all .3s; }
    label.online { background:#22c55e!important; box-shadow:0 0 5px rgba(34,197,94,.5); }
    label.offline { background:#cbd5e1!important; }

    /* -- 头像 - 始终彩色 -- */
    .chat03_content ul img { width:36px; height:36px; border-radius:10px; object-fit:cover; flex-shrink:0; transition:all .3s; }
    .chat03_content ul img.online { border-radius:10px!important; filter:none!important; box-shadow:0 0 0 2px #22c55e; }
    .chat03_content ul img.offline { border-radius:10px!important; filter:none!important; opacity:.85; }

    /* -- 新消息绿色圆点 -- */
    .chat03_content ul li.has-new-msg { background:linear-gradient(90deg,#f0fdf4,transparent); }
    .chat03_content ul li.has-new-msg::after { content:''; position:absolute; right:8px; top:50%; transform:translateY(-50%);
        width:8px; height:8px; background:#22c55e; border-radius:50%; box-shadow:0 0 6px rgba(34,197,94,.45);
        animation:msgDot 1.6s ease-in-out infinite; }
    @keyframes msgDot { 0%,100%{opacity:1;transform:translateY(-50%) scale(1)} 50%{opacity:.5;transform:translateY(-50%) scale(1.4)} }

    /* -- 发言动态效果 - 头像弹跳+光圈 -- */
    .chat03_content ul li.speaking img { animation:speakBounce .5s cubic-bezier(.36,.07,.19,.97); }
    .chat03_content ul li.speaking { background:linear-gradient(90deg,#eef2ff,#f5f3ff,transparent); }
    .chat03_content ul li.speaking label { animation:speakRing .5s ease; }
    @keyframes speakBounce {
        0%{transform:scale(1)} 20%{transform:scale(1.18)} 40%{transform:scale(.95)}
        60%{transform:scale(1.08)} 80%{transform:scale(.98)} 100%{transform:scale(1)}
    }
    @keyframes speakRing {
        0%{box-shadow:0 0 0 0 rgba(34,197,94,.6)} 100%{box-shadow:0 0 0 8px rgba(34,197,94,0)}
    }

    .chat03_name { color:#334155!important; font-size:12px; font-weight:600; position:static!important;
        display:inline!important; text-decoration:none!important; top:auto!important; left:auto!important;
        overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:80px; }
    .chat03_name:hover { color:#6366f1!important; text-decoration:none!important; }

    /* ===== 附件区 ===== */
    .chat03_file { display:none; padding:6px; flex:1; overflow-y:auto; min-height:0; }
    .chat03_file ul { overflow-y:auto; max-height:100%; margin:0; padding:0; }
    .chat03_file ul li { padding:6px 8px; border-radius:8px; margin-bottom:2px;
        display:flex; align-items:center; gap:6px; transition:background .15s; }
    .chat03_file ul li:hover { background:#eef2ff; }
    .chat03_file ul li a { text-overflow:ellipsis; overflow:hidden; white-space:nowrap; color:#475569; font-size:11px; }
    .chat03_file ul img { width:14px; height:14px; flex-shrink:0; }

    /* ===== 表情面板 ===== */
    .wl_faces_box { position:absolute; width:400px; bottom:36px; left:6px; display:none; z-index:100;
        background:#fff; border-radius:12px; box-shadow:0 8px 32px rgba(0,0,0,.12); overflow:hidden; height:auto; }
    .wl_faces_content { background:#fff; border:none; width:100%; height:auto; margin:0; padding:0; }
    .wl_faces_content .title { background:linear-gradient(135deg,#f8fafc,#f1f5f9); height:40px;
        border-bottom:1px solid #e8ecf1; display:flex; align-items:center; padding:0 14px; position:relative; }
    .wl_faces_content .title ul { display:flex; width:100%; align-items:center; }
    .wl_faces_content .title ul li { position:static; display:inline-flex; }
    .wl_faces_content .title ul li.title_name { background:none; width:auto; height:auto;
        font-size:12px; font-weight:700; color:#334155; text-align:left; line-height:normal; bottom:auto; left:auto; }
    .wl_faces_content .title ul li.wl_faces_close { margin-left:auto; position:static; right:auto; top:auto; }
    .wl_faces_content .title ul li.wl_faces_close span { background:none; cursor:pointer;
        display:flex; align-items:center; justify-content:center; width:26px; height:26px;
        border-radius:8px; transition:background .15s; font-size:0; }
    .wl_faces_content .title ul li.wl_faces_close span::after { content:'\2715'; font-size:13px; color:#94a3b8; }
    .wl_faces_content .title ul li.wl_faces_close span:hover { background:#fee2e2; }
    .wl_faces_content .title ul li.wl_faces_close span:hover::after { color:#ef4444; }
    .wl_faces_main { padding:10px; }
    .wl_faces_main ul { margin:0; overflow:hidden; border:1px solid #e8ecf1; border-radius:10px;
        display:flex; flex-wrap:wrap; width:100%; }
    .wl_faces_main ul li { float:left; border:none; height:auto; width:auto; margin:0; padding:5px;
        text-align:center; border-radius:6px; transition:background .12s; cursor:pointer; }
    .wl_faces_main ul li:hover { background:#eef2ff; }
    .wl_faces_main ul li img { width:22px; height:22px; }
    .wlf_icon { display:none; }
    .wl_emo_box { position:absolute; width:440px; bottom:36px; left:6px; display:none; z-index:100;
        background:#fff; border-radius:12px; box-shadow:0 8px 32px rgba(0,0,0,.12); overflow:hidden; height:auto; }
    .wl_emo_content { background:#fff; border:none; width:100%; height:auto; margin:0; padding:0; }
    .wl_emo_content .title { background:linear-gradient(135deg,#f8fafc,#f1f5f9); height:40px;
        border-bottom:1px solid #e8ecf1; display:flex; align-items:center; padding:0 14px; position:relative; }
    .wl_emo_content .title ul { display:flex; align-items:center; }
    .wl_emo_content .title ul li { position:static; display:inline-flex; }
    .wl_emo_content .title ul li.title_name { background:none; width:auto; height:auto;
        font-size:12px; font-weight:700; color:#334155; bottom:auto; left:auto; line-height:normal; }
    .wl_emo_main { word-wrap:break-word; margin:0; padding:10px; overflow-y:auto; width:100%; height:220px;
        cursor:pointer; font-size:22px; font-family:seguiemj; border:none; }
    .wlf_emo { display:none; }
    input.f1, input.f2 { display:none; }
    .chatpic { border-radius:8px; cursor:zoom-in!important; } .chatpic:hover { opacity:.92; }
    .enlargeImg_wrapper { display:none; position:fixed; z-index:999; top:0; right:0; bottom:0; left:0;
        background-repeat:no-repeat; background-position:center; background-color:rgba(0,0,0,.85);
        background-size:contain; cursor:zoom-out; backdrop-filter:blur(4px); }
    #progress { width:280px; }
    ::-webkit-scrollbar { width:5px; height:5px; }
    ::-webkit-scrollbar-track { background:transparent; }
    ::-webkit-scrollbar-thumb { background:#cbd5e1; border-radius:3px; }
    ::-webkit-scrollbar-thumb:hover { background:#94a3b8; }
    </style>
</head>
<body>
    <style>#stu<%=Snum %> label{background:#22c55e!important;box-shadow:0 0 6px rgba(34,197,94,.5)!important}#stu<%=Snum %> img{box-shadow:0 0 0 2px #22c55e!important;opacity:1!important}</style>
    <div class="imgBox" ></div>
    <div class="content">
        <div class="chatBox">
            <div class="chatLeft">
                <div class="chat01">
                    <div class="chat01_title">
                        <ul class="talkTo">
                            <li><a href="javascript:;"> 小组讨论   <%=Sname %> </a></li>
                        </ul>
                    </div>
                    <div class="chat01_content">
                        <div class="message_box mes" style="display: block;">
                        </div>
                    </div>
                </div>
                <div class="chat02">
                    <div class="chat02_title">					
                        <a class="chat02_title_btn ctb01" href="javascript:;" title="常用表情"></a>
                        <a class="chat02_title_btn ctb011" href="javascript:;" title="表情符号" ></a>						
						<a class="chat02_title_btn ctb02" href="javascript:;" title="其他功能"> </a>						
                        <a class="chat02_title_t" id="chatrecord" title="聊天记录"></a>
						
                        <div class="wl_faces_box" title="选择表情" >
                            <div class="wl_faces_content">
                                <div class="title">
                                    <ul>
                                        <li class="title_name">常用表情</li><li class="wl_faces_close"><span>&nbsp;</span></li></ul>
                                </div>
                                <div class="wl_faces_main">
                                    <ul>                                          
                                       <asp:Repeater ID="Rpemo" runat="server">
                                        <ItemTemplate>
                                        <li>
                                            <a href="javascript:;"> <img src='<%# Eval("Emo") %>' /></a>
                                        </li>
                                        </ItemTemplate>
                                       </asp:Repeater>

                                    </ul>
                                </div>
                            </div>
                            <div class="wlf_icon">
                            </div>
                        </div>

                        <div class="wl_emo_box" >
                            <div class="wl_emo_content">
								<div class="title">
                                    <ul>
                                        <li class="title_name">表情符号</li>
									</ul>
                                </div>
                                <div class="wl_emo_main" title="双击添加">
								
                                </div>
                            </div>
                            <div class="wlf_emo">
                            </div>
                        </div>

                    </div>
                    <div class="chat02_content">
						<div class="textarea" name="chatword"  contenteditable="true"></div>
						<a class="attach_icon" id="upphoto" title="发送图片附件"></a>
                    </div>
                    <div class="chat02_bar">
                        <ul>
                            <li style="left: 4px; ">
								<div id="progress"></div>
							</li>
                            <li style="right: 30px;"><button></button> </li>
                        </ul>
                    </div>
								<audio id="audio" hidden="true" ></audio>
                </div>
            </div>
            <div class="chatRight">
                <div class="chat03">
                    <div class="chat03_title">
                        <label class="chat03_title_t"><%=Sgtitle %></label>
                    </div>
                    <div class="chat03_content">
                        <ul>  
                           <asp:Repeater ID="Rpteam" runat="server">
                            <ItemTemplate>
                            <li id="stu<%# Eval("Snum") %>">
                                <label class="offline"></label>
                                <a href="javascript:;"><img class="offline" src='<%# Eval("Avatar") %>'></a>
                                <a href="javascript:;" class="chat03_name"><%# Eval("Sname") %></a>
                            </li>
                            </ItemTemplate>
                           </asp:Repeater>
                        </ul>
                    </div>
                </div>
				
                <div class="chat03">
                    <div class="chat03_title">
                        <label class="chat03_title_f">附件管理</label>
                    </div>
                    <div class="chat03_file">
                        <ul> 
                           <asp:Repeater ID="Rpfile" runat="server">
                            <ItemTemplate>
                            <li>
                                <a href="javascript:;"><img src='<%# Eval("ftype") %>'></a>
                                <a href='<%# Eval("furl") %>' target='_blank' ><%# Eval("fname")%></a>
                            </li>
                            </ItemTemplate>
                           </asp:Repeater> 
                        </ul>
                    </div>
                </div>
				
            </div>
            <div style="clear: both;">
            </div>
        </div>
    </div>
	
    <script type="text/javascript">
        var head = "<%=Head %>"; 
        var sname = "<%=Sname %>"; 
        var snum = "<%=Snum %>"; 
        var sgtitle = "<%=Sgtitle %>"; 
        var sgroup = "<%=Sgroup %>";
        var historys = "<%=History %>";
        var serverip = "<%=serverIp %>";
        // 立即设置当前用户在线状态（原生JS，不依赖jQuery）
        (function(){
            var me = document.getElementById('stu' + snum);
            if(me){
                var lbl = me.querySelector('label');
                var img = me.querySelector('img');
                if(lbl){ lbl.className = 'online'; }
                if(img){ img.className = 'online'; }
            }
        })();
    </script>	

<script type="text/javascript" src="../code/imgchat/chat.js?v=20260212d"></script>

</body>
</html>
