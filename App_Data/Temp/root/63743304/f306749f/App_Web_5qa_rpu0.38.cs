#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\teacher\gameupload.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "830AE0694679D8E5846E0C5A975CBFE0"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\teacher\gameupload.ashx"


using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;

public class gameupload : IHttpHandler
{
    private static readonly object _lock = new object();
    private const string GAMES_FILE = "~/App_Data/games.json";

    private void WriteJson(HttpContext ctx, string json)
    {
        ctx.Response.ContentType  = "application/json; charset=utf-8";
        ctx.Response.ContentEncoding = Encoding.UTF8;
        ctx.Response.Write(json);
    }

    private string Esc(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"")
                .Replace("\r", "").Replace("\n", "\\n");
    }

    // ── JSON helpers (same pattern as gamesave.ashx) ──────────────────

    private string ReadGamesJson(HttpContext ctx)
    {
        string path = ctx.Server.MapPath(GAMES_FILE);
        try { if (File.Exists(path)) return File.ReadAllText(path, Encoding.UTF8); }
        catch { }
        return "{\"games\":[]}";
    }

    private void WriteGamesJson(HttpContext ctx, string json)
    {
        string path = ctx.Server.MapPath(GAMES_FILE);
        string dir  = Path.GetDirectoryName(path);
        if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
        lock (_lock) { File.WriteAllText(path, json, Encoding.UTF8); }
    }

    private System.Collections.ArrayList ParseGameObjects(string arrayJson)
    {
        System.Collections.ArrayList list = new System.Collections.ArrayList();
        int depth = 0, start = -1;
        for (int i = 0; i < arrayJson.Length; i++)
        {
            char c = arrayJson[i];
            if      (c == '{') { if (depth == 0) start = i; depth++; }
            else if (c == '}') { depth--; if (depth == 0 && start >= 0) { list.Add(arrayJson.Substring(start, i - start + 1)); start = -1; } }
        }
        return list;
    }

    private string GetField(string objJson, string key)
    {
        Match m = Regex.Match(objJson, "\"" + key + "\"\\s*:\\s*\"((?:[^\"\\\\]|\\\\.)*)\"");
        if (m.Success) return m.Groups[1].Value;
        Match mb = Regex.Match(objJson, "\"" + key + "\"\\s*:\\s*(true|false)");
        if (mb.Success) return mb.Groups[1].Value;
        return "";
    }

    private string ExtractGamesArray(string fullJson)
    {
        Match m = Regex.Match(fullJson, "\"games\"\\s*:\\s*(\\[.*\\])", RegexOptions.Singleline);
        return m.Success ? m.Groups[1].Value : "[]";
    }

    private string BuildGameObject(string id, string name, bool enabled,
        string url, string description, string addedDate)
    {
        return string.Format(
            "{{\"id\":\"{0}\",\"name\":\"{1}\",\"enabled\":{2},\"url\":\"{3}\",\"description\":\"{4}\",\"addedDate\":\"{5}\"}}",
            Esc(id), Esc(name), enabled ? "true" : "false",
            Esc(url), Esc(description), Esc(addedDate));
    }

    private string RebuildJson(System.Collections.ArrayList items)
    {
        StringBuilder sb = new StringBuilder("{\"games\":[");
        for (int i = 0; i < items.Count; i++)
        { if (i > 0) sb.Append(","); sb.Append(items[i].ToString()); }
        sb.Append("]}");
        return sb.ToString();
    }

    private string NewId()
    {
        return DateTime.Now.Ticks.ToString("x") + new Random().Next(1000, 9999).ToString();
    }

    // ── 清理文件夹名：只保留字母/数字/连字符/下划线 ─────────────────────

    private string SanitizeFolderName(string name)
    {
        name = name.Trim().ToLowerInvariant();
        name = Regex.Replace(name, @"[^\w\-]", "-");
        name = Regex.Replace(name, @"-{2,}", "-").Trim('-');
        if (string.IsNullOrEmpty(name)) name = "game-" + DateTime.Now.Ticks.ToString("x").Substring(0, 8);
        return name;
    }

    // ── 主处理入口 ────────────────────────────────────────────────────

    public void ProcessRequest(HttpContext ctx)
    {
        // 验证教师登录
        HttpCookie tc = ctx.Request.Cookies[LearnSite.Common.CookieHelp.teaCookieNname];
        if (tc == null || string.IsNullOrEmpty(tc.Value))
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"请先登录\"}");
            return;
        }

        if (!ctx.Request.HttpMethod.Equals("POST", StringComparison.OrdinalIgnoreCase))
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"Method not allowed\"}");
            return;
        }

        try { HandleUpload(ctx); }
        catch (Exception ex)
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"" + Esc(ex.Message) + "\"}");
        }
    }

    private void HandleUpload(HttpContext ctx)
    {
        // 参数读取
        string gameName   = (ctx.Request.Form["gameName"]   ?? "").Trim();
        string folderName = (ctx.Request.Form["folderName"] ?? "").Trim();
        string entryFile  = (ctx.Request.Form["entryFile"]  ?? "index.html").Trim();
        string desc       = (ctx.Request.Form["desc"]       ?? "").Trim();
        string editId     = (ctx.Request.Form["editId"]     ?? "").Trim(); // 非空表示更新现有条目

        if (string.IsNullOrEmpty(gameName))
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"请填写游戏名称\"}");
            return;
        }

        HttpPostedFile file = ctx.Request.Files["zipFile"];
        if (file == null || file.ContentLength == 0)
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"请选择ZIP文件\"}");
            return;
        }

        // 校验文件扩展名
        string origName = Path.GetFileName(file.FileName);
        string ext = Path.GetExtension(origName).ToLowerInvariant();
        if (ext != ".zip")
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"只支持 .zip 格式的文件\"}");
            return;
        }

        // 目标文件夹名（若未指定，使用文件名）
        if (string.IsNullOrEmpty(folderName))
            folderName = Path.GetFileNameWithoutExtension(origName);
        folderName = SanitizeFolderName(folderName);

        // 确定目标目录（网站根目录下的子目录）
        string siteRoot  = ctx.Server.MapPath("~/");
        string targetDir = Path.Combine(siteRoot, folderName);

        // 安全检查：不允许穿越到根目录以上
        string normalTarget = Path.GetFullPath(targetDir);
        string normalRoot   = Path.GetFullPath(siteRoot);
        if (!normalTarget.StartsWith(normalRoot, StringComparison.OrdinalIgnoreCase))
        {
            WriteJson(ctx, "{\"ok\":false,\"msg\":\"非法的目标路径\"}");
            return;
        }

        // 将ZIP保存到临时文件
        string tempPath = Path.Combine(Path.GetTempPath(), "upload_" + DateTime.Now.Ticks.ToString("x") + ".zip");
        try
        {
            file.SaveAs(tempPath);

            // 备份：若目录已存在，先清空（保留目录本身）
            if (Directory.Exists(targetDir))
            {
                // 清空旧内容
                foreach (string f2 in Directory.GetFiles(targetDir, "*", SearchOption.AllDirectories))
                    try { File.Delete(f2); } catch { }
                foreach (string d2 in Directory.GetDirectories(targetDir))
                    try { Directory.Delete(d2, true); } catch { }
            }
            else
            {
                Directory.CreateDirectory(targetDir);
            }

            // 解压 ZIP
            ExtractZip(tempPath, targetDir);
        }
        finally
        {
            try { if (File.Exists(tempPath)) File.Delete(tempPath); } catch { }
        }

        // 构造游戏入口 URL（相对于网站根）
        if (string.IsNullOrEmpty(entryFile)) entryFile = "index.html";
        // 标准化：去掉开头斜杠/反斜杠
        entryFile = entryFile.TrimStart('/', '\\');
        string gameUrl = "/" + folderName + "/" + entryFile;

        // 更新 games.json
        string full = ReadGamesJson(ctx);
        string arr  = ExtractGamesArray(full);
        System.Collections.ArrayList list = ParseGameObjects(arr);

        if (!string.IsNullOrEmpty(editId))
        {
            // 更新现有条目
            bool found = false;
            for (int i = 0; i < list.Count; i++)
            {
                if (GetField(list[i].ToString(), "id") == editId)
                {
                    string addedDate = GetField(list[i].ToString(), "addedDate");
                    list[i] = BuildGameObject(editId, gameName, true, gameUrl, desc, addedDate);
                    found = true; break;
                }
            }
            if (!found) editId = ""; // 如果找不到就当新增
        }

        if (string.IsNullOrEmpty(editId))
        {
            // 新增条目
            string newId = NewId();
            list.Add(BuildGameObject(newId, gameName, true, gameUrl, desc, DateTime.Now.ToString("yyyy-MM-dd")));
        }

        WriteGamesJson(ctx, RebuildJson(list));

        WriteJson(ctx, string.Format(
            "{{\"ok\":true,\"url\":\"{0}\",\"folder\":\"{1}\"}}",
            Esc(gameUrl), Esc(folderName)));
    }

    // ── ZIP 解压（使用 System.IO.Compression.ZipFile） ────────────────

    private void ExtractZip(string zipPath, string targetDir)
    {
        // 尝试使用 .NET 4.5+ 的 ZipFile
        try
        {
            Type zipFileType = Type.GetType("System.IO.Compression.ZipFile, System.IO.Compression.FileSystem");
            if (zipFileType != null)
            {
                System.Reflection.MethodInfo extractMethod =
                    zipFileType.GetMethod("ExtractToDirectory",
                        new Type[] { typeof(string), typeof(string) });
                if (extractMethod != null)
                {
                    extractMethod.Invoke(null, new object[] { zipPath, targetDir });
                    return;
                }
            }
        }
        catch { }

        // 备选：通过反射使用 ZipArchive
        try
        {
            Type zipArchiveType = Type.GetType("System.IO.Compression.ZipArchive, System.IO.Compression");
            if (zipArchiveType == null)
            {
                // 尝试加载程序集
                System.Reflection.Assembly asm = System.Reflection.Assembly.Load(
                    "System.IO.Compression.FileSystem, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089");
                zipArchiveType = asm.GetType("System.IO.Compression.ZipArchive");
            }

            if (zipArchiveType != null)
            {
                using (FileStream fs = new FileStream(zipPath, FileMode.Open, FileAccess.Read))
                {
                    object archive = Activator.CreateInstance(zipArchiveType, fs);
                    try
                    {
                        System.Collections.IEnumerable entries =
                            (System.Collections.IEnumerable)zipArchiveType.GetProperty("Entries").GetValue(archive, null);
                        foreach (object entry in entries)
                        {
                            Type entryType = entry.GetType();
                            string fullName = (string)entryType.GetProperty("FullName").GetValue(entry, null);
                            long length     = (long)entryType.GetProperty("Length").GetValue(entry, null);

                            // 将斜杠统一为系统路径分隔符
                            string outPath = Path.Combine(targetDir,
                                fullName.Replace('/', Path.DirectorySeparatorChar)
                                        .Replace('\\', Path.DirectorySeparatorChar));

                            // 安全检查
                            if (!Path.GetFullPath(outPath).StartsWith(
                                    Path.GetFullPath(targetDir), StringComparison.OrdinalIgnoreCase))
                                continue;

                            if (fullName.EndsWith("/") || length == 0 && fullName.EndsWith("\\"))
                            {
                                Directory.CreateDirectory(outPath);
                            }
                            else
                            {
                                string dirPart = Path.GetDirectoryName(outPath);
                                if (!Directory.Exists(dirPart)) Directory.CreateDirectory(dirPart);

                                System.Reflection.MethodInfo openMethod = entryType.GetMethod("Open");
                                using (Stream entryStream = (Stream)openMethod.Invoke(entry, null))
                                using (FileStream outFs = new FileStream(outPath, FileMode.Create, FileAccess.Write))
                                {
                                    byte[] buf = new byte[65536];
                                    int read;
                                    while ((read = entryStream.Read(buf, 0, buf.Length)) > 0)
                                        outFs.Write(buf, 0, read);
                                }
                            }
                        }
                    }
                    finally
                    {
                        // 关闭 archive（IDisposable）
                        IDisposable disp = archive as IDisposable;
                        if (disp != null) disp.Dispose();
                    }
                }
                return;
            }
        }
        catch { }

        throw new InvalidOperationException(
            "服务器不支持ZIP解压（需要 .NET Framework 4.5 或更高版本）。" +
            "请手动将游戏文件夹上传到服务器，然后使用\"添加链接\"功能注册游戏。");
    }

    public bool IsReusable { get { return false; } }
}


#line default
#line hidden
