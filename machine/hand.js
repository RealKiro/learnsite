/**
 * @license
 * Copyright 2018 Google LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * =============================================================================
 */

const STATUS = document.getElementById('status');
const RESET_BUTTON = document.getElementById('reset');
const TRAIN_BUTTON = document.getElementById('train');
const SAVE_BUTTON = document.getElementById('save');
const MOBILE_NET_INPUT_WIDTH = 224;
const MOBILE_NET_INPUT_HEIGHT = 224;
const STOP_DATA_GATHER = -1;
let CLASS_NAMES = [];
const Canvaser = document.getElementById('showme');
const ANSWERS = document.getElementById('predictresult');
const ADDCATEGORY = document.getElementById('add');
const LEFTDIV = document.getElementById('inputdiv');
const CONTROL = document.getElementById('switch');
const imageInput = document.getElementById('image-input');
const imageObj = document.getElementById('image-obj');
const webcanContain=document.getElementById("webcam-container");
const enwebcam=document.getElementById("enable-webcam");
const envoice=document.getElementById("enable-voice");
const encanvas=document.getElementById("enable-canvas");
const logo=document.getElementById("logo");
const edge=document.getElementById("preview");


TRAIN_BUTTON.addEventListener('click', trainAndPredict);
RESET_BUTTON.addEventListener('click', reset);
SAVE_BUTTON.addEventListener('click', savemodel);
CONTROL.addEventListener('click', controlPredict);
enwebcam.addEventListener('click', webcamdo);
envoice.addEventListener('click', voicedo);
encanvas.addEventListener('click', canvasdo);
logo.addEventListener('click', readStorage);
edge.addEventListener('click', preview);

SAVE_BUTTON.disabled=true;
RESET_BUTTON.disabled=true;
RESET_BUTTON.style.display = "none";


let voice=true;
let videoPlaying = false;//有无摄像头
let ImagePlaying=false;//是否识别对象为图像
let ImgTrained=false;//是否完成训练
// Convenience function to setup a webcam


let modelName="model_"+snum+"_"+id;//模型名称

let canvasnull = document.createElement("canvas");//空画布
canvasnull.getContext('2d').clearRect(0, 0, 224, 224);
let isnull=true;

/**
 * Check if getUserMedia is supported for webcam access.
 **/

var fabric_canvas = new fabric.Canvas('whatimg', { backgroundColor: "#000000"});
fabric_canvas.renderTop();
fabric_canvas.isDrawingMode = true;
fabric_canvas.freeDrawingBrush.width = 18;
fabric_canvas.freeDrawingBrush.color = "#ffffff";

const flip = true; // whether to flip the webcam
let webcam ; // width, height, flip

try{
	navigator.getUserMedia(
	  {   // we would like to use video but not audio
		  // This object is browser API specific! - some implementations require boolean properties, others require strings!
		  video: true, 
		  audio: false
	  },
	  async function(videoStream) {
		  // 'success' callback - user has given permission to use the camera
		  // my code to use the camera here ... 
		  console.log("支持摄像头");
		  videoPlaying=true;
		  webcam = new tmImage.Webcam(300, 300, flip); // width, height, flip
		  await webcam.setup(); // request access to the webcam
		  await webcam.play();
      webcanContain.innerHTML='';
		  webcanContain.appendChild(webcam.canvas);
		  window.requestAnimationFrame(loop);
	  },
	 async function() {
		  // 'no permission' call back
		  console.log("没有摄像头");
		  videoPlaying=false;
	  }               
	);
}
catch{
	console.log("不支持摄像头");
}


// append elements to the DOM
async function loop() {
    webcam.update(); // update the webcam frame
    window.requestAnimationFrame(loop);
}

async function voicedo(){
  if(voice){
    voice=false;
    envoice.className="fa fa-volume-off";
    envoice.title="语音禁用";
  }
  else{
    voice=true;
    envoice.className="fa fa-volume-up";
    envoice.title="语音播报";
  }
}


