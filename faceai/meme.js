const face = document.getElementById('faceimg');
const overlay = document.getElementById('overlay');
let isready=false;

window.onload = function () {
  run();
}

async function run() {
  await faceapi.nets.tinyFaceDetector.loadFromUri('../faceai/models');
  await faceapi.nets.faceLandmark68Net.loadFromUri('../faceai/models');
  await faceapi.nets.faceRecognitionNet.loadFromUri('../faceai/models');
  await faceapi.nets.faceExpressionNet.loadFromUri('../faceai/models');
  await faceapi.nets.ageGenderNet.loadFromUri('../faceai/models');
  await faceapi.nets.ssdMobilenetv1.loadFromUri('../faceai/models').then(
    async ()=>{
      isready=true;
    }
  );
}

var isRead=false;
var islearned=false;

$("#he").hide();
$("#hf").hide();

function learned(){
  if(isRead){
    islearned=true;
  }
}

const SSD_MOBILENETV1 = 'ssd_mobilenetv1';
const TINY_FACE_DETECTOR = 'tiny_face_detector';
let selectedFaceDetector = TINY_FACE_DETECTOR;
// ssd_mobilenetv1 options
let minConfidence = 0.3;
// tiny_face_detector options
let inputSize = 512
let scoreThreshold = 0.2

function getFaceDetectorOptions() {
  return selectedFaceDetector === SSD_MOBILENETV1
    ? new faceapi.SsdMobilenetv1Options()
    : new faceapi.TinyFaceDetectorOptions()
}
const options = getFaceDetectorOptions();

let features;//特征点坐标

async function updateResults(input) {
  var canvasface = document.createElement('canvas');
  canvasface.width=input.width;
  canvasface.height=input.height;
  canvasface.getContext('2d').drawImage(input,0,0,canvasface.width,canvasface.height);
  //$("#test").append(canvasface);
  var inputface =canvasface;
  const faces  = await faceapi
    .detectAllFaces(inputface, options)
    .withFaceLandmarks()
    .withFaceExpressions()
    .withAgeAndGender();

  if(faces .length){    
      $(".overlay").show();
      //console.log("人脸信息显示：",imgface);
      faceapi.matchDimensions(overlay, inputface);
      
      //console.log("后图片尺寸：",inputface.width,inputface.height);
      const resizedResults  = faceapi.resizeResults(faces  , inputface);

      overlay.getContext('2d').clearRect(0, 0, overlay.width, overlay.height);
      faceapi.draw.drawDetections(overlay, resizedResults );
      faceapi.draw.drawFaceLandmarks(overlay, resizedResults );
      faceapi.draw.drawFaceExpressions(overlay, resizedResults );
      resizedResults .forEach(result => {
        const { age, gender, genderProbability } = result;
        new faceapi.draw.DrawTextField(
          [
            `${faceapi.utils.round(age, 0)} 年龄`,
            ` ${gender} (${faceapi.utils.round(genderProbability)})`
          ],
          result.detection.box.bottomRight
        ).draw(overlay)
      });
      for (const face of faces) {          
        const landmarkPositions = face.landmarks.positions;//脸部特征点坐标
        const facepos=[];
        let n=0;
        for(const pos of landmarkPositions){
          let pstr=n+ ' ('+parseInt(pos.x)+','+parseInt(pos.y)+')';
          n++;
          facepos.push(pstr);
          //console.log(pstr);
        }
        $("#landmarks").html(facepos.join('<br>'));
        
        features = {
          jawLeft: face.landmarks.positions[0],
          jawRight: face.landmarks.positions[16],
          eyebrowLeft: face.landmarks.positions[17],
          eyebrowRight: face.landmarks.positions[22],
          noseBridge: face.landmarks.positions[27],
          nose: face.landmarks.positions[31],
          eyeLeft: face.landmarks.positions[36],
          eyeRight: face.landmarks.positions[42],
          lipOuter: face.landmarks.positions[48],
          lipInner: face.landmarks.positions[60],
          lipLeft:face.landmarks.positions[48],
          lipRight:face.landmarks.positions[54],          
          lipCenter:face.landmarks.positions[57]
        };
       
      }

      return true;
    }
    else{
      console.log("未检测到人脸！");
      return false;
    }

}

let oldmagic='';//旧装饰分类字母，初始化

async function faceDetector() {
  //console.log(isready);
  if(isready){
    oldmagic='';
    await updateResults(face);
  }
}

async function faceSave() { 
if(islearned){
      var cv = document.createElement('canvas');
      cv.width=face.width;
      cv.height=face.height;
      cv.getContext('2d').drawImage(face,0,0,cv.width,cv.height);  
      cv.getContext('2d').drawImage(overlay,0,0,cv.width,cv.height);
  
      var imgData=cv.toDataURL('png',0.6);
      /*
      var blob = dataURLtoBlob(imgData);
      var objurl = URL.createObjectURL(blob);
      var link = document.createElement("a");
      link.download = "表情.png";
      link.href = objurl;
      link.click();
      //console.log('表情：',imgfacesave);
      */
    	
      var urls = 'upface.ashx?id=' + id;
      var formData = new FormData();//
      var cover = dataURLtoBlob(imgData);
      console.log(cover);

      formData.append('id', id);
      formData.append('cover', cover);

      $.ajax({
        url: urls,
        type: 'POST',
        cache: false,
        data: formData,
        processData: false,
        contentType: false
      }).done(function (res) {
  
        $("#he").show();
        alert("保存成功！");
        console.log(res)
      });

  }
  else{
    alert("请先上传一张照片，人脸检测后打扮！");
  }
}

