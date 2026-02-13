<%@ page language="C#" autoeventwireup="true" inherits="student_myportfolio, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
      <title>作品集</title>
  <style>
    .box {
        display: flex;  
        flex-flow: column wrap;
        height: 100vh;
      }
      .item {
        margin: 10px;
        width: calc(100%/3 - 20px);
		text-align:center;
		box-shadow: rgba(149, 157, 165, 0.2) 0px 8px 24px;
      }
	  .item:hover{
		background-color:rgba(255, 199, 123, 0.2);
		box-shadow: rgba(149, 157, 165, 0.5) 0px 8px 24px;
	  }
      .item img{
        max-width:200px;
        max-height:200px;
		margin: 10px;
      }
      .item div{
		background-color:rgba(255, 199, 123, 0.1);
      }
  </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <h1 style=" text-align:center;">
            <asp:Label ID="Labeltitle" runat="server" Text=""></asp:Label>
        </h1>
        <div class="box">
            <asp:Repeater ID="RepeaterWork" runat="server">
            <ItemTemplate>
                <div class="item">
                    <asp:Image ID="Image1" ImageUrl='<%# Eval("Wthumbnail") %>' runat="server" />
					<div >
                    <span><%# Eval("Mtitle")%></span>
                    <span><%# Eval("Wdate") %></span>
					</div>
                </div>
            </ItemTemplate>
            </asp:Repeater>

        </div>
    </div>
    </form>
</body>
</html>