async function preview(){
  if(ImgTrained){
      let previewurl="test.html?"+modelName;
      window.open(previewurl);
  }
}

async function webcamdo(){
    console.log("视频状态：",videoPlaying);
    videoPlaying=true;
    webcanContain.innerHTML='';
    webcanContain.appendChild(webcam.canvas);
    await webcam.play();
}

async function canvasdo(){
    var canvas = document.createElement("canvas");
    canvas.width = canvas.height = 300;                
    canvas.id="whatimg"; 
    webcanContain.innerHTML='';
    webcanContain.appendChild(canvas);
    fabric_canvas = new fabric.Canvas('whatimg', { backgroundColor: "#000000"});
    fabric_canvas.renderTop();
    fabric_canvas.isDrawingMode = true;
    fabric_canvas.freeDrawingBrush.width = 18;
    fabric_canvas.freeDrawingBrush.color = "#ffffff";
    console.log("初始化画布");
    videoPlaying=false;
}

// Just add more buttons in HTML to allow classification of more classes of data!

let dataCollectorButtons ;
let datacategoryButtons ;
let datadelButtons;
let dataupButtons;
let datahandButtons;

await initDataButton();

async function initDataButton(){
    CLASS_NAMES = [];
    dataCollectorButtons = document.querySelectorAll('button.dataCollector');
    datacategoryButtons = document.querySelectorAll('span.datacategory');
    datadelButtons = document.querySelectorAll('span.datadelete');
    dataupButtons = document.querySelectorAll('button.dataup');
    datahandButtons = document.querySelectorAll('button.datahand');

    for (let i = 0; i < dataCollectorButtons.length; i++) {
      dataCollectorButtons[i].addEventListener('mousedown', gatherDataForClass);
      dataCollectorButtons[i].addEventListener('mouseup', stopDataForClass);

      // Populate the human readable names for classes.
      CLASS_NAMES.push(dataCollectorButtons[i].getAttribute('data-name'));

    }

    // Just add more buttons in HTML to allow classification of more classes of data!
    for (let i = 0; i < datacategoryButtons.length; i++) {
      datacategoryButtons[i].addEventListener('blur', categorychange);
      datacategoryButtons[i].addEventListener('focus', categoryget);
      // Populate the human readable names for classes.
    }

    // Just add more buttons in HTML to allow classification of more classes of data!
    for (let i = 0; i < datadelButtons.length; i++) {
      datadelButtons[i].addEventListener('click', delcategory);
      // Populate the human readable names for classes.
    }
    
    // Just add more buttons in HTML to allow classification of more classes of data!
    for (let i = 0; i < dataupButtons.length; i++) {
      dataupButtons[i].addEventListener('click', upcanvas);
      // Populate the human readable names for classes.
    }

    // Just add more buttons in HTML to allow classification of more classes of data!
    for (let i = 0; i < datahandButtons.length; i++) {
      datahandButtons[i].addEventListener('click', handboard);
      // Populate the human readable names for classes.
    }

    //console.log("图片上传",dataupButtons);
    
}

ADDCATEGORY.addEventListener('click', addcategorynew);

document.onkeydown=function(e){
  if(e.keyCode == 13 ){
      // 分类名称修改避免回车键换行
      e.preventDefault();   
      TRAIN_BUTTON.focus();
  }
}

let mobilenet = undefined;
let gatherDataState = STOP_DATA_GATHER;
let trainingDataInputs = [];
let trainingDataOutputs = [];
let examplesCount = [];
let predict = false;

let datacanvas=[];

/**
 * Loads the MobileNet model and warms it up so ready for use.
 **/
