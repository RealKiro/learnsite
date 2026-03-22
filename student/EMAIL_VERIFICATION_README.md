# 注册页面邮箱验证功能配置说明

## 功能概述

注册页面已增强并添加了邮箱验证功能，包括：

### 美化改进
- ✨ 现代化的渐变色设计
- 🎨 流畅的动画效果和过渡
- 📱 完善的响应式布局
- 🎯 优化的用户体验

### 邮箱验证功能
- ✉️ 邮箱格式验证
- 🔐 邮箱验证码发送
- ⏱️ 60秒倒计时限制
- ✅ 验证码有效期5分钟

## 配置步骤

### 1. 配置SMTP邮件服务

复制配置文件模板：
```bash
cp App_Data/emailconfig.xml.example App_Data/emailconfig.xml
```

编辑 `App_Data/emailconfig.xml` 文件，填入您的SMTP服务器信息：

```xml
<emailConfig>
  <smtpServer>smtp.qq.com</smtpServer>
  <smtpPort>587</smtpPort>
  <fromEmail>your-email@qq.com</fromEmail>
  <fromPassword>您的授权码</fromPassword>
  <fromName>LearnSite 学习平台</fromName>
</emailConfig>
```

### 2. 常用邮箱配置参考

#### QQ邮箱
- SMTP服务器：`smtp.qq.com`
- 端口：`587` (TLS) 或 `465` (SSL)
- 授权码获取：QQ邮箱 → 设置 → 账户 → 开启SMTP服务

#### 163邮箱
- SMTP服务器：`smtp.163.com`
- 端口：`465` (SSL)
- 授权码获取：163邮箱 → 设置 → POP3/SMTP/IMAP

#### Gmail
- SMTP服务器：`smtp.gmail.com`
- 端口：`587` (TLS)
- 需要开启"允许安全性较低的应用访问"

### 3. 后端验证集成

在 `register.aspx` 的后端代码中添加验证逻辑：

```csharp
protected void BtnRegister_Click(object sender, EventArgs e)
{
    // 检查邮箱验证状态
    if (Session["EmailVerified"] == null || !(bool)Session["EmailVerified"])
    {
        labelmsg.Text = "请先完成邮箱验证";
        return;
    }

    string verifiedEmail = Session["VerifiedEmail"] as string;
    string inputEmail = TxtEmail.Text.Trim();

    if (verifiedEmail != inputEmail)
    {
        labelmsg.Text = "邮箱地址已变更，请重新验证";
        Session.Remove("EmailVerified");
        return;
    }

    // 继续原有的注册逻辑...
    // 可以将邮箱地址保存到数据库中
}
```

## 文件说明

### 新增文件
- `student/SendEmailCode.ashx` - 发送验证码处理程序
- `student/VerifyEmailCode.ashx` - 验证验证码处理程序
- `App_Data/emailconfig.xml.example` - 邮件配置模板

### 修改文件
- `student/register.aspx` - 注册页面（已美化并添加邮箱验证功能）

## 功能特性

### 前端验证
- 实时邮箱格式验证
- 发送验证码前的邮箱验证
- 60秒倒计时防止频繁发送
- 友好的错误提示和成功提示

### 后端安全
- Session存储验证码
- 5分钟验证码有效期
- 邮箱地址匹配验证
- 防止验证码重放攻击

### 邮件模板
- 精美的HTML邮件模板
- 清晰的验证码展示
- 包含有效期提示

## 开发模式

如果未配置SMTP服务器（`fromPassword`为空），系统将进入开发模式：
- 验证码仅保存在Session中
- 不实际发送邮件
- 可在浏览器控制台查看验证码（HTML注释）

## 注意事项

1. **安全性**
   - 请勿将 `emailconfig.xml` 提交到版本控制系统
   - 妥善保管SMTP授权码
   - 建议在生产环境使用环境变量存储敏感信息

2. **性能**
   - 发送邮件可能需要几秒时间
   - 建议配置适当的超时时间
   - 可考虑使用队列异步发送

3. **用户体验**
   - 确保邮件服务器稳定可用
   - 提示用户检查垃圾邮件箱
   - 提供清晰的错误信息

## 测试

1. 访问注册页面：`http://your-domain/student/register.aspx`
2. 填写注册信息
3. 输入邮箱地址并点击"发送验证码"
4. 检查邮箱收到的验证码
5. 输入验证码并完成注册

## 故障排查

### 收不到验证码
- 检查邮箱地址是否正确
- 查看垃圾邮件箱
- 确认SMTP配置正确
- 检查服务器日志

### 验证码错误
- 确认输入的验证码正确
- 检查是否超过5分钟有效期
- 验证邮箱地址是否匹配

### 发送失败
- 检查网络连接
- 确认SMTP服务器可访问
- 验证授权码是否正确
- 查看服务器错误日志

## 技术支持

如有问题，请联系系统管理员或查阅项目文档。
