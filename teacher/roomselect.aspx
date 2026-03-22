<%@ page title="" language="C#" masterpagefile="~/manager/Manage.master" autoeventwireup="true" inherits="Manager_roomselect, LearnSite" %>

<script runat="server">
    /// <summary>
    /// 获取数据库连接字符串
    /// </summary>
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { }
        }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        return cs;
    }
    
    /// <summary>
    /// 加载校区下拉列表
    /// </summary>
    protected void LoadCampusDropdown()
    {
        if (DDLCampus == null)
        {
            if (DebugInfo != null)
            {
                DebugInfo.Visible = true;
                DebugInfo.Text = "<span style='font-size: 18px; flex-shrink: 0;'>💡</span><div>调试信息：DDLCampus控件未找到</div>";
            }
            return;
        }
        
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            // 连接字符串为空，隐藏校区面板
            if (CampusPanel != null) CampusPanel.Visible = false;
            if (DebugInfo != null)
            {
                DebugInfo.Visible = true;
                DebugInfo.Text = "<span style='font-size: 18px; flex-shrink: 0;'>⚠️</span><div>调试信息：数据库连接字符串为空</div>";
            }
            return;
        }
        
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                
                // 优先检查School表是否存在（与schoolsetting.aspx保持一致）
                string checkSchoolTableSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'School'";
                using (System.Data.SqlClient.SqlCommand checkCmd = new System.Data.SqlClient.SqlCommand(checkSchoolTableSql, conn))
                {
                    checkCmd.CommandTimeout = 10;
                    object result = checkCmd.ExecuteScalar();
                    int schoolTableExists = result != null ? Convert.ToInt32(result) : 0;
                    
                    if (schoolTableExists > 0)
                    {
                        // School表存在，使用School表的数据
                        LoadFromSchoolTable(conn);
                        return;
                    }
                }
                
                // 如果School表不存在，检查Campus表
                string checkCampusTableSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Campus'";
                using (System.Data.SqlClient.SqlCommand checkCmd = new System.Data.SqlClient.SqlCommand(checkCampusTableSql, conn))
                {
                    checkCmd.CommandTimeout = 10;
                    object result = checkCmd.ExecuteScalar();
                    int campusTableExists = result != null ? Convert.ToInt32(result) : 0;
                    
                    if (campusTableExists > 0)
                    {
                        // Campus表存在，使用Campus表的数据
                        LoadFromCampusTable(conn);
                        return;
                    }
                }
                
                // 两个表都不存在
                if (CampusPanel != null) CampusPanel.Visible = false;
                if (DebugInfo != null)
                {
                    DebugInfo.Visible = true;
                    DebugInfo.Text = "<span style='font-size: 18px; flex-shrink: 0;'>💡</span><div>调试信息：School表和Campus表都不存在，校区筛选功能已隐藏。<br/>请访问 <strong>/manager/schoolsetting.aspx</strong> 添加学校数据。</div>";
                }
            }
        }
        catch (Exception ex)
        {
            // 出错时隐藏校区选择，并记录错误
            if (CampusPanel != null) CampusPanel.Visible = false;
            if (DebugInfo != null)
            {
                DebugInfo.Visible = true;
                DebugInfo.Text = "<span style='font-size: 18px; flex-shrink: 0;'>⚠️</span><div>调试信息：加载校区时出错<br/>" + Server.HtmlEncode(ex.Message) + "</div>";
            }
            System.Diagnostics.Debug.WriteLine("LoadCampusDropdown Error: " + ex.Message);
        }
    }
    
    /// <summary>
    /// 从School表加载数据
    /// </summary>
    private void LoadFromSchoolTable(System.Data.SqlClient.SqlConnection conn)
    {
        try
        {
            string sql = "SELECT SchoolId, SchoolName FROM School WHERE IsActive = 1 ORDER BY SchoolId";
            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 10;
                using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                {
                    DDLCampus.Items.Clear();
                    DDLCampus.Items.Add(new System.Web.UI.WebControls.ListItem("全部校区", "0"));
                    
                    int count = 0;
                    while (reader.Read())
                    {
                        int schoolId = reader.GetInt32(0);
                        string schoolName = reader.IsDBNull(1) ? "未命名学校" : reader.GetString(1);
                        DDLCampus.Items.Add(new System.Web.UI.WebControls.ListItem(schoolName, schoolId.ToString()));
                        count++;
                    }
                    
                    if (count == 0)
                    {
                        if (CampusPanel != null) CampusPanel.Visible = false;
                        if (DebugInfo != null)
                        {
                            DebugInfo.Visible = true;
                            DebugInfo.Text = "<span style='font-size: 18px; flex-shrink: 0;'>💡</span><div>调试信息：School表存在但没有启用的学校数据。<br/>请访问 <strong>/manager/schoolsetting.aspx</strong> 添加学校。</div>";
                        }
                    }
                    else
                    {
                        // 成功加载，隐藏调试信息
                        if (DebugInfo != null) DebugInfo.Visible = false;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            if (CampusPanel != null) CampusPanel.Visible = false;
            if (DebugInfo != null)
            {
                DebugInfo.Visible = true;
                DebugInfo.Text = "<span style='font-size: 18px; flex-shrink: 0;'>⚠️</span><div>从School表加载数据时出错：" + Server.HtmlEncode(ex.Message) + "</div>";
            }
        }
    }
    
    /// <summary>
    /// 从Campus表加载数据（向后兼容）
    /// </summary>
    private void LoadFromCampusTable(System.Data.SqlClient.SqlConnection conn)
    {
        try
        {
            string sql = "SELECT Cid, Cname FROM Campus WHERE Cdelete = 0 OR Cdelete IS NULL ORDER BY Cid";
            using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 10;
                using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                {
                    DDLCampus.Items.Clear();
                    DDLCampus.Items.Add(new System.Web.UI.WebControls.ListItem("全部校区", "0"));
                    
                    int count = 0;
                    while (reader.Read())
                    {
                        int cid = reader.GetInt32(0);
                        string cname = reader.IsDBNull(1) ? "未命名校区" : reader.GetString(1);
                        DDLCampus.Items.Add(new System.Web.UI.WebControls.ListItem(cname, cid.ToString()));
                        count++;
                    }
                    
                    if (count == 0)
                    {
                        if (CampusPanel != null) CampusPanel.Visible = false;
                        if (DebugInfo != null)
                        {
                            DebugInfo.Visible = true;
                            DebugInfo.Text = "<span style='font-size: 18px; flex-shrink: 0;'>💡</span><div>调试信息：Campus表存在但没有数据。<br/>建议使用 <strong>/manager/schoolsetting.aspx</strong> 管理学校。</div>";
                        }
                    }
                    else
                    {
                        // 成功加载，隐藏调试信息
                        if (DebugInfo != null) DebugInfo.Visible = false;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            if (CampusPanel != null) CampusPanel.Visible = false;
            if (DebugInfo != null)
            {
                DebugInfo.Visible = true;
                DebugInfo.Text = "<span style='font-size: 18px; flex-shrink: 0;'>⚠️</span><div>从Campus表加载数据时出错：" + Server.HtmlEncode(ex.Message) + "</div>";
            }
        }
    }
    
    /// <summary>
    /// 校区下拉列表改变事件
    /// </summary>
    protected void DDLCampus_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 不需要重新加载数据，使用客户端JavaScript筛选
        // 页面会自动回发并在OnPreRender中执行筛选
    }
    
    /// <summary>
    /// 确定选择按钮点击事件
    /// </summary>
    protected void Btnselect_Click(object sender, EventArgs e)
    {
        try
        {
            InvokeBaseRoomSelectHandler("Btnselect_Click", sender, e);
        }
        catch (System.Threading.ThreadAbortException)
        {
            // 基类保存后可能会跳转
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Btnselect_Click Error: " + ex.Message);
        }
    }
    
    /// <summary>
    /// 返回按钮点击事件
    /// </summary>
    protected void Btnreturn_Click(object sender, EventArgs e)
    {
        try
        {
            // 尝试调用基类方法
            try
            {
                System.Reflection.MethodInfo baseMethod = this.GetType().BaseType.GetMethod("Btnreturn_Click",
                    System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public);
                if (baseMethod != null)
                {
                    baseMethod.Invoke(this, new object[] { sender, e });
                    return;
                }
            }
            catch { }
            
            // 如果基类没有实现，返回上一页
            Response.Redirect("~/manager/");
        }
        catch (System.Threading.ThreadAbortException)
        {
            // Response.Redirect 引发的正常异常
        }
        catch { }
    }
    
    /// <summary>
    /// 从Cookie恢复班级选择状态
    /// </summary>
    private void RestoreRoomSelection()
    {
        if (DLroom == null)
        {
            return;
        }
        
        try
        {
            string savedValue = GetSelectedRoomsState();
            if (string.IsNullOrEmpty(savedValue))
            {
                return;
            }
            
            System.Collections.Generic.Dictionary<string, bool> selectedRids = new System.Collections.Generic.Dictionary<string, bool>();
            string[] rooms = savedValue.Split(',');
            foreach (string room in rooms)
            {
                if (string.IsNullOrEmpty(room))
                {
                    continue;
                }
                
                string[] parts = room.Split('|');
                string rid = parts.Length >= 1 ? parts[0] : room;
                if (!string.IsNullOrEmpty(rid))
                {
                    selectedRids[rid] = true;
                }
            }
            
            foreach (System.Web.UI.WebControls.DataListItem item in DLroom.Items)
            {
                if (item.ItemType != System.Web.UI.WebControls.ListItemType.Item && 
                    item.ItemType != System.Web.UI.WebControls.ListItemType.AlternatingItem)
                {
                    continue;
                }
                
                System.Web.UI.WebControls.CheckBox chk = item.FindControl("CheckRoom") as System.Web.UI.WebControls.CheckBox;
                System.Web.UI.WebControls.Label lblRid = item.FindControl("LabelRid") as System.Web.UI.WebControls.Label;
                
                if (chk != null && lblRid != null)
                {
                    string rid = lblRid.Text;
                    if (selectedRids.ContainsKey(rid))
                    {
                        chk.Checked = true;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // 恢复失败不影响正常功能
            System.Diagnostics.Debug.WriteLine("RestoreRoomSelection Error: " + ex.Message);
        }
    }
    
    /// <summary>
    /// DataList项数据绑定事件 - 在每个项绑定时恢复选择状态
    /// </summary>
    protected void DLroom_ItemDataBound(object sender, System.Web.UI.WebControls.DataListItemEventArgs e)
    {
        if (e.Item.ItemType != System.Web.UI.WebControls.ListItemType.Item && 
            e.Item.ItemType != System.Web.UI.WebControls.ListItemType.AlternatingItem)
        {
            return;
        }
        
        try
        {
            string savedValue = GetSelectedRoomsState();
            if (string.IsNullOrEmpty(savedValue))
            {
                return;
            }
            
            System.Collections.Generic.Dictionary<string, bool> selectedRids = new System.Collections.Generic.Dictionary<string, bool>();
            string[] rooms = savedValue.Split(',');
            foreach (string room in rooms)
            {
                if (string.IsNullOrEmpty(room))
                {
                    continue;
                }
                
                string[] parts = room.Split('|');
                string rid = parts.Length >= 1 ? parts[0] : room;
                if (!string.IsNullOrEmpty(rid))
                {
                    selectedRids[rid] = true;
                }
            }
            
            // 获取当前项的控件
            System.Web.UI.WebControls.CheckBox chk = e.Item.FindControl("CheckRoom") as System.Web.UI.WebControls.CheckBox;
            System.Web.UI.WebControls.Label lblRid = e.Item.FindControl("LabelRid") as System.Web.UI.WebControls.Label;
            
            if (chk != null && lblRid != null && !chk.Enabled == false)
            {
                string rid = lblRid.Text;
                if (selectedRids.ContainsKey(rid))
                {
                    chk.Checked = true;
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("DLroom_ItemDataBound Error: " + ex.Message);
        }
    }

    /// <summary>
    /// 获取当前页面保存的选班状态。
    /// 优先读取本次回发的隐藏字段，其次兼容旧Cookie，避免大批量选班时因Cookie 4KB限制导致状态丢失。
    /// </summary>
    private string GetSelectedRoomsState()
    {
        string savedValue = null;
        if (HiddenSelectedRooms != null)
        {
            savedValue = HiddenSelectedRooms.Value;
        }
        if (string.IsNullOrEmpty(savedValue))
        {
            savedValue = Request.Form[HiddenSelectedRooms != null ? HiddenSelectedRooms.UniqueID : "HiddenSelectedRooms"];
        }
        if (string.IsNullOrEmpty(savedValue))
        {
            System.Web.HttpCookie cookie = Request.Cookies["TeacherRoomSelection"];
            if (cookie != null)
            {
                savedValue = cookie.Value;
            }
        }
        return savedValue;
    }

    /// <summary>
    /// 通过反射调用基类的班级保存事件，保留原有数据库保存逻辑。
    /// </summary>
    private void InvokeBaseRoomSelectHandler(string methodName, object sender, EventArgs e)
    {
        Type currentType = this.GetType().BaseType;
        while (currentType != null)
        {
            System.Reflection.MethodInfo baseMethod = currentType.GetMethod(methodName,
                System.Reflection.BindingFlags.Instance |
                System.Reflection.BindingFlags.NonPublic |
                System.Reflection.BindingFlags.Public |
                System.Reflection.BindingFlags.DeclaredOnly);
            if (baseMethod != null)
            {
                try
                {
                    baseMethod.Invoke(this, new object[] { sender, e });
                }
                catch (System.Reflection.TargetInvocationException ex)
                {
                    if (ex.InnerException is System.Threading.ThreadAbortException)
                    {
                        throw ex.InnerException;
                    }
                    throw;
                }
                return;
            }
            currentType = currentType.BaseType;
        }
    }
    
    /// <summary>
    /// 根据选择的校区筛选班级 - 在DataList数据绑定后添加data属性
    /// </summary>
    private void FilterClassesByCampus()
    {
        if (DLroom == null)
        {
            return;
        }
        
        // 遍历所有班级项，为每个卡片添加 data-campus-id 属性
        foreach (System.Web.UI.WebControls.DataListItem item in DLroom.Items)
        {
            if (item.ItemType != System.Web.UI.WebControls.ListItemType.Item && 
                item.ItemType != System.Web.UI.WebControls.ListItemType.AlternatingItem)
            {
                continue;
            }
            
            // 获取班级信息
            System.Web.UI.WebControls.Label lblGrade = item.FindControl("LabelRgrade") as System.Web.UI.WebControls.Label;
            System.Web.UI.WebControls.Label lblClass = item.FindControl("LabelRclass") as System.Web.UI.WebControls.Label;
            
            if (lblGrade == null || lblClass == null)
            {
                continue;
            }
            
            string gradeText = lblGrade.Text ?? "";
            string classText = lblClass.Text ?? "";
            
            int grade = 0;
            int cls = 0;
            
            if (!int.TryParse(gradeText, out grade) || !int.TryParse(classText, out cls) || grade <= 0 || cls <= 0)
            {
                continue;
            }
            
            // 查询班级的校区ID
            int classCampusId = GetClassCampusId(grade, cls);
            
            // 找到卡片div并添加data属性
            foreach (System.Web.UI.Control ctrl in item.Controls)
            {
                if (ctrl is System.Web.UI.HtmlControls.HtmlGenericControl)
                {
                    System.Web.UI.HtmlControls.HtmlGenericControl htmlCtrl = (System.Web.UI.HtmlControls.HtmlGenericControl)ctrl;
                    if (htmlCtrl.TagName.ToLower() == "div" && htmlCtrl.Attributes["class"] != null && htmlCtrl.Attributes["class"].Contains("rs-room-card"))
                    {
                        htmlCtrl.Attributes["data-campus-id"] = classCampusId.ToString();
                        break;
                    }
                }
            }
        }
    }
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        
        if (!IsPostBack)
        {
            LoadCampusDropdown();
            // 首次加载时，数据绑定会在基类中完成
            // ItemDataBound事件会自动恢复选择状态
        }
        else
        {
            // PostBack时（选择校区后），需要在页面加载完成后执行筛选
            // 因为基类可能会重新绑定数据
            // ItemDataBound事件会自动恢复选择状态
        }
    }
    
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        
        // 在 PreRender 阶段为所有班级卡片添加 data-campus-id 属性
        // 实际的筛选将由客户端JavaScript完成
        if (DLroom != null)
        {
            FilterClassesByCampus();
            RestoreRoomSelection(); // 优先按本次提交值恢复，避免筛选回发时丢失选择
        }
        
        // 注册客户端脚本
        if (DDLCampus != null && !Page.ClientScript.IsStartupScriptRegistered("CampusFilter"))
        {
            string script = @"
<script type='text/javascript'>
(function() {
    var storageKey = 'TeacherRoomSelection:' + window.location.pathname;
    var ddl = document.getElementById('" + DDLCampus.ClientID + @"');
    var hiddenField = document.getElementById('" + HiddenSelectedRooms.ClientID + @"');
    if (!ddl) return;

    function getCards() {
        return document.querySelectorAll('.rs-room-card');
    }

    function getSelectedRoomIds() {
        var selected = [];
        getCards().forEach(function(card) {
            var chk = card.querySelector('input[type=""checkbox""]');
            var ridLabel = card.querySelector('[id$=""LabelRid""]');
            if (chk && chk.checked && ridLabel) {
                var rid = (ridLabel.textContent || ridLabel.innerText || '').trim();
                if (rid) {
                    selected.push(rid);
                }
            }
        });
        return selected;
    }

    function persistSelection() {
        var selected = getSelectedRoomIds();
        var serialized = selected.join(',');
        if (hiddenField) {
            hiddenField.value = serialized;
        }
        try {
            if (selected.length > 0) {
                window.localStorage.setItem(storageKey, serialized);
            } else {
                window.localStorage.removeItem(storageKey);
            }
        } catch (ex) {}
    }

    function getSavedSelection() {
        if (hiddenField && hiddenField.value) {
            return hiddenField.value;
        }
        try {
            return window.localStorage.getItem(storageKey) || '';
        } catch (ex) {
            return '';
        }
    }

    function restoreSelection() {
        var raw = getSavedSelection();
        if (!raw) return;
        var selected = {};
        raw.split(',').forEach(function(item) {
            if (!item) return;
            var rid = item.split('|')[0];
            if (rid) {
                selected[rid] = true;
            }
        });
        getCards().forEach(function(card) {
            var chk = card.querySelector('input[type=""checkbox""]');
            var ridLabel = card.querySelector('[id$=""LabelRid""]');
            if (!chk || !ridLabel || chk.disabled) return;
            var rid = (ridLabel.textContent || ridLabel.innerText || '').trim();
            chk.checked = !!selected[rid];
        });
    }
    
    function filterClasses() {
        var selectedValue = ddl.value;
        var cards = document.querySelectorAll('.rs-room-card[data-campus-id]');
        
        cards.forEach(function(card) {
            var campusId = card.getAttribute('data-campus-id');
            if (selectedValue === '0' || selectedValue === '' || campusId === selectedValue) {
                card.style.display = '';
            } else {
                card.style.display = 'none';
            }
        });
    }
    
    // 页面加载时执行一次筛选
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            restoreSelection();
            filterClasses();
        });
    } else {
        restoreSelection();
        filterClasses();
    }
    
    // 下拉框改变时也执行筛选（作为备份，因为AutoPostBack已经会触发）
    ddl.addEventListener('change', function() {
        persistSelection();
        filterClasses();
    });

    if (ddl.form) {
        ddl.form.addEventListener('submit', persistSelection);
    }

    window.addEventListener('beforeunload', persistSelection);
})();
<" + @"/script>";
            
            Page.ClientScript.RegisterStartupScript(this.GetType(), "CampusFilter", script, false);
        }
        
        // 注册选中状态样式切换脚本
        if (!Page.ClientScript.IsStartupScriptRegistered("RoomSelectionStyle"))
        {
            string styleScript = @"
<script type='text/javascript'>
(function() {
    var storageKey = 'TeacherRoomSelection:' + window.location.pathname;
    var hiddenField = document.getElementById('" + HiddenSelectedRooms.ClientID + @"');

    function saveSelectionState() {
        var selected = [];
        document.querySelectorAll('.rs-room-card').forEach(function(card) {
            var chk = card.querySelector('input[type=""checkbox""]');
            var ridLabel = card.querySelector('[id$=""LabelRid""]');
            if (chk && chk.checked && ridLabel) {
                var rid = (ridLabel.textContent || ridLabel.innerText || '').trim();
                if (rid) {
                    selected.push(rid);
                }
            }
        });
        var serialized = selected.join(',');
        if (hiddenField) {
            hiddenField.value = serialized;
        }
        try {
            if (selected.length > 0) {
                window.localStorage.setItem(storageKey, serialized);
            } else {
                window.localStorage.removeItem(storageKey);
            }
        } catch (ex) {}
    }
    // 等待DOM加载完成
    function initRoomSelection() {
        var checkboxes = document.querySelectorAll('.rs-room-card input[type=""checkbox""]');
        
        checkboxes.forEach(function(chk) {
            // 更新卡片样式的函数
            function updateCardStyle() {
                var card = chk.closest('.rs-room-card');
                if (card) {
                    if (chk.checked) {
                        card.classList.add('selected');
                    } else {
                        card.classList.remove('selected');
                    }
                }
            }
            
            // 初始化时更新一次样式（重要：确保页面加载时显示正确状态）
            updateCardStyle();
            
            // 监听checkbox变化
            chk.addEventListener('change', function() {
                updateCardStyle();
                saveSelectionState();
            });
            
            // 点击卡片时切换checkbox（提升用户体验）
            var card = chk.closest('.rs-room-card');
            if (card) {
                card.addEventListener('click', function(e) {
                    // 如果点击的不是checkbox本身，则切换checkbox
                    if (e.target !== chk && e.target.tagName !== 'LABEL') {
                        if (!chk.disabled) {
                            chk.checked = !chk.checked;
                            updateCardStyle();
                            saveSelectionState();
                            // 触发change事件，以便其他监听器也能响应
                            var event = new Event('change', { bubbles: true });
                            chk.dispatchEvent(event);
                        }
                    }
                });
            }
        });
        
        // 处理禁用状态的卡片（已被其他教师选用）
        var allCards = document.querySelectorAll('.rs-room-card');
        allCards.forEach(function(card) {
            var chk = card.querySelector('input[type=""checkbox""]');
            if (chk && chk.disabled) {
                card.classList.add('disabled');
                card.style.cursor = 'not-allowed';
                card.style.opacity = '0.6';
            }
        });
        
        // 调试信息：输出选中的班级数量
        var checkedCount = document.querySelectorAll('.rs-room-card input[type=""checkbox""]:checked').length;
        console.log('班级选择初始化完成，已选中 ' + checkedCount + ' 个班级');
        saveSelectionState();
    }
    
    // 页面加载时初始化
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initRoomSelection);
    } else {
        initRoomSelection();
    }
    
    // 延迟再次初始化，确保ASP.NET的ViewState恢复完成
    setTimeout(initRoomSelection, 100);
})();
<" + @"/script>";
            
            Page.ClientScript.RegisterStartupScript(this.GetType(), "RoomSelectionStyle", styleScript, false);
        }
    }
    
    /// <summary>
    /// 获取班级所属的校区ID
    /// </summary>
    private int GetClassCampusId(int grade, int cls)
    {
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
                
                // 优先检查Students表是否有SchoolId字段（与schoolsetting.aspx保持一致）
                string checkSchoolIdSql = @"
                    SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_NAME = 'Students' AND COLUMN_NAME = 'SchoolId'";
                
                using (System.Data.SqlClient.SqlCommand checkCmd = new System.Data.SqlClient.SqlCommand(checkSchoolIdSql, conn))
                {
                    checkCmd.CommandTimeout = 5;
                    int schoolIdExists = (int)checkCmd.ExecuteScalar();
                    if (schoolIdExists > 0)
                    {
                        // 使用SchoolId字段 - 获取该班级中最常见的SchoolId
                        string sql = @"
                            SELECT TOP 1 ISNULL(SchoolId, 0) AS SchoolId, COUNT(*) AS Cnt
                            FROM Students 
                            WHERE Sgrade = @Grade AND Sclass = @Class
                            GROUP BY SchoolId
                            ORDER BY COUNT(*) DESC, SchoolId DESC";
                        
                        using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@Grade", grade);
                            cmd.Parameters.AddWithValue("@Class", cls);
                            cmd.CommandTimeout = 5;
                            
                            using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    int schoolId = reader.GetInt32(0);
                                    return schoolId;
                                }
                            }
                        }
                        
                        return 0;
                    }
                }
                
                // 如果SchoolId字段不存在，检查Scampus字段（向后兼容）
                string checkScampusSql = @"
                    SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_NAME = 'Students' AND COLUMN_NAME = 'Scampus'";
                
                using (System.Data.SqlClient.SqlCommand checkCmd = new System.Data.SqlClient.SqlCommand(checkScampusSql, conn))
                {
                    checkCmd.CommandTimeout = 5;
                    int scampusExists = (int)checkCmd.ExecuteScalar();
                    if (scampusExists > 0)
                    {
                        // 使用Scampus字段
                        string sql = @"
                            SELECT TOP 1 ISNULL(Scampus, 0) AS Scampus, COUNT(*) AS Cnt
                            FROM Students 
                            WHERE Sgrade = @Grade AND Sclass = @Class
                            GROUP BY Scampus
                            ORDER BY COUNT(*) DESC, Scampus DESC";
                        
                        using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@Grade", grade);
                            cmd.Parameters.AddWithValue("@Class", cls);
                            cmd.CommandTimeout = 5;
                            
                            using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    int scampus = reader.GetInt32(0);
                                    return scampus;
                                }
                            }
                        }
                    }
                }
                
            }
        }
        catch
        {
            // 忽略错误
        }
        
        return 0;
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .rs-page { max-width:100%; padding:28px 32px 40px; font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif; }
    .rs-header { display:flex; align-items:center; gap:16px; margin-bottom:24px; }
    .rs-header-icon { width:48px;height:48px;background:linear-gradient(135deg,#6366f1,#818cf8);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(99,102,241,0.25);flex-shrink:0; }
    .rs-header-icon svg { width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round; }
    .rs-header-text h1 { font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px; }
    .rs-header-text p { font-size:13px;color:#94a3b8;margin:0; }

    .rs-card { background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,0.04);overflow:hidden;transition:box-shadow .25s; }
    .rs-card-hd { padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px; }
    .rs-card-hd .ci { width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0; }
    .rs-card-hd .ci svg { width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none; }
    .ci.purple { background:#eef2ff; } .ci.purple svg { stroke:#6366f1; }
    .rs-card-bd { padding:22px; }

    /* 图例 */
    .rs-legend { display:flex; align-items:center; gap:20px; margin-bottom:20px; flex-wrap:wrap; }
    .rs-legend-item { display:flex; align-items:center; gap:6px; font-size:13px; color:#475569; }
    .rs-legend-dot { width:16px;height:16px;border-radius:5px;border:1.5px solid #e2e8f0;flex-shrink:0; }
    .rs-legend-dot.available { background:#f8fafc; }
    .rs-legend-dot.selected { background:linear-gradient(135deg,#bbf7d0,#86efac);border-color:#86efac; }
    .rs-legend-dot.disabled { background:#cbd5e1;border-color:#94a3b8; }

    /* DataList 网格 - 紧凑美化设计 */
    .rs-grid-wrap { 
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(95px, 1fr));
        gap: 12px;
        padding: 10px 0;
    }
    
    /* 基础卡片样式 - 可选状态（默认） */
    .rs-room-card {
        background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
        border: 1.5px solid #e5e7eb;
        border-radius: 10px;
        padding: 14px 12px;
        text-align: center;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        cursor: pointer;
        position: relative;
        overflow: hidden;
    }
    
    .rs-room-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 2px;
        background: linear-gradient(90deg, #6366f1, #8b5cf6, #ec4899);
        opacity: 0;
        transition: opacity 0.3s;
    }
    
    /* 可选状态 - hover效果 */
    .rs-room-card:not(.disabled):not(.selected):hover::before {
        opacity: 0.5;
    }
    
    .rs-room-card:not(.disabled):not(.selected):hover {
        border-color: #c7d2fe;
        background: linear-gradient(135deg, #ffffff 0%, #eef2ff 100%);
        box-shadow: 0 6px 16px rgba(99, 102, 241, 0.12), 0 2px 6px rgba(99, 102, 241, 0.06);
        transform: translateY(-2px);
    }
    
    /* 已选状态 - 绿色渐变 */
    .rs-room-card:has(input[type="checkbox"]:checked),
    .rs-room-card.selected {
        border-color: #86efac !important;
        background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%) !important;
        box-shadow: 0 4px 12px rgba(34, 197, 94, 0.25) !important;
    }
    
    .rs-room-card:has(input[type="checkbox"]:checked)::before,
    .rs-room-card.selected::before {
        background: linear-gradient(90deg, #22c55e, #10b981, #059669);
        opacity: 1 !important;
    }
    
    .rs-room-card:has(input[type="checkbox"]:checked) .rs-room-number,
    .rs-room-card.selected .rs-room-number {
        background: linear-gradient(135deg, #22c55e 0%, #10b981 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
    }
    
    .rs-room-card:has(input[type="checkbox"]:checked) .rs-room-checkbox,
    .rs-room-card.selected .rs-room-checkbox {
        background: #dcfce7;
    }
    
    /* 不可选状态 - 灰色 */
    .rs-room-card.disabled,
    .rs-room-card:has(input[type="checkbox"]:disabled) {
        background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%) !important;
        border-color: #cbd5e1 !important;
        cursor: not-allowed !important;
        opacity: 0.65 !important;
    }
    
    .rs-room-card.disabled::before,
    .rs-room-card:has(input[type="checkbox"]:disabled)::before {
        display: none;
    }
    
    .rs-room-card.disabled .rs-room-number,
    .rs-room-card:has(input[type="checkbox"]:disabled) .rs-room-number {
        background: linear-gradient(135deg, #94a3b8 0%, #64748b 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
    }
    
    .rs-room-card.disabled .rs-room-label,
    .rs-room-card:has(input[type="checkbox"]:disabled) .rs-room-label {
        color: #94a3b8;
    }
    
    .rs-room-card.disabled .rs-room-checkbox,
    .rs-room-card:has(input[type="checkbox"]:disabled) .rs-room-checkbox {
        background: #cbd5e1;
    }
    
    .rs-room-card.disabled:hover,
    .rs-room-card:has(input[type="checkbox"]:disabled):hover {
        transform: none !important;
        box-shadow: none !important;
    }
    
    .rs-room-number {
        font-size: 24px;
        font-weight: 700;
        background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        margin: 0 0 6px;
        letter-spacing: 0.3px;
        line-height: 1.1;
        transition: all 0.3s;
    }
    
    .rs-room-label {
        font-size: 10px;
        color: #94a3b8;
        font-weight: 500;
        margin-bottom: 12px;
        letter-spacing: 0.4px;
        text-transform: uppercase;
        transition: all 0.3s;
    }
    
    .rs-room-checkbox {
        position: relative;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 28px;
        height: 28px;
        background: #f1f5f9;
        border-radius: 6px;
        transition: all 0.2s;
    }
    
    .rs-room-checkbox:hover {
        background: #e0e7ff;
    }
    
    .rs-room-checkbox input[type="checkbox"] {
        width: 16px;
        height: 16px;
        cursor: pointer;
        accent-color: #22c55e;
        border-radius: 3px;
        transition: all 0.15s;
    }
    
    .rs-room-checkbox input[type="checkbox"]:not(:disabled):hover {
        transform: scale(1.1);
    }
    
    .rs-room-checkbox input[type="checkbox"]:checked {
        transform: scale(1.15);
    }
    
    .rs-room-checkbox input[type="checkbox"]:disabled {
        cursor: not-allowed;
        opacity: 0.5;
    }
    
    .rs-room-link {
        display: none;
    }
    
    /* 选中状态的卡片样式（旧版，保留作为备份） */
    .rs-room-card:has(input[type="checkbox"]:checked) {
        border-color: #86efac;
        background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
        box-shadow: 0 4px 12px rgba(34, 197, 94, 0.25);
    }
    
    .rs-room-card:has(input[type="checkbox"]:checked)::before {
        opacity: 1;
        background: linear-gradient(90deg, #22c55e, #10b981, #059669);
    }

    /* 按钮区 */
    .rs-actions { display:flex; align-items:center; justify-content:center; gap:16px; margin-top:28px; }
    .btn-primary { display:inline-flex;align-items:center;justify-content:center;height:38px;padding:0 28px;background:linear-gradient(135deg,#6366f1,#7c3aed);color:#fff!important;border:none;border-radius:9px;font-size:13.5px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;box-shadow:0 2px 6px rgba(99,102,241,0.3);letter-spacing:.3px; }
    .btn-primary:hover { box-shadow:0 4px 14px rgba(99,102,241,0.4);transform:translateY(-1px); }
    .btn-primary:active { transform:translateY(0); }
    .btn-secondary { display:inline-flex;align-items:center;justify-content:center;height:38px;padding:0 28px;background:#fff;color:#475569;border:1.5px solid #e2e8f0;border-radius:9px;font-size:13.5px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s; }
    .btn-secondary:hover { border-color:#cbd5e1;background:#f8fafc;box-shadow:0 2px 8px rgba(0,0,0,0.06); }
</style>

<div class="rs-page">
    <div class="rs-header">
        <div class="rs-header-icon">
            <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
        </div>
        <div class="rs-header-text">
            <h1>班级选择</h1>
            <p>勾选需要管理的班级，灰色班级已被其他教师选用</p>
        </div>
    </div>

    <div class="rs-card">
        <div class="rs-card-hd">
            <span class="ci purple"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg></span>
            选择班级
        </div>
        <div class="rs-card-bd">
            <!-- 校区筛选 -->
            <asp:Panel ID="CampusPanel" runat="server" Visible="true">
                <div style="margin-bottom: 20px; padding: 16px 20px; background: #fff; border: 1px solid #e2e8f0; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.04);">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div style="width: 36px; height: 36px; background: linear-gradient(135deg, #8b5cf6, #6366f1); border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                            <svg style="width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;" viewBox="0 0 24 24">
                                <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
                                <polyline points="9 22 9 12 15 12 15 22"/>
                            </svg>
                        </div>
                        <div style="flex: 1;">
                            <label style="font-size: 14px; font-weight: 600; color: #334155; display: block; margin-bottom: 6px;">
                                校区筛选
                            </label>
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <asp:DropDownList ID="DDLCampus" runat="server" AutoPostBack="True" 
                                    OnSelectedIndexChanged="DDLCampus_SelectedIndexChanged"
                                    style="width: 360px; height: 40px; border-radius: 10px; border: 1px solid #e2e8f0; background: #fff; color: #1e293b; font-size: 14px; font-weight: 500; padding: 0 14px; cursor: pointer; transition: all 0.2s; font-family: 'Microsoft YaHei', 'Segoe UI', Arial, sans-serif;">
                                </asp:DropDownList>
                                <span style="font-size: 13px; color: #64748b;">
                                    选择校区后只显示该校区的班级
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </asp:Panel>
            
            <!-- 调试信息（已禁用） -->
            <asp:Label ID="DebugInfo" runat="server" Visible="false" 
                style="display: none;">
            </asp:Label>
            
            <!-- 筛选调试信息（已禁用） -->
            <asp:Panel ID="FilterDebugPanel" runat="server" Visible="false"
                style="display: none;">
                <asp:Literal ID="FilterDebugInfo" runat="server"></asp:Literal>
            </asp:Panel>
            
            <asp:HiddenField ID="HiddenSelectedRooms" runat="server" />
            
            <div class="rs-legend">
                <div class="rs-legend-item">
                    <asp:Label ID="Labelnot" runat="server" CssClass="rs-legend-dot available"></asp:Label>
                    <span>可选</span>
                </div>
                <div class="rs-legend-item">
                    <asp:Label ID="Labelselect" runat="server" CssClass="rs-legend-dot selected"></asp:Label>
                    <span>已选</span>
                </div>
                <div class="rs-legend-item">
                    <asp:Label ID="Labelother" runat="server" CssClass="rs-legend-dot disabled"></asp:Label>
                    <span>不可选</span>
                </div>
            </div>

            <div class="rs-grid-wrap">
                <asp:DataList ID="DLroom" runat="server" RepeatColumns="5" 
                    RepeatDirection="Horizontal" RepeatLayout="Flow"
                    DataKeyField="Rid" OnItemDataBound="DLroom_ItemDataBound">
                    <ItemTemplate>
                        <div class="rs-room-card">
                            <div class="rs-room-number">
                                <asp:Label ID="LabelRgrade" runat="server" Text='<%# Eval("Rgrade") %>'></asp:Label>.<asp:Label ID="LabelRclass" runat="server" Text='<%# Eval("Rclass") %>'></asp:Label>
                            </div>
                            <div class="rs-room-label">年级班级</div>
                            <div class="rs-room-checkbox">
                                <asp:CheckBox ID="CheckRoom" runat="server" />
                            </div>
                            <asp:HyperLink ID="Rgradeclass" runat="server" CssClass="rs-room-link"></asp:HyperLink>
                            <asp:Label ID="LabelRid" runat="server" Text='<%# Eval("Rid") %>' style="display:none;"></asp:Label>
                            <asp:Label ID="LabelRhid" runat="server" Text='<%# Eval("Rhid") %>' style="display:none;"></asp:Label>
                        </div>
                    </ItemTemplate>
                </asp:DataList>
            </div>

            <div class="rs-actions">
                <asp:Button ID="Btnselect" runat="server" Text="确定选择" CssClass="btn-primary" onclick="Btnselect_Click" />
                <asp:Button ID="Btnreturn" runat="server" Text="返回" CssClass="btn-secondary" onclick="Btnreturn_Click" />
            </div>
        </div>
    </div>
</div>

</asp:Content>