async function loadMobileNetFeatureModel() {
  const URL ='mobilenetv3';  
  mobilenet = await tf.loadGraphModel(URL, {fromTFHub: true});
  STATUS.innerText = 'MobileNet 神经网络准备就绪!';
  //enableCam();
  // Warm up the model by passing zeros through it once.
  tf.tidy(function () {
    let answer = mobilenet.predict(tf.zeros([1, MOBILE_NET_INPUT_HEIGHT, MOBILE_NET_INPUT_WIDTH, 3]));
    console.log(answer.shape);
  });
}

loadMobileNetFeatureModel();


let model = tf.sequential();
await initmodel();

async function initmodel(){
  model.add(tf.layers.dense({inputShape: [1024], units: 128, activation: 'relu'}));
  model.add(tf.layers.dense({units: CLASS_NAMES.length, activation: 'softmax'}));

  model.summary();

  // Compile the model with the defined optimizer and specify a loss function to use.
  model.compile({
    // Adam changes the learning rate over time which is useful.
    optimizer: 'adam',
    // Use the correct loss function. If 2 classes of data, must use binaryCrossentropy.
    // Else categoricalCrossentropy is used if more than 2 classes.
    loss: (CLASS_NAMES.length === 2) ? 'binaryCrossentropy': 'categoricalCrossentropy', 
    // As this is a classification problem you can record accuracy in the logs too!
    metrics: ['accuracy']  
  });
}


/**
 * Handle Data Gather for button mouseup/mousedown.
 **/
function gatherDataForClass() {
  let classNumber = parseInt(this.getAttribute('data-1hot'));
  gatherDataState = (gatherDataState === STOP_DATA_GATHER) ? classNumber : STOP_DATA_GATHER;
  dataGatherLoop();
}

function stopDataForClass() {
  gatherDataState =  STOP_DATA_GATHER;
}

$("#uppic").click(function(){
  imageObj.click();
});

imageObj.addEventListener('change', function(e) {
  const file = e.target.files[0];
  if(file){
      if (file.type.startsWith('image/')) { 
        const reader = new FileReader(); 
        predict=false;
        if(videoPlaying){          
          webcam.paused;
          videoPlaying=false;
        }
        ImagePlaying=true;
        reader.onload = (function(theFile) {
          return function(e) {
            // 创建一个Image元素
            const img = document.createElement('img');
            img.src = e.target.result;
            img.onload=function(){
                var imgWidth = img.width;
                var imgHeight = img.height;        
                // 选择宽度和高度中较小的一个作为正方形边长
                var squareSize = Math.min(imgWidth, imgHeight);        
                // 设置Canvas的尺寸
                var canvas = document.createElement("canvas");
                canvas.width = canvas.height = squareSize;                
                canvas.id="whatimg"; 
                    // 绘制裁剪后的图片
                canvas.getContext('2d').drawImage(
                  img, // 图片元素
                  (imgWidth - squareSize) / 2, // 从图片的x坐标开始裁剪
                  (imgHeight - squareSize) / 2, // 从图片的y坐标开始裁剪
                  squareSize, // 裁剪的宽度
                  squareSize, // 裁剪的高度
                  0, 0, // 在Canvas上的x和y位置
                  squareSize, // 绘制的宽度
                  squareSize // 绘制的高度
                );
                webcanContain.innerHTML = '';
                webcanContain.appendChild(canvas); 
                
                if(ImgTrained){
                  predict=true;               
                  CONTROL.className='fa fa-pause';
                }
            }

          };
        })(file);

        reader.readAsDataURL(file);
      }
  }
});

$("#clearpic").click(function(){
    fabric_canvas.clear();
});
let currentClassNumber;

