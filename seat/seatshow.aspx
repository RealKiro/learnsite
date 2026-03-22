<%@ page language="C#" autoeventwireup="true" inherits="Seat_seatshow, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>机房电脑布置图</title>
    <script src="../js/jquery-1.8.2.min.js" type="text/javascript"></script>
    <script src="../js/jquery-ui-1.8.24.custom.min.js" type="text/javascript"></script>
    <link href="../js/computer.css" rel="stylesheet" type="text/css" />
    <script src="../js/seatToolTip.js" type="text/javascript"></script>
    <style type="text/css">
        /* ===== Seat View - Modern Clean ===== */
        body {
            background: #f0f2f5 !important;
            margin: 0 !important;
            font-family: 'Microsoft YaHei', 'Segoe UI', -apple-system, sans-serif;
            min-height: 100vh;
        }

        .floor {
            position: relative !important;
            top: auto !important;
            width: 100%;
            display: flex;
            justify-content: center;
            padding: 24px 0;
        }

        .house {
            width: 96vw !important;
            max-width: 1400px !important;
            min-width: 900px !important;
            background: #ffffff !important;
            border-radius: 18px !important;
            border: none !important;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 8px 32px rgba(0,0,0,0.04) !important;
            overflow: hidden !important;
            margin: 0 auto !important;
            top: auto !important;
        }

        /* ---- Header bar ---- */
        .nomenu {
            background: linear-gradient(135deg, #6366f1 0%, #7c3aed 50%, #8b5cf6 100%) !important;
            color: #fff !important;
            font-size: 15px !important;
            font-weight: 600 !important;
            font-family: 'Microsoft YaHei', 'Segoe UI', sans-serif !important;
            letter-spacing: 0.3px;
            width: 100% !important;
            height: 52px !important;
            line-height: 52px !important;
            padding: 0 !important;
            margin: 0 !important;
            border-radius: 0 !important;
            text-align: center;
            box-shadow: 0 2px 12px rgba(99,102,241,0.2);
            position: relative;
        }

        .nomenu::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: url("data:image/svg+xml,%3Csvg width='60' height='60' xmlns='http://www.w3.org/2000/svg'%3E%3Cdefs%3E%3Cpattern id='g' width='60' height='60' patternUnits='userSpaceOnUse'%3E%3Ccircle cx='30' cy='30' r='1' fill='rgba(255,255,255,0.06)'/%3E%3C/pattern%3E%3C/defs%3E%3Crect fill='url(%23g)' width='60' height='60'/%3E%3C/svg%3E");
            pointer-events: none;
        }

        /* CSS icon: replace home.png with SVG home icon */
        .nomenu input[type="image"] {
            width: 0 !important;
            height: 0 !important;
            padding: 16px !important;
            border: none !important;
            border-radius: 10px !important;
            vertical-align: middle;
            cursor: pointer;
            transition: all 0.25s;
            position: relative;
            z-index: 2;
            background: rgba(255,255,255,0.15) url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z'/%3E%3Cpolyline points='9 22 9 12 15 12 15 22'/%3E%3C/svg%3E") center/20px 20px no-repeat !important;
            overflow: hidden !important;
        }

        .nomenu input[type="image"]:hover {
            background-color: rgba(255,255,255,0.25) !important;
            transform: scale(1.08);
        }

        .nomenu img {
            display: none !important;
        }

        #msg {
            color: #e0e7ff !important;
            font-weight: 500;
            font-size: 12px;
            background: rgba(255,255,255,0.12);
            padding: 4px 14px;
            border-radius: 20px;
            transition: all 0.3s;
            position: relative;
            z-index: 2;
        }

        /* ---- Seat container ---- */
        .nosortablediv {
            width: 100% !important;
            height: 780px !important;
            background:
                radial-gradient(circle at 50% 0%, rgba(99,102,241,0.03) 0%, transparent 60%),
                linear-gradient(180deg, #f8f9fb 0%, #f1f3f8 100%) !important;
            border-radius: 0 !important;
            border-top: none;
            position: relative;
            margin: 0 auto !important;
        }

        /* Subtle grid pattern */
        .nosortablediv::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background-image:
                linear-gradient(rgba(99,102,241,0.04) 1px, transparent 1px),
                linear-gradient(90deg, rgba(99,102,241,0.04) 1px, transparent 1px);
            background-size: 80px 80px;
            pointer-events: none;
            z-index: 0;
        }

        /* ---- Computer seats ---- */
        .computer {
            width: 72px !important;
            height: 46px !important;
            background-image: none !important;
            background: linear-gradient(160deg, #6366f1 0%, #4f46e5 100%) !important;
            border: 2px solid rgba(255,255,255,0.18) !important;
            border-radius: 8px 8px 3px 3px !important;
            color: #fff !important;
            font-size: 13px !important;
            font-weight: 700 !important;
            font-family: 'Microsoft YaHei', 'Segoe UI', sans-serif !important;
            text-align: center !important;
            line-height: 42px !important;
            box-shadow: 0 4px 14px rgba(99,102,241,0.28), 0 1px 3px rgba(0,0,0,0.1) !important;
            transition: all 0.2s cubic-bezier(0.4,0,0.2,1) !important;
            cursor: default !important;
            position: relative;
            overflow: visible !important;
            z-index: 1;
            text-shadow: 0 1px 2px rgba(0,0,0,0.2);
        }

        /* Screen glare */
        .computer::before {
            content: '';
            position: absolute;
            top: 2px; left: 4px; right: 4px;
            height: 14px;
            background: linear-gradient(180deg, rgba(255,255,255,0.3) 0%, rgba(255,255,255,0) 100%);
            border-radius: 6px 6px 0 0;
            pointer-events: none;
        }

        /* Monitor stand */
        .computer::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 50%;
            transform: translateX(-50%);
            width: 24px;
            height: 6px;
            background: linear-gradient(180deg, #a5b4fc, #818cf8);
            border-radius: 0 0 4px 4px;
            box-shadow: 0 2px 4px rgba(99,102,241,0.2);
            pointer-events: none;
        }

        .computer:hover {
            background: linear-gradient(160deg, #818cf8 0%, #6366f1 100%) !important;
            box-shadow: 0 10px 30px rgba(99,102,241,0.45), 0 2px 6px rgba(0,0,0,0.1) !important;
            transform: scale(1.1) translateY(-3px);
            z-index: 100 !important;
            border-color: rgba(255,255,255,0.35) !important;
        }

        /* Student seated - green */
        .computer[tabindex="1"],
        .computer[tabindex="2"] {
            background: linear-gradient(160deg, #34d399 0%, #059669 100%) !important;
            border-color: rgba(255,255,255,0.2) !important;
            box-shadow: 0 4px 14px rgba(5,150,105,0.3), 0 1px 3px rgba(0,0,0,0.1) !important;
        }
        .computer[tabindex="1"]::after,
        .computer[tabindex="2"]::after {
            background: linear-gradient(180deg, #6ee7b7, #34d399);
            box-shadow: 0 2px 4px rgba(5,150,105,0.2);
        }
        .computer[tabindex="1"]:hover,
        .computer[tabindex="2"]:hover {
            background: linear-gradient(160deg, #4ade80 0%, #16a34a 100%) !important;
            box-shadow: 0 10px 30px rgba(5,150,105,0.45), 0 2px 6px rgba(0,0,0,0.1) !important;
        }

        /* Empty seat - gray */
        .computer[tabindex="0"] {
            background: linear-gradient(160deg, #9ca3af 0%, #6b7280 100%) !important;
            border-color: rgba(255,255,255,0.12) !important;
            box-shadow: 0 4px 14px rgba(107,114,128,0.22), 0 1px 3px rgba(0,0,0,0.08) !important;
        }
        .computer[tabindex="0"]::after {
            background: linear-gradient(180deg, #d1d5db, #9ca3af);
            box-shadow: 0 2px 4px rgba(107,114,128,0.15);
        }
        .computer[tabindex="0"]:hover {
            background: linear-gradient(160deg, #b0b7c3 0%, #7c8490 100%) !important;
            box-shadow: 0 10px 30px rgba(107,114,128,0.35), 0 2px 6px rgba(0,0,0,0.08) !important;
        }

        /* ---- Tooltip ---- */
        #tooltip {
            background: #fff !important;
            border-radius: 14px !important;
            padding: 8px !important;
            box-shadow: 0 16px 48px rgba(0,0,0,0.18), 0 0 0 1px rgba(0,0,0,0.04) !important;
            border: none !important;
            z-index: 9999;
        }
        #tooltip img {
            border-radius: 10px;
            display: block;
            max-width: 200px;
        }

        /* ---- Footer legend (via LabelTitle styling) ---- */
        .nomenu span {
            position: relative;
            z-index: 2;
        }
    </style>
    <script type="text/javascript">
        $(function () {
            $(init);
            function init() {
                $(".computer").disableSelection();
                $(oldseat);
            }
        });

        function oldseat() {
            var done = "<%=this.firstshows %>";
            if (done.length > 10) {
                var old_collects = done.split('-');

                var srl = old_collects[3];
                var scook = old_collects[4];
                oldshow(srl, scook);
                adjustComputerPositions();
            }
        }

        // 调整电脑位置：平移到容器顶部 + 按比例拉开间距
        function adjustComputerPositions() {
            var $container = $('#sortable');
            var containerOffset = $container.offset();
            if (!containerOffset) return;

            var containerTop = containerOffset.top;
            var containerLeft = containerOffset.left;
            var containerW = $container.width();
            var containerH = $container.height();

            var minTop = Infinity, minLeft = Infinity;
            var maxTop = 0, maxLeft = 0;

            $(".computer").each(function () {
                var pos = $(this).offset();
                if (pos.top > 0) {
                    if (pos.top < minTop) minTop = pos.top;
                    if (pos.top > maxTop) maxTop = pos.top;
                }
                if (pos.left > 0) {
                    if (pos.left < minLeft) minLeft = pos.left;
                    if (pos.left > maxLeft) maxLeft = pos.left;
                }
            });

            if (minTop === Infinity) return;

            var padTop = 28;
            var padLeft = 28;
            var compW = 72;
            var compH = 46;
            var standH = 10;

            var rangeX = maxLeft - minLeft;
            var rangeY = maxTop - minTop;

            var availX = containerW - padLeft * 2 - compW;
            var availY = containerH - padTop * 2 - compH - standH;

            var scaleX = (rangeX > 10) ? Math.min(availX / rangeX, 1.8) : 1;
            var scaleY = (rangeY > 10) ? Math.min(availY / rangeY, 1.8) : 1;

            $(".computer").each(function () {
                var pos = $(this).offset();
                var relX = pos.left - minLeft;
                var relY = pos.top - minTop;
                $(this).offset({
                    top:  containerTop  + padTop  + relY * scaleY,
                    left: containerLeft + padLeft + relX * scaleX
                });
            });
        }
        function oldshow(roomset, cookset) {
            var croomoffset = $('#sortable').offset();
            var crl = croomoffset.left;

            if (cookset != null) {
                var cookslist = cookset.split('|');
                var cookscount = cookslist.length - 1;
                var roomfix = 0;
                if (roomset != null) {
                    roomfix = roomset - crl;
                }
                for (var i = 0; i < cookscount; i++) {
                    var cook = cookslist[i].split(':');
                    var cookname = cook[0];
                    var cookoffset = cook[1].split(',');
                    var cookleft = cookoffset[0] - roomfix; // js加运算不对，只能采用减运算
                    var cooktop = cookoffset[1];
                    restore(cookname, cookleft, cooktop);
                }
                refresher();
            }
        }
        function reviewstu(cmp, snum, sname, ptype) {
            $(".computer").each(function () {
                var id = $(this).attr("id");
                if (id === cmp) {
                    $(this).attr("title", snum);
                    $(this).attr("tabindex", ptype);
                    $(this).html(sname);
                }
            });
        }

        function restore(cn, cl, ct) {
            $(".computer").each(function () {
                var id = $(this).attr("id");
                if (id === cn) {
                    $(this).offset({
                        "top": ct,
                        "left": cl
                    });                    
                }
            });
        }

        function refresher() {
            var oldstu = $('#StoreMsg').html();
            if (oldstu != null) {
                if (oldstu.indexOf("|") > 0) {
                    var students = oldstu.split('|');
                    var scount = students.length;
                    for (var j = 0; j < scount; j++) {
                        var stu = students[j].split('-');
                        var cmp = stu[0];
                        var snum = stu[1];
                        var sname = stu[2];
                        var ptype = stu[3];
                        reviewstu(cmp, snum, sname, ptype);
                    }
                }
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div id="houserfloor" class="floor">
        <div id="computerhouse" class="house">
        <center>
            <div class="nomenu">
                <asp:ImageButton runat="server" ID="reflashStudent" 
                    ImageUrl="~/images/home.png" 
                    ToolTip="点我刷新" onclick="reflashStudent_Click" />
                &nbsp;<asp:Label runat="server" ID="LabelTitle" Font-Bold="True">机房名称</asp:Label>
                &nbsp;&nbsp;&nbsp;<label id="msg"></label></div>
            <div id="sortable" class="nosortablediv">
                <asp:Literal ID="myhouse" runat="server">
                <div >没有找到该机房电脑布置图！</div>
                </asp:Literal>
            </div>
            </center>
            <div id="StoreMsg" runat="server" style="display: none;">
            </div>
        </div>
    </div>
    </form>
</body>
</html>
