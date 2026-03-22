#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\student\taskredirect.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "8BD9B8C84478D20602A20A134E41CFEC"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\student\taskredirect.ashx"


using System;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;
using System.Reflection;

public class TaskRedirect : IHttpHandler 
{
    private bool IsPixelAddProgramSubtype(string msort)
    {
        if (string.IsNullOrEmpty(msort)) return false;
        switch (msort.Trim())
        {
            case "11": // 像素画
                return true;
            case "36": // 素材库 → ware.aspx
            case "37": // 网站设计 → website.aspx
            case "17": // 二维码任务 → program.aspx
            default:
                return false;
        }
    }
    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                FieldInfo connField = dbType.GetField("connectionString",
                    BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);
                if (connField != null)
                {
                    cs = connField.GetValue(null) as string;
                }
            }
        }
        catch { }

        if (string.IsNullOrEmpty(cs))
        {
            try { cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; }
            catch { }
        }
        return cs;
    }
    public void ProcessRequest(HttpContext context)
    {
        string lid = context.Request.QueryString["lid"];
        string mid = context.Request.QueryString["mid"];
        string cid = context.Request.QueryString["mcid"];
        bool debugMode = string.Equals(context.Request.QueryString["debug"], "1", StringComparison.Ordinal);
        
        if (string.IsNullOrEmpty(lid))
        {
            if (!string.IsNullOrEmpty(cid))
                context.Response.Redirect("showcourse.aspx?cid=" + cid);
            else
                context.Response.Redirect("myinfo.aspx");
            return;
        }
        
        try
        {
            // 查询任务类型
            string connStr = GetConnStr();
            if (string.IsNullOrEmpty(connStr))
            {
                if (!string.IsNullOrEmpty(cid))
                    context.Response.Redirect("showcourse.aspx?cid=" + cid);
                else
                    context.Response.Redirect("myinfo.aspx");
                return;
            }
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = "SELECT L.Ltype, L.Lxid, L.Lcid, M.Msort, M.Mfiletype FROM Listmenu L LEFT JOIN Mission M ON L.Lxid=M.Mid WHERE L.Lid=@lid";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@lid", lid);
                    string ltype = "0";
                    int lxid = 0;
                    int lcid = 0;
                    string msort = "";
                    string mfiletype = "";
                    bool found = false;
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            found = true;
                            ltype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString().Trim() : "0";
                            lxid = reader["Lxid"] != DBNull.Value ? Convert.ToInt32(reader["Lxid"]) : 0;
                            lcid = reader["Lcid"] != DBNull.Value ? Convert.ToInt32(reader["Lcid"]) : 0;
                            msort = reader["Msort"] != DBNull.Value ? reader["Msort"].ToString().Trim() : "";
                            mfiletype = reader["Mfiletype"] != DBNull.Value ? reader["Mfiletype"].ToString().Trim().ToLower() : "";
                        }
                    } // reader 已关闭
                    if (found)
                    {
                            // 如果URL中没有提供cid，使用数据库中的Lcid
                            if (string.IsNullOrEmpty(cid) && lcid > 0)
                            {
                                cid = lcid.ToString();
                            }
                            
                            // 先归一化，再按真实数据纠偏（处理Listmenu类型配置错误）
                            ltype = CorrectLtypeByData(conn, ltype, lxid, lcid, Convert.ToInt32(lid));
                            
                            // 使用主查询中已读取的 Mission.Mfiletype 进一步纠偏
                            // （进一步处理 Listmenu.Ltype 与实际任务类型不匹配的情况，如 Ltype="填表" 但 Mfiletype="sheet"）
                            if (!string.IsNullOrEmpty(mfiletype))
                            {
                                if (mfiletype == "km" || mfiletype == "mm" || mfiletype == "mindmap" || mfiletype == "kitymind")
                                    ltype = "10";
                                else if (mfiletype == "ware")
                                    ltype = "12";
                                else if (mfiletype == "xls" || mfiletype == "xlsx" || mfiletype == "et" || mfiletype == "ett" ||
                                         mfiletype == "csv" || mfiletype == "excel" || mfiletype == "sheet" || mfiletype == "luckysheet")
                                    ltype = "11";
                            }
                            
                            // 特殊处理：二维码任务（Msort=17）必须跳转到 program.aspx
                            if (msort == "17")
                            {
                                ltype = "17";  // 设置为特殊的类型标识
                            }
                            else if (msort == "36") // 素材库任务
                            {
                                ltype = "36";
                            }
                            else if (msort == "37") // 网站设计任务
                            {
                                ltype = "37";
                            }
                            else
                            {
                                int _msortNum;
                                if (int.TryParse(msort, out _msortNum) && _msortNum >= 18 && _msortNum <= 35)
                                    ltype = msort; // 在线文档/演示文稿等专属类型，强制 ltype = msort 匹配 switch 分支
                                else if (IsPixelAddProgramSubtype(msort) &&
                                    !(ltype == "11" &&
                                      (mfiletype == "xls" || mfiletype == "xlsx" || mfiletype == "et" || mfiletype == "ett" ||
                                       mfiletype == "csv" || mfiletype == "excel" || mfiletype == "sheet" || mfiletype == "luckysheet")))
                                    ltype = "8";
                            }
                            
                            // 根据类型重定向到不同页面
                            string targetUrl = "";
                            string routeSource = "TaskRedirect:switch(ltype)";
                            switch (ltype)
                            {
                                case "1": // 活动
                                case "2": // 主题
                                case "3": // 练习
                                    targetUrl = string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, cid);
                                    break;
                                    
                                case "4": // 积木编程
                                    targetUrl = string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, cid);
                                    break;
                                    
                                case "5": // Python
                                case "7": // 流程图
                                case "8": // 应用
                                case "9": // Html
                                case "10": // 导图
                                    targetUrl = string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, cid);
                                    break;
                                
                                case "11": // 表格：直接跳转到 excel.aspx
                                    targetUrl = string.Format("excel.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, cid);
                                    break;
                                
                                case "12": // 课件 → ware.aspx
                                    targetUrl = string.Format("ware.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, cid);
                                    break;
                                
                                case "6": // 测评
                                    targetUrl = string.Format("console.aspx?lid={0}", lid);
                                    break;
                                    
                                case "13": // 讨论
                                    targetUrl = string.Format("topicdiscuss.aspx?lid={0}&cid={1}", lid, cid);
                                    break;
                                    
                                case "14": // 调查问卷
                                    targetUrl = string.Format("surveyshow.aspx?sid={0}&cid={1}", lxid, cid);
                                    break;
                                    
                                case "15": // 填表
                                    targetUrl = string.Format("txtform.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, cid);
                                    break;
                                    
                                case "17": // 二维码任务
                                    targetUrl = string.Format("program.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, cid);
                                    routeSource = "TaskRedirect:QRCode(msort=17)";
                                    break;
                                
                                // Msort 18-37 专属任务类型（在线文档/演示文稿/素材库/网站设计等）
                                // 全部先到 program.aspx 看任务说明，点「开始创作」再跳专属编辑器
                                case "18": case "19": case "20": case "21": case "22":
                                case "23": case "24": case "25": case "26": case "27":
                                case "28": case "29": case "30": case "31": case "32":
                                case "33": case "34": case "35": case "36": case "37":
                                    targetUrl = string.Format("program.aspx?lid={0}&mid={1}&mcid={2}&msort={3}", lid, lxid, cid, ltype);
                                    routeSource = "TaskRedirect:program(msort18-37)";
                                    break;
                                    
                                default: // 默认
                                    targetUrl = string.Format("showmission.aspx?lid={0}&mid={1}&mcid={2}", lid, lxid, cid);
                                    break;
                            }
                            if (debugMode)
                            {
                                context.Response.ContentType = "text/html; charset=utf-8";
                                context.Response.Write("<div style='font-family:Segoe UI,Microsoft YaHei,Arial;padding:12px;border:1px solid #f59e0b;background:#fffbeb;color:#92400e;border-radius:8px;line-height:1.7;'>");
                                context.Response.Write("<div style='font-weight:700;margin-bottom:6px;'>TaskRedirect 调试信息（未自动跳转）</div>");
                                context.Response.Write("routeSource=" + HttpUtility.HtmlEncode(routeSource) + "<br/>");
                                context.Response.Write("lid=" + HttpUtility.HtmlEncode(lid ?? "") + "<br/>");
                                context.Response.Write("mid(req)=" + HttpUtility.HtmlEncode(mid ?? "") + "<br/>");
                                context.Response.Write("mcid=" + HttpUtility.HtmlEncode(cid ?? "") + "<br/>");
                                context.Response.Write("lxid(db)=" + HttpUtility.HtmlEncode(lxid.ToString()) + "<br/>");
                                context.Response.Write("ltype(final)=" + HttpUtility.HtmlEncode(ltype ?? "") + "<br/>");
                                context.Response.Write("target=" + HttpUtility.HtmlEncode(targetUrl) + "<br/>");
                                context.Response.Write("</div>");
                                return;
                            }
                            context.Response.Redirect(targetUrl);
                    }
                    else
                    {
                        // 未找到记录，返回课程页面
                        if (!string.IsNullOrEmpty(cid))
                            context.Response.Redirect("showcourse.aspx?cid=" + cid);
                        else
                            context.Response.Redirect("myinfo.aspx");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // 出错时返回课程页面或首页
            context.Response.Write("错误: " + ex.Message);
            if (!string.IsNullOrEmpty(cid))
                context.Response.Write("<br/><a href='showcourse.aspx?cid=" + cid + "'>返回课程</a>");
            else
                context.Response.Write("<br/><a href='myinfo.aspx'>返回首页</a>");
        }
    }
    
    public bool IsReusable 
    { 
        get { return false; } 
    }
    
    // 将中文类型名称统一转换为数字编码
    private string NormalizeLtype(string ltype)
    {
        if (string.IsNullOrEmpty(ltype)) return "0";
        ltype = ltype.Trim();
        switch (ltype)
        {
            case "活动": return "1";
            case "主题": return "2";
            case "练习": return "3";
            case "积木": case "积木编程": return "4";
            case "Python": return "5";
            case "测评": return "6";
            case "流程": case "流程图": return "7";
            case "应用": case "像素": case "拼图": return "8";
            case "Html": case "网页": return "9";
            case "导图": case "脑图": return "10";
            case "表格": return "11";
            case "课件": return "12";
            case "讨论": return "13";
            case "调查":
            case "调查问卷": return "14";
            case "填表": return "15";
            case "绘图": return "8";
            case "仓库": case "代码": return "5";
            default: return ltype;
        }
    }
    
    // 已确认的Listmenu类型配置错误覆盖表（同Mission表的不同子类型无法自动识别）
    private string ApplyKnownLtypeOverrides(string normalized, int lid, int lcid)
    {
        if (lid == 111 && lcid == 16) return "8";
        if (lid == 40 && lcid == 9) return "7"; // 流程图，非导图
        if (lid == 41 && lcid == 9) return "5"; // Python，非像素
        if (lid == 46 && lcid == 10) return "4"; // Scratch积木编程
        if (lid == 53 && lcid == 11) return "4"; // Scratch积木编程
        if (lid == 58 && lcid == 12) return "4"; // Scratch积木编程
        if (lid == 47 && lcid == 9) return "6"; // 测评，非Html
        if (lid == 48 && lcid == 9) return "8"; // 像素，非表格
        if (lid == 49 && lcid == 9) return "9"; // Html，非课件
        // if (lid == 61 && lcid == 12) return "7"; // 撤销错误硬编码
        if (lid == 85 && lcid == 12) return "10"; // 导图，禁止误判为填表
        return normalized;
    }
    
    private string CorrectLtypeByData(SqlConnection conn, string ltype, int lxid, int lcid, int lid)
    {
        string normalized = NormalizeLtype(ltype);
        normalized = ApplyKnownLtypeOverrides(normalized, lid, lcid);
        try
        {
            using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 Mfiletype FROM Mission WHERE Mid=@Mid", conn))
            {
                cmd.Parameters.AddWithValue("@Mid", lxid);
                object obj = cmd.ExecuteScalar();
                string mfiletype = obj != null && obj != DBNull.Value ? obj.ToString().Trim().ToLower() : "";
                if (mfiletype == "km" || mfiletype == "mm" || mfiletype == "mindmap" || mfiletype == "kitymind")
                    return "10";
                if (mfiletype == "ware")  // 课件任务：Mission.Mfiletype = "ware"
                    return "12";
            }
        }
        catch { }
        // 对 Ltype 1-9 的任务做纠偏：涵盖 1-3（普通）及 4-9（各类编程类）
        // 避免 Listmenu.Ltype 错误配置时（如实际填表任务被标为积木类型4）路由错误
        int nType;
        if (int.TryParse(normalized, out nType) && nType >= 1 && nType <= 9)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 1 FROM SurveyQuestion WHERE Qvid=@Qvid AND Qcid=@Lcid", conn))
                {
                    cmd.Parameters.AddWithValue("@Qvid", lxid);
                    cmd.Parameters.AddWithValue("@Lcid", lcid);
                    object obj = cmd.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                        return "14";
                }
            }
            catch { }
            
            try
            {
                using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 1 FROM TopicDiscuss WHERE Tid=@Tid AND Tcid=@Lcid", conn))
                {
                    cmd.Parameters.AddWithValue("@Tid", lxid);
                    cmd.Parameters.AddWithValue("@Lcid", lcid);
                    object obj = cmd.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                        return "13";
                }
            }
            catch { }
            
            try
            {
                using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 1 FROM TxtForm WHERE Mid=@Mid AND Mcid=@Lcid", conn))
                {
                    cmd.Parameters.AddWithValue("@Mid", lxid);
                    cmd.Parameters.AddWithValue("@Lcid", lcid);
                    object obj = cmd.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value)
                        return "15";
                }
            }
            catch { }
        }
        return normalized;
    }
}


#line default
#line hidden
