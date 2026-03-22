<%@ page title="" language="C#" masterpagefile="~/student/Scm.master" autoeventwireup="true" stylesheettheme="Student" inherits="Student_program, LearnSite" %>
<%-- 修复版本: 2024-03-11 - 添加 Msort 查询和恢复逻辑 --%>

<script runat="server">
    private sealed class MissionRouteInfo
    {
        public string Lid;
        public string Title;
        public string Ltype;
        public string Mfiletype;
        public string Msort;
        public string Mexample;
        public string Mback;
        public bool Mhelp;
        public bool Microworld;
    }

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo connField = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                if (connField != null)
                    cs = connField.GetValue(null) as string;
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            try { cs = System.Configuration.ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; }
            catch { }
        }
        return cs;
    }

    private string GetCurrentLid()
    {
        string lid = "";
        try { lid = LabelLid.Text.Trim(); } catch { }
        if (string.IsNullOrEmpty(lid)) lid = Request.QueryString["lid"] ?? "";
        return lid;
    }

    private string GetProgramPythonUrl(string lid)
    {
        return "~/student/python.aspx?lid=" + lid;
    }

    private MissionRouteInfo GetMissionRouteInfo(string lid)
    {
        if (string.IsNullOrEmpty(lid)) return null;

        string cacheKey = "ProgramMissionRouteInfo_" + lid;
        try
        {
            if (Context.Items[cacheKey] != null)
                return Context.Items[cacheKey] as MissionRouteInfo;
        }
        catch { }

        int listId = 0;
        if (!int.TryParse(lid, out listId) || listId <= 0) return null;

        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return null;

        MissionRouteInfo info = null;
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(@"
                    SELECT TOP 1
                        L.Ltype,
                        M.Mtitle,
                        M.Mfiletype,
                        M.Msort,
                        M.Mexample,
                        M.Mback,
                        M.Mhelp,
                        M.Microworld
                    FROM Listmenu L
                    LEFT JOIN Mission M ON M.Mid = L.Lxid
                    WHERE L.Lid=@Lid", conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", listId);
                    using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            info = new MissionRouteInfo();
                            info.Lid = lid;
                            info.Ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString().Trim() : "";
                            info.Title = reader["Mtitle"] != DBNull.Value ? reader["Mtitle"].ToString().Trim() : "";
                            info.Mfiletype = reader["Mfiletype"] != DBNull.Value ? reader["Mfiletype"].ToString().Trim() : "";
                            info.Msort = reader["Msort"] != DBNull.Value ? reader["Msort"].ToString().Trim() : "";
                            info.Mexample = reader["Mexample"] != DBNull.Value ? reader["Mexample"].ToString().Trim() : "";
                            info.Mback = reader["Mback"] != DBNull.Value ? reader["Mback"].ToString().Trim() : "";
                            info.Mhelp = reader["Mhelp"] != DBNull.Value && Convert.ToBoolean(reader["Mhelp"]);
                            info.Microworld = reader["Microworld"] != DBNull.Value && Convert.ToBoolean(reader["Microworld"]);
                        }
                    }
                }
            }
        }
        catch { }

        try { Context.Items[cacheKey] = info; } catch { }
        return info;
    }

    private bool HasPythonFileExtension(string value)
    {
        if (string.IsNullOrEmpty(value)) return false;
        string normalized = value.Trim().ToLowerInvariant();
        if (normalized == "py" || normalized == "python" || normalized == "pyw") return true;

        string extension = System.IO.Path.GetExtension(normalized);
        return extension == ".py" || extension == ".pyw";
    }

    private bool IsScratchFileTypeValue(string value)
    {
        if (string.IsNullOrEmpty(value)) return false;
        string normalized = value.Trim().ToLowerInvariant();
        if (normalized == "sb3" || normalized == "sb2" || normalized == "scratch")
            return true;

        string extension = System.IO.Path.GetExtension(normalized);
        return extension == ".sb3" || extension == ".sb2";
    }

    private string NormalizeProgramLtypeValue(string ltype)
    {
        string value = string.IsNullOrEmpty(ltype) ? "" : ltype.Trim();
        switch (value)
        {
            case "导图":
            case "脑图":
                return "10";
            case "积木":
            case "积木编程":
                return "4";
            case "Python":
            case "代码":
            case "仓库":
                return "5";
            case "流程":
            case "流程图":
                return "7";
            case "应用":
            case "像素":
            case "拼图":
            case "绘图":
                return "8";
            case "Html":
            case "网页":
                return "9";
            case "表格":
                return "11";
            case "课件":
                return "12";
            default:
                return value;
        }
    }

    private bool IsBlockProgrammingTask(string fileType, string ltype, System.Text.StringBuilder debugLog)
    {
        string ft = string.IsNullOrEmpty(fileType) ? "" : fileType.Trim().ToLowerInvariant();
        string lt = NormalizeProgramLtypeValue(ltype);

        if (IsScratchFileTypeValue(ft))
        {
            AppendDebug(debugLog, "通过 fileType={0} 判断为积木编程任务\n", ft);
            return true;
        }

        if (lt == "4")
        {
            AppendDebug(debugLog, "通过 Ltype={0} 判断为积木编程任务\n", ltype);
            return true;
        }

        MissionRouteInfo info = GetMissionRouteInfo(GetCurrentLid());
        if (info != null)
        {
            string infoLtype = NormalizeProgramLtypeValue(info.Ltype);
            if (infoLtype == "4")
            {
                AppendDebug(debugLog, "通过 Mission/Listmenu.Ltype={0} 判断为积木编程任务\n", info.Ltype);
                return true;
            }

            if (IsScratchFileTypeValue(info.Mfiletype))
            {
                AppendDebug(debugLog, "通过 Mission.Mfiletype={0} 判断为积木编程任务\n", info.Mfiletype);
                return true;
            }

            if (IsScratchFileTypeValue(info.Mexample))
            {
                AppendDebug(debugLog, "通过 Mission.Mexample={0} 判断为积木编程任务\n", info.Mexample);
                return true;
            }

            if (!string.IsNullOrEmpty(info.Title))
            {
                string title = info.Title.Trim();
                if (title.IndexOf("scratch", StringComparison.OrdinalIgnoreCase) >= 0 ||
                    title.IndexOf("积木", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    AppendDebug(debugLog, "通过 Mission.Mtitle={0} 判断为积木编程任务\n", info.Title);
                    return true;
                }
            }
        }

        return false;
    }

    private bool IsExcelLikeFileType(string fileType)
    {
        if (string.IsNullOrEmpty(fileType)) return false;
        string ft = fileType.Trim().ToLower();
        return ft == "xls" || ft == "xlsx" || ft == "et" || ft == "ett" ||
               ft == "csv" || ft == "excel" || ft == "sheet" || ft == "luckysheet";
    }

    private bool IsPixelAddProgramSubtype(string msort)
    {
        if (string.IsNullOrEmpty(msort)) return false;
        switch (msort.Trim())
        {
            case "11": // 像素画
                return true;
            case "36": // 素材库 → ware.aspx
            case "37": // 网站设计 → website.aspx
            case "17": // 二维码 → qrcode.aspx
            default:
                return false;
        }
    }

    // 获取 Msort 18-35 各专属类型的学生工作页面 URL（带 ~/ 虚拟路径前缀）
    private string GetMsortSpecificUrl(string msort, string lid)
    {
        if (string.IsNullOrEmpty(msort) || string.IsNullOrEmpty(lid)) return null;
        switch (msort.Trim())
        {
            case "18": return "~/student/word.aspx?lid=" + lid;           // 在线文档
            case "19": return "~/student/mpptx.aspx?lid=" + lid;          // 演示文稿
            case "20": return "~/fabriceditor/poster.aspx?lid=" + lid;    // 海报设计
            case "21": return "~/student/style.aspx?lid=" + lid;          // 风格迁移
            case "22": return "~/machine/imageclass.aspx?lid=" + lid;     // 图像分类
            case "23": return "~/faceai/face.aspx?lid=" + lid;            // 人脸识别
            case "24": return "~/student/mqtt.aspx?lid=" + lid;           // 物联网MQTT
            case "25": return "~/student/draw.aspx?lid=" + lid;           // 手绘画布
            case "26": return "~/student/sokoban.aspx?lid=" + lid;        // 推箱子地图
            case "27": return "~/deepseek/deepseek.aspx?lid=" + lid;      // 人工智能对话
            case "28": return "~/deepseek/speek.aspx?lid=" + lid;         // 语音合成
            case "29": return "~/deepseek/ocr.aspx?lid=" + lid;           // 文字识别
            case "30": return "~/deepseek/soundlab.aspx?lid=" + lid;      // 声音分析
            case "31": return "~/deepseek/tic-tac-toe.aspx?lid=" + lid;   // 井字棋
            case "32": return "~/student/handnum.aspx?lid=" + lid;        // 手写数字识别
            case "33": return "~/student/markdown.aspx?lid=" + lid;       // Markdown写作
            case "34": return "~/student/iframe.aspx?lid=" + lid;         // 嵌入本地网页
            case "35": return "~/deepseek/aidraw.aspx?lid=" + lid;        // 文生图
            case "36": return "~/student/ware.aspx?lid=" + lid;            // 素材库
            case "37": return "~/student/website.aspx?lid=" + lid;         // 网站设计
            default: return null;
        }
    }

    private bool IsQRCodeTask(string msort, string ltype, string fileType, System.Text.StringBuilder debugLog)
    {
        if (IsPythonTask(fileType, ltype, null))
        {
            AppendDebug(debugLog, "已识别为 Python 任务，跳过二维码判定\n");
            return false;
        }

        // 方法1：Msort=17（教师端创建时设置）
        if (!string.IsNullOrEmpty(msort) && msort.Trim() == "17")
        {
            AppendDebug(debugLog, "通过 Msort=17 判断为二维码任务\n");
            return true;
        }
        // 方法2：Ltype=17（DLL 存储在 Listmenu.Ltype 中的类型标识）
        if (!string.IsNullOrEmpty(ltype) && ltype.Trim() == "17")
        {
            AppendDebug(debugLog, "通过 Ltype=17 判断为二维码任务\n");
            return true;
        }
        // 方法3：Mfiletype="qrcode"（任务文件类型为二维码）
        if (!string.IsNullOrEmpty(fileType) && fileType.Trim().ToLower() == "qrcode")
        {
            AppendDebug(debugLog, "通过 fileType=qrcode 判断为二维码任务\n");
            return true;
        }
        return false;
    }

    private string GetQRCodeEditorUrl(string lid)
    {
        string mid = Request.QueryString["mid"] ?? "";
        string mcid = "";
        try { mcid = LabelMcid.Text.Trim(); } catch { }
        if (string.IsNullOrEmpty(mcid)) mcid = Request.QueryString["mcid"] ?? "";

        if (!string.IsNullOrEmpty(mid) || !string.IsNullOrEmpty(mcid))
            return string.Format("~/student/qrcode.aspx?lid={0}&mid={1}&mcid={2}&editor=1", lid, mid, mcid);
        return "~/student/qrcode.aspx?lid=" + lid + "&editor=1";
    }

    private bool IsPythonTask(string fileType, string ltype, System.Text.StringBuilder debugLog)
    {
        string lt = NormalizeProgramLtypeValue(ltype);
        if (lt == "4")
        {
            AppendDebug(debugLog, "Ltype={0} 属于积木编程任务，跳过 Python 判定\n", ltype);
            return false;
        }

        if (CheckBlockpy.Checked || CheckBlock.Checked || CheckBack.Checked)
        {
            AppendDebug(debugLog, "通过 Python 模式开关判断为 Python 任务，blockpy={0}, block={1}, turtle={2}\n",
                CheckBlockpy.Checked, CheckBlock.Checked, CheckBack.Checked);
            return true;
        }

        string ft = string.IsNullOrEmpty(fileType) ? "" : fileType.Trim().ToLower();

        if (ft == "py" || ft == "python" || ft == "pyw")
        {
            AppendDebug(debugLog, "通过 fileType={0} 判断为 Python 任务\n", ft);
            return true;
        }

        switch (lt)
        {
            case "5":
            case "Python":
            case "代码":
            case "仓库":
                AppendDebug(debugLog, "通过 Ltype={0} 判断为 Python 任务\n", lt);
                return true;
            default:
                break;
        }

        MissionRouteInfo info = GetMissionRouteInfo(GetCurrentLid());
        if (info != null)
        {
            string infoLtype = NormalizeProgramLtypeValue(info.Ltype);
            if (infoLtype == "4")
            {
                AppendDebug(debugLog, "Mission/Listmenu.Ltype={0} 属于积木编程任务，跳过 Python 判定\n", info.Ltype);
                return false;
            }

            if (IsScratchFileTypeValue(info.Mfiletype) || IsScratchFileTypeValue(info.Mexample))
            {
                AppendDebug(debugLog, "Mission 文件类型显示为 Scratch/积木，跳过 Python 判定\n");
                return false;
            }

            if (HasPythonFileExtension(info.Mfiletype))
            {
                AppendDebug(debugLog, "通过 Mission.Mfiletype={0} 判断为 Python 任务\n", info.Mfiletype);
                return true;
            }

            if (HasPythonFileExtension(info.Mexample))
            {
                AppendDebug(debugLog, "通过 Mission.Mexample={0} 判断为 Python 任务\n", info.Mexample);
                return true;
            }

            if (info.Microworld)
            {
                AppendDebug(debugLog, "通过 Mission.Microworld=1 判断为 Python 任务\n");
                return true;
            }

            if (info.Mhelp)
            {
                AppendDebug(debugLog, "通过 Mission.Mhelp=1 判断为 Python 任务\n");
                return true;
            }

            if (!string.IsNullOrEmpty(info.Mback))
            {
                AppendDebug(debugLog, "通过 Mission.Mback 非空判断为 Python 任务\n");
                return true;
            }

            if (!string.IsNullOrEmpty(info.Title) &&
                info.Title.IndexOf("python", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                AppendDebug(debugLog, "通过 Mission.Mtitle 包含 Python 判断为 Python 任务\n");
                return true;
            }
        }

        return false;
    }

    private string GetPythonEditorUrl(string lid)
    {
        string url = "~/student/python.aspx?lid=" + lid;
        if (CheckBack.Checked)
            url = "~/student/turtleidle.aspx?lid=" + lid;
        if (CheckBlock.Checked)
            url = "~/student/pythonblock.aspx?lid=" + lid;
        if (CheckBlockpy.Checked)
            url = "~/student/pythonblockly.aspx?lid=" + lid;
        return url;
    }

    private string GetMsortForLid(string lid)
    {
        if (string.IsNullOrEmpty(lid)) return "";
        int listId = 0;
        if (!int.TryParse(lid, out listId) || listId <= 0) return "";
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs)) return "";
        try
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT TOP 1 L.Ltype, M.Msort FROM Listmenu L LEFT JOIN Mission M ON M.Mid = L.Lxid WHERE L.Lid=@Lid", conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", listId);
                    using (System.Data.SqlClient.SqlDataReader _rdr = cmd.ExecuteReader())
                    {
                        if (_rdr.Read())
                        {
                            string _msortVal = _rdr["Msort"] != DBNull.Value ? _rdr["Msort"].ToString().Trim() : "";
                            string _ltypeVal = _rdr["Ltype"] != DBNull.Value ? _rdr["Ltype"].ToString().Trim() : "";
                            // Listmenu.Ltype 在 18-37 时，优先返回（比 Mission.Msort 更可靠）
                            int _ltypeN;
                            if (int.TryParse(_ltypeVal, out _ltypeN) && _ltypeN >= 18 && _ltypeN <= 37) return _ltypeVal;
                            if (!string.IsNullOrEmpty(_msortVal)) return _msortVal;
                        }
                    }
                }
            }
        }
        catch { }
        return "";
    }

    private bool IsExcelTask(string lid, string fileType)
    {
        // pxl 是像素画文件类型，绝对不是 Excel 表格任务
        if (!string.IsNullOrEmpty(fileType) && fileType.Trim().ToLower() == "pxl") return false;
        if (IsExcelLikeFileType(fileType)) return true;
        if (string.IsNullOrEmpty(lid)) return false;

        try
        {
            int listId = 0;
            if (!int.TryParse(lid, out listId) || listId <= 0) return false;

            string cs = GetConnStr();
            if (string.IsNullOrEmpty(cs)) return false;

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(@"
                    SELECT TOP 1 L.Ltype, M.Mfiletype, M.Msort
                    FROM Listmenu L
                    LEFT JOIN Mission M ON M.Mid = L.Lxid
                    WHERE L.Lid=@Lid", conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", listId);
                    using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString().Trim() : "";
                            string mfiletype = reader["Mfiletype"] != DBNull.Value ? reader["Mfiletype"].ToString().Trim() : "";
                            string msort = reader["Msort"] != DBNull.Value ? reader["Msort"].ToString().Trim() : "";
                            // Ltype="11" 在 pixeladd 场景下是 DDLTitle Value（像素画）
                            // 在普通任务场景下才是"表格"(Excel)。通过 Mission.Msort 和 Mfiletype 区分：
                            // Msort 在 11-37 内 → pixeladd 子类型，不是 Excel
                            // Mfiletype 不是 Excel 类型（如 pxl 或空）→ 不是 Excel
                            if (ltype == "11" || ltype == "表格")
                            {
                                if (IsPixelAddProgramSubtype(msort)) return false;
                                // Ltype=11 且非 pixeladd 子类型即为表格任务，Mfiletype 可为空
                                return true;
                            }
                            if (IsExcelLikeFileType(mfiletype))
                                return true;
                        }
                    }
                }
            }
        }
        catch { }
        return false;
    }
    protected override void OnPreInit(EventArgs e)
    {
        // Msort 18-35 任务：跳过 DLL 基类的 OnPreInit，防止其自动跳转到 word/mpptx 等编辑器
        // 保留 program.aspx 正常显示任务说明，点击「开始创作」再跳转
        bool _skipBasePre = false;
        try
        {
            string _preLid = Request.QueryString["lid"] ?? "";
            if (!string.IsNullOrEmpty(_preLid))
            {
                // 优先从 URL 参数获取 msort（由 taskredirect/showcourse 传入，最可靠）
                string _preMsort = Request.QueryString["msort"] ?? "";
                if (string.IsNullOrEmpty(_preMsort)) _preMsort = GetMsortForLid(_preLid);
                int _preMsortNum;
                if (int.TryParse(_preMsort, out _preMsortNum) && _preMsortNum >= 18 && _preMsortNum <= 37)
                {
                    _skipBasePre = true;
                    // 在任何 DLL 代码运行前预计算目标 URL，存入 Context.Items
                    string _preUrl = GetMsortSpecificUrl(_preMsort, _preLid);
                    if (!string.IsNullOrEmpty(_preUrl))
                        Context.Items["MsortSpecificUrl"] = _preUrl;
                }
            }
        }
        catch { }
        if (!_skipBasePre) base.OnPreInit(e);
        try
        {
            string lid = Request.QueryString["lid"] ?? "";
            if (string.IsNullOrEmpty(lid)) return;
            string cs = GetConnStr();

            int listId = 0;
            if (string.IsNullOrEmpty(cs) || !int.TryParse(lid, out listId) || listId <= 0) return;

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(cs))
            {
                conn.Open();
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(@"
                    SELECT TOP 1 L.Ltype, L.Lcid, L.Lxid, M.Mfiletype, M.Msort
                    FROM Listmenu L
                    LEFT JOIN Mission M ON M.Mid = L.Lxid
                    WHERE L.Lid=@Lid", conn))
                {
                    cmd.Parameters.AddWithValue("@Lid", listId);
                    using (System.Data.SqlClient.SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString().Trim() : "";
                            int lcid = reader["Lcid"] != DBNull.Value ? Convert.ToInt32(reader["Lcid"]) : 0;
                            string mfiletype = reader["Mfiletype"] != DBNull.Value ? reader["Mfiletype"].ToString().Trim().ToLower() : "";
                            string msort = reader["Msort"] != DBNull.Value ? reader["Msort"].ToString().Trim() : "";
                            // DB Msort 为空时，从 URL 参数补充（taskredirect 传入）
                            if (string.IsNullOrEmpty(msort)) { string _urlMs = Request.QueryString["msort"] ?? ""; if (!string.IsNullOrEmpty(_urlMs)) msort = _urlMs; }

                            // 将原始 Ltype 和 Msort 存入 Context.Items，供后续使用
                            // pixeladd 任务：Ltype=11（DDLTitle存入）；普通像素画：Ltype=8
                            Context.Items["LidLtype"] = ltype;
                            Context.Items["LidMsort"] = msort;
                            // Listmenu.Ltype 在 18-37 时：覆盖 LidMsort（Ltype 比 Mission.Msort 更可靠）
                            // 并预计算专属 URL，确保 PrepareStartCreateClientState 直接命中
                            // 注意：msort=36(素材库)/37(网站设计)与 18-35 一样经过 program.aspx 展示任务说明，再由『开始创作』跳转
                            {
                                int _ltypeOvN;
                                if (int.TryParse(ltype, out _ltypeOvN) && _ltypeOvN >= 18 && _ltypeOvN <= 37)
                                {
                                    Context.Items["LidMsort"] = ltype; // 覆盖 Mission.Msort
                                    string _ltypeOvUrl = GetMsortSpecificUrl(ltype, listId.ToString());
                                    if (!string.IsNullOrEmpty(_ltypeOvUrl))
                                        Context.Items["MsortSpecificUrl"] = _ltypeOvUrl;
                                }
                                else
                                {
                                    // Mission.Msort 在 18-37 时同样处理（备用）
                                    int _msortOvN;
                                    if (int.TryParse(msort, out _msortOvN) && _msortOvN >= 18 && _msortOvN <= 37)
                                    {
                                        Context.Items["LidMsort"] = msort;
                                        string _msortOvUrl = GetMsortSpecificUrl(msort, listId.ToString());
                                        if (!string.IsNullOrEmpty(_msortOvUrl))
                                            Context.Items["MsortSpecificUrl"] = _msortOvUrl;
                                    }
                                }
                            }

                            // 讨论类型：直接跳转到 topicdiscuss.aspx
                            if (ltype == "13" || ltype == "讨论")
                            {
                                int cid = lcid > 0 ? lcid : 0;
                                if (cid == 0) int.TryParse(Request.QueryString["mcid"] ?? "", out cid);
                                string discussUrl = cid > 0
                                    ? string.Format("~/student/topicdiscuss.aspx?lid={0}&cid={1}", listId, cid)
                                    : string.Format("~/student/topicdiscuss.aspx?lid={0}", listId);
                                Response.Redirect(discussUrl, true);
                                return;
                            }

                            // 表格类型：直接跳转到 excel.aspx
                            if ((ltype == "11" || ltype == "表格") && !IsPixelAddProgramSubtype(msort))
                            {
                                Response.Redirect("~/student/excel.aspx?lid=" + listId, true);
                                return;
                            }

                            // 填表类型：直接跳转到 txtform.aspx
                            // 排除情况：如果 Mfiletype 是 Excel 类型或思维导图类型，则不跳转，留在 program.aspx 显示任务说明
                            // （防止 Listmenu.Ltype 数据库存储为 "填表"/15 但实际是 Excel 或脑图任务时错误跳转）
                            bool _isMindMapMfile = (mfiletype == "km" || mfiletype == "mm" ||
                                                    mfiletype == "mindmap" || mfiletype == "kitymind");
                            if ((ltype == "15" || ltype == "填表") &&
                                !IsExcelLikeFileType(mfiletype) && !_isMindMapMfile)
                            {
                                int _lxidF = reader["Lxid"] != DBNull.Value ? Convert.ToInt32(reader["Lxid"]) : 0;
                                string _mcidF = lcid > 0 ? lcid.ToString() : (Request.QueryString["mcid"] ?? "");
                                Response.Redirect(string.Format("~/student/txtform.aspx?lid={0}&mid={1}&mcid={2}", listId, _lxidF, _mcidF), true);
                                return;
                            }

                            if (ltype == "导图" || ltype == "脑图" || ltype == "10" ||
                                mfiletype == "km" || mfiletype == "mm" || mfiletype == "mindmap" || mfiletype == "kitymind")
                            {
                                Context.Items["MindMapProgramGuard"] = true;
                            }
                        }
                    }
                }
            }
        }
        catch { }
    }
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        
        // 从 Context.Items 恢复 Msort 并设置到 Label
        try
        {
            if (Context.Items["LidMsort"] != null)
            {
                LabelMsort.Text = Context.Items["LidMsort"].ToString();
            }
        }
        catch { }
        
        PrepareStartCreateClientState();
        
        // 直接设置链接的 NavigateUrl（服务器端）
        try
        {
            string lid = LabelLid.Text;
            if (string.IsNullOrEmpty(lid)) lid = Request.QueryString["lid"] ?? "";
            string fileType = LabelUploadType.Text;
            string url = ResolveStartCreateUrl(lid, fileType, null);
            
            if (!string.IsNullOrEmpty(url))
            {
                // 找到 HyperLink 控件并设置 NavigateUrl
                System.Web.UI.WebControls.HyperLink linkStartCreate = 
                    (System.Web.UI.WebControls.HyperLink)FindControlRecursive(this, "LinkStartCreate");
                if (linkStartCreate != null)
                {
                    linkStartCreate.NavigateUrl = url;
                    System.Diagnostics.Debug.WriteLine("✓ 服务器端设置链接URL: " + url);
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("设置链接URL失败: " + ex.Message);
        }
    }
    
    private System.Web.UI.Control FindControlRecursive(System.Web.UI.Control root, string id)
    {
        if (root.ID == id) return root;
        foreach (System.Web.UI.Control c in root.Controls)
        {
            System.Web.UI.Control found = FindControlRecursive(c, id);
            if (found != null) return found;
        }
        return null;
    }

    private void PrepareStartCreateClientState()
    {
        try
        {
            string fileType = LabelUploadType.Text;
            string ltype = "";
            try { ltype = LabelLtype.Text.Trim(); } catch { }
            bool isBlockTask = IsBlockProgrammingTask(fileType, ltype, null);
            bool isPythonTask = IsPythonTask(fileType, ltype, null);

            // 最优先：使用 OnPreInit 预计算的 URL（URL msort 参数直接计算，在任何 DLL 代码之前）
            string preUrl = null;
            try { if (Context.Items["MsortSpecificUrl"] != null) preUrl = Context.Items["MsortSpecificUrl"].ToString(); } catch { }
            if (!string.IsNullOrEmpty(preUrl) && !isPythonTask && !isBlockTask)
            {
                HdStartCreateUrl.Value = ResolveUrl(preUrl);
                HdStartCreateAllowed.Value = IsStartCreateAllowed(null) ? "1" : "0";
                HdStartCreateMessage.Value = "活动还未开始，请仔细听讲技术关键点！";
                return;
            }
            string lid = LabelLid.Text;
            if (string.IsNullOrEmpty(lid)) lid = Request.QueryString["lid"] ?? "";
            string url = ResolveStartCreateUrl(lid, fileType, null);

            HdStartCreateUrl.Value = string.IsNullOrEmpty(url) ? "" : ResolveUrl(url);
            HdStartCreateAllowed.Value = IsStartCreateAllowed(null) ? "1" : "0";
            HdStartCreateMessage.Value = "活动还未开始，请仔细听讲技术关键点！";
        }
        catch
        {
            HdStartCreateUrl.Value = "";
            HdStartCreateAllowed.Value = "1";
            HdStartCreateMessage.Value = "";
        }
    }

    private void AppendDebug(System.Text.StringBuilder debugLog, string format, params object[] args)
    {
        if (debugLog == null) return;
        debugLog.AppendFormat(format, args);
    }

    private string GetPixelEditorUrl(string lid)
    {
        string mid = Request.QueryString["mid"] ?? "";
        string mcid = "";
        try { mcid = LabelMcid.Text.Trim(); } catch { }
        if (string.IsNullOrEmpty(mcid)) mcid = Request.QueryString["mcid"] ?? "";

        if (!string.IsNullOrEmpty(mid) || !string.IsNullOrEmpty(mcid))
            return string.Format("~/student/pixel.aspx?lid={0}&mid={1}&mcid={2}&editor=1", lid, mid, mcid);
        return "~/student/pixel.aspx?lid=" + lid + "&editor=1";
    }

    private bool IsPixelProgramTask(string fileType, string ltype, string msort, System.Text.StringBuilder debugLog)
    {
        string ft = string.IsNullOrEmpty(fileType) ? "" : fileType.Trim().ToLower();
        string lt = string.IsNullOrEmpty(ltype) ? "" : ltype.Trim();
        string ms = string.IsNullOrEmpty(msort) ? "" : msort.Trim();

        // 优先检查 mfiletype：如果明确是其他专属类型，则不是像素画
        // （防止 Mission.Msort=11 之类的脏数据把任务误判成 pixel.aspx）
        if (ft == "km" || ft == "mm" || ft == "mindmap" || ft == "kitymind")
        {
            AppendDebug(debugLog, "mfiletype={0} 明确是思维导图，非像素画\n", ft);
            return false;
        }
        if (ft == "xml")  // 流程图
        {
            AppendDebug(debugLog, "mfiletype=xml 明确是流程图，非像素画\n");
            return false;
        }
        if (ft == "py" || ft == "python" || ft == "pyw")
        {
            AppendDebug(debugLog, "mfiletype={0} 明确是 Python，非像素画\n", ft);
            return false;
        }
        if (ft == "html" || ft == "htm")
        {
            AppendDebug(debugLog, "mfiletype={0} 明确是 HTML，非像素画\n", ft);
            return false;
        }
        if (ft == "sb3" || ft == "sb2" || ft == "scratch")
        {
            AppendDebug(debugLog, "mfiletype={0} 明确是 Scratch，非像素画\n", ft);
            return false;
        }
        if (IsExcelLikeFileType(ft))
        {
            AppendDebug(debugLog, "mfiletype={0} 明确是表格，非像素画\n", ft);
            return false;
        }
        if (ft == "qrcode")
        {
            AppendDebug(debugLog, "mfiletype=qrcode 明确是二维码，非像素画\n");
            return false;
        }

        switch (lt)
        {
            case "5":
            case "Python":
            case "代码":
            case "仓库":
                AppendDebug(debugLog, "Ltype={0} 明确是 Python，非像素画\n", lt);
                return false;
        }

        if (IsPixelAddProgramSubtype(ms))
        {
            AppendDebug(debugLog, "通过 Msort={0} 判断为 pixeladd 像素画\n", ms);
            return true;
        }

        if (ft == "pxl")
        {
            AppendDebug(debugLog, "通过 fileType=pxl 判断为像素画\n");
            return true;
        }

        switch (lt)
        {
            case "8":
            case "像素":
            case "应用":
            case "拼图":
            case "绘图":
                AppendDebug(debugLog, "通过 Ltype={0} 判断为像素画\n", lt);
                return true;
            default:
                return false;
        }
    }

    private string ResolveStartCreateUrl(string lid, string fileType, System.Text.StringBuilder debugLog)
    {
        if (string.IsNullOrEmpty(lid)) lid = Request.QueryString["lid"] ?? "";
        AppendDebug(debugLog, "lid={0}, fileType={1}\n", lid, fileType);

        string url = "";

        // 优先顺序：URL msort 参数（最可靠）→ Context.Items → LabelMsort.Text → DB 查询
        string msortFirst = Request.QueryString["msort"] ?? "";
        if (string.IsNullOrEmpty(msortFirst))
            try { if (Context.Items["LidMsort"] != null) msortFirst = Context.Items["LidMsort"].ToString().Trim(); } catch { }
        if (string.IsNullOrEmpty(msortFirst)) msortFirst = LabelMsort.Text;
        if (string.IsNullOrEmpty(msortFirst))
        {
            string qsLid2 = Request.QueryString["lid"] ?? "";
            msortFirst = GetMsortForLid(!string.IsNullOrEmpty(qsLid2) ? qsLid2 : lid);
        }
        AppendDebug(debugLog, "msortFirst={0}\n", msortFirst);

        string ltype = "";
        try { ltype = LabelLtype.Text.Trim(); } catch { }
        AppendDebug(debugLog, "Ltype={0}\n", ltype);

        bool isBlockTask = IsBlockProgrammingTask(fileType, ltype, debugLog);
        if (isBlockTask)
        {
            url = "~/student/coding.aspx?lid=" + lid;
            AppendDebug(debugLog, "积木编程任务优先跳转到 coding.aspx，url={0}\n", url);
            return url;
        }

        bool isPythonTask = IsPythonTask(fileType, ltype, debugLog);
        if (isPythonTask)
        {
            url = GetProgramPythonUrl(lid);
            AppendDebug(debugLog, "Python 任务优先跳转到 python.aspx，url={0}\n", url);
            return url;
        }
        
        // Msort/Ltype 18-37 专属类型：先用 msortFirst（Mission.Msort/URL参数），再用 ltype（Listmenu.Ltype 更可靠）
        // 覆盖原单独的 36/37 分支，统一由 GetMsortSpecificUrl 处理
        if (!string.IsNullOrEmpty(msortFirst))
        {
            string msortSpecUrl = GetMsortSpecificUrl(msortFirst.Trim(), lid);
            if (!string.IsNullOrEmpty(msortSpecUrl))
            {
                AppendDebug(debugLog, "Msort={0} 专属类型，跳转到 {1}\n", msortFirst, msortSpecUrl);
                return msortSpecUrl;
            }
        }
        // msortFirst 不在 18-37，检查 ltype（Listmenu.Ltype 是更直接的任务类型来源）
        {
            int _ltypeRsvN;
            if (!string.IsNullOrEmpty(ltype) && int.TryParse(ltype, out _ltypeRsvN) && _ltypeRsvN >= 18 && _ltypeRsvN <= 37)
            {
                string _ltypeRsvUrl = GetMsortSpecificUrl(ltype, lid);
                if (!string.IsNullOrEmpty(_ltypeRsvUrl))
                {
                    AppendDebug(debugLog, "Ltype={0} 专属类型（Listmenu.Ltype），跳转到 {1}\n", ltype, _ltypeRsvUrl);
                    return _ltypeRsvUrl;
                }
            }
        }

        // 优先判断二维码任务
        bool isQRCodeTask = IsQRCodeTask(msortFirst, ltype, fileType, debugLog);
        if (isQRCodeTask)
        {
            url = GetQRCodeEditorUrl(lid);
            AppendDebug(debugLog, "二维码任务，强制跳转到 qrcode.aspx，url={0}\n", url);
            return url;
        }

        bool isPixelTask = IsPixelProgramTask(fileType, ltype, msortFirst, debugLog);

        if (isPixelTask)
        {
            url = GetPixelEditorUrl(lid);
            AppendDebug(debugLog, "像素画任务，强制跳转到 pixel.aspx，url={0}\n", url);
        }
        else if (IsExcelTask(lid, fileType))
        {
            url = "~/student/excel.aspx?lid=" + lid;
            AppendDebug(debugLog, "匹配到 Excel 任务，url={0}\n", url);
        }
        else if (!string.IsNullOrEmpty(fileType))
        {
            string ft = fileType.Trim().ToLower();
            AppendDebug(debugLog, "fileType (小写)={0}\n", ft);

            switch (ft)
            {
                case "py":
                case "python":
                case "pyw":
                    url = GetPythonEditorUrl(lid);
                    AppendDebug(debugLog, "匹配到 Python，url={0}\n", url);
                    break;
                case "sb3":
                case "sb2":
                case "scratch":
                    url = "~/student/coding.aspx?lid=" + lid;
                    AppendDebug(debugLog, "匹配到 Scratch，url={0}\n", url);
                    break;
                case "xml":
                    url = "~/student/mxgraph.aspx?lid=" + lid;
                    AppendDebug(debugLog, "匹配到 XML/流程图，url={0}\n", url);
                    break;
                case "pxl":
                    url = GetPixelEditorUrl(lid);
                    AppendDebug(debugLog, "匹配到像素画(备用分支)，url={0}\n", url);
                    break;
                case "html":
                case "htm":
                    url = "~/student/htmleditor.aspx?lid=" + lid;
                    AppendDebug(debugLog, "匹配到 HTML，url={0}\n", url);
                    break;
                case "km":
                case "mm":
                {
                    // 带完整参数，确保 kitymind.aspx 中 _calcId=mcid-mid-lid 计算正确，防止保存失败
                    string _km_mcid = "";
                    try { _km_mcid = LabelMcid.Text.Trim(); } catch { }
                    if (string.IsNullOrEmpty(_km_mcid)) _km_mcid = Request.QueryString["mcid"] ?? "";
                    string _km_mid = "";
                    try { _km_mid = LabelMid.Text.Trim(); } catch { }
                    if (!string.IsNullOrEmpty(_km_mid) && !string.IsNullOrEmpty(_km_mcid))
                        url = string.Format("~/student/kitymind.aspx?lid={0}&mid={1}&mcid={2}", lid, _km_mid, _km_mcid);
                    else if (!string.IsNullOrEmpty(_km_mcid))
                        url = string.Format("~/student/kitymind.aspx?lid={0}&mcid={1}", lid, _km_mcid);
                    else
                        url = "~/student/kitymind.aspx?lid=" + lid;
                    AppendDebug(debugLog, "匹配到思维导图，url={0}\n", url);
                    break;
                }
                default:
                    url = GetUrlByLtype(lid);
                    AppendDebug(debugLog, "未知文件类型，通过 Ltype 判断，url={0}\n", url);
                    break;
            }
        }
        else
        {
            url = GetUrlByLtype(lid);
            AppendDebug(debugLog, "文件类型为空，通过 Ltype 判断，url={0}\n", url);
        }

        if (string.IsNullOrEmpty(url))
        {
            url = "~/student/coding.aspx?lid=" + lid;
            AppendDebug(debugLog, "URL 为空，使用默认 coding 编辑器，url={0}\n", url);
        }

        AppendDebug(debugLog, "最终 URL={0}\n", url);
        return url;
    }

    private void GetStudentRoomInfo(out string snum, out string grade, out string cls, System.Text.StringBuilder debugLog)
    {
        snum = "";
        grade = "";
        cls = "";

        try
        {
            System.Web.HttpCookie sc = Request.Cookies[LearnSite.Common.CookieHelp.stuCookieNname];
            if (sc == null || string.IsNullOrEmpty(sc.Value)) return;

            string cookieVal = sc.Value;
            if (cookieVal.Contains("%"))
            {
                try { cookieVal = System.Web.HttpUtility.UrlDecode(cookieVal, System.Text.Encoding.UTF8); }
                catch { }
            }

            Type ct = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.Model.Cook");
            if (ct == null) return;

            object m = Activator.CreateInstance(ct);
            System.Reflection.MethodInfo mi = ct.GetMethod("ToModel",
                System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            if (mi != null) mi.Invoke(m, new object[] { cookieVal });

            System.Reflection.PropertyInfo pn = ct.GetProperty("Snum");
            System.Reflection.PropertyInfo pg = ct.GetProperty("Sgrade");
            System.Reflection.PropertyInfo pc = ct.GetProperty("Sclass");

            if (pn != null)
            {
                object v = pn.GetValue(m, null);
                if (v != null) snum = v.ToString();
            }
            if (pg != null)
            {
                object gv = pg.GetValue(m, null);
                if (gv != null) grade = gv.ToString();
            }
            if (pc != null)
            {
                object cv = pc.GetValue(m, null);
                if (cv != null) cls = cv.ToString();
            }
        }
        catch (Exception ex)
        {
            AppendDebug(debugLog, "获取学号/年级班级失败: {0}\n", ex.Message);
        }

        AppendDebug(debugLog, "snum={0}\n", snum);
        AppendDebug(debugLog, "grade={0}, class={1}\n", grade, cls);
    }

    private bool IsStartCreateAllowed(System.Text.StringBuilder debugLog)
    {
        string snum;
        string grade;
        string cls;
        GetStudentRoomInfo(out snum, out grade, out cls, debugLog);

        if (!string.IsNullOrEmpty(snum) && snum.ToLower().StartsWith("s"))
        {
            AppendDebug(debugLog, "学号以 s 开头，直接跳转\n");
            AppendDebug(debugLog, "allowed=True\n");
            return true;
        }

        bool allowed = false;
        try
        {
            Type roomType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.BLL.Room");
            if (roomType != null)
            {
                object room = Activator.CreateInstance(roomType);
                System.Reflection.MethodInfo isRs = roomType.GetMethod("IsRscratch",
                    System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance);
                if (isRs != null)
                {
                    object result = isRs.Invoke(room, new object[] { grade, cls });
                    if (result is bool) allowed = (bool)result;
                }
            }
            else
            {
                allowed = true;
                AppendDebug(debugLog, "找不到 Room 类型，默认允许跳转\n");
            }
        }
        catch (Exception ex)
        {
            allowed = true;
            AppendDebug(debugLog, "IsRscratch 检查失败，默认允许跳转: {0}\n", ex.Message);
        }

        AppendDebug(debugLog, "allowed={0}\n", allowed);
        return allowed;
    }
    /// <summary>
    /// 覆盖 DLL 中的 BtnScratch_Click：修复文件类型匹配（改为忽略大小写）
    /// 并增加对更多类型的兼容，解决点击"开始创作"后跳转回任务说明的问题。
    /// 增强版：添加详细的调试日志和错误处理，强制跳转
    /// </summary>
    protected new void BtnScratch_Click(object sender, EventArgs e)
    {
        System.Text.StringBuilder debugLog = new System.Text.StringBuilder("=== BtnScratch_Click 调试日志 ===\n");
        string lid = "";

        try
        {
            string fileType = LabelUploadType.Text;
            lid = LabelLid.Text;
            if (string.IsNullOrEmpty(lid)) lid = Request.QueryString["lid"] ?? "";

            string url = ResolveStartCreateUrl(lid, fileType, debugLog);
            bool allowed = IsStartCreateAllowed(debugLog);
            System.Diagnostics.Debug.WriteLine(debugLog.ToString());

            if (allowed)
            {
                Response.Redirect(url, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            else
            {
                string script = "alert('活动还未开始，请仔细听讲技术关键点！');";
                Page.ClientScript.RegisterStartupScript(this.GetType(), "ScratchAlert", script, true);
            }
        }
        catch (System.Threading.ThreadAbortException)
        {
            System.Diagnostics.Debug.WriteLine(debugLog.ToString() + "正常跳转\n");
        }
        catch (Exception ex)
        {
            debugLog.AppendFormat("发生异常: {0}\n堆栈: {1}\n", ex.Message, ex.StackTrace);
            System.Diagnostics.Debug.WriteLine(debugLog.ToString());

            string errorScript = string.Format("alert('跳转失败，请联系管理员。\\n错误信息：{0}');",
                Server.HtmlEncode(ex.Message).Replace("'", "\\'"));
            Page.ClientScript.RegisterStartupScript(this.GetType(), "ErrorAlert", errorScript, true);

            try
            {
                // 优先用 Msort 专属 URL 回退，避免硬编码跳回 coding.aspx
                string fbMsort = "";
                try { if (Context.Items["LidMsort"] != null) fbMsort = Context.Items["LidMsort"].ToString().Trim(); } catch { }
                if (string.IsNullOrEmpty(fbMsort)) fbMsort = LabelMsort.Text;
                string fallbackUrl;
                if (!string.IsNullOrEmpty(fbMsort))
                {
                    string fbSpecUrl = GetMsortSpecificUrl(fbMsort, lid);
                    fallbackUrl = !string.IsNullOrEmpty(fbSpecUrl) ? fbSpecUrl : ("~/student/coding.aspx?lid=" + lid);
                }
                else
                {
                    fallbackUrl = "~/student/coding.aspx?lid=" + (string.IsNullOrEmpty(lid) ? (Request.QueryString["lid"] ?? "") : lid);
                }
                System.Diagnostics.Debug.WriteLine("回退到: " + fallbackUrl);
                Response.Redirect(fallbackUrl, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex2)
            {
                System.Diagnostics.Debug.WriteLine("回退也失败: " + ex2.Message);
            }
        }
    }

    /// <summary>
    /// 根据 LabelLtype（任务类型）确定编辑器 URL。
    /// 当 Mfiletype 无法匹配时作为回退方案。
    /// </summary>
    private string GetUrlByLtype(string lid)
    {
        string msortG = Request.QueryString["msort"] ?? "";
        if (string.IsNullOrEmpty(msortG))
            try { if (Context.Items["LidMsort"] != null) msortG = Context.Items["LidMsort"].ToString().Trim(); } catch { }
        if (string.IsNullOrEmpty(msortG)) msortG = LabelMsort.Text;
        if (string.IsNullOrEmpty(msortG)) msortG = GetMsortForLid(lid);
        if (IsPythonTask(LabelUploadType.Text, LabelLtype.Text, null))
            return GetProgramPythonUrl(lid);
        if (IsPixelAddProgramSubtype(msortG))
            return GetPixelEditorUrl(lid);
        // Msort 18-35 专属类型备用路由（当 fileType 为空时走此分支）
        if (!string.IsNullOrEmpty(msortG))
        {
            string msSpcUrl = GetMsortSpecificUrl(msortG, lid);
            if (!string.IsNullOrEmpty(msSpcUrl))
                return msSpcUrl;
        }
        if (IsExcelTask(lid, LabelUploadType.Text))
            return "~/student/excel.aspx?lid=" + lid;
        string ltype = "";
        try { ltype = LabelLtype.Text.Trim(); } catch { }

        // 将中文类型名归一化为数字
        ltype = NormalizeProgramLtypeValue(ltype);

        switch (ltype)
        {
            case "36":  // 素材库
                return "~/student/ware.aspx?lid=" + lid;
            case "37":  // 网站设计
                return "~/student/website.aspx?lid=" + lid;
            case "17":  // 二维码任务（安全网：防止 msort/fileType 检测均漏判时落到此处）
                return GetQRCodeEditorUrl(lid);
            case "13": case "讨论":  // 讨论类型跳转到 topicdiscuss.aspx
            {
                string cid = "";
                try { cid = LabelMcid.Text; } catch { }
                if (string.IsNullOrEmpty(cid)) cid = Request.QueryString["mcid"] ?? "";
                return !string.IsNullOrEmpty(cid)
                    ? "~/student/topicdiscuss.aspx?lid=" + lid + "&cid=" + cid
                    : "~/student/topicdiscuss.aspx?lid=" + lid;
            }
            case "10":  // 导图/脑图 → 带完整参数，确保 kitymind.aspx 中 _calcId=mcid-mid-lid 计算正确
            {
                string _kl_mcid = "";
                try { _kl_mcid = LabelMcid.Text.Trim(); } catch { }
                if (string.IsNullOrEmpty(_kl_mcid)) _kl_mcid = Request.QueryString["mcid"] ?? "";
                string _kl_mid = "";
                try { _kl_mid = LabelMid.Text.Trim(); } catch { }
                if (!string.IsNullOrEmpty(_kl_mid) && !string.IsNullOrEmpty(_kl_mcid))
                    return string.Format("~/student/kitymind.aspx?lid={0}&mid={1}&mcid={2}", lid, _kl_mid, _kl_mcid);
                if (!string.IsNullOrEmpty(_kl_mcid))
                    return string.Format("~/student/kitymind.aspx?lid={0}&mcid={1}", lid, _kl_mcid);
                return "~/student/kitymind.aspx?lid=" + lid;
            }
            case "4":   // 积木编程
                return "~/student/coding.aspx?lid=" + lid;
            case "5":   // Python
                return GetProgramPythonUrl(lid);
            case "7":   // 流程图
                return "~/student/mxgraph.aspx?lid=" + lid;
            case "8":   // 像素/应用 - 所有像素画任务都跳转到 pixel.aspx
                return GetPixelEditorUrl(lid);
            case "9":   // Html
                return "~/student/htmleditor.aspx?lid=" + lid;
            case "11":  // 表格
                return "~/student/excel.aspx?lid=" + lid;
            case "12":  // 课件
                return "~/student/pptist.aspx?lid=" + lid;
            default:    // 默认 coding 编辑器
                return "~/student/coding.aspx?lid=" + lid;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" Runat="Server">
<link href="../kindeditor/themes/me/me.css" rel="stylesheet" type="text/css" />
<script charset="utf-8" src="../kindeditor/kindeditor-min.js" type="text/javascript"></script>
<script charset="utf-8" src="../kindeditor/lang/zh_CN.js" type="text/javascript"></script>
<style type="text/css">
    body:has(.program-page) .stu,
    body:has(.program-page) .studmasterhead,
    body:has(.program-page) .placeauto {
        width: 100% !important;
        max-width: none !important;
        margin-left: 0 !important;
        margin-right: 0 !important;
    }
    body:has(.program-page) .placeauto {
        padding-left: 0 !important;
        padding-right: 0 !important;
        width: calc(100vw - 180px) !important;
        margin: 0 !important;
    }
    body:has(.program-page) center,
    body:has(.program-page) .stu > center {
        width: 100% !important;
        max-width: none !important;
        margin: 0 !important;
        padding: 0 !important;
        text-align: left !important;
    }
    body:has(.program-page) .stu {
        margin: 0 !important;
        padding: 0 !important;
    }
    body:has(.program-page) .studmasterhead {
        margin-left: 0 !important;
        padding-left: 0 !important;
    }
    body:has(.program-page) {
        padding-left: 196px !important;
    }
    /* 页面基础容器 */
    .program-page {
        max-width: 1720px;
        width: calc(100vw - 220px);
        max-width: calc(100vw - 220px);
        margin: 0 !important;
        padding: 30px 24px 60px 8px;
        color: #334155;
        font-family: "Segoe UI", "Microsoft YaHei", sans-serif;
    }

    /* 布局容器：Flexbox 双栏 */
    .program-shell {
        display: flex;
        gap: 16px;
        align-items: flex-start;
    }

    /* 主内容区 */
    .program-main {
        flex: 0 1 calc(100% - 400px);
        min-width: 0; /* 防止内容溢出 */
    }

    /* 侧边栏 */
    .program-side {
        width: 400px;
        flex-shrink: 0;
    }

    /* 卡片通用样式 */
    .program-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 24px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
        overflow: hidden;
        transition: box-shadow 0.3s ease;
    }
    
    .program-card:hover {
        box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05), 0 4px 6px -2px rgba(0, 0, 0, 0.025);
    }

    /* 任务头部 Hero 区域 */
    .program-hero {
        padding: 40px 48px;
        background: linear-gradient(120deg, #f0f9ff 0%, #e0f2fe 100%);
        border-bottom: 1px solid #e0f2fe;
        position: relative;
        overflow: hidden;
    }
    
    /* 装饰背景图形 */
    .program-hero::before {
        content: "";
        position: absolute;
        top: -50px;
        right: -50px;
        width: 200px;
        height: 200px;
        background: rgba(59, 130, 246, 0.05);
        border-radius: 50%;
        z-index: 0;
    }

    .program-tag-badge {
        display: inline-flex;
        align-items: center;
        padding: 6px 16px;
        margin-bottom: 16px;
        background: #ffffff;
        color: #0284c7;
        font-size: 13px;
        font-weight: 700;
        border-radius: 99px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        position: relative;
        z-index: 1;
    }

    .program-title {
        margin: 0;
        font-size: 32px;
        line-height: 1.3;
        color: #0f172a;
        font-weight: 800;
        position: relative;
        z-index: 1;
        letter-spacing: -0.02em;
    }

    .program-subtitle {
        margin-top: 16px;
        font-size: 15px;
        line-height: 1.6;
        color: #475569;
        max-width: 800px;
        position: relative;
        z-index: 1;
    }

    /* 内容区域 */
    .program-content-wrap {
        padding: 48px;
        background: #fff;
    }

    .program-content {
        min-height: 400px;
        font-size: 16px;
        line-height: 1.8;
        color: #334155;
    }
    
    /* 内容区元素样式增强 */
    .program-content h1, .program-content h2, .program-content h3 { color: #1e293b; font-weight: 700; margin-top: 1.5em; margin-bottom: 0.8em; }
    .program-content p { margin-bottom: 1.2em; }
    .program-content img { max-width: 100%; height: auto; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin: 12px 0; }
    .program-content pre { background: #f1f5f9; padding: 16px; border-radius: 12px; overflow-x: auto; }
    .program-content blockquote { border-left: 4px solid #3b82f6; padding-left: 16px; color: #475569; font-style: italic; background: #f8fafc; padding: 12px 16px; border-radius: 0 8px 8px 0; }

    /* 侧边栏卡片 */
    .program-side-card {
        padding: 32px;
        position: sticky;
        top: 24px;
    }

    .program-side-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid #f1f5f9;
    }

    .program-side-title {
        margin: 0;
        font-size: 18px;
        color: #0f172a;
        font-weight: 700;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .program-side-title::before {
        content: "";
        display: block;
        width: 4px;
        height: 18px;
        background: #3b82f6;
        border-radius: 2px;
    }

    /* 预览区美化 */
    .program-preview-box {
        background: #fff;
        border-radius: 16px;
        padding: 16px;
        text-align: center;
        display: flex;
        flex-direction: column;
        align-items: center;
        margin-bottom: 24px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
    }
    
    .program-preview-box:hover {
        border-color: #3b82f6;
        box-shadow: 0 10px 15px -3px rgba(59, 130, 246, 0.1);
        transform: translateY(-2px);
    }

    .program-preview-image-wrap {
        background: #f8fafc;
        border-radius: 12px;
        overflow: hidden;
        position: relative;
        width: 100%;
        margin: 0 auto;
        min-height: 190px;
        aspect-ratio: 16 / 9;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 1px dashed #cbd5e1;
    }

    /* 默认占位符图标 (当没有图片时) */
    .program-preview-image-wrap::before {
        content: "\f03e"; /* FontAwesome image icon */
        font-family: FontAwesome;
        font-size: 48px;
        color: #cbd5e1;
        position: absolute;
        left: 50%;
        top: 50%;
        transform: translate(-50%, -50%);
        z-index: 0;
    }

    .program-preview-box img {
        position: relative;
        z-index: 1;
        width: 100%;
        height: 100%;
        display: block;
        object-fit: contain;
        padding: 10px;
        box-sizing: border-box;
        transition: transform 0.5s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .program-preview-box:hover img {
        transform: scale(1.05);
    }

    .program-work-title {
        display: block;
        width: 100%;
        margin-top: 14px;
        font-size: 15px;
        color: #1e293b;
        font-weight: 700;
        line-height: 1.4;
        padding: 0 4px;
    }
    
    .program-work-title:empty::after {
        content: "暂无作品标题";
        color: #94a3b8;
        font-weight: normal;
        font-size: 13px;
        font-style: italic;
    }

    /* 按钮组 */
    .program-actions {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }

    /* 按钮容器 - 用于处理 asp:Button 的图标定位 */
    .program-btn-wrap {
        position: relative;
        width: 100%;
        display: block;
    }

    .program-btn-icon-overlay {
        position: absolute;
        left: 20px;
        top: 50%;
        transform: translateY(-50%);
        z-index: 5;
        font-size: 16px;
        pointer-events: none;
    }

    /* 开关按钮 */
    .program-btn-toggle {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        color: #475569;
        font-size: 14px;
        padding: 10px 20px;
    }
    .program-btn-toggle:hover {
        background: #f1f5f9;
        color: #334155;
        border-color: #cbd5e1;
    }

    /* 通用按钮样式 */
    .program-btn {
        display: inline-flex;
        justify-content: center;
        align-items: center;
        gap: 8px;
        width: 100%;
        padding: 12px 20px;
        font-size: 15px;
        font-weight: 600;
        border-radius: 12px;
        cursor: pointer;
        transition: all 0.2s ease;
        text-decoration: none !important;
        box-sizing: border-box;
        border: none;
        outline: none;
        font-family: inherit;
        line-height: 1.5;
    }

    /* 主操作按钮 */
    .program-btn-primary-wrap input.program-btn {
        padding-left: 44px;
    }
    .program-btn-primary {
        background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
        color: #ffffff;
        box-shadow: 0 4px 10px rgba(37, 99, 235, 0.25);
    }
    .program-btn-primary:hover {
        background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
        transform: translateY(-1px);
        box-shadow: 0 6px 14px rgba(37, 99, 235, 0.35);
    }
    .program-btn-primary-wrap .program-btn-icon-overlay { color: #fff; }

    /* 次要按钮 */
    .program-btn-secondary {
        background: #ffffff;
        border: 1px solid #cbd5e1;
        color: #475569;
    }
    .program-btn-secondary:hover {
        background: #f8fafc;
        border-color: #94a3b8;
        color: #334155;
    }
    .program-btn-secondary-wrap .program-btn-icon-overlay { color: #64748b; }

    /* 网盘按钮 */
    .program-btn-disk {
        background: #f0fdf4;
        border: 1px solid #bbf7d0;
        color: #166534;
    }
    .program-btn-disk:hover {
        background: #dcfce7;
        color: #15803d;
        border-color: #86efac;
    }

    /* 链接样式按钮 */
    .program-btn-link {
        background: #fff7ed;
        border: 1px solid #ffedd5;
        color: #c2410c;
    }
    .program-btn-link:hover {
        background: #ffedd5;
        color: #9a3412;
        border-color: #fed7aa;
    }

    /* 清除按钮 */
    .program-btn-danger {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        color: #ef4444;
        font-size: 14px;
        padding: 10px 20px;
    }
    .program-btn-danger:hover {
        background: #fef2f2;
        color: #dc2626;
        border-color: #fca5a5;
    }

    /* 状态提示信息 */
    .program-status-area {
        margin-top: 24px;
        text-align: center;
    }

    .program-note {
        display: block;
        font-size: 13px;
        color: #64748b;
        margin: 12px 0;
        padding: 8px;
        background: #f1f5f9;
        border-radius: 8px;
    }
    
    .program-note:empty {
        display: none;
    }

    .program-message {
        display: block;
        margin-top: 16px;
        padding: 12px;
        background: #fefce8;
        border: 1px solid #fde047;
        border-radius: 8px;
        color: #a16207;
        font-size: 14px;
        font-weight: 500;
    }
    
    .program-message:empty {
        display: none;
    }

    .program-pass-badge {
        margin-top: 16px;
        width: 80px;
        height: auto;
        opacity: 0;
        animation: stampIn 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
    }

    @keyframes stampIn {
        from { opacity: 0; transform: scale(3) rotate(-15deg); }
        to { opacity: 1; transform: scale(1) rotate(0deg); }
    }

    /* 响应式适配 */
    @media (max-width: 900px) {
        .program-shell {
            flex-direction: column;
        }
        .program-side {
            width: 100%;
            position: static;
        }
        .program-hero {
            padding: 32px 24px;
        }
        .program-content-wrap {
            padding: 24px;
        }
    }
</style>

<div class="program-page">
    <!-- 隐藏的数据控件 (功能必需) -->
    <div style="display:none;">
        <asp:Label ID="LabelSnum" runat="server"></asp:Label>
        <asp:Label ID="LabelMid" runat="server"></asp:Label>
        <asp:Label ID="LabelUploadType" runat="server"></asp:Label>
        <asp:Label ID="LabelMcid" runat="server"></asp:Label>
        <asp:Label ID="LabelMsort" runat="server"></asp:Label>
        <asp:CheckBox ID="CheckBack" runat="server" />
        <asp:CheckBox ID="CheckBlock" runat="server" />
        <asp:CheckBox ID="CheckBlockpy" runat="server" />
        <asp:Label ID="LabelLid" runat="server"></asp:Label>
        <asp:Label ID="LabelLtype" runat="server"></asp:Label>
        <asp:HiddenField ID="HdStartCreateUrl" runat="server" />
        <asp:HiddenField ID="HdStartCreateAllowed" runat="server" />
        <asp:HiddenField ID="HdStartCreateMessage" runat="server" />
    </div>

    <div class="program-shell">
        <!-- 左侧：主要内容区 -->
        <main class="program-main">
            <div class="program-card">
                <div class="program-hero">
                    <div class="program-tag-badge"><i class="fa fa-tasks" style="margin-right:6px;"></i> 学习任务</div>
                    <h1 class="program-title"><asp:Label ID="LabelMtitle" runat="server"></asp:Label></h1>
                    <div class="program-subtitle">
                        请仔细阅读下方的任务说明，完成后点击右侧按钮提交您的作品。
                    </div>
                </div>
                
                <div class="program-content-wrap">
                    <div id="Mcontent" class="program-content" runat="server"></div>
                </div>
            </div>
        </main>

        <!-- 右侧：操作面板 -->
        <aside class="program-side">
            <div class="program-card program-side-card">
                <div class="program-side-header">
                    <h3 class="program-side-title">我的作品</h3>
                </div>

                <div class="program-preview-box">
                    <div class="program-preview-image-wrap">
                        <asp:Image ID="Thumbnail" runat="server" ToolTip="作品预览图" />
                    </div>
                    <div id="pixelsmall" runat="server" style="display:none;"></div>
                    <asp:Label ID="Wtitle" runat="server" CssClass="program-work-title"></asp:Label>
                </div>

                <div class="program-actions">
                    <!-- 核心操作：开始创作 -->
                    <div class="program-btn-wrap program-btn-primary-wrap">
                        <i class="fa fa-rocket program-btn-icon-overlay"></i>
                        <asp:HyperLink ID="LinkStartCreate" runat="server" CssClass="program-btn program-btn-primary" 
                            NavigateUrl="#" onclick="return handleStartCreate();"
                            style="text-decoration:none !important; display:inline-flex; justify-content:center; align-items:center; gap:8px;">
                            开始创作
                        </asp:HyperLink>
                        <asp:Button ID="BtnScratch" runat="server" style="display:none;" OnClick="BtnScratch_Click" />
                    </div>
                    
                    <asp:Label ID="Labelscratch" runat="server" CssClass="program-note"></asp:Label>

                    <!-- 辅助操作 -->
                    <button type="button" class="program-btn program-btn-disk" onclick="showShare()">
                        <i class="fa fa-folder-open"></i> 我的网盘
                    </button>
                    
                    <asp:HyperLink ID="VoteLink" runat="server" Target="_blank" CssClass="program-btn program-btn-link">
                        <i class="fa fa-thumbs-up"></i> 作品互评
                    </asp:HyperLink>

                    <!-- 开关指令 -->
                    <asp:Button ID="BtnBegin" runat="server" CssClass="program-btn program-btn-toggle" 
                        onclick="BtnBegin_Click" Text="⚡ 开关指令" />

                    <!-- 清除提交 -->
                    <asp:Button ID="ButtonClear" runat="server" CssClass="program-btn program-btn-danger" 
                        onclick="ButtonClear_Click" Text="✖ 清除提交" 
                        OnClientClick="return confirm('确定要清除已提交的作品吗？此操作不可恢复！');" />
                </div>

                <div class="program-status-area">
                    <asp:Label ID="Labelmsg" runat="server" CssClass="program-message"></asp:Label>
                    <asp:Image ID="ImagePass" CssClass="program-pass-badge" runat="server" ImageUrl="~/images/sucessed.png" Visible="False" />
                </div>
            </div>
        </aside>
    </div>
</div>

<script type="text/javascript">
function getStartCreateFieldValue(clientId) {
    var el = document.getElementById(clientId);
    return el ? (el.value || el.getAttribute('value') || '') : '';
}

function handleStartCreate() {
    console.log('=== 开始创作按钮点击（增强版本）===');

    try {
        var url = getStartCreateFieldValue('<%= HdStartCreateUrl.ClientID %>');
        var allowed = getStartCreateFieldValue('<%= HdStartCreateAllowed.ClientID %>');
        var message = getStartCreateFieldValue('<%= HdStartCreateMessage.ClientID %>') || '活动还未开始，请仔细听讲技术关键点！';

        console.log('预计算跳转URL（原始）:', url);
        console.log('允许开始创作:', allowed);
        console.log('提示消息:', message);

        if (allowed !== '1') {
            alert(message);
            console.log('不允许开始创作，已显示提示');
            return false;
        }

        if (!url) {
            console.error('❌ URL为空，无法跳转！');
            alert('跳转地址未生成，请刷新页面重试或联系管理员。');
            return false;
        }

        // 解码 HTML 实体（&amp; → &）
        var tempDiv = document.createElement('div');
        tempDiv.innerHTML = url;
        url = tempDiv.textContent || tempDiv.innerText || url;
        
        console.log('✓ 解码后的URL:', url);
        console.log('✓ 准备跳转到:', url);
        
        // 使用多种方法尝试跳转，确保至少一种能成功
        console.log('✓ 方法1: window.location.href');
        window.location.href = url;
        
        // 备用方法：延迟后再次尝试
        setTimeout(function() {
            console.log('✓ 方法2: window.location.assign (延迟100ms)');
            window.location.assign(url);
        }, 100);
        
        // 第三种备用方法
        setTimeout(function() {
            console.log('✓ 方法3: window.location.replace (延迟200ms)');
            window.location.replace(url);
        }, 200);
        
        // 最后的备用方法：使用 <a> 标签模拟点击
        setTimeout(function() {
            console.log('✓ 方法4: 创建隐藏链接并点击 (延迟300ms)');
            var link = document.createElement('a');
            link.href = url;
            link.style.display = 'none';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }, 300);
        
        return false;
    } catch (ex) {
        console.error('❌ 客户端跳转失败:', ex);
        alert('跳转失败：' + ex.message);
        return false;
    }
}

window.addEventListener('DOMContentLoaded', function() {
    console.log('=== 页面加载完成（服务器端链接版本）===');
    console.log('当前URL:', window.location.href);
    
    // 查找链接元素
    var link = document.querySelector('a[id*="LinkStartCreate"]');
    if (link) {
        console.log('✓ 找到开始创作链接');
        console.log('  链接 href:', link.href);
        console.log('  链接文本:', link.textContent);
        
        // 检查 href 是否正确设置
        if (link.href && link.href !== '#' && link.href.indexOf('javascript:') === -1) {
            console.log('✓ 链接 URL 已正确设置，点击即可跳转');
        } else {
            console.error('✗ 链接 URL 未正确设置:', link.href);
        }
    } else {
        console.error('✗ 未找到开始创作链接');
    }
    
    // 验证隐藏字段
    var hdUrl = document.getElementById('<%= HdStartCreateUrl.ClientID %>');
    var hdAllowed = document.getElementById('<%= HdStartCreateAllowed.ClientID %>');
    
    if (hdUrl) {
        console.log('✓ HdStartCreateUrl 字段存在，值:', hdUrl.value);
    }
    
    if (hdAllowed) {
        console.log('✓ HdStartCreateAllowed 字段存在，值:', hdAllowed.value);
    }
});
</script>

</asp:Content>