function handboard(){
  var canvas = document.getElementById('whatimg');  
  if(canvas){
        currentClassNumber = parseInt(this.getAttribute('data-hand'));
        
        let outputname='output'+(currentClassNumber+1).toString();
        let imageContainer = document.getElementById(outputname);

        var cv = document.createElement("canvas");
        cv.id="thumb";
        cv.width = cv.height =224;
        

        cv.getContext('2d').drawImage(canvas,0,0,224,224);
        // 将图片添加到容器中
        ImagePlaying=true;
        imageContainer.appendChild(cv);
        datacanvas[currentClassNumber]=cv;
        fabric_canvas.clear();

        STATUS.innerText = '采集图像样本中……';
        let collectname='collector'+(currentClassNumber+1).toString();
        let STATUSCOUNT = document.getElementById(collectname);
        let imgcount =  parseFloat(STATUSCOUNT.innerText);
        imgcount++;
        STATUSCOUNT.innerText = imgcount + '个图像样本 ';
        console.log("采集",collectname);
  }
}

function upcanvas(){  
  currentClassNumber = parseInt(this.getAttribute('data-up'));
  imageInput.click();
}

imageInput.addEventListener('change', function(e) {
  const files = e.target.files;

  let outputname='output'+(currentClassNumber+1).toString();
	let imageContainer = document.getElementById(outputname);
  let imgcount=0;
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    if (!file.type.startsWith('image/')) {
      continue;
    }
    else{      
      imgcount++;
    }

    const reader = new FileReader();
    reader.onload = (function(theFile) {
      return function(e) {
        // 创建一个Image元素
        const img = document.createElement('img');
        img.src = e.target.result;
        img.onload=function(){
            //图像样本显示
            // 获取原始图片的宽度和高度
            var imgWidth = img.width;
            var imgHeight = img.height;        
            // 选择宽度和高度中较小的一个作为正方形边长
            var squareSize = Math.min(imgWidth, imgHeight);        
            // 设置Canvas的尺寸
            var canvas = document.createElement("canvas");
            canvas.width = canvas.height = squareSize;
                // 绘制裁剪后的图片
            canvas.getContext('2d').drawImage(
              img, // 图片元素
              (imgWidth - squareSize) / 2, // 从图片的x坐标开始裁剪
              (imgHeight - squareSize) / 2, // 从图片的y坐标开始裁剪
              squareSize, // 裁剪的宽度
              squareSize, // 裁剪的高度
              0, 0, // 在Canvas上的x和y位置
              squareSize, // 绘制的宽度
              squareSize // 绘制的高度
            );
            
            var cv = document.createElement("canvas");
            cv.id="thumb";
            cv.width = cv.height =224;
            cv.getContext('2d').drawImage(canvas,0,0,224,224);
            // 将图片添加到容器中
            imageContainer.appendChild(cv);
            datacanvas[currentClassNumber]=cv;
        }

      };
    })(file);

    reader.readAsDataURL(file);
  }

  STATUS.innerText = '采集图像样本中……';

  let collectname='collector'+(currentClassNumber+1).toString();
  let STATUSCOUNT = document.getElementById(collectname);
  let oldcount =  parseFloat(STATUSCOUNT.innerText);
  if(oldcount){
    imgcount=oldcount+imgcount;
  }
  STATUSCOUNT.innerText = imgcount + '个图像样本 ';

});

function controlPredict() {
  if(ImgTrained){
    if (predict) {    
      predict=false;
      STATUS.innerHTML = '暂停预测';
      CONTROL.className='fa fa-play';
    }
    else{
      predict=true;
      STATUS.innerHTML = '预测中……';
      CONTROL.className='fa fa-pause';
    }
  }
}

let currentcategory="";

function categoryget(){
  currentcategory=this.innerText.trim();
  if (document.body.createTextRange) {
    var range = document.body.createTextRange();
    range.moveToElementText(this);
    range.select();
  } else if (window.getSelection) {
    var selection = window.getSelection();
    var range = document.createRange();
    range.selectNodeContents(this);
    selection.removeAllRanges();
    selection.addRange(range);
  }
}

