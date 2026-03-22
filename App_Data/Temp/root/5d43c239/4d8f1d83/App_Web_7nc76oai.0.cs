#pragma checksum "C:\inetpub\wwwroot\LearnSite\teacher\typediag.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "2D63349385A14D517EAD0AAFB7A76DF2"

#line 1 "C:\inetpub\wwwroot\LearnSite\teacher\typediag.ashx"


using System;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Text;
using System.Reflection;

public class TypeDiag : IHttpHandler
{
    public bool IsReusable { get { return false; } }
    
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
            try { cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString; } catch { }
        }
        return cs;
    }
    
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
            case "调查": return "14";
            case "填表": return "15";
            case "绘图": return "8";
            case "仓库": case "代码": return "5";
            default: return ltype;
        }
    }
    
    private string ApplyKnownLtypeOverrides(string normalized, int lid, int lcid)
    {
        if (lid == 23 && lcid == 5) return "14";
        if (lid == 40 && lcid == 9) return "7";
        if (lid == 41 && lcid == 9) return "5";
        if (lid == 53 && lcid == 11) return "4";
        if (lid == 58 && lcid == 12) return "4";
        if (lid == 47 && lcid == 9) return "6";
        if (lid == 48 && lcid == 9) return "8";
        if (lid == 49 && lcid == 9) return "9";
        return normalized;
    }
    
    private string GetTypeName(string ltype)
    {
        switch (ltype)
        {
            case "1": return "活动";
            case "2": return "主题";
            case "3": return "练习";
            case "4": return "积木编程";
            case "5": return "Python";
            case "6": return "测评";
            case "7": return "流程图";
            case "8": return "应用(像素)";
            case "9": return "Html";
            case "10": return "导图";
            case "11": return "表格";
            case "12": return "课件";
            case "13": return "讨论";
            case "14": return "调查";
            case "15": return "填表";
            default: return "未知(" + ltype + ")";
        }
    }
    
    private string GetTeacherPage(string ltype)
    {
        switch (ltype)
        {
            case "1": return "missionshow.aspx";
            case "2": return "topicshow.aspx";
            case "3": return "missionshow.aspx";
            case "4": return "programshow.aspx";
            case "5": return "pythonshow.aspx";
            case "6": return "consoleshow.aspx";
            case "7": return "graphshow.aspx";
            case "8": return "pixelshow.aspx";
            case "9": return "htmlshow.aspx";
            case "10": return "kitymindshow.aspx";
            case "11": return "excelshow.aspx";
            case "12": return "../student/ware.aspx";
            case "13": return "../student/topicdiscuss.aspx";
            case "14": return "missionshow.aspx";
            case "15": return "txtformshow.aspx";
            default: return "missionshow.aspx";
        }
    }
    
    private string GetStudentPage(string ltype)
    {
        switch (ltype)
        {
            case "1": case "2": case "3":
                return "showmission.aspx";
            case "4":
                return "program.aspx";
            case "6":
                return "console.aspx";
            case "5": case "7": case "8": case "9": case "10": case "11": case "12":
                return "program.aspx";
            case "13":
                return "topicdiscuss.aspx";
            case "14":
                return "surveyshow.aspx";
            case "15":
                return "txtformresult.aspx";
            default:
                return "showmission.aspx";
        }
    }
    
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/html";
        context.Response.Charset = "utf-8";
        
        string cidStr = context.Request.QueryString["cid"];
        if (string.IsNullOrEmpty(cidStr))
        {
            context.Response.Write("<h2>请提供 cid 参数，例如 typediag.ashx?cid=10</h2>");
            return;
        }
        
        int cid;
        if (!int.TryParse(cidStr, out cid))
        {
            context.Response.Write("<h2>无效的 cid 参数</h2>");
            return;
        }
        
        string cs = GetConnStr();
        if (string.IsNullOrEmpty(cs))
        {
            context.Response.Write("<h2>无法获取数据库连接字符串</h2>");
            return;
        }
        
        StringBuilder sb = new StringBuilder();
        sb.Append("<!DOCTYPE html><html><head><meta charset='utf-8'><title>课程类型诊断 - CID=" + cid + "</title>");
        sb.Append(@"<style>
            body { font-family: 'Microsoft YaHei', sans-serif; padding: 20px; background: #f8fafc; }
            h1 { color: #1e293b; }
            table { border-collapse: collapse; width: 100%; background: #fff; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,0.1); }
            th { background: #4f46e5; color: #fff; padding: 12px 16px; text-align: left; font-size: 13px; }
            td { padding: 10px 16px; border-bottom: 1px solid #e2e8f0; font-size: 13px; }
            tr:hover td { background: #f1f5f9; }
            .changed { background: #fef3c7 !important; }
            .error { color: #dc2626; font-weight: bold; }
            .ok { color: #16a34a; }
            .badge { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 12px; font-weight: 500; }
            .badge-num { background: #e0e7ff; color: #4338ca; }
            .badge-text { background: #fef3c7; color: #92400e; }
        </style>");
        sb.Append("</head><body>");
        
        try
        {
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                
                // Get course name
                string courseName = "";
                using (SqlCommand cmd2 = new SqlCommand("SELECT Ctitle FROM Courses WHERE Cid=@Cid", conn))
                {
                    cmd2.Parameters.AddWithValue("@Cid", cid);
                    object result = cmd2.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        courseName = result.ToString();
                }
                
                sb.AppendFormat("<h1>课程类型诊断: {0} (CID={1})</h1>", 
                    System.Web.HttpUtility.HtmlEncode(courseName), cid);
                
                string sql = @"
                    SELECT L.Lid, L.Lxid, L.Ltype, L.Ltitle, L.Lcid, L.Lsort, L.lshow,
                           CASE WHEN EXISTS(SELECT 1 FROM SurveyQuestion SQ WHERE SQ.Qvid = L.Lxid AND SQ.Qcid = L.Lcid) THEN 1 ELSE 0 END AS IsSurvey,
                           CASE WHEN EXISTS(SELECT 1 FROM TopicDiscuss TD WHERE TD.Tid = L.Lxid AND TD.Tcid = L.Lcid) THEN 1 ELSE 0 END AS IsTopic,
                           CASE WHEN EXISTS(SELECT 1 FROM TxtForm TF WHERE TF.Mid = L.Lxid AND TF.Mcid = L.Lcid) THEN 1 ELSE 0 END AS IsTxtForm
                    FROM Listmenu L
                    WHERE L.Lcid = @Lcid
                    ORDER BY L.Lsort
                ";
                
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Lcid", cid);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        sb.Append("<table>");
                        sb.Append("<tr><th>序号</th><th>Lid</th><th>Lxid</th><th>标题</th><th>DB原始Ltype</th><th>归一化后</th><th>Override后</th><th>最终纠偏</th><th>类型名称</th><th>教师端页面</th><th>学生端页面</th><th>是否修改</th></tr>");
                        
                        int row = 0;
                        while (reader.Read())
                        {
                            row++;
                            int lid = reader["Lid"] != DBNull.Value ? Convert.ToInt32(reader["Lid"]) : 0;
                            int lxid = reader["Lxid"] != DBNull.Value ? Convert.ToInt32(reader["Lxid"]) : 0;
                            int lcid = reader["Lcid"] != DBNull.Value ? Convert.ToInt32(reader["Lcid"]) : 0;
                            string rawLtype = reader["Ltype"] != DBNull.Value ? reader["Ltype"].ToString() : "";
                            string ltitle = reader["Ltitle"] != DBNull.Value ? reader["Ltitle"].ToString() : "";
                            bool isSurvey = reader["IsSurvey"] != DBNull.Value && Convert.ToInt32(reader["IsSurvey"]) == 1;
                            bool isTopic = reader["IsTopic"] != DBNull.Value && Convert.ToInt32(reader["IsTopic"]) == 1;
                            bool isTxtForm = reader["IsTxtForm"] != DBNull.Value && Convert.ToInt32(reader["IsTxtForm"]) == 1;
                            
                            string normalized = NormalizeLtype(rawLtype);
                            string overridden = ApplyKnownLtypeOverrides(normalized, lid, lcid);
                            
                            // Final correction with survey/topic/txtform
                            string final2 = overridden;
                            int nType;
                            if (int.TryParse(overridden, out nType) && nType >= 1 && nType <= 12)
                            {
                                if (isSurvey) final2 = "14";
                                else if (isTopic) final2 = "13";
                                else if (isTxtForm) final2 = "15";
                            }
                            
                            bool changed = rawLtype != final2;
                            string typeName = GetTypeName(final2);
                            string teacherPage = GetTeacherPage(final2);
                            string studentPage = GetStudentPage(final2);
                            
                            string rowClass = changed ? " class='changed'" : "";
                            string rawBadge = "";
                            int rawNum;
                            if (int.TryParse(rawLtype, out rawNum))
                                rawBadge = "<span class='badge badge-num'>" + rawLtype + "</span>";
                            else
                                rawBadge = "<span class='badge badge-text'>" + System.Web.HttpUtility.HtmlEncode(rawLtype) + "</span>";
                            
                            sb.AppendFormat("<tr{0}><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td>{5}</td><td>{6}</td><td>{7}</td><td><b>{8}</b></td><td><b>{9}</b></td><td>{10}</td><td>{11}</td><td>{12}</td></tr>",
                                rowClass,
                                row,
                                lid,
                                lxid,
                                System.Web.HttpUtility.HtmlEncode(ltitle),
                                rawBadge,
                                normalized,
                                overridden,
                                final2,
                                System.Web.HttpUtility.HtmlEncode(typeName),
                                teacherPage,
                                studentPage,
                                changed ? "<span class='error'>已纠偏</span>" : "<span class='ok'>正常</span>"
                            );
                        }
                        
                        sb.Append("</table>");
                        sb.AppendFormat("<p style='margin-top:16px; color:#64748b; font-size:13px;'>共 {0} 条记录</p>", row);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            sb.AppendFormat("<div class='error'>查询出错: {0}<br/>{1}</div>", 
                System.Web.HttpUtility.HtmlEncode(ex.Message),
                System.Web.HttpUtility.HtmlEncode(ex.StackTrace));
        }
        
        sb.Append("</body></html>");
        context.Response.Write(sb.ToString());
    }
}


#line default
#line hidden
