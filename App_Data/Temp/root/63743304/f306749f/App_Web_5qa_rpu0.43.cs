#pragma checksum "C:\Users\Administrator\Downloads\LearnSite\teacher\captcha.ashx" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "FE131ED896CF61E5F2B12EF54F584CAE"

#line 1 "C:\Users\Administrator\Downloads\LearnSite\teacher\captcha.ashx"


using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Web;
using System.Web.SessionState;

public class CaptchaHandler : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        // 获取验证码类型
        string type = context.Request.QueryString["type"];
        string sessionKey = "TeacherCaptcha"; // 默认登录验证码
        
        if (!string.IsNullOrEmpty(type))
        {
            if (type.Equals("email", StringComparison.OrdinalIgnoreCase))
            {
                sessionKey = "EmailCaptcha";
            }
        }
        
        // 生成随机验证码
        string code = GenerateRandomCode(4);
        
        // 保存到Session
        context.Session[sessionKey] = code;
        context.Session.Timeout = 10; // 10分钟过期
        
        // 生成图片
        Bitmap bitmap = GenerateCaptchaImage(code);
        
        // 输出图片（使用 MemoryStream 避免直接写入 OutputStream 的兼容性问题）
        context.Response.ContentType = "image/png";
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        context.Response.Cache.SetNoStore();
        context.Response.Cache.SetExpires(DateTime.Now.AddSeconds(-1));
        
        try
        {
            using (System.IO.MemoryStream ms = new System.IO.MemoryStream())
            {
                bitmap.Save(ms, ImageFormat.Png);
                context.Response.BinaryWrite(ms.ToArray());
            }
        }
        finally
        {
            bitmap.Dispose();
        }
    }
    
    private string GenerateRandomCode(int length)
    {
        // 使用数字和大写字母，排除容易混淆的字符
        string chars = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
        Random random = new Random();
        char[] code = new char[length];
        
        for (int i = 0; i < length; i++)
        {
            code[i] = chars[random.Next(chars.Length)];
        }
        
        return new string(code);
    }
    
    private Bitmap GenerateCaptchaImage(string code)
    {
        int width = 120;
        int height = 40;
        
        Bitmap bitmap = new Bitmap(width, height);
        Graphics g = Graphics.FromImage(bitmap);
        
        try
        {
            // 设置高质量渲染
            g.SmoothingMode = SmoothingMode.AntiAlias;
            g.TextRenderingHint = System.Drawing.Text.TextRenderingHint.AntiAlias;
            
            // 背景渐变
            using (LinearGradientBrush bgBrush = new LinearGradientBrush(
                new Rectangle(0, 0, width, height),
                Color.FromArgb(240, 243, 250),
                Color.FromArgb(230, 235, 245),
                LinearGradientMode.Vertical))
            {
                g.FillRectangle(bgBrush, 0, 0, width, height);
            }
            
            // 添加噪点
            Random random = new Random();
            for (int i = 0; i < 50; i++)
            {
                int x = random.Next(width);
                int y = random.Next(height);
                int size = random.Next(1, 3);
                Color color = Color.FromArgb(random.Next(100, 200), random.Next(100, 200), random.Next(100, 200));
                using (SolidBrush dotBrush = new SolidBrush(color))
                {
                    g.FillEllipse(dotBrush, x, y, size, size);
                }
            }
            
            // 添加干扰线
            for (int i = 0; i < 3; i++)
            {
                int x1 = random.Next(width);
                int y1 = random.Next(height);
                int x2 = random.Next(width);
                int y2 = random.Next(height);
                Color color = Color.FromArgb(random.Next(150, 220), random.Next(150, 220), random.Next(150, 220));
                using (Pen linePen = new Pen(color, 1))
                {
                    g.DrawLine(linePen, x1, y1, x2, y2);
                }
            }
            
            // 绘制验证码文字（控制在图片范围内，避免被裁剪）
            // 优先使用 Arial，降级到 Microsoft YaHei 或 Tahoma，最终回退到 GenericSansSerif
            Font font = null;
            string[] fontNames = { "Arial", "Tahoma", "Microsoft YaHei", "SimHei" };
            foreach (string fn in fontNames)
            {
                try
                {
                    font = new Font(fn, 20, FontStyle.Bold);
                    if (font.Name.Equals(fn, StringComparison.OrdinalIgnoreCase)) break;
                    font.Dispose(); font = null;
                }
                catch { font = null; }
            }
            if (font == null)
                font = new Font(FontFamily.GenericSansSerif, 20, FontStyle.Bold);
            
            int charWidth = width / code.Length;
            
            try
            {
                for (int i = 0; i < code.Length; i++)
                {
                    Color color = Color.FromArgb(
                        random.Next(50, 120),
                        random.Next(50, 120),
                        random.Next(50, 120));
                    
                    float x = i * charWidth + random.Next(5, 10);
                    float y = (height - font.Size) / 2 + random.Next(-4, 5);
                    float angle = random.Next(-15, 15);
                    
                    GraphicsState state = g.Save();
                    g.TranslateTransform(x, y);
                    g.RotateTransform(angle);
                    using (SolidBrush textBrush = new SolidBrush(color))
                    {
                        g.DrawString(code[i].ToString(), font, textBrush, 0, 0);
                    }
                    g.Restore(state);
                }
            }
            finally
            {
                font.Dispose();
            }
            
            // 边框
            using (Pen borderPen = new Pen(Color.FromArgb(200, 210, 225), 1))
            {
                g.DrawRectangle(borderPen, 0, 0, width - 1, height - 1);
            }
        }
        finally
        {
            g.Dispose();
        }
        
        return bitmap;
    }
    
    public bool IsReusable
    {
        get { return false; }
    }
}


#line default
#line hidden