function categorychange() { 
  let txt=this.innerText.trim();
  if(txt=="" || txt==currentcategory)
    {
      this.innerText=currentcategory;
    }
  else{
      if(txt.length>5){
        alert("分类名称不能超过5个字,超过将自动裁剪。");
        txt=txt.slice(0,5);
        this.innerText=txt;
      }
      let classNumber = parseInt(this.getAttribute('data-num')); 
      CLASS_NAMES[classNumber]=txt;
      console.log(CLASS_NAMES);
      dataCollectorButtons[classNumber].setAttribute('data-name',txt);
    }
}

function addcategorynew() {
  let n=CLASS_NAMES.length;//至多增加三个分类
  if(n<3){
    let m=n+1;
    let htmlcategory=[
      '<div>',    
      '	<i class="fa fa-pencil" aria-hidden="true" ></i>',
      '	<span class="datacategory" data-num="'+n+'" contenteditable="plaintext-only">分类'+m+'</span>',
      '	<span class="datadelete"  data-del="'+n+'"  title="删除分类" ><i class="fa fa-trash"aria-hidden="true" /></i></span>',
      '</div>',
      '<div>',
      '	<span class="counter" id="collector'+m+'">0个图像样本</span>',
      '	<button class="dataCollector" data-1hot="'+n+'" data-name="分类'+m+'"><i class="fa fa-camera"></i>采集视频</button>',
      '	<button class="dataup" data-up="'+n+'"><i class="fa fa-picture-o" aria-hidden="true" ></i>上传图像</button>',
      ' <button class="datahand" data-hand="'+n+'"><i class="fa fa-paint-brush" aria-hidden="true" ></i>添加手写</button>',
      '</div>',
      '<div id="output'+m+'" class="outpic"></div>'
    ].join('');
    let div = document.createElement("div");
    div.className='category';
    div.innerHTML=htmlcategory;
    LEFTDIV.append(div);
    console.clear();
    initDataButton();
    model = tf.sequential();
    initmodel();
  }
  else{
    console.log("最多三个分类");
  }
}


function delcategory(){
  if(!predict){
      let num=this.getAttribute('data-del');
      let me=parseInt(num)+1;
      let collectname='collector'+me;
      let STATUSCOUNT = document.getElementById(collectname);
      let oldcount =  parseFloat(STATUSCOUNT.innerText);
      console.log("当前图像样本数：",oldcount);
      if(oldcount==0){          
        if(CLASS_NAMES.length>2){
          if(confirm("请确认删除"+CLASS_NAMES[num]+"?")){
              this.parentNode.parentNode.parentNode.removeChild(this.parentNode.parentNode);//删除父元素
              CLASS_NAMES.splice(num,1);
              //console.log(CLASS_NAMES);
              console.clear();
              initDataButton();
              model = tf.sequential();
              initmodel();
              //reset();
          }
        }
        else{
          console.log("至少两个分类");
        }
      }
      else{
        if(confirm("请确认清空"+oldcount+"图像样本?")){
          let outputname='output'+me;
          let imageContainer = document.getElementById(outputname);
          imageContainer.innerHTML='';
          STATUSCOUNT.innerText="0个图像样本 ";
        }
      }      
  }
}
//识别对像
function calculateFeaturesOnCurrentFrame() {
  return tf.tidy(function() {
    // Grab pixels from current VIDEO frame. datacanvas
    let videoFrameAsTensor = tf.browser.fromPixels(canvasnull);
    if(videoPlaying){
      videoFrameAsTensor = tf.browser.fromPixels(webcam.canvas);
      isnull=false;
    }
    if(ImagePlaying){      
      let canvas = document.getElementById("whatimg");
      if(canvas){
        videoFrameAsTensor = tf.browser.fromPixels(canvas);
        isnull=false;
        //console.log(canvas.toDataURL());
      }      
    }

    // Resize video frame tensor to be 224 x 224 pixels which is needed by MobileNet for input.
    let resizedTensorFrame = tf.image.resizeBilinear(
        videoFrameAsTensor, 
        [MOBILE_NET_INPUT_HEIGHT, MOBILE_NET_INPUT_WIDTH],
        true
    );

    let normalizedTensorFrame = resizedTensorFrame.div(255);

    return mobilenet.predict(normalizedTensorFrame.expandDims()).squeeze();
  });
}

