const facevideo = document.getElementById('inputVideo');
const overlay = document.getElementById('overlay');

window.onload = function () {
  run();
}

async function run() {
  await faceapi.nets.tinyFaceDetector.loadFromUri('../faceai/models');
  await faceapi.nets.faceLandmark68Net.loadFromUri('../faceai/models');
  await faceapi.nets.faceRecognitionNet.loadFromUri('../faceai/models');
  await faceapi.nets.faceExpressionNet.loadFromUri('../faceai/models');
  await faceapi.nets.ageGenderNet.loadFromUri('../faceai/models');
  await faceapi.nets.ssdMobilenetv1.loadFromUri('../faceai/models');
}

$("#ha").show();
$("#hb").show();

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

async function onPlay(videoEl) {
  if (!videoEl.currentTime || videoEl.paused || videoEl.ended )
    return setTimeout(() => onPlay(videoEl));

  const ts = Date.now();

  let task = faceapi.detectAllFaces(videoEl, options);
  task = task.withFaceLandmarks() ;
  const results = await task;

  const canvas = $('#overlay').get(0);
  const dims = faceapi.matchDimensions(canvas, videoEl, true);

  const resizedResults = faceapi.resizeResults(results, dims);

  faceapi.draw.drawFaceLandmarks(canvas, resizedResults);


  setTimeout(() => onPlay(videoEl));
}

async function faceDetector() {
  onPlay($('#inputVideo').get(0));
  facevideo.muted=false;
  $("#hc").show();
}


let n=1;
function videoChange(){
  n++;
  if(n>3){
    n=1;
  }
  facevideo.src="videos/test"+n+".mp4";
  console.log(facevideo);
}