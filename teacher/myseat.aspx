<%@ page title="" language="C#" masterpagefile="~/teacher/Teach.master" autoeventwireup="true" inherits="Teacher_myseat, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<script runat="server">
    protected string firstshow = string.Empty;

    private string GetConnStr()
    {
        try
        {
            System.Configuration.ConnectionStringSettings cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"];
            return cs != null ? cs.ConnectionString : string.Empty;
        }
        catch
        {
            return string.Empty;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        BindHouseList();
        BindSeatList();
    }

    protected void DDLhouse_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindSeatList();
    }

    private string GetRequestedHid()
    {
        string hid = Request.QueryString["hid"];
        if (string.IsNullOrEmpty(hid))
        {
            hid = Request.QueryString["Hid"];
        }
        return hid;
    }

    private void BindHouseList()
    {
        if (DDLhouse == null || DDLhouse.Items.Count > 0)
        {
            return;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            return;
        }

        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("SELECT Hid, Hname FROM House ORDER BY Hid", conn))
                {
                    using (System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader())
                    {
                        DDLhouse.Items.Clear();
                        while (dr.Read())
                        {
                            DDLhouse.Items.Add(new System.Web.UI.WebControls.ListItem(dr["Hname"].ToString(), dr["Hid"].ToString()));
                        }
                    }
                }
            }
        }
        catch { }

        if (DDLhouse.Items.Count > 0 && string.IsNullOrEmpty(DDLhouse.SelectedValue))
        {
            DDLhouse.SelectedIndex = 0;
        }

        string requestedHid = GetRequestedHid();
        if (!string.IsNullOrEmpty(requestedHid))
        {
            System.Web.UI.WebControls.ListItem hidItem = DDLhouse.Items.FindByValue(requestedHid);
            if (hidItem != null)
            {
                DDLhouse.ClearSelection();
                hidItem.Selected = true;
            }
        }
    }

    private void BindSeatList()
    {
        if (DDLhouse == null || myhouse == null)
        {
            return;
        }

        int hid = GetSelectedHid();
        string seatLayout = GetHouseSeat(hid);
        firstshow = seatLayout;

        int columnCount;
        int seatCount;
        string sortWay;
        if (TryParseSeatLayout(seatLayout, out columnCount, out seatCount, out sortWay))
        {
            myhouse.Text = CreateSeats(columnCount, seatCount, sortWay);
            if (Labelnum != null) Labelnum.Text = seatCount.ToString();
            return;
        }

        seatCount = GetComputerCount(hid);
        if (seatCount <= 0)
        {
            seatCount = 30;
        }
        columnCount = seatCount < 6 ? seatCount : 6;
        if (columnCount <= 0)
        {
            columnCount = 6;
        }
        myhouse.Text = CreateSeats(columnCount, seatCount, "0");
        if (Labelnum != null) Labelnum.Text = seatCount.ToString();
    }

    private int GetSelectedHid()
    {
        int hid = 0;
        if (DDLhouse != null && DDLhouse.Items.Count > 0)
        {
            int.TryParse(DDLhouse.SelectedValue, out hid);
            if (hid <= 0)
            {
                int.TryParse(DDLhouse.Items[0].Value, out hid);
            }
        }
        return hid;
    }

    private string GetHouseSeat(int hid)
    {
        if (hid <= 0)
        {
            return string.Empty;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            return string.Empty;
        }

        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("SELECT Hseat FROM House WHERE Hid=@Hid", conn))
                {
                    cmd.Parameters.Add("@Hid", System.Data.SqlDbType.Int).Value = hid;
                    object value = cmd.ExecuteScalar();
                    if (value != null && value != DBNull.Value)
                    {
                        return value.ToString();
                    }
                }
            }
        }
        catch
        {
        }

        return string.Empty;
    }

    private int GetComputerCount(int hid)
    {
        if (hid <= 0)
        {
            return 0;
        }

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            return 0;
        }

        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("SELECT COUNT(*) FROM Computers WHERE Phid=@Phid", conn))
                {
                    cmd.Parameters.Add("@Phid", System.Data.SqlDbType.Int).Value = hid;
                    object value = cmd.ExecuteScalar();
                    if (value != null && value != DBNull.Value)
                    {
                        return Convert.ToInt32(value);
                    }
                }
            }
        }
        catch
        {
        }

        return 0;
    }

    private bool TryParseSeatLayout(string seatLayout, out int columnCount, out int seatCount, out string sortWay)
    {
        columnCount = 6;
        seatCount = 0;
        sortWay = "0";

        if (string.IsNullOrEmpty(seatLayout))
        {
            return false;
        }

        string[] parts = seatLayout.Split('-');
        if (parts.Length < 3)
        {
            return false;
        }

        int tempColumnCount;
        int tempSeatCount;
        if (!Int32.TryParse(parts[0], out tempColumnCount) || !Int32.TryParse(parts[1], out tempSeatCount))
        {
            return false;
        }

        if (tempColumnCount <= 0 || tempSeatCount <= 0)
        {
            return false;
        }

        columnCount = tempColumnCount;
        seatCount = tempSeatCount;
        sortWay = parts[2];
        return true;
    }

    private string CreateSeats(int lnum, int allnum, string sort)
    {
        string context = string.Empty;
        int hnum = allnum / lnum;

        if (hnum == 0)
        {
            lnum = 1;
        }

        int cmp = 0;
        for (int i = 0; i < lnum; i++)
        {
            context += "<div class=\"computer-place\">\r\n";
            for (int j = 0; j < hnum; j++)
            {
                cmp++;
                if (cmp > allnum)
                {
                    break;
                }

                int cname = 888;
                if (sort == "0")
                {
                    cname = i * hnum + j + 1;
                }
                else
                {
                    cname = j * lnum + i + 1;
                }
                context += "<div class=\"computer\" id=\"" + cname + "\">" + cname + "</div>\r\n";
            }

            if (i == lnum - 1 && cmp < allnum)
            {
                int leftnum = allnum - hnum * lnum;
                if (leftnum > 0)
                {
                    for (int k = 0; k < leftnum; k++)
                    {
                        cmp++;
                        context += "<div class=\"computer\" id=\"" + cmp + "\">" + cmp + "</div>\r\n";
                    }
                }
            }

            context += "</div>\r\n";
        }

        return context;
    }