//采集样本
function calculateFeaturesOnCanvas(canvas) {
  return tf.tidy(function() {
    // Grab pixels from current VIDEO frame.
    let videoFrameAsTensor = tf.browser.fromPixels(canvas);
    // Resize video frame tensor to be 224 x 224 pixels which is needed by MobileNet for input.
    let resizedTensorFrame = tf.image.resizeBilinear(
        videoFrameAsTensor, 
        [MOBILE_NET_INPUT_HEIGHT, MOBILE_NET_INPUT_WIDTH],
        true
    );

    let normalizedTensorFrame = resizedTensorFrame.div(255);

    return mobilenet.predict(normalizedTensorFrame.expandDims()).squeeze();
  });
}

function dataGatherTrain(){  
  trainingDataInputs.splice(0);
  trainingDataOutputs.splice(0);
  for (let n = 0; n < CLASS_NAMES.length; n++) {
    let outputname='output'+(n+1).toString();
	  let OUTPUTIMG = document.getElementById(outputname);    
    let outputcanvas = OUTPUTIMG.querySelectorAll('canvas');
    //console.log(CLASS_NAMES[n],outputcanvas.length);
    // 输出获取到的canvas元素
    outputcanvas.forEach(function(canvas) {
      //console.log(canvas);      
      let imageFeatures = calculateFeaturesOnCanvas(canvas);
      trainingDataInputs.push(imageFeatures);
      trainingDataOutputs.push(n);
    });
  }
}

/**
 * When a button used to gather data is pressed, record feature vectors along with class type to arrays.
 **/
function dataGatherLoop() {
  // Only gather data if webcam is on and a relevent button is pressed. 
  if (videoPlaying && gatherDataState !== STOP_DATA_GATHER) {
    // Ensure tensors are cleaned up.

    //let imageFeatures = calculateFeaturesOnCurrentFrame();

    //trainingDataInputs.push(imageFeatures);
    //trainingDataOutputs.push(gatherDataState);

    // Intialize array index element if currently undefined.
    if (examplesCount[gatherDataState] === undefined) {
      examplesCount[gatherDataState] = 0;
    }
    // Increment counts of examples for user interface to show.
    examplesCount[gatherDataState]++;

    //图像样本显示
    var canvas = document.createElement("canvas");
    canvas.id="thumb";
    canvas.width = 224 ;
    canvas.height = 224;
    canvas.getContext('2d').drawImage(webcam.canvas, 0, 0, canvas.width, canvas.height);
	
	  let outputname='output'+(gatherDataState+1).toString();
	  let OUTPUTIMG = document.getElementById(outputname);	
    OUTPUTIMG.append(canvas);//显示视频帧图片
	
    datacanvas[gatherDataState]=canvas;

    STATUS.innerText = '采集图像样本中……';
		
    for (let n = 0; n < CLASS_NAMES.length; n++) {
        if (examplesCount[n] === undefined) {
            examplesCount[n] = 0;
        }
        //STATUS.innerText += CLASS_NAMES[n] + ' ：' + examplesCount[n] + '图像样本 \r\n ';	
		let collectname='collector'+(n+1).toString();
		//console.log(collectname);
		let STATUSCOUNT = document.getElementById(collectname);
		STATUSCOUNT.innerText = examplesCount[n] + '个图像样本 ';
    }

    window.requestAnimationFrame(dataGatherLoop);
  }
}


/**
 * Once data collected actually perform the transfer learning.
 **/
