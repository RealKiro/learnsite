<%@ Page Language="C#" MasterPageFile="~/manager/Manage.master" AutoEventWireup="true" %>
<%@ Import Namespace="System.Xml" %>

<script runat="server">
    private string xmlPath;

    protected void Page_Load(object sender, EventArgs e)
    {
        xmlPath = Server.MapPath("~/website.xml");
        if (!IsPostBack)
        {
            LoadSettings();
        }
    }

    private string GetXmlValue(XmlDocument doc, string key)
    {
        XmlNode node = doc.SelectSingleNode("//add[@key='" + key + "']");
        if (node != null && node.Attributes["value"] != null)
            return node.Attributes["value"].Value;
        return "";
    }

    private void SetXmlValue(XmlDocument doc, string key, string val)
    {
        XmlNode node = doc.SelectSingleNode("//add[@key='" + key + "']");
        if (node != null)
        {
            node.Attributes["value"].Value = val;
        }
        else
        {
            XmlNode parent = doc.SelectSingleNode("//website");
            if (parent != null)
            {
                XmlElement elem = doc.CreateElement("add");
                elem.SetAttribute("key", key);
                elem.SetAttribute("value", val);
                parent.AppendChild(elem);
            }
        }
    }

    private void LoadSettings()
    {
        try
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            TextBoxHost.Text = GetXmlValue(doc, "SmtpHost");
            TextBoxPort.Text = GetXmlValue(doc, "SmtpPort");
            TextBoxUser.Text = GetXmlValue(doc, "SmtpUser");
            TextBoxPass.Text = GetXmlValue(doc, "SmtpPass");
            CheckBoxSsl.Checked = GetXmlValue(doc, "SmtpSsl").ToLower() == "true";
            TextBoxFrom.Text = GetXmlValue(doc, "SmtpFrom");
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "Load error: " + ex.Message;
        }
    }

    protected void BtnSave_Click(object sender, EventArgs e)
    {
        try
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            SetXmlValue(doc, "SmtpHost", TextBoxHost.Text.Trim());
            SetXmlValue(doc, "SmtpPort", TextBoxPort.Text.Trim());
            SetXmlValue(doc, "SmtpUser", TextBoxUser.Text.Trim());
            SetXmlValue(doc, "SmtpPass", TextBoxPass.Text.Trim());
            SetXmlValue(doc, "SmtpSsl", CheckBoxSsl.Checked ? "True" : "False");
            SetXmlValue(doc, "SmtpFrom", TextBoxFrom.Text.Trim());
            doc.Save(xmlPath);
            LabelMsg.ForeColor = System.Drawing.Color.Green;
            LabelMsg.Text = "SMTP OK &#x2713;";
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "Save error: " + ex.Message;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .es-page{max-width:100%;padding:28px 32px 40px;font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif;}
    .es-hd{display:flex;align-items:center;gap:16px;margin-bottom:28px;}
    .es-hd-icon{width:48px;height:48px;background:linear-gradient(135deg,#10b981,#34d399);border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(16,185,129,.25);flex-shrink:0;}
    .es-hd-icon svg{width:26px;height:26px;stroke:#fff;fill:none;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;}
    .es-hd h1{font-size:22px;font-weight:700;color:#0f172a;margin:0 0 2px;}
    .es-hd p{font-size:13px;color:#94a3b8;margin:0;}
    .es-card{background:#fff;border-radius:14px;border:1px solid #e2e8f0;box-shadow:0 1px 4px rgba(0,0,0,.04);overflow:hidden;margin-bottom:20px;}
    .es-card:hover{box-shadow:0 8px 24px rgba(0,0,0,.07);}
    .es-card-hd{padding:16px 22px;font-size:15px;font-weight:600;color:#1e293b;border-bottom:1px solid #f1f5f9;display:flex;align-items:center;gap:12px;}
    .es-card-hd .ci{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
    .es-card-hd .ci svg{width:19px;height:19px;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;fill:none;}
    .ci.emerald{background:#ecfdf5;} .ci.emerald svg{stroke:#10b981;}
    .ci.sky{background:#f0f9ff;} .ci.sky svg{stroke:#0ea5e9;}
    .ci.amber{background:#fffbeb;} .ci.amber svg{stroke:#f59e0b;}
    .es-card-bd{padding:22px;}
    .es-row{display:flex;align-items:center;padding:12px 0;border-bottom:1px solid #f8fafc;gap:14px;font-size:13.5px;}
    .es-row:last-child{border-bottom:none;}
    .es-label{min-width:110px;font-weight:500;color:#475569;flex-shrink:0;text-align:right;font-size:13px;}
    .es-val{flex:1;display:flex;align-items:center;gap:10px;flex-wrap:wrap;}
    .es-hint{font-size:11.5px;color:#94a3b8;margin-top:3px;line-height:1.5;}
    .es-card input[type="text"]{height:36px;padding:0 14px;border:1.5px solid #e2e8f0;border-radius:9px;font-size:13.5px;font-family:inherit;outline:none;transition:border-color .2s,box-shadow .2s;background:#f8fafc;min-width:280px;}
    .es-card input[type="text"]:focus{border-color:#6366f1;box-shadow:0 0 0 3px rgba(99,102,241,.08);background:#fff;}
    .es-card input[type="password"]{height:36px;padding:0 14px;border:1.5px solid #e2e8f0;border-radius:9px;font-size:13.5px;font-family:inherit;outline:none;transition:border-color .2s,box-shadow .2s;background:#f8fafc;min-width:280px;}
    .es-card input[type="password"]:focus{border-color:#6366f1;box-shadow:0 0 0 3px rgba(99,102,241,.08);background:#fff;}
    .es-card input[type="checkbox"]{width:17px;height:17px;accent-color:#10b981;cursor:pointer;}
    .pwd-toggle{display:inline-flex;align-items:center;justify-content:center;width:36px;height:36px;border:1.5px solid #e2e8f0;border-radius:9px;background:#f8fafc;cursor:pointer;transition:all .2s;margin-left:-10px;}
    .pwd-toggle:hover{background:#eef2ff;border-color:#c7d2fe;}
    .pwd-toggle svg{width:18px;height:18px;stroke:#64748b;fill:none;stroke-width:2;}
    .btn-primary{display:inline-flex;align-items:center;justify-content:center;gap:6px;height:36px;padding:0 20px;background:linear-gradient(135deg,#6366f1,#7c3aed);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;box-shadow:0 2px 6px rgba(99,102,241,.3);}
    .btn-primary:hover{box-shadow:0 4px 14px rgba(99,102,241,.4);transform:translateY(-1px);}
    .btn-test{display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 20px;background:linear-gradient(135deg,#10b981,#059669);color:#fff!important;border:none;border-radius:9px;font-size:13px;font-family:inherit;font-weight:500;cursor:pointer;transition:all .2s;box-shadow:0 2px 6px rgba(16,185,129,.3);}
    .btn-test:hover{box-shadow:0 4px 14px rgba(16,185,129,.4);transform:translateY(-1px);}
    .btn-test:disabled{opacity:.5;cursor:not-allowed;}
    .test-result{margin-top:8px;font-size:12.5px;padding:6px 12px;border-radius:8px;display:none;}
    .test-result.ok{display:block;background:#ecfdf5;color:#059669;}
    .test-result.err{display:block;background:#fef2f2;color:#dc2626;}
    .test-result.loading{display:block;background:#eef2ff;color:#6366f1;}
    .es-msg{text-align:center;padding:10px;font-size:13px;margin-top:8px;}
    .smtp-presets{margin-top:12px;}
    .smtp-presets-title{font-size:12px;color:#94a3b8;margin-bottom:8px;font-weight:500;}
    .smtp-preset{display:inline-flex;align-items:center;padding:5px 12px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:8px;font-size:12px;color:#475569;cursor:pointer;transition:all .15s;margin:0 6px 6px 0;}
    .smtp-preset:hover{background:#eef2ff;border-color:#c7d2fe;color:#4f46e5;}
</style>

<div class="es-page">
    <div class="es-hd">
        <div class="es-hd-icon"><svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg></div>
        <div><h1>&#x90AE;&#x7BB1;&#x670D;&#x52A1;&#x914D;&#x7F6E;</h1><p>&#x914D;&#x7F6E; SMTP &#x670D;&#x52A1;&#x5668;&#xFF0C;&#x7528;&#x4E8E;&#x5BC6;&#x7801;&#x627E;&#x56DE;&#x9A8C;&#x8BC1;&#x7801;&#x7684;&#x53D1;&#x9001;</p></div>
    </div>

    <div class="es-card">
        <div class="es-card-hd"><span class="ci emerald"><svg viewBox="0 0 24 24"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg></span>SMTP &#x670D;&#x52A1;&#x5668;&#x914D;&#x7F6E;</div>
        <div class="es-card-bd">
            <div class="es-row"><div class="es-label">SMTP &#x4E3B;&#x673A;</div><div class="es-val"><asp:TextBox ID="TextBoxHost" runat="server" Width="280px" /><div class="es-hint">&#x5982; smtp.qq.com&#x3001;smtp.163.com</div></div></div>
            <div class="es-row"><div class="es-label">&#x7AEF;&#x53E3;&#x53F7;</div><div class="es-val"><asp:TextBox ID="TextBoxPort" runat="server" Width="100px" /><div class="es-hint">SSL &#x5E38;&#x7528; 465 &#x6216; 587</div></div></div>
            <div class="es-row"><div class="es-label">&#x767B;&#x5F55;&#x8D26;&#x53F7;</div><div class="es-val"><asp:TextBox ID="TextBoxUser" runat="server" Width="280px" /></div></div>
            <div class="es-row"><div class="es-label">&#x767B;&#x5F55;&#x5BC6;&#x7801;</div><div class="es-val"><asp:TextBox ID="TextBoxPass" runat="server" TextMode="Password" Width="280px" /><span class="pwd-toggle" onclick="togglePassword()" title="显示/隐藏密码"><svg id="eyeIcon" viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></span><div class="es-hint">&#x90E8;&#x5206;&#x90AE;&#x7BB1;&#x9700;&#x4F7F;&#x7528;&#x6388;&#x6743;&#x7801;</div></div></div>
            <div class="es-row"><div class="es-label">&#x542F;&#x7528; SSL</div><div class="es-val"><asp:CheckBox ID="CheckBoxSsl" runat="server" /></div></div>
            <div class="es-row"><div class="es-label">&#x53D1;&#x4EF6;&#x4EBA;</div><div class="es-val"><asp:TextBox ID="TextBoxFrom" runat="server" Width="280px" /><div class="es-hint">&#x7559;&#x7A7A;&#x5219;&#x7528;&#x767B;&#x5F55;&#x8D26;&#x53F7;</div></div></div>
            <div style="padding:16px 0 0 124px;"><asp:Button ID="BtnSave" runat="server" Text="&#x4FDD;&#x5B58;&#x914D;&#x7F6E;" CssClass="btn-primary" OnClick="BtnSave_Click" /></div>
            <div class="smtp-presets" style="padding:16px 0 0 124px;">
                <div class="smtp-presets-title">&#x5FEB;&#x6377;&#x586B;&#x5165;&#xFF1A;</div>
                <span class="smtp-preset" onclick="fillPreset('smtp.qq.com','587','True')">QQ &#x90AE;&#x7BB1;</span>
                <span class="smtp-preset" onclick="fillPreset('smtp.163.com','465','True')">163 &#x90AE;&#x7BB1;</span>
                <span class="smtp-preset" onclick="fillPreset('smtp.126.com','465','True')">126 &#x90AE;&#x7BB1;</span>
                <span class="smtp-preset" onclick="fillPreset('smtp.gmail.com','587','True')">Gmail</span>
                <span class="smtp-preset" onclick="fillPreset('smtp.exmail.qq.com','465','True')">&#x817E;&#x8BAF;&#x4F01;&#x4E1A;&#x90AE;</span>
            </div>
        </div>
    </div>

    <div class="es-card">
        <div class="es-card-hd"><span class="ci sky"><svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg></span>&#x6D4B;&#x8BD5;&#x53D1;&#x9001;</div>
        <div class="es-card-bd">
            <div class="es-row"><div class="es-label">&#x6536;&#x4EF6;&#x90AE;&#x7BB1;</div><div class="es-val"><input type="text" id="testEmail" placeholder="test@example.com" style="min-width:280px;" /><button type="button" class="btn-test" id="btnTest" onclick="testSmtp()">&#x53D1;&#x9001;&#x6D4B;&#x8BD5;</button></div></div>
            <div style="padding:4px 0 0 124px;"><div class="test-result" id="testResult"></div></div>
        </div>
    </div>

    <div class="es-card">
        <div class="es-card-hd"><span class="ci amber"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg></span>&#x4F7F;&#x7528;&#x8BF4;&#x660E;</div>
        <div class="es-card-bd" style="font-size:13px;color:#475569;line-height:2;">
            <p><strong>1.</strong> &#x586B;&#x5199; SMTP &#x914D;&#x7F6E;&#x5E76;&#x4FDD;&#x5B58;</p>
            <p><strong>2.</strong> &#x6559;&#x5E08;/&#x7BA1;&#x7406;&#x5458;&#x5728;&#x300C;&#x4E2A;&#x4EBA;&#x4E2D;&#x5FC3;&#x300D;&#x7ED1;&#x5B9A;&#x90AE;&#x7BB1;</p>
            <p><strong>3.</strong> &#x767B;&#x5F55;&#x9875;&#x70B9;&#x300C;&#x5FD8;&#x8BB0;&#x5BC6;&#x7801;&#x300D;&#x5373;&#x53EF;&#x901A;&#x8FC7;&#x90AE;&#x7BB1;&#x9A8C;&#x8BC1;&#x7801;&#x91CD;&#x7F6E;</p>
            <p style="color:#94a3b8;font-size:12px;margin-top:8px;"><strong>QQ&#x90AE;&#x7BB1;:</strong> &#x8BBE;&#x7F6E; &#x2192; POP3/SMTP &#x2192; &#x751F;&#x6210;&#x6388;&#x6743;&#x7801;<br/><strong>163&#x90AE;&#x7BB1;:</strong> &#x8BBE;&#x7F6E; &#x2192; POP3/SMTP/IMAP &#x2192; &#x8BBE;&#x7F6E;&#x6388;&#x6743;&#x5BC6;&#x7801;</p>
        </div>
    </div>

    <div class="es-msg"><asp:Label ID="LabelMsg" runat="server"></asp:Label></div>
</div>

<script type="text/javascript">
    function fillPreset(host, port, ssl) {
        var h = document.getElementById('<%= TextBoxHost.ClientID %>');
        var p = document.getElementById('<%= TextBoxPort.ClientID %>');
        var s = document.getElementById('<%= CheckBoxSsl.ClientID %>');
        if (h) h.value = host; if (p) p.value = port; if (s) s.checked = (ssl === 'True');
    }
    
    function togglePassword() {
        var pwd = document.getElementById('<%= TextBoxPass.ClientID %>');
        var icon = document.getElementById('eyeIcon');
        if (pwd.type === 'password') {
            pwd.type = 'text';
            icon.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/>';
        } else {
            pwd.type = 'password';
            icon.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>';
        }
    }
    
    function testSmtp() {
        var email = document.getElementById('testEmail').value;
        var result = document.getElementById('testResult');
        var btn = document.getElementById('btnTest');
        if (!email || email.indexOf('@') < 0) { result.className='test-result err'; result.innerHTML='请输入有效的邮箱地址'; return; }
        btn.disabled = true; result.className='test-result loading'; result.innerHTML='发送中，请稍候...';
        var xhr; try{xhr=new XMLHttpRequest();}catch(e){try{xhr=new ActiveXObject("Microsoft.XMLHTTP");}catch(e2){return;}}
        xhr.open('GET', '<%= ResolveUrl("~/manager/testsmtp.ashx") %>' + '?to=' + encodeURIComponent(email), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                btn.disabled = false;
                if (xhr.status === 200) {
                    try { var r = eval('(' + xhr.responseText + ')'); result.className = r.success===1 ? 'test-result ok' : 'test-result err'; result.innerHTML = r.message; }
                    catch(e) { result.className='test-result err'; result.innerHTML='解析错误'; }
                } else { result.className='test-result err'; result.innerHTML='网络错误 ' + xhr.status; }
            }
        };
        xhr.send(null);
    }
</script>
</asp:Content>
