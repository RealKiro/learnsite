function Axis(){
	
	var self = this;
	var app = null;
	this.keyPoint = new PIXI.Graphics();
	this.keyPoint.beginFill(0xff00ff,1);
	this.keyPoint.drawCircle(0,0,6);
	this.keyPoint.endFill();

	//关键点显示
	this.keyPointInfo = new PIXI.Graphics();
	this.keyPointInfo.beginFill(0xffffff,1);
	this.keyPointInfo.lineStyle(1, 0x000000, 1);
	this.keyPointInfo.drawRect(0, 0, 120, 40);
	this.keyPointInfo.endFill();
	//icon
	this.keyPointIcon = new PIXI.Graphics();
	this.keyPointIcon.beginFill(0xff00ff,1);
	this.keyPointIcon.drawCircle(0,0,6);
	this.keyPointIcon.endFill();
	this.keyPointInfo.addChild(this.keyPointIcon);
	this.keyPointIcon.x = 20;
	this.keyPointIcon.y = 20;

	var style = new PIXI.TextStyle( {
		fontFamily: 'Arial',
		fontSize: 16
	});
	//xinfo
	this.keyPointXTxt = new PIXI.Text("x: 0", style);
	this.keyPointInfo.addChild(this.keyPointXTxt);
	this.keyPointXTxt.x = 40;
	this.keyPointXTxt.y = 3;
	//yinfo
	this.keyPointYTxt = new PIXI.Text("y: 0", style);
	this.keyPointInfo.addChild(this.keyPointYTxt);
	this.keyPointYTxt.x = 40;
	this.keyPointYTxt.y = 19;

	//放大按钮
	this.preScaleX = 0;
	this.preScaleY = 0;
	this.fdBtn = new PIXI.Sprite.fromImage("axis/fd.png");
	this.fdBtn.x = 20;
	this.fdBtn.y = 15;
	this.fdBtn.interactive = true;
	this.fdBtn.buttonMode = true;
	this.fdBtn.on("click", function(e){
		//pixi中断事件冒泡
		e.stopPropagation();

		if(self.preScaleX == 0) {
			self.preScaleX = self.ScaleX;
			self.preScaleY = self.ScaleY;
		}
		self.ScaleX += self.preScaleX * 0.2;
		self.ScaleY += self.preScaleY * 0.2;

		self.setCenter(cx, cy);
		self.updateScaleShow();

		//回调更新model显示
		if(self.updateAxisCb) {
			self.updateAxisCb();
		}

		
		
		//self.drawModel(self.draw_model, self.draw_from, self.draw_to, self.draw_step, self.draw_scaleX, self.draw_scaleY);
	});

	//缩小按钮
	this.sxBtn = new PIXI.Sprite.fromImage("axis/sx.png");
	this.sxBtn.x = 70;
	this.sxBtn.y = 15;
	this.sxBtn.interactive = true;
	this.sxBtn.buttonMode = true;
	this.sxBtn.on("click", function(e){
		//pixi中断事件冒泡
		e.stopPropagation();

		if(self.preScaleX == 0) {
			self.preScaleX = self.ScaleX;
			self.preScaleY = self.ScaleY;
		}
		if(self.ScaleX - self.preScaleX * 0.2 <= 0) {
			return;
		}
		self.ScaleX -= self.preScaleX * 0.2;
		self.ScaleY -= self.preScaleY * 0.2;

		self.setCenter(cx, cy);
		self.updateScaleShow();

		//回调更新model显示
		if(self.updateAxisCb) {
			self.updateAxisCb();
		}

		
		//self.drawModel(self.draw_model, self.draw_from, self.draw_to, self.draw_step, self.draw_scaleX, self.draw_scaleY);
	});
	
	this.lineList = [];
	this.Scale = 50;
	this.ScaleX = 50;
	this.ScaleY = 50;

	var style = new PIXI.TextStyle( {
		fontFamily: 'Arial',
		fontSize: 16
	})
	this.xTxt = new PIXI.Text("", style);
	this.yTxt = new PIXI.Text("", style);
	this.stage = null;

	//坐标系支持提示
	//背景
    this.unSupportBg = new PIXI.Graphics();
	this.unSupportBg.visible = false;

	//文本提示
	var style = new PIXI.TextStyle( {
		fontFamily: 'Arial',
		fontSize: 26
	})
	this.unSupport = new PIXI.Text("只显示单输入、输出结构", style);
	this.unSupport.anchor.set(0.5);
	this.unSupport.visible = false;

	//只初始化
	this.initOnly = function(width, height, scale="100%") {
		this.stage = new PIXI.Container();
		var graphics = new PIXI.Graphics();
	
		graphics.beginFill(0xefefeb, 1);
		graphics.drawRect(0, 0, width, height);
		this.stage.addChild(graphics);
		this.initAxis(width, height, scale);

	}
	
	//获取容器
	this.getContainer = function() {
		return this.stage;
	}
	
	//内嵌到html
	this.init = function(divName, width, height, scale="100%"){
		app = new PIXI.Application(width,height,{backgroundColor : 0xefefeb});
		// app.view.style.width = scale;
		if(divName==null){
			document.body.appendChild(app.view);
		}else{
			document.getElementById(divName).appendChild(app.view);
		}
		this.stage = app.stage;

		this.initAxis(width, height, scale);

		//初始化关键点信息提示位置
		this.keyPointInfo.x = width - 140;
		this.keyPointInfo.y = 20;
	}

	this.initAxis = function(width, height, scale) {
		this.width = width;
		this.height = height;
		this.axisMap = new PIXI.Graphics();
		this.scaleMap = new PIXI.Graphics();
		this.pointMap = new PIXI.Graphics();
		this.pointMap2 = new PIXI.Graphics();
		this.rectMap = new PIXI.Graphics();
		this.imgContainer = new PIXI.Container();

		//画个背景，用于控制
		var bgControl = new PIXI.Graphics();
		bgControl.beginFill(0xefefeb, 1);
		bgControl.drawRect(0, 0, width, height);
		this.stage.addChild(bgControl);

		this.pointMap.lineStyle(1,0,1);
		this.pointMap2.lineStyle(1,0,1);
		this.stage.addChild(this.rectMap);

		//刻度
		this.stage.addChild(this.scaleMap);
		//坐标轴
		this.stage.addChild(this.axisMap);

		this.stage.addChild(this.keyLine);

		this.stage.addChild(this.pointMap2);
		this.stage.addChild(this.pointMap);
		this.stage.addChild(this.keyPoint);

		this.modelLine = this.createLine();
		this.modelLine.lineStyle(4,0xFF6B6B,1);

		//关键点显示
		this.stage.addChild(this.keyPointInfo);

		this.stage.addChild(this.imgContainer);

		//ui按钮
		this.stage.addChild(this.fdBtn);
		this.stage.addChild(this.sxBtn);

		//系统支持提示
		this.unSupportBg.beginFill(0x778877, 1);
		this.unSupportBg.drawRect(0, 0, width, height);
		this.unSupportBg.endFill();
		this.stage.addChild(this.unSupportBg);
		this.unSupportBg.alpha = 0.6;

		this.stage.addChild(this.unSupport);
		this.unSupport.x = width / 2;
		this.unSupport.y = height / 2;
	}

	this.updateAxisCb = null;
	//更新坐标系显示回调
	this.setUpdateAxis = function(func) {
		self.updateAxisCb = func;
	}

	//记录最后一次绘制的model
	this.draw_model = null;
	this.draw_from = null;
	this.draw_to = null;
	this.draw_step = null;
	this.draw_scaleX = null;
	this.draw_scaleY = null;

	this.drawPredict = function(predict, from, to, step, scaleX = 1, scaleY = 1) {
		self.modelLine.clear();
        self.modelLine.lineStyle(4,0x003399, 1);
        
		for(var i = from; i < to; i += step) {

			var y = predict(tf.tensor([[i]]));
			y = y.dataSync()[0];

			if(i == from) {
				self.moveTo(self.modelLine, i * scaleX, y * scaleY);
				continue;
			}

			self.lineTo(self.modelLine, i * scaleX, y * scaleY);
		}
	}

	//new 方法 显示model
	this.drawModel = function(model, from, to, step, scaleX = 1, scaleY = 1, isRev = false) {

		self.modelLine.clear();
        self.modelLine.lineStyle(4,0x003399,1);
        
		for(var i = from; i < to; i += step) {

			var y = model.predict(tf.tensor2d([[i]]));
			y = y.dataSync()[0];

			if(i == from) {
				if(isRev == false) {
					self.moveTo(self.modelLine, i * scaleX, y * scaleY);
				} else {
					self.moveTo(self.modelLine, y * scaleY, i * scaleX);
				}
				
				continue;
			}
			if(isRev == false) {
				self.lineTo(self.modelLine, i * scaleX, y * scaleY);
			} else {
				self.lineTo(self.modelLine, y * scaleY, i * scaleX);
			}
		}

		//记录上一次绘制的model
		self.draw_model = model;
		self.draw_from = from;
		self.draw_to = to;
		self.draw_step = step;
		self.draw_scaleX = scaleX;
		self.draw_scaleY = scaleY;
	}

	//显示 tf 预测
	this.showModel = function(model, from, to, step, scaleX = 1, scaleY = 1, isRev = false) {
		self.drawModel(model, from, to, step, scaleX, scaleY, isRev);
	}

	//显示 tf 预测
	this.showModelHand = function(model, from, to, step, scaleX, scaleY) {
		self.modelLine.clear();
		self.modelLine.lineStyle(4,0x003399,1);
		self.moveTo(self.modelLine, from, 0);
		
		for(var i = from; i < to; i += step) {
			var y = model.predict(i / scaleX);
			self.lineTo(self.modelLine, i / scaleX, y / scaleY);

		}
	}

	var spriteObj = {};
	//添加图片
	this.addSprite = function(key, sprite, x, y) {
		if(spriteObj[key] != null) {
			sprite = spriteObj[key];
		} else {
			this.imgContainer.addChild(sprite);
		}
		sprite.preX = x;
		sprite.preY = y;
		sprite.x = this.getX(x);
		sprite.y = this.getY(y);

		spriteObj[key] = sprite;
	}
	

	this.clearSpriteByName = function(key) {
		if(spriteObj[key] != null) {
			sprite = spriteObj[key];
			sprite.parent.removeChild(sprite);
			spriteObj[key] = null;
		}
	}

	this.clearSprite = function() {
		var children = this.imgContainer.children;
		for(var i = 0; i < children.length; i ++) {
			var child = children[i];
			child.parent.removeChild(child);
		}
	}

	this.keyLine = new PIXI.Graphics();

	this.pointTo = function(x,y){
		this.keyPoint.x = this.getX(x);
		this.keyPoint.y = this.getY(y);

		//辅助线
		self.keyLine.clear();
		self.keyLine.lineStyle(2,0x006B6B,1);
		
		self.keyLine.moveTo(cx, this.keyPoint.y);
		self.keyLine.lineTo(this.keyPoint.x, this.keyPoint.y);

		self.keyLine.moveTo(this.keyPoint.x, cy);
		self.keyLine.lineTo(this.keyPoint.x, this.keyPoint.y);
		self.keyLine.endFill();

		//更新坐标显示
		self.keyPointXTxt.text = "x: " + x.toFixed(1);
		self.keyPointYTxt.text = "y: " + y.toFixed(1);

	}

	this.getStage = function(){
		return app.stage;
	}
	this.render = function(){
		app.render();
	}
	this.update = function(fun){
		app.ticker.add(fun);
	}
	
	var inputArr = [];
	var outputArr = [];

	this.addPoint = function(x,y,color,isAdd = true){
		this.pointMap.lineStyle(1,0,1);
		this.pointMap.beginFill(color,1);
		var xx = this.getX(x);
		var yy = this.getY(y);

		this.pointMap.drawCircle(xx,yy,4);
		this.pointMap.endFill();

		if(isAdd == true) {
			inputArr.push(x);
			outputArr.push(y);
		}
		
	}

	this.addPoint2 = function(x,y,color){
		this.pointMap2.beginFill(color,1);
		var xx = this.getX(x);
		var yy = this.getY(y);
		this.pointMap2.drawCircle(xx,yy,5);
		this.pointMap2.endFill();
	}

	this.clearAll = function(){
		this.axisMap.cacheAsBitmap = false;
		this.rectMap.cacheAsBitmap = false;
		this.rectMap.clear();
		this.pointMap.clear();
		this.pointMap.lineStyle(1,0,1);
		this.pointMap2.clear();
		this.pointMap2.lineStyle(1,0,1);

		for(var key in this.lineList){
			this.stage.removeChild(this.lineList[key]);
		}
	}
	this.clearRect = function(){
		this.rectMap.cacheAsBitmap = false;
		this.rectMap.clear();
	}

	this.clearPoint = function() {
		this.pointMap.clear();
		this.pointMap.lineStyle(1,0,1);
		inputArr = [];
		outputArr = [];
	}
	
	this.createLine = function(){
		var line = new PIXI.Graphics();
		line.lineStyle(4, 0xffd900, 1);
		this.lineList.push(line);
		this.stage.addChild(line);
		return line;
	}
	
	this.moveTo = function(line,x,y){	
		line.moveTo(this.getX(x), this.getY(y));
	}
	this.lineTo = function(line,x,y){
		line.lineTo(this.getX(x), this.getY(y));
	}
	
	this.drawPoly = function (line,list,color){
		if(list.length<2){
			return;
		}
		line.beginFill(color); 
		line.moveTo(this.getX(list[0][0]), this.getY(list[0][1]));
		for(var i=1;i<list.length;i++){
			line.lineTo(this.getX(list[i][0]), this.getY(list[i][1]));
		}
		line.endFill();
	}
	

	this.addRect = function (x,y,color){
		this.rectMap.cacheAsBitmap = false;

		this.rectMap.beginFill(color,1);
		var xx = this.getX(x);
		var yy = this.getY(y);
		this.rectMap.drawRect(xx,yy-this.Scale,this.Scale,this.Scale);
		this.rectMap.endFill();

		this.rectMap.cacheAsBitmap = true;
	}

	this.addPic = function(pic, x, y) {
		this.stage.addChild(pic);
		this.setPicPos(pic, x, y);
		
	}

	this.setPicPos = function(pic, x, y) {
		var xx = this.getX(x);
		var yy = this.getY(y);
		pic.x = xx;
		pic.y = yy;

	}
	
	var cx = 250;
	var cy = 250;
	//设置中心点，重画坐标系
	this.setCenter = function(x,y){
		//中心点位置
		cx = x;
		cy = y;	

		//清空刻度
		var list = self.scaleMap.children;
		for(var i = list.length - 1; i >= 0; i --){
			self.scaleMap.removeChild(list[i]);
		}

		var mapChildLine = new PIXI.Graphics()
		mapChildLine.lineStyle(2, 0);
		mapChildLine.lineColor = 0xbcbcbc;
		self.scaleMap.addChild(mapChildLine);

		//横向显示偏移
		var xp = cx % 50;
		//纵向显示偏移
		var yp = cy % 50;
		//网格线 纵线
		for(var i = - parseInt(x / 50); i < (this.width) / 50; i ++) {
			mapChildLine.moveTo(i * 50 + x , 0);
			mapChildLine.lineTo(i * 50 + x , this.height);

			//添加坐标提示
			var style = {
				fontFamily: 'Arial',
				fontSize: 12,
				pWeight: 'bold'
			}
			var scaleTxt = new PIXI.Text((i / this.ScaleX * 50).toFixed(1), style);
			self.scaleMap.addChild(scaleTxt);
			scaleTxt.x = i * 50 + x ;
			scaleTxt.y = cy;

		}

		//网格线 横线
		for(var j = - parseInt(y / 50); j < (this.height) / 50; j ++) {
			mapChildLine.moveTo(0, j * 50 + y );
			mapChildLine.lineTo(this.width, j * 50 + y );

			//添加坐标提示
			var style = {
				fontFamily: 'Arial',
				fontSize: 12,
				pWeight: 'bold'
			}
			var scaleTxt = new PIXI.Text((-j / this.ScaleY * 50).toFixed(1), style);
			self.scaleMap.addChild(scaleTxt);
			scaleTxt.x = cx;
			scaleTxt.y = j * 50 + y ;

		}
		
		//坐标轴
		this.axisMap.lineStyle(2,0);
		this.axisMap.lineColor = 0x443333;
		this.axisMap.moveTo(0, y);
		this.axisMap.lineTo(this.width,y);
	
		this.axisMap.moveTo(x, 0);
		this.axisMap.lineTo(x,this.height);
		
		this.keyPoint.x = x;
		this.keyPoint.y = y;

	}

	var xAxisTxt = "";
	var yAxisTxt = "";
	
	//设置x y坐标的文本说明
	this.setTxt = function(xTxt, yTxt) {
		xAxisTxt = xTxt;
		yAxisTxt = yTxt;

		this.xTxt.text = xTxt;
		this.yTxt.text = yTxt;

		this.stage.addChild(this.xTxt);
		this.stage.addChild(this.yTxt);

		this.xTxt.x = this.width - 80;
		this.xTxt.y = cy - 25;

		this.yTxt.x = cx + 30;
		this.yTxt.y = 5;

	}

	//获得训练数据的 Html
	this.getTrainDataHtml = function() {
		var html = "";
		html += `<table style="cellspacing:1px;background-color:#000;width:` + self.width + `px">`;
		html += `<tr style="background-color:#eeffee">`;
		html += `<th>` + xAxisTxt + `</th><th>` + yAxisTxt + `</th>`;
		html += `</tr>`;
		for(var i = 0; i < inputArr.length; i ++) {
			var x = inputArr[i].toFixed(1);
			var y = outputArr[i].toFixed(1);
			html += `<tr style="background-color:#ffffff">`;
			html += `<td align="center">` + x + `</td><td align="center">` + y + `</td>`;
			html += `</tr>`;
		}
		html += `</table>`;
		return html;
	}

	//更新坐标系中元素的显示
	this.updateScaleShow = function() {

		//清空刻度
		self.pointMap.clear();

		var list = self.imgContainer.children;
		for(var i = 0; i < list.length; i++) {
			var child = list[i];
			child.x = self.getX(child.preX);
			child.y = self.getY(child.preY);
		}

		for(var i = 0; i < inputArr.length; i ++) {
			var x = inputArr[i];
			var y = outputArr[i];
			self.addPoint(x, y, 0xff0000, false);
		}


	}
	

	//#########################
	//		 是否支持提示
	//#########################
	this.setSupport = function(isSupport) {
		if(isSupport) {
			self.unSupport.visible = false;
			self.unSupportBg.visible = false;
		} else {
			self.unSupport.visible = true;
			self.unSupportBg.visible = true;
		}
	}




	//#########################
	//		    控制
	//#########################
	this.controlCb = null;
	this.trainType = null;
	this.openControl = function(callBack, trainType = 1) {
		self.controlCb = callBack;
		self.trainType = trainType;
		this.stage.interactive = true;
		this.stage.on("click", function(event) {
			
			var pos = event.data.getLocalPosition(self.stage);
			
			//添加测试数据
			var color = 0xff0000;
			if(self.trainType == 2) {
				color = self.dataColor;
			}

			var pointX = (pos.x - cx) / self.ScaleX;
			var pointY = (cy - pos.y) / self.ScaleY;

			self.addPoint(pointX, pointY, color);

			//返回数据
			if(self.trainType == 1) {
				self.controlCb(pointX, pointY);
			} else {
				self.controlCb([pointX, pointY], self.dataType);
			}
			

		});
	}

	//控制添加数据的类型
	this.dataType = 0;
	this.dataColor = 0xff0000;
	this.setDataType = function(type, color) {
		self.dataType = type;
		self.dataColor = color;
	}

	this.cacheAsBitmap = function(){
		this.axisMap.cacheAsBitmap = true;
		this.rectMap.cacheAsBitmap = true;
	}

	this.getX = function(x){
		return cx+x*this.ScaleX;
	}

	this.getY = function(y){
		return cy-y*this.ScaleY;
	}
}
