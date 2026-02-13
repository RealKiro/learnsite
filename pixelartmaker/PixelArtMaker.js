$(function () {
    const PIXELCANVAS = $("#pixel_canvas");
    const PALETTE = $("#palette"); //color selection table
    const PALETTEB = $("#paletteB"); //color selection table
    const BODY = $("body");
    let colorPicker = "rgb(0, 0, 0)";
	let oldcolor;
	
    $("#colorPicker").on("change", function (e) {
        colorPicker = $(e.target).val();		
    });
		
    $("#colorPicker").on("input", function (e) {
        colorPicker = $(e.target).val();		
    });	
	
    // determine wether mouse is down or not
    let mouseDown = false;
	let mouseright=false;
	let mousegrid=true;
	let userid="pixel"+id;
	let usercount="imgcount";
	let imgcount=0;
	let imgpos=1;
	let canvaswidth=50;
	let canvasheight=36;
	let countframe=1;
	let currentframe="#fm"+countframe;
	var framearray=new Array();
	let flagplay=true;	
	let userallframe=userid+id;	

    PIXELCANVAS.on("mousedown", function (event) {
		if(event.button == 0){
			mouseDown = true;
			//console.log("左键");
			$(this).css("cursor", "url(../PixelArtMaker/pen.png) 0 16 ,pointer");
			return false; //this stops a bug where continuous painting sometimes occurred when mouse was not held down
		}else if(event.button == 2){
			mouseright = true;
			//console.log("右键");
			$(this).css("cursor", "url(../PixelArtMaker/eraser.png) 0 16 ,pointer");
			return false; //this stops a bug where continuous painting sometimes			
		}
    });

    PIXELCANVAS.on("mouseup", function (event) {
		saveimg();
		$(this).css("cursor", "url(../PixelArtMaker/pen.png) 0 16 ,pointer");
    });
	function saveimg(){	
		imgcount++;	
		var img=PIXELCANVAS.html();
		imgpos=imgcount;

		if (imgcount>10) {
			localStorage.clear();
			imgpos=imgcount=0;
		}
		var userimg=userid+currentframe+"at"+imgcount;
		var allframe=compessframe();	
		localStorage.setItem(userimg,img);
		localStorage.setItem(usercount,imgcount);		
		localStorage.setItem(userallframe,allframe);	
		snapshot(img);
		console.log("第",imgcount,"次临时保存");
		//console.log(framearray);
	}
	
	function history() {
		var imgcountset=localStorage.getItem(usercount);	
		if(imgcountset!=null){imgcount=parseInt(imgcountset);}
		
		if(imgpos<1){ imgpos=1;}		
		if(imgpos>imgcount){ imgpos=imgcount;}
		
		var userimg=userid+currentframe+"at"+imgpos;
		
		var img=localStorage.getItem(userimg);
		if(img!=null){
			PIXELCANVAS.html(img);
		}
	}	
	
	function compessframe()
	{
		let farr=new Array();
		
		framearray.forEach(function(item){
			let arr = new Array();
			let tds=item+" td";
			$(tds).each(function(){
				let bgcolor=$(this).css('background-color');
				const regex = /\((.*?)\)/; // 定义正则表达式，其中 \() 表示左括号，(.*?) 表示非贪婪模式匹配任意字符，\( \) 表示右括号
				const matchResult = bgcolor.match(regex); // 使用 match 函数进行匹配
				let cl=matchResult[1];				
				if(cl=="0, 0, 0, 0"){
					cl="";
				}			
				if(cl=="0,0,0"){
					cl=" ";
				}
				
				arr.push(cl);
			})
			farr.push(arr);
			//console.log(tds);
		})
		console.log("开始压缩编码工作===================");
		//console.log("数组",farr);
		//console.log("数组字节数",Math.round(farr.toString().length/1024),"kb");
		let str=JSON.stringify(farr);//数组转JSON字符串
		//console.log("json编码",Math.round(str.length/1024),"kb");
		
		var res = LZString144.compress(str);//JSON字符串lz压缩
		//console.log("LZString",Math.round(res.length/1024),"kb");
		//var two= strToBinary(res);//lz压缩转二进制字符串
		
		//console.log("二进制",Math.round(two.length/1024),"kb");
		//console.log(two);
		
		var three=stringToHex(res);
		//console.log(three);
		//console.log("字符转十六进制",Math.round(three.length/1024),"kb");
		
		//var dethree=hexToString(three);
		//console.log(dethree);
		//console.log("十六进制转字符",Math.round(dethree.length/1024),"kb");
		
		
		//console.log("开始编码解压工作===================");
		//开始解压工作
		//var one =binaryToStr(two);//二进制字符串转字符
		//console.log("one",one.length/1024);
		//var onede= LZString144.decompress(one);//lz解压为JSON字符串
		//console.log("onede",onede.length/1024);
		//let onearr=new Array();
		//onearr= JSON.parse(onede);//JSON字符串转数组
		
		
		//console.log("数组转字符串", strToBinary(farr.toString()).length/1024);
		
		
		//str= btoa(str);
		//console.log("btoa",str.length/1024);				
		
		return three;
	}
	
	function stringToHex(str){
		let list = str.split('');
		return list.map(item => {
			return item.charCodeAt().toString(16);
		}).join(' ');
　　}
	
	function hexToString(str){		
		var result = [];
		var list = str.split(" ");
		for(var i=0;i<list.length;i++){
			 var item = list[i];
			 var asciiCode = parseInt(item,16);
			 var charValue = String.fromCharCode(asciiCode);
			 result.push(charValue);
		}
		return result.join("");
　　}
	
	function uncompessframe(three)
	{	//开始解压工作
		//console.log(three);
		console.log("开始解压编码工作===================");
		//console.log("十六进制",Math.round(three.length/1024),"kb");
		var one =hexToString(three);//十六进制字符串转字符
		//console.log("LZString",Math.round(one.length/1024),"kb");
		var onede= LZString144.decompress(one);//lz解压为JSON字符串
		//console.log("json编码",Math.round(onede.length/1024),"kb");
		let onearr=new Array();
		onearr= JSON.parse(onede);//JSON字符串转数组
		//console.log("数组",onearr);
		//console.log("数组字节数",Math.round(onearr.toString().length/1024),"kb");
	
		var farr= onearr;
		//console.log("解码");
		//console.log(farr);
		let cf=1;
		framearray=new Array();
		farr.forEach(function(item){	
			let arr = item;
			let len=arr.length;
			let count=0;
			let tds="#pixel_canvas td";
			$(tds).each(function(){
				let cl=arr[count];
				if(cl==""){
					cl="0, 0, 0, 0";
				}			
				if(cl==" "){
					cl="0,0,0";
				}
				
				cl="rgba("+cl+")";
				$(this).css("background-color", cl);
				//console.log(cl);
				count++;
			})
			
			var img=PIXELCANVAS.html();
			var imgthumb=img.replaceAll("cell","cellthumb");
			imgthumb="<table>"+imgthumb+"</table>";
			if(cf>1){
				var framehtml=`<div id="fm${cf}" class="frame"></div>`;		
				$("#framelist").append(framehtml);	
			}
			let currentframe="#fm"+cf;
			framearray.push(currentframe);
			cf++;			
			$(currentframe).html(imgthumb);
		})
		countframe=framearray.length;
		console.log("动画帧数：共",countframe,"桢");
		thumbview();
	}
	
	
	$(document).ready(function(){
        palette();
		paletteB();
		makeGrid();
		if(pixfile!=""){
			uncompessframe(pixfile);
			console.log("读取像素动画成功！");				
		}

		else{
			var imgall=localStorage.getItem(userallframe);
			if(imgall!=null){
				uncompessframe(imgall);
				console.log("恢复缓存像素动画成功！");
				//setTimeout(()=>alert("从临时缓存里恢复，请立即保存！"),1000);
			}
			else{				
				framearray.push(currentframe);
			}
		}	

        $("#framelist").sortable({
			cursor:"move",
			items:".frame",
			opacity:0.6,
			revert:true,
			update:function(event,ui){
				const newarr=$(this).sortable("toArray");
				framearray= newarr.map(item=>`#${item}`);
				//console.log("排序",framearray);
			}
		})

	});
	
	var animate=null;
	$("#playbtn").on("click", function (e) {
		if(flagplay){
			console.log("动画开始");
			this.innerText="停止";
			let flen=framearray.length;
			console.log("动画帧数：共",flen,"帧");
			let index=0;
			animate = setInterval(function(){
				if(index<flen){
					$(".frame").css("opacity", "0.6");
					const framename=framearray[index];
					$(framename).css("opacity", "1");
					let fimg=$(framename).html();
					fimg=fimg.replaceAll("cellthumb","cell");
					PIXELCANVAS.html(fimg);
					index++;
					//console.log("第",index,"帧",framename);
				}
				else {
					index=0;
				}
			},500);
			flagplay=false;
		}
		else{
			clearInterval(animate);
			console.log("动画结束");
			this.innerText="播放";
			flagplay=true;
		}		
	});
	
	function getframename(){
		var num=framearray.indexOf(currentframe)+1;
		return "第"+num+"帧";
	}
	
	$("#framelist").on("click", ".frame", function (e) {	
		if(!flagplay){
			clearInterval(animate);
			console.log("动画结束");
			$("#playbtn").text("播放");
			flagplay=true;			
		}
		currentframe="#"+this.id;
		let fimg=$(currentframe).html();
		//console.log(fimg);
		fimg=fimg.replaceAll("cellthumb","cell");
		PIXELCANVAS.html(fimg);
		console.log("当前帧：",getframename());			
		$(".frame").css("opacity", "0.6");
		$(currentframe).css("opacity", "1");

    });	
	
	$("#plus").on("click", function (e) {
		if(framearray.length<9){
			let fimg=$(currentframe).html();
			countframe++;	
			var framehtml=`<div id="fm${countframe}" class="frame"></div>`;	
			
			$("#framelist").append(framehtml);			
			currentframe=`#fm${countframe}`;
			$(currentframe).html(fimg);
			framearray.push(currentframe);
			console.log("复制帧",currentframe);			
			$(".frame").css("opacity", "0.6");
			$(currentframe).css("opacity", "1");
		}
		//console.log(framearray);	
    });	
	
	$("#minus").on("click", function (e) {
		if(framearray.length>1){		
			$(currentframe).remove();
			framearray=framearray.filter(function(item){
				return item!==currentframe
			});
			console.log("删除帧",currentframe);
			console.log("所有帧",framearray);
			currentframe=framearray.at(-1);
			console.log("最后帧",currentframe);
			thumbview();
		}
    });	
	
	function snapshot(img)
	{ 
		$(currentframe).css("opacity", "1");
		//console.log(currentframe);	
		img=PIXELCANVAS.html();
		var imgthumb=img.replaceAll("cell","cellthumb");
		imgthumb="<table>"+imgthumb+"</table>";
		$(currentframe).html(imgthumb);
	}
	
	function thumbview()
	{
		$(currentframe).css("opacity", "1");
		currentframe=currentframe ;
		let thumb=$(currentframe).html();
		console.log("当前帧：",getframename());	
		var imgthumb=thumb.replaceAll("cellthumb","cell");
		PIXELCANVAS.html(imgthumb);
	}
	
    BODY.on("mouseup", function () {
        mouseDown = false;
		mouseright = false;
    });
	
    //fill PALETTE with colours
	const colorArr = [
		"rgb(0,0,0)",
		"rgb(34,32,52)",
		"rgb(69,40,60)",
		"rgb(102,57,49)",
		"rgb(143,86,59)",
		"rgb(223,113,38)",
		"rgb(217,160,102)",
		"rgb(238,195,154)",
		"rgb(229,184,7)",
		"rgb(251,242,54)",
		"rgb(153,229,80)",
		"rgb(73,210,73)",
		"rgb(106,190,48)",
		"rgb(55,148,110)",
		"rgb(75,105,47)",
		"rgb(82,75,36)",
		"rgb(50,60,57)",
		"rgb(63,63,116)",
		"rgb(48,96,130)",
		"rgb(91,110,225)",
		"rgb(99,155,255)",
		"rgb(95,205,228)",
		"rgb(203,219,252)",
		"rgb(255,255,255)",
		"rgb(155,173,183)",
		"rgb(132,126,135)",
		"rgb(105,106,106)",
		"rgb(89,86,82)",
		"rgb(118,66,138)",
		"rgb(172,50,50)",		
		"rgb(215,28,28)",
		"rgb(217,87,99)",
		"rgb(215,123,186)",
		"rgb(143,151,74)",
		"rgb(138,111,48)"
	];
    function colorPalette() {
        let hue;
        let i;
        for (i = 0; i < colorArr.length; i += 1) {
            hue = colorArr[i];
							
			if(i==0){				
				$(".palette:first")
					.css("background-color", hue)
					.removeClass("palette")
					.addClass("paletteFull")					
					.css("border-width", "2px");
			} else{
				$(".palette:first")
					.css("background-color", hue)
					.removeClass("palette")
					.addClass("paletteFull");				
			}
        }
		
    }
    // make cells for colour palette
    function palette() {
        PALETTE.children().remove();
        PALETTE.prepend("<tr></tr>");
        const tr = $("tr");
        let i;
        for (i = 1; i <= colorArr.length; i += 1) {
			tr.first().append('<td class="palette"></td>');
        }

        colorPalette();
    }
    function makeGrid() {		
        const ROW = canvasheight ;
        const COLUMN = canvaswidth;
        //remove old grid (if any)
        PIXELCANVAS.children().remove();
        //build grid
        let j;
        for (j = 0; j < ROW; j += 1) {
            PIXELCANVAS.append("<tr></tr>");
            const tr = $("tr");
            let i;
            for (i = 0; i < COLUMN; i += 1) {
				var id="r"+j+"c"+i
                tr.last().append("<td id='"+id+"' class='cell'></td>");
            }
        }
    }
	
	$("#logo").on("click", function (e) {
		//$(".cell").css("background-color", colorPicker);
		$("#petcolor").toggle();
    });
	
   //paint when a cell is clicked

	
    PIXELCANVAS.on("click", ".cell", function (e) {	
        const CURRENTCOLOR = oldcolor;
        //current cell will change color
        if (CURRENTCOLOR === "rgba(0, 0, 0, 0)") {
            $(e.target).css("background-color", colorPicker);
			oldcolor=colorPicker;
        }else {
			if(CURRENTCOLOR===colorPicker){			
            $(e.target).css("background-color", "rgba(0, 0, 0, 0)");
			oldcolor="rgba(0, 0, 0, 0)";
			}else{				
				$(e.target).css("background-color", colorPicker);
				oldcolor=colorPicker;
			}
        }
		snapshot();
		voice();
    });
	
	
    // paint when mouse held down
    PIXELCANVAS.on("mouseenter", ".cell", function (e) {
		oldcolor=$(this).css("background-color");
        if (mouseDown === true ) {
            $(e.target).css("background-color", colorPicker);
			oldcolor=colorPicker;			
        }
		if(!mouseright){
			$(this).css("background-color",colorPicker);
		}
    });
	
	    // paint when mouse held down
    PIXELCANVAS.on("mouseout", ".cell", function (e) {
		$(this).css("background-color",oldcolor);
        if (mouseDown === true) {
            $(e.target).css("background-color", colorPicker);
			oldcolor=colorPicker;
			
        }else if(mouseright === true){			
			$(e.target).css("background-color", "rgba(0, 0, 0, 0)");
			oldcolor="rgba(0, 0, 0, 0)";
		}
    });
	
    // When a PALETTE cell is clicked, colorPicker value is that colour
    PALETTE.on("click", ".paletteFull", function (e) {
        colorPicker = $(e.target).css("background-color");
		$("#colorPicker").val(colorPicker.colorHex());
	
		$(".paletteFull").css("border-width", "2px");
		$(e.target).css("border-top-width", "0px");
    });
		
    PALETTEB.on("click", ".paletteFull", function (e) {
        colorPicker = $(e.target).css("background-color");
		$("#colorPicker").val(colorPicker.colorHex());
	
		$(".paletteFull").css("border-top-color", "black");
		$(e.target).css("border-top-color", "white");
    });
	
	String.prototype.colorHex = function () {
		// RGB颜色值的正则
		var reg = /^(rgb|RGB)/;
		var color = this;
		if (reg.test(color)) {
		var strHex = "#";
		// 把RGB的3个数值变成数组
		var colorArr = color.replace(/(?:\(|\)|rgb|RGB)*/g, "").split(",");
		// 转成16进制
		for (var i = 0; i < colorArr.length; i++) {
		var hex = Number(colorArr[i]).toString(16);
		if (hex === "0") {
		hex += hex;
		}
		strHex += hex;
		}
		return strHex;
		} else {
			return String(color);
		}
	};
	
	
	$('#main').bind('contextmenu', function() {
        return false;
    });
	
	function voice() {
		var audio = document.createElement("audio");
		audio.src = '../PixelArtMaker/draw.ogg';
		audio.play();
	}
			
	document.addEventListener('copy', function(e) {
		e.preventDefault();
		var img=PIXELCANVAS.html();
		e.clipboardData.setData('text', img);
		console.log("copy");
	});
	document.addEventListener('paste', function(e) {
		var img=e.clipboardData.getData('text');
		if(img!=null){
			PIXELCANVAS.html(img);
			console.log("paste");
		} else {
			history();			
		}
	});

	function savetopng(){
		var gif = new GIF({
			workers:2, // 并行处理数量
			quality: 10, // 输出图片质量 (0 - 1)
		});
		
		var begin=new Date();
		var allframe=compessframe();				
		$(".frame").css("opacity", "1");
		//console.log(framearray);
		framearray.forEach((item,index)=>{	
			var canvas = savecanvas(item);	
			gif.addFrame(canvas);
			if(index==framearray.length-1){
				gif.render();
			}
		})
		
		gif.on('finished', function(cover) {
			//window.open(URL.createObjectURL(cover));		  		
			$(".frame").css("opacity", "0.6");
			$(currentframe).css("opacity", "1");			
			upload(cover,allframe);
			var end=new Date();			
			console.log(end-begin,'毫秒生成动画成功!');
		});
					
	}
	
	function upload(cover,allframe){
		if(id){
			var urls = 'uploadpixel.ashx?id=' + id;
			var formData = new FormData();
			formData.append('title', '');
			formData.append('cover', cover);
			formData.append('content', allframe);
			formData.append('ext', 'pxl');			

			$.ajax({
				url: urls,
				type: 'POST',
				cache: false,
				data: formData,
				processData: false,
				contentType: false
			}).done(function (res) {
				alert("保存成功！");
				console.log(res)
			});
		}
	}
	
    	//表格图片二倍放大后转canvas
	function savecanvas(item){		
		var framename=item+" td";
		let pixeldata=[];	
		let tdarr=[];
		$(framename).each(function(){
			var tdcolor =$(this).css("background-color");	
			tdarr.push(tdcolor);
		});
		
		let t=tdarr.length*4;
		let tdarrdouble=[];
		for(var i=0;i<30;i++){
			for(var j=0;j<50;j++){
				tdarrdouble.push(tdarr[50*i+j]);
				tdarrdouble.push(tdarr[50*i+j]);				
			}
			for(var j=0;j<50;j++){
				tdarrdouble.push(tdarr[50*i+j]);
				tdarrdouble.push(tdarr[50*i+j]);				
			}
		}
					
		for(var k=0;k<t;k++){
			colorTodata(pixeldata,tdarrdouble[k]);
		}
		
		let cv = document.createElement("canvas");
		//cv.className ="canvascap";
		cv.width=100;
		cv.height=60;
		let ctx=cv.getContext("2d");
		var ImageData = ctx.getImageData(0,0,cv.width,cv.height);
		for(var i=0;i<pixeldata.length;i++){
			ImageData.data[i]=pixeldata[i];
		}
		for(var i = 0; i < ImageData.data.length; i += 4) {
			// 当该像素是透明的，则设置成白色
			if(ImageData.data[i + 3] == 0) {
				ImageData.data[i] = 255;
				ImageData.data[i + 1] = 255;
				ImageData.data[i + 2] = 255;
				ImageData.data[i + 3] = 255; 
			}
		}
		ctx.putImageData(ImageData,0,0);		
		return cv;
	}

    function colorTodata(pixeldata,cr){
		if(cr!=null){
			let str = cr.match(/[^\(\)]+(?=\))/g);
			//console.log(str);
			let strp=str[0].split(",");
			let n=strp.length;
			pixeldata.push(strp[0]);
			pixeldata.push(strp[1]);
			pixeldata.push(strp[2]);
			if(n===4){
				pixeldata.push(strp[3]);
			}
			else{
				pixeldata.push(255);
			}		
		}
	}

	function blob(dataURI) {
        var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]; 
        var byteString = atob(dataURI.split(',')[1]); 
        var arrayBuffer = new ArrayBuffer(byteString.length); 
        var intArray = new Uint8Array(arrayBuffer); 

        for (var i = 0; i < byteString.length; i++) {
            intArray[i] = byteString.charCodeAt(i);
        }
        return new Blob([intArray], {type: mimeString});
    }
	
	$(document).keydown(function(event){
        var keyNum = event.which;   //获取键值
        switch(keyNum){  //判断按键
        case 37: console.log("左"); imgpos--;history(); break;
        case 39: console.log("右");imgpos++;history();break;
        case 119: console.log("保存");savetopng();break;
		case 46:
			$(".cell").css("background-color", "rgba(0, 0, 0, 0)");
			snapshot();
			break			
        default:
            break;        
        }
    });
	

	$("#savebtn").on("click", function (e) {
        savetopng();
		//alert("保存成功！");
    });
	

	$("#returnbtn").on("click", function (e) {
        returnurl();
    });
	
	// make cells for colour palette
	
    function paletteB() {
        PALETTEB.children().remove();
        PALETTEB.append("<tr>");
        let i;
        for (i = 1; i <= colorBrr.length; i += 1) {
			colorBrr[i-1];
			PALETTEB.append('<td class="palette"></td>');
			if(i%10==0){
				PALETTEB.append('</tr><tr>');
			}
        }
		
		PALETTEB.append("</tr>");
        colorPaletteB();
    }
	
	function colorPaletteB() {
		let hex="";
		let i;
		for (i = 0; i < colorBrr.length; i += 1) {
			hex =colorBrr[i];	
			if(i==0){				
				$(".palette:first")
					.css("background-color", hex)
					.removeClass("palette")
					.addClass("paletteFull")					
					.css("border-width", "2px");
			} else{
				$(".palette:first")
					.css("background-color", hex)
					.removeClass("palette")
					.addClass("paletteFull");				
			}
		}
    }
		
	function hexToRgb(hex) {
	  let r = parseInt(hex.substring(1, 3), 16);
	  let g = parseInt(hex.substring(3, 5), 16);
	  let b = parseInt(hex.substring(5, 7), 16);
	  let rgb="rgb("+r+","+g+","+b+")";
	  return rgb;
	}	
	
	//273颜色
	const colorBrr =[
		"rgb(244,67,54)",
		"rgb(255,235,238)",
		"rgb(255,205,210)",
		"rgb(239,154,154)",
		"rgb(229,115,115)",
		"rgb(239,83,80)",
		"rgb(244,67,54)",
		"rgb(229,57,53)",
		"rgb(211,47,47)",
		"rgb(198,40,40)",
		"rgb(183,28,28)",
		"rgb(255,138,128)",
		"rgb(255,82,82)",
		"rgb(255,23,68)",
		"rgb(213,0,0)",
		"rgb(233,30,99)",
		"rgb(252,228,236)",
		"rgb(248,187,208)",
		"rgb(244,143,177)",
		"rgb(240,98,146)",
		"rgb(236,64,122)",
		"rgb(233,30,99)",
		"rgb(216,27,96)",
		"rgb(194,24,91)",
		"rgb(173,20,87)",
		"rgb(136,14,79)",
		"rgb(255,128,171)",
		"rgb(255,64,129)",
		"rgb(245,0,87)",
		"rgb(197,17,98)",
		"rgb(156,39,176)",
		"rgb(243,229,245)",
		"rgb(225,190,231)",
		"rgb(206,147,216)",
		"rgb(186,104,200)",
		"rgb(171,71,188)",
		"rgb(156,39,176)",
		"rgb(142,36,170)",
		"rgb(123,31,162)",
		"rgb(106,27,154)",
		"rgb(74,20,140)",
		"rgb(234,128,252)",
		"rgb(224,64,251)",
		"rgb(213,0,249)",
		"rgb(170,0,255)",
		"rgb(103,58,183)",
		"rgb(237,231,246)",
		"rgb(209,196,233)",
		"rgb(179,157,219)",
		"rgb(149,117,205)",
		"rgb(126,87,194)",
		"rgb(103,58,183)",
		"rgb(94,53,177)",
		"rgb(81,45,168)",
		"rgb(69,39,160)",
		"rgb(49,27,146)",
		"rgb(179,136,255)",
		"rgb(124,77,255)",
		"rgb(101,31,255)",
		"rgb(98,0,234)",
		"rgb(63,81,181)",
		"rgb(232,234,246)",
		"rgb(197,202,233)",
		"rgb(159,168,218)",
		"rgb(121,134,203)",
		"rgb(92,107,192)",
		"rgb(63,81,181)",
		"rgb(57,73,171)",
		"rgb(48,63,159)",
		"rgb(40,53,147)",
		"rgb(26,35,126)",
		"rgb(140,158,255)",
		"rgb(83,109,254)",
		"rgb(61,90,254)",
		"rgb(48,79,254)",
		"rgb(33,150,243)",
		"rgb(227,242,253)",
		"rgb(187,222,251)",
		"rgb(144,202,249)",
		"rgb(100,181,246)",
		"rgb(66,165,245)",
		"rgb(33,150,243)",
		"rgb(30,136,229)",
		"rgb(25,118,210)",
		"rgb(21,101,192)",
		"rgb(13,71,161)",
		"rgb(130,177,255)",
		"rgb(68,138,255)",
		"rgb(41,121,255)",
		"rgb(41,98,255)",
		"rgb(3,169,244)",
		"rgb(225,245,254)",
		"rgb(179,229,252)",
		"rgb(129,212,250)",
		"rgb(79,195,247)",
		"rgb(41,182,246)",
		"rgb(3,169,244)",
		"rgb(3,155,229)",
		"rgb(2,136,209)",
		"rgb(2,119,189)",
		"rgb(1,87,155)",
		"rgb(128,216,255)",
		"rgb(64,196,255)",
		"rgb(0,176,255)",
		"rgb(0,145,234)",
		"rgb(0,188,212)",
		"rgb(224,247,250)",
		"rgb(178,235,242)",
		"rgb(128,222,234)",
		"rgb(77,208,225)",
		"rgb(38,198,218)",
		"rgb(0,188,212)",
		"rgb(0,172,193)",
		"rgb(0,151,167)",
		"rgb(0,131,143)",
		"rgb(0,96,100)",
		"rgb(132,255,255)",
		"rgb(24,255,255)",
		"rgb(0,229,255)",
		"rgb(0,184,212)",
		"rgb(0,150,136)",
		"rgb(224,242,241)",
		"rgb(178,223,219)",
		"rgb(128,203,196)",
		"rgb(77,182,172)",
		"rgb(38,166,154)",
		"rgb(0,150,136)",
		"rgb(0,137,123)",
		"rgb(0,121,107)",
		"rgb(0,105,92)",
		"rgb(0,77,64)",
		"rgb(167,255,235)",
		"rgb(100,255,218)",
		"rgb(29,233,182)",
		"rgb(0,191,165)",
		"rgb(76,175,80)",
		"rgb(232,245,233)",
		"rgb(200,230,201)",
		"rgb(165,214,167)",
		"rgb(129,199,132)",
		"rgb(102,187,106)",
		"rgb(76,175,80)",
		"rgb(67,160,71)",
		"rgb(56,142,60)",
		"rgb(46,125,50)",
		"rgb(27,94,32)",
		"rgb(185,246,202)",
		"rgb(105,240,174)",
		"rgb(0,230,118)",
		"rgb(0,200,83)",
		"rgb(139,195,74)",
		"rgb(241,248,233)",
		"rgb(220,237,200)",
		"rgb(197,225,165)",
		"rgb(174,213,129)",
		"rgb(156,204,101)",
		"rgb(139,195,74)",
		"rgb(124,179,66)",
		"rgb(104,159,56)",
		"rgb(85,139,47)",
		"rgb(51,105,30)",
		"rgb(204,255,144)",
		"rgb(178,255,89)",
		"rgb(118,255,3)",
		"rgb(100,221,23)",
		"rgb(205,220,57)",
		"rgb(249,251,231)",
		"rgb(240,244,195)",
		"rgb(230,238,156)",
		"rgb(220,231,117)",
		"rgb(212,225,87)",
		"rgb(205,220,57)",
		"rgb(192,202,51)",
		"rgb(175,180,43)",
		"rgb(158,157,36)",
		"rgb(130,119,23)",
		"rgb(244,255,129)",
		"rgb(238,255,65)",
		"rgb(198,255,0)",
		"rgb(174,234,0)",
		"rgb(255,235,59)",
		"rgb(255,253,231)",
		"rgb(255,249,196)",
		"rgb(255,245,157)",
		"rgb(255,241,118)",
		"rgb(255,238,88)",
		"rgb(255,235,59)",
		"rgb(253,216,53)",
		"rgb(251,192,45)",
		"rgb(249,168,37)",
		"rgb(245,127,23)",
		"rgb(255,255,141)",
		"rgb(255,255,0)",
		"rgb(255,234,0)",
		"rgb(255,214,0)",
		"rgb(255,193,7)",
		"rgb(255,248,225)",
		"rgb(255,236,179)",
		"rgb(255,224,130)",
		"rgb(255,213,79)",
		"rgb(255,202,40)",
		"rgb(255,193,7)",
		"rgb(255,179,0)",
		"rgb(255,160,0)",
		"rgb(255,143,0)",
		"rgb(255,111,0)",
		"rgb(255,229,127)",
		"rgb(255,215,64)",
		"rgb(255,196,0)",
		"rgb(255,171,0)",
		"rgb(255,152,0)",
		"rgb(255,243,224)",
		"rgb(255,224,178)",
		"rgb(255,204,128)",
		"rgb(255,183,77)",
		"rgb(255,167,38)",
		"rgb(255,152,0)",
		"rgb(251,140,0)",
		"rgb(245,124,0)",
		"rgb(239,108,0)",
		"rgb(230,81,0)",
		"rgb(255,209,128)",
		"rgb(255,171,64)",
		"rgb(255,145,0)",
		"rgb(255,109,0)",
		"rgb(255,87,34)",
		"rgb(251,233,231)",
		"rgb(255,204,188)",
		"rgb(255,171,145)",
		"rgb(255,138,101)",
		"rgb(255,112,67)",
		"rgb(255,87,34)",
		"rgb(244,81,30)",
		"rgb(230,74,25)",
		"rgb(216,67,21)",
		"rgb(191,54,12)",
		"rgb(255,158,128)",
		"rgb(255,110,64)",
		"rgb(255,61,0)",
		"rgb(221,44,0)",
		"rgb(121,85,72)",
		"rgb(239,235,233)",
		"rgb(215,204,200)",
		"rgb(188,170,164)",
		"rgb(161,136,127)",
		"rgb(141,110,99)",
		"rgb(121,85,72)",
		"rgb(109,76,65)",
		"rgb(93,64,55)",
		"rgb(78,52,46)",
		"rgb(62,39,35)",
		"rgb(158,158,158)",
		"rgb(238,238,238)",
		"rgb(224,224,224)",
		"rgb(189,189,189)",
		"rgb(158,158,158)",
		"rgb(117,117,117)",
		"rgb(97,97,97)",
		"rgb(66,66,66)",
		"rgb(33,33,33)",
		"rgb(96,125,139)",
		"rgb(236,239,241)",
		"rgb(207,216,220)",
		"rgb(176,190,197)",
		"rgb(144,164,174)",
		"rgb(120,144,156)",
		"rgb(96,125,139)",
		"rgb(69,90,100)",
		"rgb(55,71,79)",
		"rgb(38,50,56)"
	];
	
});
