
var renderer = new PIXI.autoDetectRenderer(392, 392, {backgroundColor : 0x1099bb});
//var app = new PIXI.Application(600, 600);
document.getElementById("hand").appendChild(renderer.view);
renderer.view.style.width = "100%";

var size = 14;
var num = 392/size;
var maxNum = num*num;


function Hand(){

	this.stage = new PIXI.Container();
	
	this.stage.alpha = 0.9;
	var bg=new PIXI.Sprite.from("../ai/handnum/css/images/tian.png");
	this.stage.addChild(bg);
	
	this.tileList = new Array();
	
	this.resArr = new Array(maxNum);
	
	zeroArray(this.resArr);
	
	this.down = false;
	for(var i=0;i<maxNum;i++){
		var xx = i%num;
		var yy = Math.floor(i/num);
		var tile = new Tile();
		tile.view.x = xx*size;
		tile.view.y = yy*size;
		
		this.tileList.push(tile);
		this.stage.addChild(tile.view);	
	}
	
	this.stage.buttonMode = true;
	this.stage.interactive = true;
	this.stage.on("mousedown",onMouseDown);
	this.stage.on("mousemove",onMouseMove);
	this.stage.on("mouseup",onMouseUp);
	this.stage.on("mouseout",onMouseUp);
	
	var self = this;
	function onMouseDown(e){
		self.down = true;
		
		var pt = e.data.getLocalPosition(self.stage);
		var xx = Math.floor(pt.x/size);
		var yy = Math.floor(pt.y/size);
		
		change(xx, yy);
	}
	function onMouseMove(e){
		
		if(self.down==false){
			return ;
		}
		
		var pt = e.data.getLocalPosition(self.stage);
		var xx = Math.floor(pt.x/size);
		var yy = Math.floor(pt.y/size);

		change(xx, yy);
		change(xx + 1, yy);
		change(xx, yy + 1);
		change(xx + 1, yy + 1);
		// change(xx - 1, yy);
		// change(xx, yy - 1);
		
	}
	function onMouseUp(e){
		self.down = false;
	}

	function change(xx, yy) {

		var index = xx + yy * num;
		if(self.tileList.length < index) {
			return;
		}

		if(self.tileList[index] == null || self.tileList[index].data==1){
			return ;
		}

		self.tileList[index].change();
		self.resArr[index]=self.tileList[index].data;

	}
	
	this.clear = function(){
		for(var i=0;i<maxNum;i++){
			this.tileList[i].select(false);
		}
		zeroArray(this.resArr);
	}
	
	this.getData = function(){
		return this.resArr;
	}
	this.setData = function(arr){
		var len = arr.length;
		for(var i=0;i<len;i++){
			this.tileList[i].setValue(arr[i]);
		}
	}
}


function Tile (){
	
	this.view = new PIXI.Container();
	
	this.view1 = new PIXI.Graphics();
	this.view.addChild(this.view1);
	this.view1.beginFill(0,1);
	//this.view1.lineStyle(1,0xffffff);
	this.view1.drawRect(0,0,size,size);
	this.view1.endFill();
	
	this.data = 0;
	
	this.change = function(){
		if(this.data==0){
			this.select(true);
		}else{
			this.select(false);
		}
	}
	this.setValue = function(value){
		if(value<0.3){
			this.select(false);
		}else{
			this.data = 1;
			this.view1.beginFill(0xffffff,value);
			this.view1.drawRect(0,0,size,size);
			this.view1.endFill();
		}
	}
	
	this.select = function(value){
		this.view1.clear();
		if(value==false){
			this.data = 0;
			this.view1.beginFill(0,1);
			//this.view1.lineStyle(1,0xffffff);
			this.view1.drawRect(0,0,size,size);
			this.view1.endFill();
		}else{
			this.data = 1;
			this.view1.beginFill(0xffffff,1);
			this.view1.drawRect(0,0,size,size);
			this.view1.endFill();
		}
	}
	
}

function zeroArray(arr){
	var len = arr.length;
	for(var i=0;i<len;i++){
		arr[i]=0.0;
	}
}