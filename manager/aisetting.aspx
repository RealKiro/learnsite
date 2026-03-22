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
            LoadQuizSettings();
            LoadLessonSettings();
            // 设置占位符
            TextBoxAiSystemPrompt.Attributes["placeholder"] = "欢迎使用learnsite！";
            TextBoxQuizSystemPrompt.Attributes["placeholder"] = "你是一位专业的信息技术教师，擅长出题。";
            TextBoxLessonSystemPrompt.Attributes["placeholder"] = "你是一位专业的信息技术教师，擅长编写教学学案。";
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
            CheckBoxAiEnabled.Checked = GetXmlValue(doc, "AiEnabled").ToLower() == "true";
            TextBoxAiApiUrl.Text = GetXmlValue(doc, "AiApiUrl");
            TextBoxAiApiKey.Text = GetXmlValue(doc, "AiApiKey");
            TextBoxAiModel.Text = GetXmlValue(doc, "AiModel");
            string temp = GetXmlValue(doc, "AiTemperature");
            TextBoxAiTemperature.Text = string.IsNullOrEmpty(temp) ? "0.7" : temp;
            string maxTokens = GetXmlValue(doc, "AiMaxTokens");
            TextBoxAiMaxTokens.Text = string.IsNullOrEmpty(maxTokens) ? "2000" : maxTokens;
            TextBoxAiSystemPrompt.Text = GetXmlValue(doc, "AiSystemPrompt");
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "加载失败: " + ex.Message;
        }
    }

    private void LoadQuizSettings()
    {
        try
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            CheckBoxQuizEnabled.Checked = GetXmlValue(doc, "AiQuizEnabled").ToLower() == "true";
            TextBoxQuizApiUrl.Text = GetXmlValue(doc, "AiQuizApiUrl");
            TextBoxQuizApiKey.Text = GetXmlValue(doc, "AiQuizApiKey");
            TextBoxQuizModel.Text = GetXmlValue(doc, "AiQuizModel");
            string temp = GetXmlValue(doc, "AiQuizTemperature");
            TextBoxQuizTemperature.Text = string.IsNullOrEmpty(temp) ? "0.7" : temp;
            string maxTokens = GetXmlValue(doc, "AiQuizMaxTokens");
            TextBoxQuizMaxTokens.Text = string.IsNullOrEmpty(maxTokens) ? "4000" : maxTokens;
            TextBoxQuizSystemPrompt.Text = GetXmlValue(doc, "AiQuizSystemPrompt");
            TextBoxQuizKeywords.Text = GetXmlValue(doc, "AiQuizKeywords");
        }
        catch (Exception ex)
        {
            LabelQuizMsg.ForeColor = System.Drawing.Color.Red;
            LabelQuizMsg.Text = "加载失败: " + ex.Message;
        }
    }

    private void LoadLessonSettings()
    {
        try
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            CheckBoxLessonEnabled.Checked = GetXmlValue(doc, "AiLessonEnabled").ToLower() == "true";
            TextBoxLessonApiUrl.Text = GetXmlValue(doc, "AiLessonApiUrl");
            TextBoxLessonApiKey.Text = GetXmlValue(doc, "AiLessonApiKey");
            TextBoxLessonModel.Text = GetXmlValue(doc, "AiLessonModel");
            string temp = GetXmlValue(doc, "AiLessonTemperature");
            TextBoxLessonTemperature.Text = string.IsNullOrEmpty(temp) ? "0.7" : temp;
            string maxTokens = GetXmlValue(doc, "AiLessonMaxTokens");
            TextBoxLessonMaxTokens.Text = string.IsNullOrEmpty(maxTokens) ? "4000" : maxTokens;
            TextBoxLessonSystemPrompt.Text = GetXmlValue(doc, "AiLessonSystemPrompt");
            TextBoxLessonKeywords.Text = GetXmlValue(doc, "AiLessonKeywords");
        }
        catch (Exception ex)
        {
            LabelLessonMsg.ForeColor = System.Drawing.Color.Red;
            LabelLessonMsg.Text = "加载失败: " + ex.Message;
        }
    }

    protected void BtnSave_Click(object sender, EventArgs e)
    {
        try
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            SetXmlValue(doc, "AiEnabled", CheckBoxAiEnabled.Checked ? "True" : "False");
            SetXmlValue(doc, "AiApiUrl", TextBoxAiApiUrl.Text.Trim());
            SetXmlValue(doc, "AiApiKey", TextBoxAiApiKey.Text.Trim());
            SetXmlValue(doc, "AiModel", TextBoxAiModel.Text.Trim());
            SetXmlValue(doc, "AiTemperature", TextBoxAiTemperature.Text.Trim());
            SetXmlValue(doc, "AiMaxTokens", TextBoxAiMaxTokens.Text.Trim());
            SetXmlValue(doc, "AiSystemPrompt", TextBoxAiSystemPrompt.Text.Trim());
            doc.Save(xmlPath);
            LabelMsg.ForeColor = System.Drawing.Color.FromArgb(5, 150, 105);
            LabelMsg.Text = "&#10004; 大模型配置已保存";
        }
        catch (Exception ex)
        {
            LabelMsg.ForeColor = System.Drawing.Color.Red;
            LabelMsg.Text = "保存失败: " + ex.Message;
        }
    }

    protected void BtnSaveQuiz_Click(object sender, EventArgs e)
    {
        try
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            SetXmlValue(doc, "AiQuizEnabled", CheckBoxQuizEnabled.Checked ? "True" : "False");
            SetXmlValue(doc, "AiQuizApiUrl", TextBoxQuizApiUrl.Text.Trim());
            SetXmlValue(doc, "AiQuizApiKey", TextBoxQuizApiKey.Text.Trim());
            SetXmlValue(doc, "AiQuizModel", TextBoxQuizModel.Text.Trim());
            SetXmlValue(doc, "AiQuizTemperature", TextBoxQuizTemperature.Text.Trim());
            SetXmlValue(doc, "AiQuizMaxTokens", TextBoxQuizMaxTokens.Text.Trim());
            SetXmlValue(doc, "AiQuizSystemPrompt", TextBoxQuizSystemPrompt.Text.Trim());
            SetXmlValue(doc, "AiQuizKeywords", TextBoxQuizKeywords.Text.Trim());
            doc.Save(xmlPath);
            LabelQuizMsg.ForeColor = System.Drawing.Color.FromArgb(5, 150, 105);
            LabelQuizMsg.Text = "&#10004; AI出题配置已保存";
        }
        catch (Exception ex)
        {
            LabelQuizMsg.ForeColor = System.Drawing.Color.Red;
            LabelQuizMsg.Text = "保存失败: " + ex.Message;
        }
    }
    protected void BtnSaveLesson_Click(object sender, EventArgs e)
    {
        try
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(xmlPath);
            SetXmlValue(doc, "AiLessonEnabled", CheckBoxLessonEnabled.Checked ? "True" : "False");
            SetXmlValue(doc, "AiLessonApiUrl", TextBoxLessonApiUrl.Text.Trim());
            SetXmlValue(doc, "AiLessonApiKey", TextBoxLessonApiKey.Text.Trim());
            SetXmlValue(doc, "AiLessonModel", TextBoxLessonModel.Text.Trim());
            SetXmlValue(doc, "AiLessonTemperature", TextBoxLessonTemperature.Text.Trim());
            SetXmlValue(doc, "AiLessonMaxTokens", TextBoxLessonMaxTokens.Text.Trim());
            SetXmlValue(doc, "AiLessonSystemPrompt", TextBoxLessonSystemPrompt.Text.Trim());
            SetXmlValue(doc, "AiLessonKeywords", TextBoxLessonKeywords.Text.Trim());
            doc.Save(xmlPath);
            LabelLessonMsg.ForeColor = System.Drawing.Color.FromArgb(5, 150, 105);
            LabelLessonMsg.Text = "&#10004; AI学案配置已保存";
        }
        catch (Exception ex)
        {
            LabelLessonMsg.ForeColor = System.Drawing.Color.Red;
            LabelLessonMsg.Text = "保存失败: " + ex.Message;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="Server">
<style>
    .ai-page { max-width:100%; padding:28px 32px 40px; font-family:'Microsoft YaHei','Segoe UI',-apple-system,Arial,sans-serif; }
    .ai-hd { display:flex; align-items:center; gap:16px; margin-bottom:28px; }
    .ai-hd-icon { width:48px; height:48px; background:linear-gradient(135deg,#8b5cf6,#7c3aed); border-radius:14px; display:flex; align-items:center; justify-content:center; box-shadow:0 4px 12px rgba(139,92,246,.25); flex-shrink:0; }
    .ai-hd-icon svg { width:26px; height:26px; stroke:#fff; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
    .ai-hd h1 { font-size:22px; font-weight:700; color:#0f172a; margin:0 0 2px; }
    .ai-hd p { font-size:13px; color:#94a3b8; margin:0; }

    .ai-grid { display:grid; grid-template-columns:1fr 320px; gap:20px; }
    @media (max-width:960px) { .ai-grid { grid-template-columns:1fr; } }

    .ai-card { background:#fff; border-radius:14px; border:1px solid #e2e8f0; box-shadow:0 1px 4px rgba(0,0,0,.04); overflow:hidden; margin-bottom:20px; }
    .ai-card:hover { box-shadow:0 8px 24px rgba(0,0,0,.07); }
    .ai-card-hd { padding:16px 22px; font-size:15px; font-weight:600; color:#1e293b; border-bottom:1px solid #f1f5f9; display:flex; align-items:center; gap:12px; }
    .ai-card-hd .ci { width:34px; height:34px; border-radius:10px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
    .ai-card-hd .ci svg { width:19px; height:19px; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; fill:none; }
    .ci.purple { background:#f5f3ff; } .ci.purple svg { stroke:#8b5cf6; }
    .ci.sky { background:#f0f9ff; } .ci.sky svg { stroke:#0ea5e9; }
    .ci.amber { background:#fffbeb; } .ci.amber svg { stroke:#f59e0b; }
    .ai-card-bd { padding:22px; }

    .ai-row { display:flex; align-items:center; padding:14px 0; border-bottom:1px solid #f8fafc; gap:14px; font-size:13.5px; }
    .ai-row:last-child { border-bottom:none; }
    .ai-label { min-width:110px; font-weight:500; color:#475569; flex-shrink:0; text-align:right; font-size:13px; }
    .ai-val { flex:1; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
    .ai-hint { font-size:11.5px; color:#94a3b8; margin-top:3px; line-height:1.5; }

    .ai-card input[type="text"] {
        height:38px; padding:0 14px; border:1.5px solid #e2e8f0; border-radius:9px;
        font-size:13.5px; font-family:inherit; outline:none; background:#f8fafc;
        transition: border-color .2s, box-shadow .2s; min-width:280px;
    }
    .ai-card input[type="text"]:focus { border-color:#8b5cf6; box-shadow:0 0 0 3px rgba(139,92,246,.08); background:#fff; }
    .ai-card input[type="text"].short { min-width:120px; width:120px; }
    .ai-card input[type="checkbox"] { width:17px; height:17px; accent-color:#8b5cf6; cursor:pointer; }
    .ai-card textarea {
        width:100%; min-height:100px; padding:12px 14px; border:1.5px solid #e2e8f0; border-radius:9px;
        font-size:13px; font-family:inherit; outline:none; background:#f8fafc; resize:vertical; line-height:1.8;
        transition: border-color .2s, box-shadow .2s;
    }
    .ai-card textarea:focus { border-color:#8b5cf6; box-shadow:0 0 0 3px rgba(139,92,246,.08); background:#fff; }

    /* Status badge */
    .ai-badge { display:inline-flex; align-items:center; gap:5px; padding:4px 12px; border-radius:20px; font-size:12px; font-weight:600; }
    .ai-badge.on { background:#ecfdf5; color:#059669; }
    .ai-badge.off { background:#fef2f2; color:#ef4444; }
    .ai-badge-dot { width:7px; height:7px; border-radius:50%; }
    .ai-badge.on .ai-badge-dot { background:#10b981; }
    .ai-badge.off .ai-badge-dot { background:#ef4444; }

    .ai-actions { padding:16px 22px; border-top:1px solid #f1f5f9; display:flex; align-items:center; gap:14px; }
    .btn-save {
        display:inline-flex; align-items:center; justify-content:center; gap:6px;
        height:40px; padding:0 28px;
        background:linear-gradient(135deg,#8b5cf6,#7c3aed); color:#fff!important;
        border:none; border-radius:10px; font-size:14px; font-family:inherit; font-weight:600;
        cursor:pointer; transition:all .2s; box-shadow:0 2px 8px rgba(139,92,246,.3);
    }
    .btn-save:hover { box-shadow:0 4px 16px rgba(139,92,246,.4); transform:translateY(-1px); }
    .ai-msg { font-size:13px; }

    /* Side */
    .ai-side-card { background:#fff; border-radius:14px; border:1px solid #e2e8f0; box-shadow:0 1px 4px rgba(0,0,0,.04); overflow:hidden; margin-bottom:16px; }
    .ai-side-hd { padding:14px 18px; font-size:14px; font-weight:600; color:#1e293b; border-bottom:1px solid #f1f5f9; display:flex; align-items:center; gap:10px; }
    .ai-side-bd { padding:16px 18px; font-size:13px; color:#64748b; line-height:2; }
    .ai-side-bd li { margin-bottom:4px; }

    .ai-tip-card { background:linear-gradient(135deg,#f5f3ff,#ede9fe); border:1px solid #ddd6fe; border-radius:14px; padding:18px; margin-bottom:16px; }
    .ai-tip-card h4 { font-size:14px; color:#5b21b6; margin:0 0 8px; display:flex; align-items:center; gap:8px; }
    .ai-tip-card p { font-size:12.5px; color:#6d28d9; line-height:1.8; margin:0; opacity:.8; }

    /* Tab nav */
    .ai-tabs { display:flex; gap:0; margin-bottom:24px; background:#fff; border-radius:12px; border:1px solid #e2e8f0; padding:4px; box-shadow:0 1px 4px rgba(0,0,0,.04); }
    .ai-tab { flex:1; display:flex; align-items:center; justify-content:center; gap:8px; padding:12px 20px; border-radius:9px; font-size:14px; font-weight:500; color:#64748b; cursor:pointer; transition:all .2s; border:none; background:transparent; user-select:none; }
    .ai-tab:hover { color:#7c3aed; background:#f5f3ff; }
    .ai-tab.active { background:linear-gradient(135deg,#8b5cf6,#7c3aed); color:#fff; box-shadow:0 2px 8px rgba(139,92,246,.3); }
    .ai-tab .tab-icon { width:20px; height:20px; flex-shrink:0; }
    .ai-tab .tab-icon svg { width:20px; height:20px; stroke:currentColor; fill:none; stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
    .ai-tab-panel { display:none; }
    .ai-tab-panel.active { display:block; }

    /* Preset buttons */
    .ai-presets { margin-top:16px; }
    .ai-presets-title { font-size:12px; color:#94a3b8; margin-bottom:8px; font-weight:500; }
    .ai-preset { display:inline-flex; align-items:center; padding:5px 12px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; font-size:12px; color:#475569; cursor:pointer; transition:all .15s; margin:0 6px 6px 0; }
    .ai-preset:hover { background:#f5f3ff; border-color:#ddd6fe; color:#7c3aed; }
</style>

<div class="ai-page">
    <div class="ai-hd">
        <div class="ai-hd-icon"><svg viewBox="0 0 24 24"><path d="M12 2a4 4 0 0 1 4 4v1h1a3 3 0 0 1 3 3v1a3 3 0 0 1-3 3h-1v4a4 4 0 0 1-8 0v-4H7a3 3 0 0 1-3-3v-1a3 3 0 0 1 3-3h1V6a4 4 0 0 1 4-4z"/><circle cx="9" cy="13" r="1"/><circle cx="15" cy="13" r="1"/></svg></div>
        <div><h1>大模型设置</h1><p>配置 AI 大语言模型的 API 参数，用于平台智能功能</p></div>
    </div>

    <!-- Tab 导航 -->
    <div class="ai-tabs">
        <div class="ai-tab active" onclick="switchTab('general',this)">
            <span class="tab-icon"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
            AI 通用模型
        </div>
        <div class="ai-tab" onclick="switchTab('quiz',this)">
            <span class="tab-icon"><svg viewBox="0 0 24 24"><path d="M12 2a4 4 0 0 1 4 4c0 1.95-1.4 3.58-3.25 3.93L12 22l-.75-12.07A4.001 4.001 0 0 1 12 2z"/><circle cx="12" cy="6" r="1"/></svg></span>
            AI 出题模型
        </div>
        <div class="ai-tab" onclick="switchTab('lesson',this)">
            <span class="tab-icon"><svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/><line x1="8" y1="7" x2="16" y2="7"/><line x1="8" y1="11" x2="14" y2="11"/></svg></span>
            AI 学案模型
        </div>
    </div>

    <div class="ai-grid">
        <div>
            <!-- === Tab: 通用模型 === -->
            <div id="tab-general" class="ai-tab-panel active">
            <!-- API 配置 -->
            <div class="ai-card">
                <div class="ai-card-hd">
                    <span class="ci purple"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
                    API 连接配置
                </div>
                <div class="ai-card-bd">
                    <div class="ai-row">
                        <div class="ai-label">启用 AI</div>
                        <div class="ai-val">
                            <asp:CheckBox ID="CheckBoxAiEnabled" runat="server" />
                            <span style="font-size:13px;color:#64748b;">开启后平台将启用 AI 相关功能</span>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">API 地址</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxAiApiUrl" runat="server" Width="400px" />
                            <div class="ai-hint">如 https://api.openai.com/v1 或其他兼容接口地址</div>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">API 密钥</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxAiApiKey" runat="server" Width="400px" />
                            <div class="ai-hint">填写服务商提供的 API Key，请妥善保管</div>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">模型名称</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxAiModel" runat="server" Width="280px" />
                            <div class="ai-hint">如 gpt-4o-mini、deepseek-chat、qwen-turbo 等</div>
                        </div>
                    </div>
                    <div class="ai-presets" style="padding-left:124px;">
                        <div class="ai-presets-title">快捷填入：</div>
                        <span class="ai-preset" onclick="fillPreset('https://api.openai.com/v1','gpt-4o-mini')">OpenAI</span>
                        <span class="ai-preset" onclick="fillPreset('https://api.deepseek.com/v1','deepseek-chat')">DeepSeek</span>
                        <span class="ai-preset" onclick="fillPreset('https://dashscope.aliyuncs.com/compatible-mode/v1','qwen-turbo')">通义千问</span>
                        <span class="ai-preset" onclick="fillPreset('https://open.bigmodel.cn/api/paas/v4','glm-4-flash')">智谱 GLM</span>
                        <span class="ai-preset" onclick="fillPreset('https://api.moonshot.cn/v1','moonshot-v1-8k')">Kimi</span>
                    </div>
                </div>
            </div>

            <!-- 模型参数 -->
            <div class="ai-card">
                <div class="ai-card-hd">
                    <span class="ci sky"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg></span>
                    模型参数
                </div>
                <div class="ai-card-bd">
                    <div class="ai-row">
                        <div class="ai-label">温度</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxAiTemperature" runat="server" Width="100px" CssClass="short" />
                            <div class="ai-hint">0~2 之间，值越低回答越确定，推荐 0.7</div>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">最大 Token</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxAiMaxTokens" runat="server" Width="120px" CssClass="short" />
                            <div class="ai-hint">单次回复最大长度，推荐 2000</div>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">关键词设置</div>
                        <div class="ai-val" style="flex-direction:column;align-items:stretch;">
                            <asp:TextBox ID="TextBoxAiSystemPrompt" runat="server" TextMode="MultiLine" Rows="4" />
                            <div class="ai-hint">设置 AI 的角色和行为规则，留空则使用默认</div>
                        </div>
                    </div>
                </div>
                <div class="ai-actions">
                    <asp:Button ID="BtnSave" runat="server" Text="保存配置" CssClass="btn-save" OnClick="BtnSave_Click" />
                    <span class="ai-msg"><asp:Label ID="LabelMsg" runat="server"></asp:Label></span>
                </div>
            </div>
            </div><!-- /tab-general -->

            <!-- === Tab: 出题模型 === -->
            <div id="tab-quiz" class="ai-tab-panel">
            <!-- AI出题模型配置 -->
            <div class="ai-card">
                <div class="ai-card-hd">
                    <span class="ci amber"><svg viewBox="0 0 24 24"><path d="M12 2a4 4 0 0 1 4 4c0 1.95-1.4 3.58-3.25 3.93L12 22l-.75-12.07A4.001 4.001 0 0 1 12 2z"/><circle cx="12" cy="6" r="1"/></svg></span>
                    AI 出题模型配置
                </div>
                <div class="ai-card-bd">
                    <div class="ai-row">
                        <div class="ai-label">启用出题</div>
                        <div class="ai-val">
                            <asp:CheckBox ID="CheckBoxQuizEnabled" runat="server" />
                            <span style="font-size:13px;color:#64748b;">开启后教师可在题库/试卷中使用 AI 出题</span>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">出题 API 地址</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxQuizApiUrl" runat="server" Width="400px" />
                            <div class="ai-hint">AI 出题专用 API 地址，留空则使用上方通用配置</div>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">出题 API 密钥</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxQuizApiKey" runat="server" Width="400px" />
                            <div class="ai-hint">AI 出题专用密钥，留空则使用上方通用密钥</div>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">出题模型</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxQuizModel" runat="server" Width="280px" />
                            <div class="ai-hint">AI 出题专用模型，留空则使用上方通用模型</div>
                        </div>
                    </div>
                    <div class="ai-presets" style="padding-left:124px;">
                        <div class="ai-presets-title">快捷填入：</div>
                        <span class="ai-preset" onclick="fillQuizPreset('https://api.openai.com/v1','gpt-4o-mini')">OpenAI</span>
                        <span class="ai-preset" onclick="fillQuizPreset('https://api.deepseek.com/v1','deepseek-chat')">DeepSeek</span>
                        <span class="ai-preset" onclick="fillQuizPreset('https://dashscope.aliyuncs.com/compatible-mode/v1','qwen-turbo')">通义千问</span>
                        <span class="ai-preset" onclick="fillQuizPreset('https://open.bigmodel.cn/api/paas/v4','glm-4-flash')">智谱 GLM</span>
                        <span class="ai-preset" onclick="fillQuizPreset('https://api.moonshot.cn/v1','moonshot-v1-8k')">Kimi</span>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">出题温度</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxQuizTemperature" runat="server" Width="100px" CssClass="short" />
                            <div class="ai-hint">出题推荐 0.7~1.0，值越高题目越多样</div>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">出题 MaxTokens</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxQuizMaxTokens" runat="server" Width="120px" CssClass="short" />
                            <div class="ai-hint">出题内容较长，推荐 4000</div>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">关键词设置</div>
                        <div class="ai-val" style="flex-direction:column;align-items:stretch;">
                            <asp:TextBox ID="TextBoxQuizSystemPrompt" runat="server" TextMode="MultiLine" Rows="4" />
                            <div class="ai-hint">AI 出题时的系统提示词，留空使用默认</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 出题关键词设置 -->
            <div class="ai-card">
                <div class="ai-card-hd">
                    <span class="ci sky"><svg viewBox="0 0 24 24"><line x1="4" y1="9" x2="20" y2="9"/><line x1="4" y1="15" x2="20" y2="15"/><line x1="10" y1="3" x2="8" y2="21"/><line x1="16" y1="3" x2="14" y2="21"/></svg></span>
                    出题关键词设置
                </div>
                <div class="ai-card-bd">
                    <div class="ai-row">
                        <div class="ai-label">关键词列表</div>
                        <div class="ai-val" style="flex-direction:column;align-items:stretch;">
                            <asp:TextBox ID="TextBoxQuizKeywords" runat="server" TextMode="MultiLine" Rows="3" />
                            <div class="ai-hint">逗号分隔，如：Python基础,Scratch动画,计算机网络,数据结构,信息安全。教师出题时可快速选择</div>
                        </div>
                    </div>
                </div>
                <div class="ai-actions">
                    <asp:Button ID="BtnSaveQuiz" runat="server" Text="保存出题配置" CssClass="btn-save" OnClick="BtnSaveQuiz_Click" />
                    <span class="ai-msg"><asp:Label ID="LabelQuizMsg" runat="server"></asp:Label></span>
                </div>
            </div>
            </div><!-- /tab-quiz -->

            <!-- === Tab: 学案模型 === -->
            <div id="tab-lesson" class="ai-tab-panel">
            <!-- AI学案模型设置 -->
            <div class="ai-card">
                <div class="ai-card-hd">
                    <span class="ci sky"><svg viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/><line x1="8" y1="7" x2="16" y2="7"/><line x1="8" y1="11" x2="14" y2="11"/></svg></span>
                    AI 学案模型设置
                </div>
                <div class="ai-card-bd">
                    <div class="ai-row">
                        <div class="ai-label">启用学案</div>
                        <div class="ai-val">
                            <asp:CheckBox ID="CheckBoxLessonEnabled" runat="server" />
                            <span style="font-size:13px;color:#64748b;">开启后教师可使用 AI 生成教学学案</span>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">学案 API 地址</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxLessonApiUrl" runat="server" Width="400px" />
                            <div class="ai-hint">AI 学案专用 API 地址，留空则使用上方通用配置</div>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">学案 API 密钥</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxLessonApiKey" runat="server" Width="400px" />
                            <div class="ai-hint">AI 学案专用密钥，留空则使用上方通用密钥</div>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">学案模型</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxLessonModel" runat="server" Width="280px" />
                            <div class="ai-hint">AI 学案专用模型，留空则使用上方通用模型</div>
                        </div>
                    </div>
                    <div class="ai-presets" style="padding-left:124px;">
                        <div class="ai-presets-title">快捷填入：</div>
                        <span class="ai-preset" onclick="fillLessonPreset('https://api.openai.com/v1','gpt-4o-mini')">OpenAI</span>
                        <span class="ai-preset" onclick="fillLessonPreset('https://api.deepseek.com/v1','deepseek-chat')">DeepSeek</span>
                        <span class="ai-preset" onclick="fillLessonPreset('https://dashscope.aliyuncs.com/compatible-mode/v1','qwen-turbo')">通义千问</span>
                        <span class="ai-preset" onclick="fillLessonPreset('https://open.bigmodel.cn/api/paas/v4','glm-4-flash')">智谱 GLM</span>
                        <span class="ai-preset" onclick="fillLessonPreset('https://api.moonshot.cn/v1','moonshot-v1-8k')">Kimi</span>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">学案温度</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxLessonTemperature" runat="server" Width="100px" CssClass="short" />
                            <div class="ai-hint">学案推荐 0.7~1.0，值越高内容越丰富</div>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">学案 MaxTokens</div>
                        <div class="ai-val">
                            <asp:TextBox ID="TextBoxLessonMaxTokens" runat="server" Width="120px" CssClass="short" />
                            <div class="ai-hint">学案内容较长，推荐 4000</div>
                        </div>
                    </div>
                    <div class="ai-row">
                        <div class="ai-label">关键词设置</div>
                        <div class="ai-val" style="flex-direction:column;align-items:stretch;">
                            <asp:TextBox ID="TextBoxLessonSystemPrompt" runat="server" TextMode="MultiLine" Rows="4" />
                            <div class="ai-hint">AI 生成学案时的系统提示词，留空使用默认</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 学案关键词设置 -->
            <div class="ai-card">
                <div class="ai-card-hd">
                    <span class="ci sky"><svg viewBox="0 0 24 24"><line x1="4" y1="9" x2="20" y2="9"/><line x1="4" y1="15" x2="20" y2="15"/><line x1="10" y1="3" x2="8" y2="21"/><line x1="16" y1="3" x2="14" y2="21"/></svg></span>
                    学案关键词设置
                </div>
                <div class="ai-card-bd">
                    <div class="ai-row">
                        <div class="ai-label">关键词列表</div>
                        <div class="ai-val" style="flex-direction:column;align-items:stretch;">
                            <asp:TextBox ID="TextBoxLessonKeywords" runat="server" TextMode="MultiLine" Rows="3" />
                            <div class="ai-hint">逗号分隔，如：Python基础,Scratch动画,计算机网络,数据结构,信息安全。教师生成学案时可快速选择</div>
                        </div>
                    </div>
                </div>
                <div class="ai-actions">
                    <asp:Button ID="BtnSaveLesson" runat="server" Text="保存学案配置" CssClass="btn-save" OnClick="BtnSaveLesson_Click" />
                    <span class="ai-msg"><asp:Label ID="LabelLessonMsg" runat="server"></asp:Label></span>
                </div>
            </div>
            </div><!-- /tab-lesson -->
        </div>

        <!-- 右侧 -->
        <div>
            <div class="ai-tip-card">
                <h4>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#5b21b6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2a4 4 0 0 1 4 4v1h1a3 3 0 0 1 3 3v1a3 3 0 0 1-3 3h-1v4a4 4 0 0 1-8 0v-4H7a3 3 0 0 1-3-3v-1a3 3 0 0 1 3-3h1V6a4 4 0 0 1 4-4z"/><circle cx="9" cy="13" r="1"/><circle cx="15" cy="13" r="1"/></svg>
                    AI 功能说明
                </h4>
                <p>配置大模型 API 后，平台可以提供 AI 辅助教学、智能批改等功能。请确保 API 密钥有效且有足够额度。</p>
            </div>

            <div class="ai-side-card">
                <div class="ai-side-hd">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0ea5e9" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    配置说明
                </div>
                <div class="ai-side-bd">
                    <ul style="padding-left:16px;">
                        <li><strong>API 地址</strong>：大模型服务的接口地址</li>
                        <li><strong>API 密钥</strong>：服务商提供的认证密钥</li>
                        <li><strong>模型名称</strong>：要使用的模型标识</li>
                        <li><strong>温度</strong>：控制回答的随机性</li>
                        <li><strong>系统提示词</strong>：定义 AI 的角色</li>
                    </ul>
                </div>
            </div>

            <div class="ai-side-card">
                <div class="ai-side-hd">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#f59e0b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                    安全提醒
                </div>
                <div class="ai-side-bd">
                    <ul style="padding-left:16px;">
                        <li>API 密钥是敏感信息，请勿泄露</li>
                        <li>建议定期检查 API 用量和费用</li>
                        <li>首次使用建议先用小额度测试</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    function switchTab(name, el) {
        var panels = document.querySelectorAll('.ai-tab-panel');
        for (var i = 0; i < panels.length; i++) panels[i].className = 'ai-tab-panel';
        var tabs = document.querySelectorAll('.ai-tab');
        for (var i = 0; i < tabs.length; i++) tabs[i].className = 'ai-tab';
        document.getElementById('tab-' + name).className = 'ai-tab-panel active';
        el.className = 'ai-tab active';
    }
    function fillPreset(apiUrl, model) {
        var u = document.getElementById('<%= TextBoxAiApiUrl.ClientID %>');
        var m = document.getElementById('<%= TextBoxAiModel.ClientID %>');
        if (u) u.value = apiUrl;
        if (m) m.value = model;
    }
    function fillQuizPreset(apiUrl, model) {
        var u = document.getElementById('<%= TextBoxQuizApiUrl.ClientID %>');
        var m = document.getElementById('<%= TextBoxQuizModel.ClientID %>');
        if (u) u.value = apiUrl;
        if (m) m.value = model;
    }
    function fillLessonPreset(apiUrl, model) {
        var u = document.getElementById('<%= TextBoxLessonApiUrl.ClientID %>');
        var m = document.getElementById('<%= TextBoxLessonModel.ClientID %>');
        if (u) u.value = apiUrl;
        if (m) m.value = model;
    }
</script>
</asp:Content>
