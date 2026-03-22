#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\student\getproject.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "50D1FFD820B2D27F560FCC1ED2053735"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\student\getproject.ashx"


using System;
using System.Web;
using System.IO;
using System.Text;

// 版本: 2026-02-27 修复ntext类型LEN函数错误
public class getproject : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        if (context.Request.QueryString["id"] != null)
        {
            string id = context.Request.QueryString["id"].ToString();
            string type = context.Request.QueryString["type"];
            
            // 如果请求类型是 code，返回纯文本代码
            if (!string.IsNullOrEmpty(type) && type.ToLower() == "code")
            {
                ReturnCodeAsText(context, id);
            }
            else
            {
                // 默认行为：返回二进制文件
                LearnSite.BLL.Works bll = new LearnSite.BLL.Works();
                bll.SworkToBytes(id);
            }
        }
        else
            context.Response.BinaryWrite(null);
    }
    
    private void ReturnCodeAsText(HttpContext context, string wid)
    {
        try
        {
            // 从Works表获取代码内容
            string connStr = GetConnStr();
            if (string.IsNullOrEmpty(connStr))
            {
                context.Response.ContentType = "text/plain; charset=utf-8";
                context.Response.Write("// 数据库连接失败");
                return;
            }
            
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connStr))
            {
                conn.Open();
                
                // 直接获取代码内容（不使用LEN函数避免ntext类型错误）
                string sql = "SELECT Wcode, Wtype FROM Works WHERE Wid=@wid";
                using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@wid", wid);
                    
                    using (System.Data.SqlClient.SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            string wtype = dr["Wtype"] != DBNull.Value ? dr["Wtype"].ToString() : "";
                            
                            // 添加调试信息到响应头
                            context.Response.AddHeader("X-Debug-Wid", wid);
                            context.Response.AddHeader("X-Debug-Wtype", wtype);
                            
                            if (dr["Wcode"] == DBNull.Value)
                            {
                                context.Response.ContentType = "text/plain; charset=utf-8";
                                context.Response.Write("// 未找到代码内容（Wcode字段为NULL）");
                                return;
                            }
                            
                            string code = dr["Wcode"].ToString();
                            
                            if (string.IsNullOrEmpty(code))
                            {
                                context.Response.ContentType = "text/plain; charset=utf-8";
                                context.Response.Write("// 代码内容为空（Wcode字段存在但为空字符串）");
                                return;
                            }
                            
                            // 尝试检测并解码
                            // 如果是Base64编码的，先解码
                            try
                            {
                                if (!code.Contains("\n") && !code.Contains("\r") && System.Text.RegularExpressions.Regex.IsMatch(code, "^[A-Za-z0-9+/=]+$"))
                                {
                                    byte[] bytes = Convert.FromBase64String(code);
                                    code = System.Text.Encoding.UTF8.GetString(bytes);
                                    
                                    // 可能还有URL编码
                                    if (code.Contains("%"))
                                    {
                                        code = HttpUtility.UrlDecode(code);
                                    }
                                }
                            }
                            catch
                            {
                                // 解码失败，使用原始内容
                            }
                            
                            context.Response.ContentType = "text/plain; charset=utf-8";
                            context.Response.Write(code);
                        }
                        else
                        {
                            context.Response.ContentType = "text/plain; charset=utf-8";
                            context.Response.Write("// 未找到作品记录（Wid=" + wid + "）");
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            context.Response.ContentType = "text/plain; charset=utf-8";
            context.Response.Write("// 加载失败: " + ex.Message + "\n// StackTrace: " + ex.StackTrace);
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
        return cs;
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}

#line default
#line hidden
