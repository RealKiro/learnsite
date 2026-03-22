#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\manager\uploadavatar.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "26B90EDFDC1045F1E59B508F2A819234"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\manager\uploadavatar.ashx"


using System;
using System.IO;
using System.Web;
using System.Text;
using System.Data.SqlClient;
using System.Configuration;
using System.Reflection;

public class uploadavatar : IHttpHandler
{
    private static BindingFlags allFlags =
        BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static;

    private void WriteJson(HttpContext context, string json)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.ContentEncoding = Encoding.UTF8;
        context.Response.Charset = "utf-8";
        byte[] data = Encoding.UTF8.GetBytes(json);
        context.Response.OutputStream.Write(data, 0, data.Length);
    }

    private string EscapeJson(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", " ");
    }

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly.GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                FieldInfo connField = dbType.GetField("connectionString", allFlags);
                if (connField != null)
                {
                    cs = connField.GetValue(null) as string;
                }
            }
        }
        catch { }
        if (string.IsNullOrEmpty(cs))
        {
            cs = ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString;
        }
        if (cs != null && cs.ToLower().IndexOf("connection timeout") < 0 && cs.ToLower().IndexOf("connect timeout") < 0)
        {
            cs = cs.TrimEnd(';') + ";Connection Timeout=5;";
        }
        return cs;
    }

    private object DecodeCookieModel(string typeName, string cookieValue)
    {
        Assembly asm = typeof(LearnSite.Common.CookieHelp).Assembly;
        Type cookType = asm.GetType(typeName);
        if (cookType == null) return null;
        object model = Activator.CreateInstance(cookType);
        MethodInfo toModel = cookType.GetMethod("ToModel", allFlags);
        if (toModel != null)
            toModel.Invoke(model, new object[] { cookieValue });
        return model;
    }

    private int GetCookIntProp(object model, string propName)
    {
        if (model == null) return 0;
        PropertyInfo prop = model.GetType().GetProperty(propName);
        if (prop == null) return 0;
        object val = prop.GetValue(model, null);
        if (val == null) return 0;
        int result;
        if (int.TryParse(val.ToString(), out result)) return result;
        return 0;
    }

    private int GetCurrentHid(HttpContext context)
    {
        // 1. Manager cookie
        try
        {
            string mngName = LearnSite.Common.CookieHelp.mngCookieNname;
            HttpCookie mngCookie = context.Request.Cookies[mngName];
            if (mngCookie != null && !string.IsNullOrEmpty(mngCookie.Value))
            {
                object mcook = DecodeCookieModel("LearnSite.Model.MngCook", mngCookie.Value);
                int hid = GetCookIntProp(mcook, "Hid");
                if (hid > 0) return hid;
            }
        }
        catch { }

        // 2. Fallback: teacher cookie
        try
        {
            string teaName = LearnSite.Common.CookieHelp.teaCookieNname;
            HttpCookie teaCookie = context.Request.Cookies[teaName];
            if (teaCookie != null && !string.IsNullOrEmpty(teaCookie.Value))
            {
                object tcook = DecodeCookieModel("LearnSite.Model.TeaCook", teaCookie.Value);
                int hid = GetCookIntProp(tcook, "Hid");
                if (hid > 0) return hid;
            }
        }
        catch { }

        return 0;
    }

    public void ProcessRequest(HttpContext context)
    {
        try
        {
            int hid = GetCurrentHid(context);
            if (hid <= 0)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"未登录，请先登录管理后台\"}");
                return;
            }

            if (context.Request.Files.Count == 0)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"未选择文件\"}");
                return;
            }

            HttpPostedFile file = context.Request.Files[0];
            if (file == null || file.ContentLength == 0)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"文件为空\"}");
                return;
            }

            if (file.ContentLength > 2 * 1024 * 1024)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"文件大小不能超过2MB\"}");
                return;
            }

            string ext = Path.GetExtension(file.FileName).ToLower();
            string[] allowedExts = new string[] { ".png", ".jpg", ".jpeg", ".gif", ".webp" };
            if (Array.IndexOf(allowedExts, ext) == -1)
            {
                WriteJson(context, "{\"success\":0,\"message\":\"仅支持 PNG/JPG/GIF/WEBP 格式\"}");
                return;
            }

            string avatarDir = context.Server.MapPath("~/images/avatars");
            if (!Directory.Exists(avatarDir))
            {
                Directory.CreateDirectory(avatarDir);
            }

            foreach (string oldExt in allowedExts)
            {
                string oldFile = Path.Combine(avatarDir, hid.ToString() + oldExt);
                if (File.Exists(oldFile))
                    File.Delete(oldFile);
            }

            string fileName = hid.ToString() + ext;
            string savePath = Path.Combine(avatarDir, fileName);
            file.SaveAs(savePath);

            // Update DB (non-critical, avatar file already saved)
            string avatarUrl = "~/images/avatars/" + fileName;
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnStr()))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand("UPDATE Teacher SET Havatar=@avatar WHERE Hid=@hid", conn);
                    cmd.Parameters.AddWithValue("@avatar", avatarUrl);
                    cmd.Parameters.AddWithValue("@hid", hid);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }

            string appPath = context.Request.ApplicationPath.TrimEnd('/');
            string url = appPath + "/images/avatars/" + fileName + "?t=" + DateTime.Now.Ticks.ToString();
            WriteJson(context, "{\"success\":1,\"message\":\"头像上传成功\",\"url\":\"" + EscapeJson(url) + "\"}");
        }
        catch (Exception ex)
        {
            WriteJson(context, "{\"success\":0,\"message\":\"" + EscapeJson(ex.Message) + "\"}");
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}


#line default
#line hidden
