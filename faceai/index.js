const faceone = document.getElementById('faceimgone');
const facetwo = document.getElementById('faceimgtwo');
const message = document.getElementById('result');
const layone = document.getElementById('overlayone');
const laytwo = document.getElementById('overlaytwo');

const hc = document.getElementById('hc');
const hd = document.getElementById('hd');
const he = document.getElementById('he');

window.onload = function () {
  run();
}

var isRead=false;
$("#hd").hide();
$("#he").hide();
$("#hf").hide();

function learned(){
  if(isRead){
    $("#hd").show();
  }
}

async function run() {
  await faceapi.nets.tinyFaceDetector.loadFromUri('../faceai/models');
  await faceapi.nets.faceLandmark68Net.loadFromUri('../faceai/models');
  await faceapi.nets.faceRecognitionNet.loadFromUri('../faceai/models');
  await faceapi.nets.faceExpressionNet.loadFromUri('../faceai/models');
  await faceapi.nets.ageGenderNet.loadFromUri('../faceai/models');
  await faceapi.nets.ssdMobilenetv1.loadFromUri('../faceai/models');
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

async function updateResults(inputface,overlay) {
  const results = await faceapi
    .detectAllFaces(inputface, options)
    .withFaceLandmarks()
    .withFaceExpressions()
    .withAgeAndGender();

  if(results.length){    
      $(".overlay").show();
      //console.log("人脸信息显示：",imgface);
      faceapi.matchDimensions(overlay, inputface)
      const resizedResults  = faceapi.resizeResults(results , inputface);

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
      return true;
    }
    else{
      console.log("未检测到人脸！");
      return false;
    }

}

async function faceDetector() {
  let one = await updateResults(faceone,layone);
  let two = await updateResults(facetwo,laytwo);
  if(one && two){
    await Descriptor();
  } 
  else{
    message.innerHTML = "未检测到人脸";
  }

}


async function Descriptor() {
  desc1 = await faceapi.computeFaceDescriptor(faceone);
  desc2 = await faceapi.computeFaceDescriptor(facetwo);
  const distance = faceapi.utils.round(faceapi.euclideanDistance(desc1, desc2));

  console.clear();
  let dstr = "特征点距离：" + distance+" ";
  if (distance < 0.5) {
    dstr = " 为同一人，"+ dstr ;
  }
  else {
    dstr = " 五官不匹配，"+ dstr ;
  }
  message.innerHTML = dstr;
  console.log(dstr); 
  learned();
}


var imgId;

$(".upimgIcon").click(function(){
    $("#uploadimg").click();//点击图片，弹出上传浏览窗口
    imgId= this.id; 
    //console.log(imgId);
    isRead=true;
});

$("#uploadimg").change(function(){
  const file = this.files[0];
  if(file){
    let reader = new FileReader();
    reader.onload = function(event){
      $(imgId).attr('src', event.target.result);
    }
    reader.readAsDataURL(file);
    $(".overlay").hide();
    message.innerHTML = "";
  }

});

$("#scales").click(function(){
  $(".overlay").toggle();
})