async function trainAndPredict() { 
  TRAIN_BUTTON.disabled=true;//防止多次点击
  STATUS.innerText = '机器训练学习中……';   
  dataGatherTrain();//读取样本数据

  if(trainingDataInputs.length>0){
    predict = false;
    tf.util.shuffleCombo(trainingDataInputs, trainingDataOutputs);

    let outputsAsTensor = tf.tensor1d(trainingDataOutputs, 'int32');
    let oneHotOutputs = tf.oneHot(outputsAsTensor, CLASS_NAMES.length);
    let inputsAsTensor = tf.stack(trainingDataInputs);

    console.log("训练数据：",trainingDataInputs.length,"样本",trainingDataOutputs.length,"标识",CLASS_NAMES.length,"分类");
    
    let results = await model.fit(inputsAsTensor, oneHotOutputs, {
      shuffle: true,
      batchSize: 5,
      epochs: 10,
      callbacks: {onEpochEnd: logProgress}
    });
    
    outputsAsTensor.dispose();
    oneHotOutputs.dispose();
    inputsAsTensor.dispose();
    
    predict = true;
    SAVE_BUTTON.disabled=false;
    ImgTrained=true;//训练完成

    STATUS.innerHTML = '预测中……';
    CONTROL.className='fa fa-pause';

    predictLoop();
  }
  else{
    STATUS.innerText = '未采集分类数据';
  }
  
  TRAIN_BUTTON.disabled=false;
}

let keydict=[];
keydict[0]='localstorage://'+modelName;
keydict[1]='tensorflowjs_models/'+modelName+'/info';
keydict[2]='tensorflowjs_models/'+modelName+'/model_topology';
keydict[3]='tensorflowjs_models/'+modelName+'/weight_specs';
keydict[4]='tensorflowjs_models/'+modelName+'/weight_data';
keydict[5]='tensorflowjs_models/'+modelName+'/model_metadata';
keydict[6]='tensorflowjs_models/'+modelName+'/model_classname';

async function savemodel(){
  console.log("保存模型中……");
  localStorage.clear();
  console.log("localStorage",keydict[0]);
  localStorage.setItem(keydict[6], CLASS_NAMES);  
  let resultsave = await model.save(keydict[0]);
  if(resultsave){
      await readStorage();
  } 
  RESET_BUTTON.disabled=false; 
}

async function readStorage(){
    let dict=[];
    if(localStorage.getItem(keydict[6])){
      for(var i =1;i<7;i++){
          let value=localStorage.getItem(keydict[i]);
          //console.log(value);
          dict.push(value);
      }
      //console.log("存储模型：\n",dict);   
      let jsonstr= JSON.stringify(dict);
      //console.log("转为JSON字符串:\n",jsonstr);
      let base64 = btoa(encodeURI(jsonstr));
      //console.log("转为base64:\n",base64);
      await upload(base64);

      //解码
      //let newjsonstr = decodeURI(atob(base64));
      //console.log("转为JSON字符串:\n",newjsonstr);
  
      //let readict=JSON.parse(newjsonstr);
      //console.log("json转字典:\n",readict);
    }
    else{
      console.log("不存在模型");
    }
}

