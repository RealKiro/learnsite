<%@ page title="" language="C#" masterpagefile="~/student/Scm.master" autoeventwireup="true" stylesheettheme="Student" inherits="Student_description, LearnSite" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Cpcm" Runat="Server">
<div  id="showcontent">
<div class="centerdiv">
<br />
    <div   class="missiontitle">
    <asp:Label ID="LabelMtitle"  runat="server" ></asp:Label><br />
   </div>
   <div class="courseother">
   </div>   
    <link href="../kindeditor/plugins/syntaxhighlighter/styles/shCore.css" rel="stylesheet" type="text/css" />
    <link href="../kindeditor/plugins/syntaxhighlighter/styles/shThemeRDark.css" rel="stylesheet"   type="text/css" />
    <script src="../kindeditor/plugins/syntaxhighlighter/scripts/shCore.js" type="text/javascript"></script>
    <script src="../kindeditor/plugins/syntaxhighlighter/scripts/shBrushCss.js" type="text/javascript"></script>
    <script src="../kindeditor/plugins/syntaxhighlighter/scripts/shBrushJScript.js" type="text/javascript"></script>
    <script src="../kindeditor/plugins/syntaxhighlighter/scripts/shBrushVb.js" type="text/javascript"></script>
    <script src="../kindeditor/plugins/syntaxhighlighter/scripts/shBrushCSharp.js" type="text/javascript"></script>
    <script src="../kindeditor/plugins/syntaxhighlighter/scripts/shBrushCpp.js" type="text/javascript"></script>
    <script src="../kindeditor/plugins/syntaxhighlighter/scripts/shBrushPython.js" type="text/javascript"></script>
    <script src="../kindeditor/plugins/syntaxhighlighter/scripts/shBrushPhp.js" type="text/javascript"></script>
    <script src="../kindeditor/plugins/syntaxhighlighter/scripts/shBrushXml.js" type="text/javascript"></script>
    <script  type="text/javascript">        SyntaxHighlighter.all();  </script>
    <style>
        .star {
            font-size: 30px;
            cursor: pointer;
            color: #ddd;
            transition: color 0.2s;
        }

        .star:hover,
        .star.active {
            color: #ffd700;
        }  
    </style>
<div   id="Mcontent"  class="descriptioncontent" runat="server">	
</div>
<center>
    <div class="rating-text">
    学习评价：
        <span class="star" data-value="1">★</span>
        <span class="star" data-value="2">★</span>
        <span class="star" data-value="3">★</span>
        <span class="star" data-value="4">★</span>
        <span class="star" data-value="5">★</span>
    </div>
</center>
<br />
    <asp:Button ID="Btnread" runat="server" onclick="Btnread_Click" Text="确定" 
        ToolTip="选择后评价"  Enabled="False" BackColor="#3399FF" 
        BorderStyle="None" Height="24px" Width="80px"  />
		<br />
		<br />
    <input id="TextBoxStar" name="TextBoxStar" type="hidden"  value="0"/>
</div>   
</div>
    <script type="text/javascript">
        const stars = document.querySelectorAll('.star');
        var currentRating = 0;
        const mystar ="<%= mystar %>";

        stars.forEach(star => {
            star.addEventListener('click', setRating);
            star.addEventListener('mouseover', addHover);
            star.addEventListener('mouseout', removeHover);
        });

        
        function initRating() {
            if(mystar>0){
                stars.forEach(star => {
                    const starValue = parseInt(star.dataset.value);
                    star.classList.toggle('active', starValue <= mystar);
                });       
            }    
        }
        initRating();

        function setRating(e) {
            const value = parseInt(e.target.dataset.value);
            currentRating =value;
            stars.forEach(star => {
                const starValue = parseInt(star.dataset.value);
                star.classList.toggle('active', starValue <= value);
            });

            document.getElementById("TextBoxStar").value = value;
            setbar();             
        }

        function addHover(e) {
            if(mystar == 0){
                const hoverValue = parseInt(e.target.dataset.value);
                stars.forEach(star => {
                    const starValue = parseInt(star.dataset.value);
                    star.classList.toggle('active', starValue <= hoverValue);
                });
            }
        }

        function removeHover() {        
            if(mystar == 0){
                stars.forEach(star => {
                    const starValue = parseInt(star.dataset.value);
                    star.classList.toggle('active', starValue <= currentRating);
                });
            }
        }

        function setbar() {
            var btnid = "<%= Btnread.ClientID %>";
            if (document.getElementById(btnid) != null) {
                 document.getElementById(btnid).disabled = false;
            }
        }
            
    </script>
</asp:Content>