</script>

<style type="text/css">
    <% if (string.Equals(Request.QueryString["embed"], "1", StringComparison.OrdinalIgnoreCase)
        || string.Equals(Request.QueryString["embed"], "true", StringComparison.OrdinalIgnoreCase)) { %>
    html, body, #form1, .layout-wrapper, .main-area, .content-area {
        width: 100% !important;
        height: auto !important;
        min-height: 0 !important;
        overflow: visible !important;
        background: transparent !important;
    }
    body {
        background: transparent !important;
    }
    .layout-wrapper,
    .main-area {
        display: block !important;
    }
    .sidebar,
    .top-header {
        display: none !important;
    }
    .content-area {
        padding: 0 !important;
        box-shadow: none !important;
        border: none !important;
    }
    <% } %>

    .seat-page {
        width: 100%;
        max-width: 100%;
        margin: 0 auto;
        padding: <%= (string.Equals(Request.QueryString["embed"], "1", StringComparison.OrdinalIgnoreCase)
            || string.Equals(Request.QueryString["embed"], "true", StringComparison.OrdinalIgnoreCase)) ? "8px 0 0" : "20px" %>;
        color: #334155;
        font-family: "Microsoft YaHei", "Segoe UI", Arial, sans-serif;
        min-height: <%= (string.Equals(Request.QueryString["embed"], "1", StringComparison.OrdinalIgnoreCase)
            || string.Equals(Request.QueryString["embed"], "true", StringComparison.OrdinalIgnoreCase)) ? "720px" : "0" %>;
    }
    .seat-shell {
        width: 100%;
        min-height: <%= (string.Equals(Request.QueryString["embed"], "1", StringComparison.OrdinalIgnoreCase)
            || string.Equals(Request.QueryString["embed"], "true", StringComparison.OrdinalIgnoreCase)) ? "720px" : "0" %>;
        background:
            radial-gradient(circle at top left, rgba(191,219,254,0.35), transparent 36%),
            linear-gradient(180deg, #fbfdff 0%, #ffffff 100%);
        border: 1px solid rgba(147,197,253,0.42);
        border-radius: 24px;
        box-shadow: 0 20px 44px rgba(37, 99, 235, 0.12), inset 0 1px 0 rgba(255,255,255,0.85);
        overflow: hidden;
    }
    .seat-toolbar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 18px;
        padding: 22px 26px 18px;
        border-bottom: 1px solid rgba(191,219,254,0.65);
        background: linear-gradient(135deg, rgba(239,246,255,0.92) 0%, rgba(248,251,255,0.96) 100%);
    }
    .seat-title {
        display: flex;
        flex-direction: column;
        gap: 7px;
    }
    .seat-title-main {
        font-size: 20px;
        font-weight: 700;
        color: #1e3a8a;
        letter-spacing: 0.3px;
    }
    .seat-title-sub {
        font-size: 12px;
        color: #64748b;
        line-height: 1.6;
    }
    .seat-toolbar-control {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-width: 196px;
        padding: 8px;
        border-radius: 18px;
        background: rgba(255,255,255,0.88);
        border: 1px solid rgba(191,219,254,0.7);
        box-shadow: inset 0 1px 0 rgba(255,255,255,0.8), 0 8px 20px rgba(37,99,235,0.08);
    }
    .seat-toolbar select {
        width: 164px;
        min-width: 164px;
        height: 40px;
        padding: 0 12px;
        border: 1px solid #bfdbfe;
        border-radius: 999px;
        background: linear-gradient(180deg, #ffffff 0%, #f8fbff 100%);
        color: #1e293b;
        font-size: 14px;
        outline: none;
    }
    .seat-toolbar select:focus {
        border-color: #60a5fa;
        box-shadow: 0 0 0 3px rgba(96, 165, 250, 0.18);
    }
    .seat-body {
        padding: 20px 26px 26px;
        min-height: <%= (string.Equals(Request.QueryString["embed"], "1", StringComparison.OrdinalIgnoreCase)
            || string.Equals(Request.QueryString["embed"], "true", StringComparison.OrdinalIgnoreCase)) ? "520px" : "0" %>;
    }
    .seat-count {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 18px;
        padding: 10px 14px;
        border-radius: 999px;
        background: linear-gradient(135deg, rgba(255,255,255,0.96), rgba(239,246,255,0.92));
        border: 1px solid rgba(191,219,254,0.85);
        color: #2563eb;
        font-size: 12px;
        font-weight: 700;
        box-shadow: 0 10px 22px rgba(37,99,235,0.08);
    }
    .seat-count-label {
        color: #64748b;
        font-weight: 600;
    }
    .seat-count-value {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-width: 30px;
        height: 30px;
        padding: 0 10px;
        border-radius: 999px;
        background: linear-gradient(135deg, #2563eb, #3b82f6);
        color: #fff;
        font-size: 13px;
        font-weight: 700;
        box-shadow: 0 10px 18px rgba(37,99,235,0.22);
    }
    .seat-grid {
        position: relative;
        width: 100%;
        min-height: <%= (string.Equals(Request.QueryString["embed"], "1", StringComparison.OrdinalIgnoreCase)
            || string.Equals(Request.QueryString["embed"], "true", StringComparison.OrdinalIgnoreCase)) ? "610px" : "640px" %>;
        padding: 18px;
        border-radius: 24px;
        background:
            radial-gradient(circle at top center, rgba(191,219,254,0.16), transparent 42%),
            linear-gradient(180deg, rgba(255,255,255,0.94) 0%, rgba(244,248,255,0.98) 100%);
        border: 1px solid rgba(191,219,254,0.78);
        box-shadow: inset 0 1px 0 rgba(255,255,255,0.92), 0 16px 34px rgba(37,99,235,0.08);
        overflow: hidden;
    }
    .seat-grid:before {
        content: "";
        position: absolute;
        top: 18px;
        right: 18px;
        bottom: 18px;
        left: 18px;
        border-radius: 18px;
        background-image:
            linear-gradient(rgba(148,163,184,0.08) 1px, transparent 1px),
            linear-gradient(90deg, rgba(148,163,184,0.08) 1px, transparent 1px);
        background-size: 74px 74px;
        pointer-events: none;
    }
    .seat-layout {
        position: relative;
        width: 100%;
        min-height: <%= (string.Equals(Request.QueryString["embed"], "1", StringComparison.OrdinalIgnoreCase)
            || string.Equals(Request.QueryString["embed"], "true", StringComparison.OrdinalIgnoreCase)) ? "574px" : "604px" %>;
        border-radius: 18px;
        overflow: hidden;
        z-index: 1;
    }
    .computer-place {
        width: 72px;
        float: left;
        position: relative;
        z-index: 1;
    }
    .computer {
        position: relative;
        width: 64px;
        height: 42px;
        margin: 4px;
        border-radius: 12px 12px 5px 5px;
        border: 1px solid rgba(255,255,255,0.18);
        background: linear-gradient(160deg, #2563eb 0%, #1d4ed8 100%);
        color: #ffffff;
        font-size: 13px;
        font-weight: 700;
        line-height: 39px;
        text-align: center;
        box-shadow: 0 10px 22px rgba(37,99,235,0.22), 0 1px 3px rgba(15,23,42,0.08);
        user-select: none;
    }
    .computer:before {
        content: "";
        position: absolute;
        top: 3px;
        left: 6px;
        right: 6px;
        height: 12px;
        border-radius: 8px 8px 0 0;
        background: linear-gradient(180deg, rgba(255,255,255,0.28), rgba(255,255,255,0));
    }
    .computer:after {
        content: "";
        position: absolute;
        bottom: -8px;
        left: 50%;
        width: 20px;
        height: 6px;
        margin-left: -10px;
        border-radius: 0 0 4px 4px;
        background: linear-gradient(180deg, #93c5fd, #60a5fa);
        box-shadow: 0 2px 4px rgba(37,99,235,0.18);
    }
    .seat-layout.seat-ready .computer-place {
        float: none;
        width: 0;
        height: 0;
    }
    .seat-layout.seat-ready .computer {
        position: absolute;
        margin: 0;
    }
    @media (max-width: 900px) {
        .seat-toolbar {
            flex-direction: column;
            align-items: stretch;
        }
        .seat-toolbar-control {
            width: 100%;
            min-width: 0;
        }
        .seat-toolbar select {
            min-width: 0;
            width: 100%;
        }
        .seat-grid {
            min-height: 520px;
            padding: 14px;
        }
        .seat-grid:before {
            top: 14px;
            right: 14px;
            bottom: 14px;
            left: 14px;
        }
        .seat-layout {
            min-height: 470px;
        }
    }
</style>

<div class="seat-page">
    <div class="seat-shell">
        <div class="seat-toolbar">
            <div class="seat-title">
                <span class="seat-title-main">机房座位布局</span>
                <span class="seat-title-sub">按机房查看已生成的主机模型和坐标</span>
            </div>
            <div class="seat-toolbar-control">
                <asp:DropDownList ID="DDLhouse" runat="server" AutoPostBack="True"
                    Font-Size="9pt" Height="16px"
                    onselectedindexchanged="DDLhouse_SelectedIndexChanged" Width="180px">
                </asp:DropDownList>
            </div>
        </div>
        <div class="seat-body">
            <div class="seat-count"><span class="seat-count-label">当前主机数</span><span class="seat-count-value"><asp:Label ID="Labelnum" runat="server"></asp:Label></span></div>
            <div class="seat-grid">
                <div id="sortable" class="seat-layout">
                    <asp:Literal ID="myhouse" runat="server"></asp:Literal>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    (function () {
        var layoutValue = '<%= this.firstshow %>';
        var sortableId = "sortable";
        var labelId = "<%= Labelnum.ClientID %>";
        var embed = <%= (string.Equals(Request.QueryString["embed"], "1", StringComparison.OrdinalIgnoreCase)
            || string.Equals(Request.QueryString["embed"], "true", StringComparison.OrdinalIgnoreCase)) ? "true" : "false" %>;

        function hasClass(el, className) {
            return el && (" " + el.className + " ").indexOf(" " + className + " ") >= 0;
        }

        function addClass(el, className) {
            if (!el || hasClass(el, className)) {
                return;
            }
            el.className = (el.className ? el.className + " " : "") + className;
        }

        function getSeatNodes(container) {
            if (!container) {
                return [];
            }
            if (container.getElementsByClassName) {
                return container.getElementsByClassName("computer");
            }
            return container.querySelectorAll(".computer");
        }

        function syncSeatCount() {
            var label = document.getElementById(labelId);
            var container = document.getElementById(sortableId);
            if (!label || !container) {
                return;
            }
            var count = getSeatNodes(container).length;
            if (count > 0) {
                label.innerHTML = count.toString();
            }
        }

        function restoreSeatLayout() {
            var container = document.getElementById(sortableId);
            if (!container || !layoutValue || layoutValue.length <= 10) {
                syncSeatCount();
                return;
            }

            var parts = layoutValue.split("-");
            if (parts.length < 5) {
                syncSeatCount();
                return;
            }

            var cookset = parts.slice(4).join("-");
            if (!cookset) {
                syncSeatCount();
                return;
            }

            var items = cookset.split("|");
            var seatMap = {};
            var minLeft = 999999;
            var minTop = 999999;
            var maxLeft = 0;
            var maxTop = 0;
            var validCount = 0;
            var i;

            for (i = 0; i < items.length; i++) {
                if (!items[i]) {
                    continue;
                }
                var seatParts = items[i].split(":");
                if (seatParts.length != 2) {
                    continue;
                }
                var offsetParts = seatParts[1].split(",");
                if (offsetParts.length != 2) {
                    continue;
                }
                var left = parseInt(offsetParts[0], 10);
                var top = parseInt(offsetParts[1], 10);
                if (isNaN(left) || isNaN(top)) {
                    continue;
                }

                seatMap[seatParts[0]] = { left: left, top: top };
                if (left < minLeft) minLeft = left;
                if (top < minTop) minTop = top;
                if (left > maxLeft) maxLeft = left;
                if (top > maxTop) maxTop = top;
                validCount++;
            }

            if (validCount == 0) {
                syncSeatCount();
                return;
            }

            addClass(container, "seat-ready");

            var paddingLeft = 28;
            var paddingTop = 24;
            var seatWidth = 64;
            var seatHeight = 50;
            var containerWidth = container.clientWidth || container.offsetWidth || 800;
            var containerHeight = container.clientHeight || container.offsetHeight || 520;
            var rangeX = maxLeft - minLeft;
            var rangeY = maxTop - minTop;
            var availableX = containerWidth - paddingLeft * 2 - seatWidth;
            var availableY = containerHeight - paddingTop * 2 - seatHeight;
            var scaleX = rangeX > 10 ? Math.min(availableX / rangeX, 1.8) : 1;
            var scaleY = rangeY > 10 ? Math.min(availableY / rangeY, 1.8) : 1;
            var seatNodes = getSeatNodes(container);

            for (i = 0; i < seatNodes.length; i++) {
                var seat = seatNodes[i];
                var saved = seatMap[seat.id];
                if (!saved) {
                    continue;
                }
                seat.style.left = Math.round(paddingLeft + (saved.left - minLeft) * scaleX) + "px";
                seat.style.top = Math.round(paddingTop + (saved.top - minTop) * scaleY) + "px";
            }

            syncSeatCount();
        }

        if (!embed) {
            if (window.addEventListener) {
                window.addEventListener("load", restoreSeatLayout);
                window.addEventListener("resize", restoreSeatLayout);
            } else if (window.attachEvent) {
                window.attachEvent("onload", restoreSeatLayout);
            }
            return;
        }

        function notifyParentHeight() {
            var doc = document.documentElement;
            var body = document.body;
            var height = Math.max(
                body ? body.scrollHeight : 0,
                doc ? doc.scrollHeight : 0,
                body ? body.offsetHeight : 0,
                doc ? doc.offsetHeight : 0
            );

            try {
                if (window.parent && window.parent !== window) {
                    window.parent.postMessage({ type: "learnsite-myseat-height", height: height }, "*");
                }
            } catch (e) { }
        }

        if (window.addEventListener) {
            window.addEventListener("load", function () {
                restoreSeatLayout();
                notifyParentHeight();
            });
            window.addEventListener("resize", function () {
                restoreSeatLayout();
                notifyParentHeight();
            });
        } else if (window.attachEvent) {
            window.attachEvent("onload", function () {
                restoreSeatLayout();
                notifyParentHeight();
            });
        }

        setTimeout(function () { restoreSeatLayout(); notifyParentHeight(); }, 60);
        setTimeout(function () { restoreSeatLayout(); notifyParentHeight(); }, 240);
        setTimeout(function () { restoreSeatLayout(); notifyParentHeight(); }, 600);
    })();
</script>
</asp:Content>
