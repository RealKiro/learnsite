<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" CodeFile="computer.aspx.cs" inherits="Seat_computer" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<script src="../js/jquery-1.8.2.min.js" type="text/javascript"></script>
<script src="../js/jquery-ui-1.8.24.custom.min.js" type="text/javascript"></script>
<script src="../js/jquery.cookie.js" type="text/javascript"></script>
<script src="../js/seatsave.js" type="text/javascript"></script>
<style>
    /* ===== 机房布置页面样式 ===== */
    .cp-page{max-width:100%;padding:20px 24px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}

    /* 页面头部 */
    .cp-hd{display:flex;align-items:center;gap:16px;margin-bottom:24px;}
    .cp-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#6366f1,#a78bfa);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(99,102,241,.25);flex-shrink:0;}
    .cp-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .cp-hd-text h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .cp-hd-text p{font-size:13px;color:#94a3b8;margin:0;}

    /* 工具栏卡片 */
    .cp-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;transition:box-shadow .25s;margin-bottom:20px;}
    .cp-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);}
    .cp-card-hd{padding:14px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .cp-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .cp-card-hd .ci svg{width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.indigo{background:#eef2ff;} .ci.indigo svg{stroke:#6366f1;}
    .ci.sky{background:#f0f9ff;} .ci.sky svg{stroke:#0ea5e9;}
    .ci.emerald{background:#ecfdf5;} .ci.emerald svg{stroke:#10b981;}
    .cp-card-bd{padding:16px 22px;}

    /* 工具栏布局 */
    .cp-toolbar{display:flex;align-items:center;flex-wrap:wrap;gap:12px;font-size:13px;color:#475569;}
    .cp-toolbar label{font-weight:600;color:#374151;}
    .cp-toolbar select,
    .cp-toolbar input[type="text"]{
        padding:7px 12px;border:1.5px solid #e2e8f0;border-radius:9px;font-size:13px;font-family:inherit;
        color:#1e293b;background:#f8fafc;transition:border-color .2s,box-shadow .2s;outline:none;
    }
    .cp-toolbar select:focus,
    .cp-toolbar input[type="text"]:focus{border-color:#818cf8;box-shadow:0 0 0 3px rgba(99,102,241,.12);background:#fff;}
    .cp-toolbar input[type="text"]{width:56px;text-align:center;}
    .cp-toolbar select{min-width:56px;cursor:pointer;}

    /* 单选按钮美化 */
    .cp-toolbar .radio-group{display:inline-flex;align-items:center;gap:2px;background:#f1f5f9;border-radius:9px;padding:3px;}
    .cp-toolbar .radio-group label{
        padding:5px 14px;border-radius:7px;cursor:pointer;font-weight:500;font-size:12.5px;
        color:#64748b;transition:all .2s;user-select:none;
    }
    .cp-toolbar .radio-group input[type="radio"]:checked + label,
    .cp-toolbar .radio-group label.rb-active{background:#fff;color:#4f46e5;font-weight:600;box-shadow:0 1px 4px rgba(0,0,0,.08);}

    /* 按钮样式 */
    .btn-indigo{
        display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 18px;
        background:linear-gradient(135deg,#6366f1,#4f46e5);color:#fff!important;border:none;border-radius:9px;
        font-size:13px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;
        box-shadow:0 2px 8px rgba(99,102,241,.3);text-decoration:none;
    }
    .btn-indigo:hover{box-shadow:0 4px 14px rgba(99,102,241,.4);transform:translateY(-1px);}

    .btn-outline{
        display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 16px;
        background:#fff;color:#475569;border:1.5px solid #e2e8f0;border-radius:9px;
        font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;
        text-decoration:none;gap:6px;
    }
    .btn-outline:hover{border-color:#cbd5e1;background:#f8fafc;color:#1e293b;box-shadow:0 2px 8px rgba(0,0,0,.06);}
    .btn-outline svg{width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}

    .btn-success{
        display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 18px;
        background:linear-gradient(135deg,#10b981,#059669);color:#fff!important;border:none;border-radius:9px;
        font-size:13px;font-family:inherit;font-weight:600;cursor:pointer;transition:all .2s;
        box-shadow:0 2px 8px rgba(16,185,129,.3);text-decoration:none;gap:6px;
    }
    .btn-success:hover{box-shadow:0 4px 14px rgba(16,185,129,.4);transform:translateY(-1px);}
    .btn-success svg{width:16px;height:16px;stroke:#fff;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;}

    /* 消息提示 */
    .cp-msg{display:inline-flex;align-items:center;gap:6px;padding:5px 14px;background:#f0fdf4;color:#15803d;border-radius:8px;font-size:12.5px;font-weight:500;min-height:28px;transition:all .3s;}
    .cp-msg:empty{padding:0;background:transparent;}

    /* 机房画布区域 */
    .cp-canvas-wrap{position:relative;}

    /* 覆盖旧 computer.css 样式 */
    .floor{position:relative!important;top:auto!important;}
    .house{width:100%!important;margin:0!important;overflow:visible!important;}
    .sortablediv{
        margin:0 auto!important;width:100%!important;max-width:860px;min-height:400px;height:auto;
        cursor:default;background-color:#f8fafc;background-image:none!important;
        border:2px dashed #e2e8f0;border-radius:12px;overflow:hidden;position:relative;
        padding:16px 12px;
    }
    .sortablediv::after{content:'';display:table;clear:both;}
    .nosortablediv{
        margin:0 auto!important;width:100%!important;max-width:800px;height:600px;
        cursor:default;background-color:#f8fafc;border:2px dashed #e2e8f0;border-radius:12px;overflow:hidden;
    }
    .computer{
        margin:3px!important;width:56px;height:44px;
        background:linear-gradient(135deg,#f0f4ff 0%,#e8eeff 100%);
        border:1.5px solid #c7d2fe;border-radius:10px;
        font-family:'Microsoft YaHei',Arial,sans-serif;font-size:12px;font-weight:700;
        text-align:center;line-height:44px;color:#4338ca;
        box-shadow:0 1px 3px rgba(99,102,241,.15);
        transition:all .2s ease;position:relative;user-select:none;
    }
    .computer:hover{
        background:linear-gradient(135deg,#e0e7ff,#c7d2fe);
        border-color:#818cf8;color:#3730a3;
        box-shadow:0 4px 12px rgba(99,102,241,.25);
        transform:translateY(-1px);z-index:10;
    }
    .computer::before{
        content:'';position:absolute;top:3px;left:50%;transform:translateX(-50%);
        width:24px;height:2px;background:#c7d2fe;border-radius:2px;opacity:.6;
    }
    .computer-place{width:62px;float:left;margin:0;padding:0;}
    .menu{display:none!important;}
    .nomenu{display:none!important;}
    .msgtext{display:none!important;}

    /* 底部移动按钮 */
    .cp-move-bar{display:flex;align-items:center;justify-content:center;gap:8px;padding:16px 0 0;flex-wrap:wrap;}
    .cp-move-bar .btn-outline{height:34px;padding:0 14px;font-size:12.5px;}
    .cp-move-bar .btn-outline svg{width:15px;height:15px;}

    /* 隐藏对话框 */
    #showMessage{display:none;}

    /* 响应式 */
    @media(max-width:900px){
        .cp-toolbar{gap:8px;}
        .sortablediv,.nosortablediv{height:500px;}
    }
</style>

<div class="cp-page">
    <!-- 页面标题 -->
    <div class="cp-hd">
        <div class="cp-hd-icon"><svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg></div>
        <div class="cp-hd-text"><h1>机房电脑布置</h1><p>拖拽电脑图标调整机房座位布局，设置完成后提交保存</p></div>
    </div>

    <!-- 工具栏 -->
    <div class="cp-card">
        <div class="cp-card-hd">
            <span class="ci indigo"><svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg></span>
            布置设置
        </div>
        <div class="cp-card-bd">
            <div class="cp-toolbar">
                <label>列数</label>
                <asp:DropDownList runat="server" ID="ddll" Width="56px">
                    <asp:ListItem>3</asp:ListItem>
                    <asp:ListItem>4</asp:ListItem>
                    <asp:ListItem>5</asp:ListItem>
                    <asp:ListItem Selected="True">6</asp:ListItem>
                    <asp:ListItem>7</asp:ListItem>
                    <asp:ListItem>8</asp:ListItem>
                    <asp:ListItem>9</asp:ListItem>
                    <asp:ListItem>10</asp:ListItem>
                    <asp:ListItem>11</asp:ListItem>
                    <asp:ListItem>12</asp:ListItem>
                </asp:DropDownList>

                <label>总数</label>
                <asp:TextBox ID="TextBoxall" runat="server" Width="48px" Wrap="False">30</asp:TextBox>

                <asp:RadioButtonList ID="RadioBtnSelect" runat="server" RepeatDirection="Horizontal"
                    RepeatLayout="Flow" ToolTip="电脑编号次序按纵向或横向">
                    <asp:ListItem Selected="True" Value="0">纵向</asp:ListItem>
                    <asp:ListItem Value="1">横向</asp:ListItem>
                </asp:RadioButtonList>

                <asp:Button ID="Buttoninit" runat="server" OnClick="Buttoninit_Click"
                    Text="初始化布置" ToolTip="初始化当前机房布置！" CssClass="btn-indigo" />

                <a onclick="save();return false;" href="#" class="btn-outline" title="保存当前布置">
                    <svg viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
                    临时保存
                </a>
                <a onclick="reshow();return false;" href="#" class="btn-outline" title="恢复到上次保存的布置">
                    <svg viewBox="0 0 24 24"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/></svg>
                    恢复
                </a>
                <a onclick="uploadseat();return false;" href="#" class="btn-success" title="将当前布置提交给平台数据库">
                    <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                    提交
                </a>

                <label id="msg" class="cp-msg"></label>
            </div>
        </div>
    </div>

    <!-- 电脑布置画布 -->
    <div class="cp-card">
        <div class="cp-card-hd">
            <span class="ci sky"><svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg></span>
            机房布局
            <span style="margin-left:auto;display:flex;gap:8px;">
                <a onclick="vturn();return false;" href="#" class="btn-outline" style="height:30px;padding:0 12px;font-size:12px;" title="垂直翻转所有电脑位置">
                    <svg viewBox="0 0 24 24" style="width:14px;height:14px;"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>
                    垂直翻转
                </a>
                <a onclick="hturn();return false;" href="#" class="btn-outline" style="height:30px;padding:0 12px;font-size:12px;" title="水平翻转所有电脑位置">
                    <svg viewBox="0 0 24 24" style="width:14px;height:14px;"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>
                    水平翻转
                </a>
            </span>
        </div>
        <div class="cp-card-bd cp-canvas-wrap">
            <div id="houserfloor" class="floor">
                <div id="computerhouse" class="house">
                    <div id="sortable" class="sortablediv">
                        <asp:Literal ID="myhouse" runat="server">
                        <div></div>
                        </asp:Literal>
                    </div>
                </div>
            </div>

            <!-- 移动按钮 -->
            <div class="cp-move-bar">
                <a onclick="lefttoleft();return false;" href="#" class="btn-outline" title="水平左移所有电脑位置">
                    <svg viewBox="0 0 24 24"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
                    左移
                </a>
                <a onclick="lefttoright();return false;" href="#" class="btn-outline" title="水平右移所有电脑位置">
                    <svg viewBox="0 0 24 24"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                    右移
                </a>
                <a onclick="toptotop();return false;" href="#" class="btn-outline" title="垂直上移所有电脑位置">
                    <svg viewBox="0 0 24 24"><line x1="12" y1="19" x2="12" y2="5"/><polyline points="5 12 12 5 19 12"/></svg>
                    上移
                </a>
                <a onclick="toptodown();return false;" href="#" class="btn-outline" title="垂直下移所有电脑位置">
                    <svg viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><polyline points="19 12 12 19 5 12"/></svg>
                    下移
                </a>
            </div>
        </div>
    </div>

    <div id="showMessage" style="display:none;"></div>
</div>

<script type="text/javascript">
    $(function () {
        $(init);
        function init() {
            $('.computer').draggable({ opacity: 0.35, helper: 'original', grid: [2, 2],
                containment: "#sortable", snap: true, snapTolerance: 8,
                drag: function (event, ui) {
                    var offset = $(this).offset();
                    var l = offset.left;
                    var t = offset.top;
                    var idname = $(this).attr("id");
                    var msgstr = idname + ' 左: ' + l + ' 上: ' + t;
                    $('#msg').html(msgstr);
                }
            });
            $(".computer").css("cursor", "move");
            $(".computer").disableSelection();
            $(oldseat);
        }
    });
    //垂直翻转（镜像）
    function vturn() {
        var tmin = 888;
        var tmax = 0;
        $(".computer").each(function () {
            var offset = $(this).offset();
            var t = offset.top;
            if (t < tmin) tmin = t;
            if (t > tmax) tmax = t;
        });
        var middle = (tmax + tmin) / 2 + 20;
        $(".computer").each(function () {
            var offset = $(this).offset();
            var cl = offset.left;
            var ct = offset.top;
            if (ct < middle) {
                var midd = middle - ct;
                ct = middle + midd - 40;
            } else {
                var mid = ct - middle;
                ct = middle - mid - 40;
            }
            $(this).offset({ "top": ct, "left": cl });
        });
    }
    //水平翻转（镜像）
    function hturn() {
        var lmin = 888;
        var lmax = 0;
        $(".computer").each(function () {
            var offset = $(this).offset();
            var l = offset.left;
            if (l < lmin) lmin = l;
            if (l > lmax) lmax = l;
        });
        var middle = (lmax + lmin) / 2 + 30;
        $(".computer").each(function () {
            var offset = $(this).offset();
            var cl = offset.left;
            var ct = offset.top;
            if (cl < middle) {
                var midd = middle - cl;
                cl = middle + midd - 60;
            } else {
                var mid = cl - middle;
                cl = middle - mid - 60;
            }
            $(this).offset({ "top": ct, "left": cl });
        });
    }
    function calu() {
        var str = "";
        var roomoffset = $('#sortable').offset();
        var rl = roomoffset.left;
        var rt = roomoffset.top;
        $(".computer").each(function () {
            var offset = $(this).offset();
            var xl = offset.left;
            var xt = offset.top;
            var xidname = $(this).attr("id");
            switch (xidname.length) {
                case 1: xidname = ".." + xidname; break;
                case 2: xidname = "." + xidname; break;
            }
            str = str + xidname + "：左:" + (xl - rl).toString() + "&nbsp;上:" + (xt - rt).toString() + "<br />";
        });
        $('#showMessage').html(str);
        $("#showMessage").dialog();
    }
    function save() {
        var cookstr = "";
        $(".computer").each(function () {
            var offset = $(this).offset();
            var xl = offset.left;
            var xt = offset.top;
            var xidname = $(this).attr("id");
            cookstr = cookstr + xidname + ":" + xl + "," + xt + "|";
        });
        var selecthnum = $('#<%= ddll.ClientID %>').val();
        var seatnum = $('#<%= TextBoxall.ClientID %>').val();
        var sortway = $("input[name='<%= RadioBtnSelect.UniqueID %>']:checked").val();
        var cookcollect = 'ls_' + selecthnum + "_" + seatnum + "_" + sortway;
        var roomcollect = cookcollect + 'room';
        $.cookie(cookcollect, cookstr);
        var roomoffset = $('#sortable').offset();
        var rl = roomoffset.left;
        $.cookie(roomcollect, rl);
        $('#msg').html("将当前布置临时保存!");
    }

    function uploadseat() {
        var cookstr = "";
        var hid = "<%=getHid() %>";
        $(".computer").each(function () {
            var offset = $(this).offset();
            var xl = offset.left;
            var xt = offset.top;
            var xidname = $(this).attr("id");
            cookstr = cookstr + xidname + ":" + xl + "," + xt + "|";
        });
        var selecthnum = $('#<%= ddll.ClientID %>').val();
        var seatnum = $('#<%= TextBoxall.ClientID %>').val();
        var sortway = $("input[name='<%= RadioBtnSelect.UniqueID %>']:checked").val();
        var roomoffset = $('#sortable').offset();
        var rl = roomoffset.left;
        var collects = selecthnum + "-" + seatnum + "-" + sortway + "-" + rl + "-" + cookstr;
        SaveSeats(hid, collects);
    }
    function oldseat() {
        var done = "<%=this.firstshow %>";
        if (done.length > 10) {
            var old_collects = done.split('-');
            if (old_collects.length < 5) {
                return;
            }
            var slnum = old_collects[0];
            var sallnum = old_collects[1];
            var ssortway = old_collects[2];
            var srl = old_collects[3];
            var scook = old_collects.slice(4).join('-');
            $('#<%= ddll.ClientID %>').val(slnum);
            $('#<%= TextBoxall.ClientID %>').val(sallnum);
            $("input[name='<%= RadioBtnSelect.UniqueID %>'][value='" + ssortway + "']").prop("checked", true);
            oldshow(srl, scook);
        }
    }
    function oldshow(roomset, cookset) {
        var croomoffset = $('#sortable').offset();
        var crl = croomoffset.left;
        if (cookset != null) {
            var cookslist = cookset.split('|');
            var cookscount = cookslist.length - 1;
            var roomfix = 0;
            if (roomset != null) { roomfix = roomset - crl; }
            for (i = 0; i < cookscount; i++) {
                var cook = cookslist[i].split(':');
                var cookname = cook[0];
                var cookoffset = cook[1].split(',');
                var cookleft = cookoffset[0] - roomfix;
                var cooktop = cookoffset[1];
                restore(cookname, cookleft, cooktop);
            }
            $('#msg').html("显示数据库保存布置!");
        }
    }
    function reshow() {
        var selecthnum = $('#<%= ddll.ClientID %>').val();
        var seatnum = $('#<%= TextBoxall.ClientID %>').val();
        var sortway = $("input[name='<%= RadioBtnSelect.UniqueID %>']:checked").val();
        var cookcollect = 'ls_' + selecthnum + "_" + seatnum + "_" + sortway;
        var roomcollect = cookcollect + 'room';
        var cookset = $.cookie(cookcollect);
        var croomoffset = $('#sortable').offset();
        var crl = croomoffset.left;
        var roomset = $.cookie(roomcollect);
        if (cookset != null) {
            var cookslist = cookset.split('|');
            var cookscount = cookslist.length - 1;
            var roomfix = 0;
            if (roomset != null) { roomfix = roomset - crl; }
            for (i = 0; i < cookscount; i++) {
                var cook = cookslist[i].split(':');
                var cookname = cook[0];
                var cookoffset = cook[1].split(',');
                var cookleft = cookoffset[0] - roomfix;
                var cooktop = cookoffset[1];
                restore(cookname, cookleft, cooktop);
            }
            $('#msg').html("恢复到上次临时布置!");
        }
    }
    function restore(cn, cl, ct) {
        $(".computer").each(function () {
            var id = $(this).attr("id");
            if (id === cn) {
                $(this).offset({ "top": ct, "left": cl });
            }
        });
    }
    function lefttoleft() {
        $(".computer").each(function () {
            var coffset = $(this).offset();
            $(this).offset({ "top": coffset.top, "left": coffset.left - 32 });
        });
    }
    function lefttoright() {
        $(".computer").each(function () {
            var coffset = $(this).offset();
            $(this).offset({ "top": coffset.top, "left": parseInt(coffset.left) + 32 });
        });
    }
    function toptotop() {
        $(".computer").each(function () {
            var coffset = $(this).offset();
            $(this).offset({ "top": parseInt(coffset.top) - 32, "left": coffset.left });
        });
    }
    function toptodown() {
        $(".computer").each(function () {
            var coffset = $(this).offset();
            $(this).offset({ "top": parseInt(coffset.top) + 32, "left": coffset.left });
        });
    }
</script>
</asp:Content>
