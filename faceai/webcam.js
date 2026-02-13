const face = document.getElementById('webcam-container');
const imageObj = document.getElementById('image-obj');
const overlay = document.getElementById('overlay'); 
const enablevoice = document.getElementById('enable-voice');

let videoPlaying = false;
let ImagePlaying = false;


let descriptors=[];
let pid=0;

window.onload = function () {
  enableCam(); 
  run();
}

async function run() {
  await faceapi.nets.tinyFaceDetector.loadFromUri('../faceai/models');
  await faceapi.nets.faceLandmark68Net.loadFromUri('../faceai/models');
  await faceapi.nets.faceRecognitionNet.loadFromUri('../faceai/models');
  await faceapi.nets.ssdMobilenetv1.loadFromUri('../faceai/models');

  await initFace();

  setInterval(checkface,50);
  setInterval(faceDetector,5000);
}


$("#hf").hide();

function enableCam() {
  if (hasGetUserMedia()) {
    // getUsermedia parameters.
    const constraints = {
      video: true,
      width: 300,
      height: 400
    };

    // Activate the webcam stream.
    navigator.mediaDevices.getUserMedia(constraints).then(function(stream) {
      face.srcObject = stream;
      face.addEventListener('loadeddata', function() {
        videoPlaying = true;
      });
    });
  } else {
    console.warn('getUserMedia() is not supported by your browser');
  }
}

function hasGetUserMedia() {
  return !!(navigator.mediaDevices && navigator.mediaDevices.getUserMedia);
}

let voice =false;
$("#enable-voice").click(function () {
  if(voice){
    voice=false;
    enablevoice.className = "fa fa-volume-off";
    enablevoice.title="语音禁用";
  }
  else{
    voice=true;
    enablevoice.className="fa fa-volume-up";
    enablevoice.title="语音播报";
  }
});

$("#upimg").click(function () {
  $("#image-obj").click();
});


function faceStore(){  
  $("#collector").html("人脸仓库图片: "+pid+"张");
}

$(".dataCollector").click(function () {
    //采集照片
    createCavnas(face);
});

$(".dataup").click(function () {
    $("#image-input").click();
});

$(".outpic").mouseleave(function () {
  $(".dataup").focus();
});

$("#image-input").change(function(e){
    const files = e.target.files;
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      if (!file.type.startsWith('image/')) {
        continue;
      }
  
      const reader = new FileReader();
      reader.onload = (function(theFile) {
        return async function(e) {
          // 创建一个Image元素
          const img = document.createElement('img');
          pid++;
          img.id="pf"+pid;
          img.className="thumb";
          img.src = e.target.result;  

          var div = document.createElement("div");
          div.id='d'+pid;
          div.className='piclist';
          $('#output').append(div);
          let strid="#"+'d'+pid;
          $(strid).append(img);//显示视频帧图片
          var sp=document.createElement("span");
          sp.id='p'+pid;
          sp.className='spname';
          sp.contentEditable = true;
          sp.innerText="名字"+pid;
          $(strid).append(sp);

          let desc_img = await faceapi.computeFaceDescriptor(img);
          descriptors.push(desc_img); 
          faceStore();
          //console.log(descriptors);
        };
      })(file);  
      reader.readAsDataURL(file);
    }

});

async function initFace(){
  let famenames=['特朗谱','施瓦辛格','未知'];
  for(var i=1;i<3;i++){
    var img=document.createElement('img');  
    pid++;
    img.id="pf"+pid;
    img.className="thumb";
    img.src="images/fame/"+i+".jpg"; 
    //console.log(img); 

    var div = document.createElement("div");
    div.id='d'+pid;
    div.className='piclist';
    $('#output').append(div);
    let strid="#"+'d'+pid;
    $(strid).append(img);//显示视频帧图片
    var sp=document.createElement("span");
    sp.id='p'+pid;
    sp.className='spname';
    sp.contentEditable = true;
    sp.innerText=famenames[pid-1];
    $(strid).append(sp);


    img.onload= async function(){
      let desc_img = await faceapi.computeFaceDescriptor(img);
      descriptors.push(desc_img);
      faceStore();
    }
  }  
  //console.log(descriptors);
}

async function createCavnas(inputElm){
  if(videoPlaying){
    var canvas = document.createElement("canvas");
    canvas.className="thumb";
    canvas.width = 480 ;
    canvas.height = 480;
    canvas.getContext('2d').drawImage(inputElm,80,0,480,480, 0, 0, canvas.width, canvas.height);
    var img=document.createElement('img');
    pid++;
    img.id="pf"+pid;
    img.className="thumb";
    img.src=canvas.toDataURL();

    var div = document.createElement("div");
    div.id='d'+pid;
    div.className='piclist';
    $('#output').append(div);
    let strid="#"+'d'+pid;
    $(strid).append(img);//显示视频帧图片
    var sp=document.createElement("span");
    sp.id='p'+pid;
    sp.className='spname';
    sp.contentEditable = true;
    sp.innerText="我的名字";
    $(strid).append(sp);
    
    let desc_cam = await faceapi.computeFaceDescriptor(canvas);
    descriptors.push(desc_cam);
    faceStore();
    //console.log(descriptors);
  }
}


async function checkface(){
  const singleFace  = await faceapi
  .detectSingleFace(face,new faceapi.SsdMobilenetv1Options())
  .withFaceLandmarks()

  if(singleFace){
    const dims = faceapi.matchDimensions(overlay, face, true);
    const resizedResults = faceapi.resizeResults(singleFace, dims);
    faceapi.draw.drawFaceLandmarks(overlay, resizedResults);
  }
}


async function faceDetector() {
  var passtxt="";
  $('#pass').html(passtxt);

  if(videoPlaying ||ImagePlaying){
    let desc_face = await faceapi.computeFaceDescriptor(face);
    let facecount = descriptors.length;
    console.log("人脸库数量：",facecount);
    let pass=-1;
    
    for(let i=0;i<facecount;i++){
      const distance = faceapi.utils.round(faceapi.euclideanDistance(desc_face, descriptors[i]));
      console.log(distance);
      if(distance<0.4){
        pass=i;
        break;
      }
    }
    if(pass>0){ 
      let currentid=pass+1;
      $("#pf"+currentid).css('background-color', 'yellowgreen');
      let fname=$('#p'+currentid).text();
      passtxt= fname + " 扫脸通过！";
       $("#hf").show();
      //console.log(passtxt);
    }
    else{
      passtxt="扫脸失败！";
    }
    $('#pass').html(passtxt);
    
    //console.log("ok");
}

  playText(passtxt);
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