async function upload(base64){	
  var urls = 'upmodel.ashx?id=' + id;
  var formData = new FormData();//
  var cover = blob(mergecanvas());
  console.log(cover);

  formData.append('id', id);
  formData.append('modelName', modelName);
  formData.append('base64', base64);
  formData.append('cover', cover);

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

//合并图片为封面缩略图
function mergecanvas(){    
    var cv = document.createElement("canvas");
    cv.width = 500 ;
    cv.height = 300;
    var ctx=cv.getContext('2d');
    ctx.strokeStyle="gray";
    ctx.strokeRect(0,0,500,300);
    ctx.font ='36px "微软雅黑"';
    ctx.textBaseline = "bottom";

    ctx.fillText(CLASS_NAMES[0],50,290);
    ctx.fillText(CLASS_NAMES[1],300,290);

    ctx.drawImage(datacanvas[0], 18, 10);    
    ctx.drawImage(datacanvas[1], 260, 10);
    ctx.font ='72px "微软雅黑"';
    //ctx.fillStyle='red';
    ctx.globalAlpha = 0.3;
    ctx.fillText('✡',225,310);

    var base64=cv.toDataURL("image/png");
    //console.log(base64);
    return base64;
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

/**
 * Log training progress.
 **/
function logProgress(epoch, logs) {
	  STATUS.innerText = '机器训练学习中……';
    //console.log('数据集训练轮数 ' + epoch, logs);
    console.log('训练轮数 ' + epoch);
    var n=epoch+1;
    load.innerText=n*10+"%";
    load.style.width=n*10+'%';
    if(n==10){
      load.innerText='';
    }
}


/**
 *  Make live predictions from webcam once trained.
 **/
function predictLoop() {
  if (predict) {
    tf.tidy(function() {
      let imageFeatures = calculateFeaturesOnCurrentFrame();
      let prediction = model.predict(imageFeatures.expandDims()).squeeze();
      let highestIndex = prediction.argMax().arraySync();
      let predictionArray = prediction.arraySync();
      
      let acc=Math.floor(predictionArray[highestIndex] * 100)+1;
      
      //ANSWERS.innerText = CLASS_NAMES[highestIndex] + '  ' + acc + '%';
      
      let anshtml=[
        '<div style="text-align: right;">',
        '<div class="accbox" title="识别率" ><div class="accload" style="width:'+acc+'%" >'+acc+'%</div></div>',
        '</div> '
      ].join('');
      
      if(isnull){
        ANSWERS.innerHTML='';
      }
      else{
        ANSWERS.innerHTML= CLASS_NAMES[highestIndex]+"："+anshtml;
      }

      if(datacanvas.length>0){
        var destCtx = Canvaser.getContext('2d');
        if(acc>80){
          //destCtx.drawImage(datacanvas[highestIndex], 0, 0,224,224);
          playText(CLASS_NAMES[highestIndex]);
        }
        else{
          destCtx.clearRect(0, 0,224,224);
        }
      }
    });
  }

  window.requestAnimationFrame(predictLoop);    
  
}

const utterance = new SpeechSynthesisUtterance();
function playText(text) {
  if(text && voice){
    if (speechSynthesis.paused && speechSynthesis.speaking) {
      return speechSynthesis.resume();
    }
    if (speechSynthesis.speaking) return;
    utterance.text = text;
    utterance.rate =  1;

    speechSynthesis.speak(utterance);
  }
}

/**
 * Purge data and start over. Note this does not dispose of the loaded 
 * MobileNet model and MLP head tensors as you will need to reuse 
 * them to train a new model.
 **/
function reset() {
  predict = false;
  examplesCount.splice(0);
  for (let i = 0; i < trainingDataInputs.length; i++) {
    trainingDataInputs[i].dispose();
  }
  trainingDataInputs.splice(0);
  trainingDataOutputs.splice(0);
  STATUS.innerText = '无数据收集';
  CONTROL.className='';  
  load.innerText=''; 
  load.style.width='0%';

  for (let n = 0; n < CLASS_NAMES.length; n++) {
    let collectname='collector'+(n+1).toString();
    let STATUSCOUNT = document.getElementById(collectname);
    STATUSCOUNT.innerText = '';
    let outputname='output'+(n+1).toString();
    let OUTPUTIMG = document.getElementById(outputname);
    if(OUTPUTIMG){
      OUTPUTIMG.innerText = '';
    }
  }
  ANSWERS.innerText = '';
  var cxt = Canvaser.getContext("2d");
  cxt.clearRect(0, 0, 224, 224);
  
  SAVE_BUTTON.disabled=true;
  RESET_BUTTON.disabled=true;
  
  console.log('内存中的张量: ' + tf.memory().numTensors);
}