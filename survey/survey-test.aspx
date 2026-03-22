<%@ Page Language="C#" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>GridView复选框测试</title>
    <style>
        body { font-family: 'Microsoft YaHei'; }
        table { border-collapse: collapse; width: 100%; margin: 20px; }
        th, td { border: 1px solid #ddd; padding: 12px; }
        th { background: #f5f5f5; }
        .info { padding: 20px; background: #e3f2fd; margin: 20px; border-radius: 8px; }
    </style>
</head>
<body>
    <div class="info">
        <h1>GridView复选框测试 (.NET 2.0)</h1>
        <p>如果下面的表格第一列能显示复选框，说明ASP.NET TemplateField工作正常。</p>
    </div>
    
    <form runat="server">
        <asp:GridView ID="TestGrid" runat="server" AutoGenerateColumns="False" CellPadding="5">
            <Columns>
                <asp:TemplateField HeaderText="选择">
                    <HeaderTemplate>
                        <input type="checkbox" id="checkAll" style="width: 18px; height: 18px; cursor: pointer;" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <input type="checkbox" class="row-checkbox" 
                            style="width: 18px; height: 18px; cursor: pointer;" />
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" Width="60px" />
                </asp:TemplateField>
                <asp:BoundField DataField="Id" HeaderText="ID">
                    <ItemStyle Width="80px" />
                </asp:BoundField>
                <asp:BoundField DataField="Name" HeaderText="名称" />
            </Columns>
        </asp:GridView>
    </form>
    
    <div class="info">
        <h2>调试信息</h2>
        <div id="debug"></div>
    </div>
    
    <script>
        window.onload = function() {
            var checkboxes = document.querySelectorAll('.row-checkbox');
            var debugDiv = document.getElementById('debug');
            debugDiv.innerHTML = '<p><strong>找到 ' + checkboxes.length + ' 个复选框</strong></p>';
            
            if (checkboxes.length > 0) {
                debugDiv.innerHTML += '<p style="color: green;">✅ 复选框渲染成功！</p>';
                debugDiv.innerHTML += '<p>这说明ASP.NET TemplateField可以正常工作。</p>';
            } else {
                debugDiv.innerHTML += '<p style="color: red;">❌ 复选框未渲染！</p>';
                debugDiv.innerHTML += '<p>这说明TemplateField有问题。</p>';
            }
        };
    </script>
    
    <script runat="server">
        public class TestData
        {
            private int _id;
            private string _name;
            
            public int Id
            {
                get { return _id; }
                set { _id = value; }
            }
            
            public string Name
            {
                get { return _name; }
                set { _name = value; }
            }
        }
        
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                List<TestData> data = new List<TestData>();
                
                TestData item1 = new TestData();
                item1.Id = 1;
                item1.Name = "测试题目1";
                data.Add(item1);
                
                TestData item2 = new TestData();
                item2.Id = 2;
                item2.Name = "测试题目2";
                data.Add(item2);
                
                TestData item3 = new TestData();
                item3.Id = 3;
                item3.Name = "测试题目3";
                data.Add(item3);
                
                TestGrid.DataSource = data;
                TestGrid.DataBind();
            }
        }
    </script>
</body>
</html>