function  dataURLtoBlob(dataurl) {
  var arr = dataurl.split(','), mime = arr[0].match(/:(.*?);/)[1],
    bstr = atob(arr[1]), n = bstr.length, u8arr = new Uint8Array(n);
  while(n--){
      u8arr[n] = bstr.charCodeAt(n);
  }
  return new Blob([u8arr], {type:mime});
}


$(".cartoon").click(function () {
  //绘制魔法饰品
  
  const ctx = overlay.getContext('2d'); 
  // 设置全局透明度为半透明    
  ctx.globalAlpha = 1;
  var width = this.width;
  var height = this.height; 
  if (features) {
    var box = getseat(this);
    var l = box.ln;
    var x = box.xn;
    var y = box.yn;
    var angle= box.gm;
    if(oldmagic==box.m || oldmagic==''){
      ctx.clearRect(0, 0, overlay.width, overlay.height);//同类饰品则清空画布
    }    
    oldmagic =box.m;
    if(oldmagic=='p'||oldmagic=='m'){
      ctx.globalAlpha = 0.8;
    }
    var cw = l * 2;
    var ch = height / width * cw;
    const radians = Math.atan2(ch, cw);
    const rotatedWidth = Math.abs(cw * Math.cos(radians)) + Math.abs(ch * Math.sin(radians));
    const rotatedHeight = Math.abs(cw * Math.sin(radians)) + Math.abs(ch * Math.cos(radians));
    // 设置Canvas尺寸
    
    let canvas = document.createElement('canvas');
    let canvastx =canvas.getContext('2d');
    canvas.width = rotatedWidth;
    canvas.height = rotatedHeight;

    // 将Canvas原点移到中心
    canvastx.translate(rotatedWidth / 2, rotatedHeight / 2);

    // 旋转图片
    canvastx.rotate(angle); // 'angle'是旋转的角度
    console.log(angle);
    canvastx.drawImage(this, -cw / 2, -ch / 2, cw, ch);

    ctx.drawImage(canvas, x, y);    
    learned();
  }
  else {
    alert("请先进行人脸检测！");
  }

});

function getseat(img){
  //console.log(img.src);
  const fileName = getFileNameWithoutExtension(img.src);
  //console.log(fileName);
  var magic=fileName[0];
  var imgh=img.height;
  var l,x,y;
  
  var a= Math.abs(features.jawLeft.x-features.jawRight.x);//直角边a
  var b= features.jawRight.y-features.jawLeft.y;//直角边b
  const gamma = Math.atan(b / a);

  switch(magic){
    case 'b'://脸谱
      l = features.eyebrowRight.x - features.eyebrowLeft.x;
      x = features.eyebrowLeft.x-l*3/4;
      y = features.eyeLeft.y-l*3/2;
      break;
    case 'h'://帽子  
      l = (features.eyebrowRight.x - features.eyebrowLeft.x)*3/2;
      x = features.eyebrowLeft.x-l*3/4+b;
      y = features.eyeLeft.y-l*2;
      break;
    case 'e'://眼睛
      l = features.eyebrowRight.x - features.eyebrowLeft.x;
      x = features.eyebrowLeft.x-l/4;
      y = features.eyeLeft.y-l*3/4;
      break;
    case 'l'://驴角
      l = features.eyebrowRight.x - features.eyebrowLeft.x;
      x = features.eyebrowLeft.x-l/3;
      y = features.eyeLeft.y-l*2;
      break;
    case 'x'://猫须
      l = features.eyebrowRight.x - features.eyebrowLeft.x;
      x = features.eyebrowLeft.x-l/4;
      y = features.eyeLeft.y-l*2/5;
      break;
    case 'm'://唇
      l = features.lipRight.x - features.lipLeft.x;
      x = features.lipLeft.x-l/2;
      y = features.lipCenter.y-l*3/4;
      break;
    case 'p'://眼镜
      l = features.eyebrowRight.x - features.eyebrowLeft.x;
      x = features.eyebrowLeft.x-l/4;
      y = features.noseBridge.y-l*3/4;
      break;
  }
  //console.log("角度：",gamma);

  var box ={
    ln:l,
    xn:x,
    yn:y,
    gm:gamma,
    gy:b/2,
    m:magic
  }
  console.log(box);
  return box;
}
function getFileNameWithoutExtension(path) {
    var i=path.lastIndexOf('/')+1;
    var fname=path.slice(i);
    return fname.split('.')[0];
}


$(".upimgIcon").click(function(){
    $("#uploadimg").click();//点击图片，弹出上传浏览窗口
    isRead=true;
});

$("#uploadimg").change(function(){
  const file = this.files[0];
  if(file){
    let reader = new FileReader();
    reader.onload = function(event){
      face.src = event.target.result;
    }
    reader.readAsDataURL(file);
    $(".overlay").hide();
    $("#landmarks").html('');
    features=null;
  }

});
