<%@ page language="C#" autoeventwireup="true" inherits="student_chat, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>在线讨论</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" type="text/css" href="../code/imgchat/chat.css" />
    <script type="text/javascript" src="../code/jquery.min.js"></script>
<script type="text/javascript" src="../code/imgchat/fcup.min.js"></script>
<script type="text/javascript" src="../code/imgchat/jquery.lineProgressbar.js"></script>
    <link rel="stylesheet" type="text/css" href="../code/imgchat/jquery.lineProgressbar.css" />
</head>
<body>	
    <div class="imgBox" ></div>	
    <div class="content">
        <div class="chatBox">
            <div class="chatLeft">
                <div class="chat01">
                    <div class="chat01_title">
                        <ul class="talkTo">
                            <li><a href="javascript:;"> 小组讨论   <%=Sname %> </a></li>
							</ul>
                    </div>
                    <div class="chat01_content">
                        <div class="message_box mes" style="display: block;">
                        </div>
                    </div>
                </div>
                <div class="chat02">
                    <div class="chat02_title">					
                        <a class="chat02_title_btn ctb01" href="javascript:;" title="常用表情"></a>
                        <a class="chat02_title_btn ctb011" href="javascript:;" title="表情符号" ></a>						
						<a class="chat02_title_btn ctb02" id="upphoto" title="发送图片附件"> </a>						
                        <a class="chat02_title_t" id="chatrecord" title="聊天记录"></a>
						
                        <div class="wl_faces_box" title="选择表情" >
                            <div class="wl_faces_content">
                                <div class="title">
                                    <ul>
                                        <li class="title_name">常用表情</li><li class="wl_faces_close"><span>&nbsp;</span></li></ul>
                                </div>
                                <div class="wl_faces_main">
                                    <ul>                                          
                                       <asp:Repeater ID="Rpemo" runat="server">
                                        <ItemTemplate>
                                        <li>
                                            <a href="javascript:;"> <img src='<%# Eval("Emo") %>' /></a>
                                        </li>
                                        </ItemTemplate>
                                       </asp:Repeater>

                                    </ul>
                                </div>
                            </div>
                            <div class="wlf_icon">
                            </div>
                        </div>

                        <div class="wl_emo_box" >
                            <div class="wl_emo_content">
								<div class="title">
                                    <ul>
                                        <li class="title_name">表情符号</li>
									</ul>
                                </div>
                                <div class="wl_emo_main" title="双击添加">
								
                                </div>
                            </div>
                            <div class="wlf_emo">
                            </div>
                        </div>

                    </div>
                    <div class="chat02_content">
						<div class="textarea" name="chatword"  contenteditable="true"></div>
                    </div>
                    <div class="chat02_bar">
                        <ul>
                            <li style="left: 4px; ">
								<div id="progress"></div>
							</li>
                            <li style="right: 30px;"><button></button> </li>
                        </ul>
                    </div>
								<audio id="audio" hidden="true" ></audio>
                </div>
            </div>
            <div class="chatRight">
                <div class="chat03">
                    <div class="chat03_title">
                        <label class="chat03_title_t"><%=Sgtitle %></label>
                    </div>
                    <div class="chat03_content">
                        <ul>  
                           <asp:Repeater ID="Rpteam" runat="server">
                            <ItemTemplate>
                            <li id="<%# Eval("Snum") %>">
                                <label class="online"></label>
                                <a href="javascript:;"><img class="offline" src='<%# Eval("Avatar") %>'></a>
                                <a href="javascript:;" class="chat03_name"><%# Eval("Sname") %></a>
                            </li>
                            </ItemTemplate>
                           </asp:Repeater>
                        </ul>
                    </div>
                </div>
				
                <div class="chat03">
                    <div class="chat03_title">
                        <label class="chat03_title_f">附件管理</label>
                    </div>
                    <div class="chat03_file">
                        <ul> 
                           <asp:Repeater ID="Rpfile" runat="server">
                            <ItemTemplate>
                            <li>
                                <a href="javascript:;"><img src='<%# Eval("ftype") %>'></a>
                                <a href='<%# Eval("furl") %>' target='_blank' ><%# Eval("fname")%></a>
                            </li>
                            </ItemTemplate>
                           </asp:Repeater> 
                        </ul>
                    </div>
                </div>
				
            </div>
            <div style="clear: both;">
            </div>
        </div>
    </div>
	
    <script type="text/javascript">
        var head = "<%=Head %>"; 
        var sname = "<%=Sname %>"; 
        var snum = "<%=Snum %>"; 
        var sgtitle = "<%=Sgtitle %>"; 
        var sgroup = "<%=Sgroup %>";
        var historys = "<%=History %>";
        var serverip = "<%=serverIp %>";
    </script>	

    <script type="text/javascript" src="../code/imgchat/chat.js"></script>		

</body>
</html>
