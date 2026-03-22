<%@ page title="" language="C#" masterpagefile="~/student/Scm.master" stylesheettheme="Student" autoeventwireup="true" inherits="Student_txtform, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" runat="Server">
<style>
    /* ===== 填表页面 — 重新设计 ===== */

    /* ---------- 主容器（纵向：标题 + 双栏） ---------- */
    div#showcontent,
    #showcontent {
        display: flex !important;
        flex-direction: column !important;
        gap: 24px !important;
        max-width: 1640px !important;
        margin: 0 auto !important;
        padding: 34px 24px 56px !important;
        min-height: calc(100vh - 200px);
        animation: tf-fadeIn .5s cubic-bezier(.22,1,.36,1) !important;
        width: min(100%, 1640px) !important;
        font-size: 14px !important;
        position: relative !important;
    }

    /* ---------- 双栏容器（横向） ---------- */
    .tf-columns {
        display: flex !important;
        flex-direction: row !important;
        flex-wrap: nowrap !important;
        align-items: flex-start !important;
        gap: 32px !important;
    }

    @keyframes tf-fadeIn {
        from { opacity: 0; transform: translateY(16px); }
        to   { opacity: 1; transform: translateY(0); }
    }
    @keyframes tf-popIn {
        from { opacity: 0; transform: scale(.92); }
        to   { opacity: 1; transform: scale(1); }
    }
    @keyframes tf-checkBounce {
        0%,100% { transform: scale(1); }
        40%     { transform: scale(1.12); }
    }

    /* ---------- 左侧内容区 ---------- */
    .tf-columns > .left,
    div#showcontent .left,
    #showcontent .left {
        flex: 1 !important;
        min-width: 0 !important;
        display: flex !important;
        flex-direction: column !important;
        gap: 20px !important;
        float: none !important;
        width: auto !important;
        overflow: visible !important;
        text-align: left !important;
    }

    /* ---- 任务标题 ---- */
    div.missiontitle,
    .missiontitle {
        background: linear-gradient(135deg, #f8fbff 0%, #eef4ff 52%, #f7f1ff 100%) !important;
        border: 1px solid #d9e5ff !important;
        border-radius: 22px !important;
        padding: 28px 34px !important;
        margin-bottom: 0 !important;
        color: #12223d !important;
        box-shadow: none !important;
        position: relative !important;
        overflow: hidden !important;
        display: flex !important;
        align-items: center !important;
        gap: 14px !important;
        text-align: left !important;
        font-size: 24px !important;
        width: auto !important;
        box-sizing: border-box !important;
    }
    div.missiontitle::before,
    .missiontitle::before {
        content: '\270F' !important; /* ✏ */
        font-size: 40px !important;
        opacity: .08 !important;
        position: absolute !important;
        right: 24px !important;
        top: 50% !important;
        left: auto !important;
        width: auto !important;
        height: auto !important;
        transform: translateY(-50%) rotate(-12deg) !important;
        pointer-events: none !important;
        background: none !important;
        animation: none !important;
    }
    .missiontitle span,
    .missiontitle label {
        font-size: 24px !important;
        font-weight: 700 !important;
        color: #12223d !important;
        position: relative;
        z-index: 1;
        letter-spacing: .3px;
        text-shadow: none !important;
    }
    .missiontitle #connected {
        position: relative;
        z-index: 1;
        width: 26px;
        height: 26px;
        vertical-align: middle;
        cursor: pointer;
        transition: transform .25s;
        filter: brightness(1.15);
    }
    .missiontitle #connected:hover {
        transform: scale(1.18) rotate(8deg);
    }

    /* ---- 通用卡片 ---- */
    .tf-card {
        background: #fff;
        border-radius: 20px;
        border: 1px solid #e2e8f0;
        box-shadow: none;
        position: relative;
        overflow: hidden;
    }
    .tf-card:hover {
        box-shadow: none;
    }
    .tf-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 3px;
        background: linear-gradient(90deg, #6366f1, #a78bfa, #c4b5fd);
        border-radius: 14px 14px 0 0;
    }

    /* ---- 任务说明内容 ---- */
    .tf-card.coursecontent {
        padding: 28px 34px !important;
        line-height: 1.8 !important;
        font-size: 16px !important;
        color: #374151 !important;
        min-height: auto !important;
        width: auto !important;
        box-sizing: border-box !important;
    }

    /* ---- 表格区域 ---- */
    .coursetable {
        padding: 24px 28px;
        overflow-x: auto;
    }
    .coursetable table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        font-size: 15px;
        min-width: 980px;
    }
    .coursetable table tr:first-child td {
        background: #f8fafc;
        font-weight: 600;
        color: #334155;
    }
    .coursetable table td {
        padding: 14px 16px;
        border: 1px solid #e2e8f0;
        transition: background .2s, border-color .2s;
    }
    .coursetable table td[contenteditable="true"] {
        background: #f0fdf4;
        border-color: #86efac;
        cursor: text;
        outline: none;
    }
    .coursetable table td[contenteditable="true"]:focus {
        background: #dcfce7;
        border-color: #4ade80;
        box-shadow: inset 0 0 0 2px rgba(74,222,128,.25);
    }
    .coursetable table td[contenteditable="true"]:hover {
        background: #dcfce7;
    }
    .coursetable table td[contenteditable="false"],
    .coursetable table td[contenteditable="none"] {
        background: #fefce8;
        border-color: #fde68a;
        color: #92400e;
        cursor: not-allowed;
    }

    /* ---------- 右侧操作面板 ---------- */
    .tf-columns > .right,
    div#showcontent .right,
    #showcontent .right {
        width: 360px !important;
        flex-shrink: 0 !important;
        position: sticky !important;
        top: 92px !important;
        height: fit-content !important;
        float: none !important;
        overflow: visible !important;
        text-align: center !important;
    }

    .tf-action-panel {
        background: #fff;
        border-radius: 20px;
        border: 1px solid #e2e8f0;
        box-shadow: none;
        padding: 30px 26px;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 20px;
        position: relative;
        overflow: hidden;
    }
    .tf-action-panel::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 3px;
        background: linear-gradient(90deg, #6366f1, #a78bfa);
    }

    .tf-action-panel .tf-panel-title {
        font-size: 16px;
        font-weight: 700;
        color: #1e293b;
        letter-spacing: .3px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .tf-action-panel .tf-panel-title svg {
        width: 18px;
        height: 18px;
        stroke: #6366f1;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
        flex-shrink: 0;
    }

    .tf-action-panel .tf-divider {
        width: 100%;
        height: 1px;
        background: #f1f5f9;
    }

    /* 成功图标 */
    #sucessed {
        width: 80px;
        height: 80px;
        display: none;
        animation: tf-checkBounce .6s ease;
    }

    /* 提交按钮 */
    #Btnform {
        background: linear-gradient(135deg, #6366f1, #818cf8) !important;
        color: #fff !important;
        border: none !important;
        border-radius: 14px !important;
        padding: 14px 0 !important;
        width: 100% !important;
        height: auto !important;
        font-size: 16px !important;
        font-weight: 700 !important;
        cursor: pointer !important;
        transition: all .25s !important;
        box-shadow: none !important;
        letter-spacing: 1px;
    }
    #Btnform:hover {
        background: linear-gradient(135deg, #4f46e5, #6366f1) !important;
        transform: translateY(-2px);
        box-shadow: none !important;
    }
    #Btnform:active {
        transform: translateY(0);
        box-shadow: none !important;
    }

    /* 消息提示 */
    #msg:not(:empty) {
        color: #dc2626;
        font-size: 13px;
        padding: 10px 14px;
        background: #fef2f2;
        border: 1px solid #fecaca;
        border-radius: 8px;
        width: 100%;
        text-align: center;
        animation: tf-popIn .3s ease;
    }

    /* 查看结果链接 */
    .txts20center {
        display: inline-flex !important;
        align-items: center !important;
        justify-content: center !important;
        gap: 8px !important;
        padding: 12px 0 !important;
        width: 100% !important;
        height: auto !important;
        background: #f8fafc !important;
        color: #475569 !important;
        border-radius: 14px !important;
        font-size: 15px !important;
        font-weight: 600 !important;
        text-decoration: none !important;
        transition: all .25s !important;
        border: 1px solid #e2e8f0 !important;
    }
    .txts20center:hover {
        background: #eef2ff !important;
        color: #4f46e5 !important;
        border-color: #c7d2fe !important;
        transform: translateY(-1px);
    }
    .txts20center svg {
        width: 16px;
        height: 16px;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
        flex-shrink: 0;
    }

    /* 协作者提示框 */
    .namebox {
        position: absolute;
        display: none;
        color: #fff;
        background: linear-gradient(135deg, #6366f1, #818cf8);
        padding: 5px 12px;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 500;
        box-shadow: 0 3px 10px rgba(99,102,241,.30);
        z-index: 1000;
        white-space: nowrap;
        pointer-events: none;
    }
    .namebox::after {
        content: '';
        position: absolute;
        bottom: -4px;
        left: 12px;
        width: 8px; height: 8px;
        background: #818cf8;
        transform: rotate(45deg);
    }

    /* ---------- 响应式 ---------- */
    @media (max-width: 1024px) {
        div#showcontent,
        #showcontent {
            padding: 24px 16px 40px !important;
        }
        .tf-columns {
            flex-direction: column !important;
        }
        .tf-columns > .right,
        div#showcontent .right,
        #showcontent .right {
            width: 100% !important;
            position: static !important;
        }
        .tf-action-panel {
            flex-direction: row;
            flex-wrap: wrap;
            justify-content: center;
        }
        .tf-action-panel .tf-divider { display: none; }
        #Btnform { width: auto; padding: 12px 40px; }
        .txts20center { width: auto; padding: 10px 28px; }
    }

    @media (max-width: 768px) {
        #showcontent { padding: 16px 10px 32px; gap: 16px; }
        .missiontitle { padding: 18px 20px; border-radius: 12px; }
        .missiontitle span { font-size: 17px; }
        .coursecontent { padding: 18px 20px; }
        .coursetable { padding: 14px 16px; }
        .coursetable table td { padding: 10px 10px; font-size: 13px; }
        .tf-card { border-radius: 12px; }
    }
