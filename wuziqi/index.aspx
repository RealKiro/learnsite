<%@ page language="C#" autoeventwireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">
    protected string grank = "";
    protected string guser = "游客";
    protected int gpass = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ShowBox();
        }
    }

    private void ShowBox()
    {
        // 获取学生姓名
        try
        {
            LearnSite.Model.Cook cook = new LearnSite.Model.Cook();
            if (cook.Sid > 0)
                guser = System.Web.HttpUtility.UrlDecode(cook.Sname);
        }
        catch { }

        // 计算登录时长（防止 TimePassed 因 Session/Cookie 中时间字符串为 null 而崩溃）
        try
        {
            gpass = LearnSite.Common.Computer.TimePassed();
        }
        catch
        {
            gpass = 0;
        }

        // 获取排行榜
        try
        {
            grank = GetGameRank();
        }
        catch { }
    }

    private string GetGameRank()
    {
        string result = "";
        string connStr = GetConnStr();
        if (string.IsNullOrEmpty(connStr)) return result;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            using (SqlCommand cmd = new SqlCommand(
                "SELECT TOP 10 Gsname, Gnum, Gdate FROM Game WHERE Gtitle=@Title ORDER BY Gnum ASC", conn))
            {
                cmd.Parameters.AddWithValue("@Title", "wuziqi");
                cmd.CommandTimeout = 5;
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    int rank = 1;
                    while (dr.Read())
                    {
                        result += string.Format("<br>{0}、{1} 步数:{2}",
                            rank, dr["Gsname"], dr["Gnum"]);
                        rank++;
                    }
                }
            }
        }
        return result;
    }

    private string GetConnStr()
    {
        string cs = null;
        try
        {
            System.Type dbType = typeof(LearnSite.Common.CookieHelp).Assembly
                .GetType("LearnSite.DBUtility.DbHelperSQL");
            if (dbType != null)
            {
                System.Reflection.FieldInfo f = dbType.GetField("connectionString",
                    System.Reflection.BindingFlags.Public |
                    System.Reflection.BindingFlags.NonPublic |
                    System.Reflection.BindingFlags.Static);
                if (f != null) cs = f.GetValue(null) as string;
            }
        }
        catch { }

        if (string.IsNullOrEmpty(cs))
        {
            try
            {
                cs = System.Configuration.ConfigurationManager
                    .ConnectionStrings["SqlServer"].ConnectionString;
            }
            catch { }
        }
        return cs;
    }
</script>
<!DOCTYPE html>
<html >
<head>
	<meta  charset="utf-8" name = "viewport" content = "user-scalable=no, initial-scale=1.0, maximum-scale=1.0, width=device-width">
	<link rel="icon" type="image/png" href="images/icon.png" />

	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

	<title>AI 五子棋</title>

	<link rel="stylesheet" href="style/jquery.mobile-1.2.0.min.css" />
	<script src="js/jquery-1.8.2.min.js"></script>
	<script src="js/jquery.mobile-1.2.0.min.js"></script>

	<link rel="stylesheet" href="style/w.min.css" />
	<link rel='stylesheet' href='style/style.css' type='text/css'/>

	<script src='js/Player.js' type='text/javascript'></script>
	<script src='js/Board.js' type='text/javascript'></script>
	<script src='js/Game.js' type='text/javascript'></script>
	<script src='js/layout.js' type='text/javascript'></script>
	<script src='js/interface.js' type='text/javascript'></script>
	<script src='js/storage.js' type='text/javascript'></script>
</head>
<body ontouchstart="">
<div class='fullscreen-wrapper' id='happy-outer'>
	<img src='images/happy.png' class='happy-face screen-center'>
</div>
<div class='fullscreen-wrapper' id='sad-outer'>
	<img src='images/sad.png' class='sad-face screen-center'>