</style>
    <div id="showcontent">
        <div class="missiontitle">
            <asp:Label ID="LabelMtitle" runat="server"></asp:Label>
            <img id="connected" alt="" src="../images/topictitle.png" style="display: none;"
                title="小组协作填表已开启" />
        </div>
        <div class="tf-columns">
        <div class="left">
            <div class="courseother"></div>
            <div id="Mcontent" class="tf-card coursecontent" runat="server">
            </div>
            <div id="Mtable" class="tf-card coursetable" runat="server">
            </div>
        </div>
        <div class="right">
            <div class="tf-action-panel">
                <span class="tf-panel-title"><svg viewBox="0 0 24 24"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2"/><rect x="9" y="3" width="6" height="4" rx="1"/><path d="M9 12h6"/><path d="M9 16h6"/></svg>操作面板</span>
                <div class="tf-divider"></div>
                <img id="sucessed" alt="" src="../images/sucessed.png" />
                <input id="Btnform" type="button" value="提交填写" onclick="SaveForm();" />
                <div id="msg"></div>
                <asp:HyperLink ID="Hlresult" runat="server" CssClass="txts20center"
                    SkinID="HyperLink" Target="_blank"><svg viewBox="0 0 24 24"><path d="M18 20V10"/><path d="M12 20V4"/><path d="M6 20v-6"/></svg>查看结果</asp:HyperLink>
            </div>
        </div>
        </div>
        <span class="namebox">TextName</span>
            <script type="text/javascript">

                var snum = "<%=Snum %>";
                var sname = "<%=Sname %>";
                var sgroup = "<%=Sgroup %>";
                var isopen = true;
                var collabo = "<%=Collabo %>";
                var serverip = "<%=serverIp %>";

                if (collabo == "false") {
                    $("#connected").hide();
                    isopen = false;
                }

                $("#connected").click(function () {
                    if (isopen) {
                        isopen = false;
                        $(this).css("filter", "hue-rotate(200deg)");
                        $(this).attr("title", "不接收小组协作内容");
                    }
                    else {
                        isopen = true;
                        $(this).css("filter", "");
                        $(this).attr("title", "接收小组协作内容");
                    }
                });

                function tableshow() {
                    var table = $("div.coursecontent table");  // tableId是你需要遍历的Table的id
                    table.css("table-layout", "auto");
                    var tds = []; //清空数组
                    var idx = 0;
                    table.find("tr").each(function () {
                        $(this).find("td").each(function () {
                            $(this).attr("id", "cell" + idx);
                            idx += 1;
                            var cellContent = $(this).text();  // 获取单元格中的内容
                            cellContent = jQuery.trim(cellContent);
                            var cellCan = $(this).attr("contenteditable");
                            var cellId = $(this).attr("id");
                            if (cellCan) {
                                //console.log(cellId," ",cellContent,"  ",cellCan);  // 在控制台中显示单元格中的内容
                                tds.push(cellContent);
                                $(this).text(cellContent);
                            }
                        });
                    });
                    //console.log(tds);
                    return tds;
                }

                var oldid = "";
                var isconnect = false;

                var start = function () {
                    tableshow(); //给表格单元格id赋值

                    var msg = "正在连接协作服务...\n";
                    var hostip = location.host;
                    if (serverip != "") {
                        hostip = serverip;
                    }
                    console.log(hostip, msg);

                    // create a new websocket and connect（自动适配 HTTPS → wss）
                    var wsProto = location.protocol === 'https:' ? 'wss:' : 'ws:';
                    var wsurl = wsProto + "//" + hostip + ":8188/";
                    window.ws = new WebSocket(wsurl);

                    //当客户端收到服务端发来的消息时，触发onmessage事件
                    //参数e.data包含server传递过来的数据
                    ws.onmessage = function (evt) {
                        var msg = JSON.parse(evt.data);
                        var idstr = "#" + msg[0];
                        var textstr = msg[1];
                        var snumstr = msg[2];
                        var namestr = msg[3];
                        var txtform = msg[4];
                        var sgroupstr = msg[5];
                        var talktimestr = msg[6];

                        if (isopen) {
                            if (txtform == "txtform") {
                                if (sgroup == sgroupstr) {
                                    if (oldid != "") {
                                        $(oldid).attr({ contenteditable: "true" }); //设置当前单元格可编辑
                                    }
                                    oldid = idstr; //存储当前单元格id
                                    $(idstr).text(textstr);
                                    $(".namebox").text(namestr + "正在输入...");
                                    $(".namebox").show();

                                    var p = $(idstr).offset();
                                    p.left = p.left + textstr.length;
                                    p.top = p.top;
                                    $(".namebox").offset(p);
                                    console.log("接收小组成员", namestr, "协作信息", talktimestr);
                                    if (snum != snumstr) {
                                        $(idstr).attr({ contenteditable: "none" }); //设置当前单元格占用，不可编辑
                                    }
                                }
                                else {
                                    $(".namebox").hide();
                                    console.log("...");
                                }
                            }
                        }
                    };

                    // 当WebSocket创建成功时，触发onopen事件
                    ws.onopen = function () {
                        msg = '.. 已连接\n';
                        console.log(msg);
                        isconnect = true;
                        if (collabo == "true") {
                            $("#connected").show();
                        }
                    };

                    // 当客户端收到服务端发送的关闭连接请求时，触发onclose事件
                    ws.onclose = function () {
                        msg = '.. 已断开\n';
                        console.log(msg);
                        isconnect = false;
                        $(".namebox").hide();
                    }

                    // 如果出现连接、处理、接收、发送数据失败的时候触发onerror事件
                    ws.onerror = function (e) {
                        console.log("发送失败!");
                        $("#connected").hide();
                    }

                    $("td").keyup(function (e) {
                        e.preventDefault();
                        var da = new Date;
                        var talktime = da.toLocaleString();

                        var dic = [];
                        dic.push($(this).attr("id"));
                        dic.push($(this).text());
                        dic.push(snum);
                        dic.push(sname);
                        dic.push("txtform");
                        dic.push(sgroup);
                        dic.push(talktime);

                        var dicstr = JSON.stringify(dic);
                        if (isconnect && isopen) {
                            ws.send(dicstr);
                            //console.log("发送协作",dicstr);
                        }
                        else {
                            //console.log("无法协作",dicstr);
                        }

                    });

                    $("td").click(function () {
                        //$(".namebox").hide();
                    });


                }

                if (collabo == "false") {
                    console.log("独立模式");
                }
                else {
                    window.onload = start;
                    console.log("协作模式");
                }

                var timer = setInterval(function () {
                    if (isconnect) {
                        $(".namebox").hide();
                        if (oldid != "") {
                            $(oldid).attr({ contenteditable: "true" }); //设置当前单元格可编辑
                        }
                    }
                }, 8000); // 设置超时时间为8秒

                //---------------------协作测试-------------------------


                function SaveForm() {
                    var saveurl = "saveform.ashx?lid=" + "<%=Lid %>";

                    var contentstr = $("div.coursecontent").html();

                    var wordstr = "";
                    // $("div.coursecontent table").prop('outerHTML');
                    $(function () {
                        $("div.coursecontent table").each(function (index, element) {
                            var htmlstr = $(element).prop('outerHTML') + "<br>";
                            wordstr = wordstr + htmlstr;
                        })
                    })
                    var formData = new FormData();
                    formData.append('Word', wordstr);
                    formData.append('Content', contentstr);
                    $.ajax({
                        url: saveurl,
                        type: 'POST',
                        cache: false,
                        data: formData,
                        processData: false,
                        contentType: false
                    }).done(function (res) {
                        $("#sucessed").show();
                        alert("提交成功！");
                        location.reload(); //重新加载当前页面
                    }).fail(function (res) {
                        console.log(res)
                    });
                }

                var isdone = "<%=Done %>";
                if (isdone == "true") {
                    $("#sucessed").show();

                    //$("div.coursecontent table").innerHTML = $("div.coursetable table").innerHTML;
                }
                else {
                    $("#sucessed").hide();
                }


                function HTMLDecode(text) {
                    var temp = document.createElement("div");
                    temp.innerHTML = text;
                    var output = temp.innerText || temp.textContent;
                    temp = null;
                    return output;
                } 

            </script>
    </div>
    <asp:HiddenField ID="hiddencount" runat="server" />
</asp:Content>