</div>
<div data-role='page' data-theme='w' id='game-page' class='no-background'>
	<div data-role='content' class='center no-padding'>
		<div id='game-region'>
			<header class='game-ult'>AI 五子棋</header>
			<div id='game-info' class='game-ult ui-bar ui-bar-e'>
				<span class='go black'></span>
				<span class='cont'>请下棋</span>
			</div>
			<div id='main-but-group' class='game-ult'>			
				<header class='game-user'>游客</header>
				<br>
				<a href='#new-game' data-rel='dialog' data-role='button' data-icon="grid">开始新的一局</a>
				<br>
			</div>            
			<div id='other-but-group' class='game-ult'>
				<a href='#help-page' id='help-button' data-icon="star" data-role='button'>排行榜</a>
			</div>
			<div class='go-board' data-enhance=false>
				
			</div>
			<table class='board' data-enhance=false>
				<tbody>
					
				</tbody>
			</table>
		</div>
	</div>
</div>
<div id='game-won' data-theme='e' data-role='dialog'>
	<div data-role='header'>
		<h4>你赢了!</h4>
	</div>
	<div data-role='content'>
		<div id='win-content'>
			你赢了! 再来一局?
		</div>
		<fieldset class="ui-grid-a">
			<div class="ui-block-a"><button class='back-to-game'  data-theme='c'>返回</button></div>
			<div class="ui-block-b">
				<a href='#new-game' data-rel='dialog' data-role='button' data-icon="grid">
					开始新的一局
				</a>
			</div>	   
		</fieldset>
	</div>
</div>
<div id='new-game'  data-theme='e' data-role='dialog' class='long-dialog'>
	<div data-role='header'>
		<h4>新的一局</h4>
	</div>
	<div data-role='content'>
		<fieldset data-role="controlgroup"  data-theme='e' id='mode-select'>
			<legend>对局</legend>
				<input type="radio" name="radio-choice-1" id="radio-choice-1" value="vshuman"/>
				<label for="radio-choice-1">双人</label>

				<input type="radio" name="radio-choice-1" id="radio-choice-2" value="vscomputer"  />
				<label for="radio-choice-2">电脑</label>
		</fieldset> 
		
		<fieldset data-role="controlgroup" data-theme='e' id='color-select' class='vs-computer'>
			<legend>选择</legend>
				<input type="radio" name="radio-choice-1" id="radio-choice-2" value="black" data-theme='a'  />
				<label for="radio-choice-2">执黑</label>
				
				<input type="radio" name="radio-choice-1" id="radio-choice-1" value="white" data-theme='c' />
				<label for="radio-choice-1">执白</label>
		</fieldset>
		
		<fieldset data-role="controlgroup"  data-theme='e' id='level-select'  class='vs-computer'>
			<legend>难度</legend>
			
				<input type="radio" name="radio-choice-1" id="radio-choice-1" value="novice" />
				<label for="radio-choice-1">入门</label>

				<input type="radio" name="radio-choice-1" id="radio-choice-2" value="medium"  />
				<label for="radio-choice-2">中等</label>

				<input type="radio" name="radio-choice-1" id="radio-choice-3" value="expert"  />
				<label for="radio-choice-3">大师</label>
				
		</fieldset>
		<fieldset class="ui-grid-a">
			<div class="ui-block-a"><button class='back-to-game'  data-theme='c'>返回</button></div>
			<div class="ui-block-b"><button id='start-game'  data-theme='b'>开始</button></div>	   
		</fieldset>
	</div>
</div>

<audio id="myaudio" src="sound/pipa.mp3" controls="controls" autoplay loop="true" hidden="true" ></audio>		
<audio id="audio" controls="controls"  hidden="true" ></audio>
<div data-role='dialog' data-theme='e' id='help-page'>
	<div data-role='header'>
		<h4>五子棋高手排行榜</h4>
	</div>
	<div data-role='content' class='thin-content'>
		<div id="rank" class="move"> 
		排行榜：
		</div>
	</div>
</div>		
	<script type="text/javascript">
	    var grank = "<%=grank %>";
	    var guser = "<%=guser %>";
	    var gpass = "<%=gpass %>";
	    $(".game-user").html(guser);
	    $("#rank").html(grank);

	    if (gpass > 15) {
	        $('#start-game').prop('disabled', false);
	    }
	    else {
	        alert("当前已经登录" + gpass + "分钟，15分钟后才可以开始五子棋。");
	    }
    </script>
</body>
</html>


