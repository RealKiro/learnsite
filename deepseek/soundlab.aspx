<%@ page language="C#" autoeventwireup="true" inherits="deepseek_soundlab, LearnSite" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>

<head  runat="server">
    <title>🎙️ SoundLab 在线声音分析</title>
    <style>
        * { box-sizing: border-box; }
        body {
            max-width: 860px; margin: 0 auto;
            background: #f1f5f9; color: #1e293b;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            font-size: 13px; padding-bottom: 28px;
        }
        h1 { margin: 0; font-size: 20px; font-weight: 700; color: #fff; }

        /* Header */
        .sl-header {
            background: linear-gradient(135deg, #312e81 0%, #4f46e5 60%, #818cf8 100%);
            padding: 22px 28px; margin-bottom: 16px;
            display: flex; flex-direction: column; align-items: center; gap: 4px;
            position: relative; overflow: hidden;
        }
        .sl-header::before {
            content: ''; position: absolute; right: -30px; top: -30px;
            width: 120px; height: 120px; border-radius: 50%;
            background: rgba(255,255,255,.06);
        }
        .sl-sub { font-size: 12px; color: rgba(255,255,255,.65); letter-spacing: .5px; margin: 0; }

        /* Panel card */
        .sl-panel {
            background: #fff; border-radius: 12px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 1px 4px rgba(0,0,0,.05);
            overflow: hidden; margin: 0 16px 14px;
        }
        .sl-panel-head {
            display: flex; align-items: center; gap: 7px;
            padding: 9px 16px;
            font-size: 11px; font-weight: 700; color: #64748b;
            background: #f8fafc; border-bottom: 1px solid #f1f5f9;
            letter-spacing: .5px; text-transform: uppercase;
        }
        .sl-panel-head svg {
            width: 14px; height: 14px; stroke: #6366f1; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0;
        }
        .sl-hint { font-weight: 400; color: #94a3b8; margin-left: 4px; }

        /* Canvas */
        canvas { background: #0f172a; display: block; width: 100%; margin: 0; border-radius: 0; box-shadow: none; }

        /* Controls card */
        .sl-controls-card {
            background: #fff; border-radius: 12px;
            border: 1px solid #e2e8f0; box-shadow: 0 1px 4px rgba(0,0,0,.05);
            padding: 14px 16px; margin: 0 16px 14px;
        }
        .controls { display: flex; justify-content: center; gap: 10px; margin-bottom: 10px; }

        /* Buttons */
        button {
            height: 34px; padding: 0 16px; border-radius: 8px; border: none;
            font-size: 13px; font-weight: 500; cursor: pointer; transition: all .15s;
            font-family: inherit; display: inline-flex; align-items: center; gap: 6px;
            background: #6366f1; color: #fff;
        }
        button svg {
            width: 13px; height: 13px; stroke: currentColor; fill: none;
            stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; flex-shrink: 0;
        }
        button:hover { opacity: .85; transform: translateY(-1px); }
        button:disabled { background: #e2e8f0 !important; color: #94a3b8 !important; cursor: not-allowed; transform: none !important; opacity: 1 !important; }
        #startBtn { background: linear-gradient(135deg, #10b981, #34d399); }
        #stopBtn  { background: linear-gradient(135deg, #ef4444, #f87171); }

        /* Status */
        #status {
            text-align: center; font-size: 12px; color: #64748b;
            padding: 5px 18px; background: #f8fafc;
            border-radius: 20px; border: 1px solid #e2e8f0;
            width: fit-content; margin: 0 auto;
            font-family: 'Consolas', monospace;
        }

        /* Recordings */
        .recordings-list { padding: 0; }
        .recording-item {
            display: flex; align-items: center; gap: 12px;
            padding: 12px 16px; border-bottom: 1px solid #f1f5f9; transition: background .1s;
        }
        .recording-item:last-child { border-bottom: none; }
        .recording-item:hover { background: #f8fafc; }
        .recording-title { width: 130px; flex-shrink: 0; }
        .recording-title h4 { font-size: 13px; font-weight: 600; color: #1e293b; margin: 0 0 4px; cursor: text; }
        .recording-title div { font-size: 11px; color: #94a3b8; margin-top: 2px; }
        .recording-img { flex: 1; min-width: 0; overflow: hidden; }
        .recording-img img { width: 100%; background: #0f172a; border-radius: 4px; display: block; margin-bottom: 4px; }
        .recording-tool {
            width: 80px; flex-shrink: 0;
            display: flex; flex-direction: column; gap: 6px; align-items: stretch; text-align: center;
        }
        .recording-item button { width: 100%; height: 30px; font-size: 12px; border-radius: 6px; margin: 0; }
        .recording-item button.delete-btn { background: linear-gradient(135deg, #ef4444, #f87171); }

        /* Compare */
        .compare-section {
            padding: 14px 16px; background: #f8fafc;
            border-top: 1px solid #f1f5f9;
        }
        .compare-section > h3 {
            font-size: 11px; font-weight: 700; color: #64748b;
            text-transform: uppercase; letter-spacing: .5px;
            display: flex; align-items: center; gap: 6px; margin: 0 0 12px;
        }
        .compare-controls {
            display: grid; grid-template-columns: 1fr 1fr auto;
            gap: 10px; margin-bottom: 12px; align-items: center;
        }
        select {
            height: 34px; padding: 0 10px; border: 1px solid #e2e8f0; border-radius: 8px;
            font-size: 13px; background: #fff; color: #334155; outline: none; font-family: inherit;
        }
        select:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,.1); }
        .result-box { padding: 12px; background: #fff; border-radius: 8px; border: 1px solid #e2e8f0; min-height: 44px; }
        .similar    { color: #10b981; font-weight: 700; }
        .dissimilar { color: #ef4444; font-weight: 700; }
        .medium     { color: #f59e0b; font-weight: 700; }
        .similarity-meter {
            background: #e2e8f0; height: 32px; border-radius: 16px;
            position: relative; margin: 8px 0; overflow: hidden;
        }
        .similarity-meter .bar {
            background: linear-gradient(90deg, #ef4444, #f59e0b, #10b981);
            height: 100%; border-radius: 16px; transition: width .5s ease;
            display: flex; align-items: center; justify-content: center;
            font-size: 13px; font-weight: 600; color: #fff;
            text-shadow: 0 1px 2px rgba(0,0,0,.3);
        }
        .similarity-meter span {
            position: absolute; left: 50%; top: 50%;
            transform: translate(-50%, -50%);
            color: #64748b; font-size: 12px; font-weight: 600;
        }
        .feature-comparison { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 20px; }

        /* Toast */
        .sl-toast {
            position: fixed; bottom: 30px; left: 50%;
            transform: translateX(-50%) translateY(16px);
            background: #1e293b; color: #fff;
            padding: 10px 24px; border-radius: 8px;
            font-size: 13px; font-weight: 500;
            opacity: 0; pointer-events: none;
            transition: all .25s; z-index: 9999;
            white-space: nowrap; box-shadow: 0 4px 16px rgba(0,0,0,.2);
        }
        .sl-toast.show { opacity: 1; transform: translateX(-50%) translateY(0); }
        .sl-toast.success { background: #10b981; }
        .sl-toast.error   { background: #ef4444; }
    </style>
    
    <script src="../code/jquery.min.js" type="text/javascript"></script>
    <script src="../code/html2canvas.min.js" type="text/javascript"></script>
</head>
<body>

<div class="sl-header">
    <h1>🎙️ SoundLab 在线声音分析</h1>
    <p class="sl-sub">声音三要素 &middot; 音高 &middot; 音色 &middot; 响度</p>
</div>

<!-- 实时波形 -->
<div class="sl-panel">
    <div class="sl-panel-head">
        <svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
        实时波形 <span class="sl-hint">振幅 = 响度</span>
    </div>
    <canvas id="waveform" width="800" height="150" title="波形图：振幅为响度"></canvas>
</div>

<!-- 频谱分析 -->
<div class="sl-panel">
    <div class="sl-panel-head">
        <svg viewBox="0 0 24 24"><rect x="2" y="10" width="4" height="11" rx="1" fill="none"/><rect x="10" y="4" width="4" height="17" rx="1" fill="none"/><rect x="18" y="7" width="4" height="14" rx="1" fill="none"/></svg>
        频谱分析 <span class="sl-hint">频率分布</span>
    </div>
    <canvas id="spectrum" width="800" height="150" title="频谱图：振幅为频率"></canvas>
</div>

<!-- MFCC -->
<div class="sl-panel">
    <div class="sl-panel-head">
        <svg viewBox="0 0 24 24"><path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/></svg>
        MFCC 特征 <span class="sl-hint">音色倒谱</span>
    </div>
    <canvas id="mfcc" width="800" height="150" title="倒谱图：音色"></canvas>
</div>

<!-- 控制栏 -->
<div class="sl-controls-card">
    <div class="controls">
        <button id="startBtn">
            <svg viewBox="0 0 24 24" fill="currentColor" stroke="none"><circle cx="12" cy="12" r="9"/></svg>
            开始录音
        </button>
        <button id="stopBtn" disabled>
            <svg viewBox="0 0 24 24" fill="currentColor" stroke="none"><rect x="6" y="6" width="12" height="12" rx="1"/></svg>
            停止录音
        </button>
        <button onclick="savechat()" title="保存到服务器">
            <svg viewBox="0 0 24 24"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
            保存
        </button>
        <button onclick="returnurl()" title="返回到学案页面">
            <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
            返回
        </button>
    </div>
    <div id="status">准备就绪</div>
    <audio id="audioPlayer" controls hidden></audio>
</div>

<!-- 录音历史 -->
<div class="sl-panel" id="recordhistory">
    <div class="sl-panel-head">
        <svg viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
        录音列表
    </div>
    <div class="recordings-list">
        <div id="recordings"></div>
    </div>
    <!-- 对比功能 -->
    <div class="compare-section">
        <h3>
            <svg viewBox="0 0 24 24" style="width:13px;height:13px;stroke:#6366f1;fill:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:round"><path d="M18 20V10"/><path d="M12 20V4"/><path d="M6 20v-6"/></svg>
            声音相似度对比
        </h3>
        <div class="compare-controls">
            <select id="recording1"><option value="">选择第一个录音</option></select>
            <select id="recording2"><option value="">选择第二个录音</option></select>
            <button onclick="compareRecordings()">
                <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                开始比较
            </button>
        </div>
        <div id="result" class="result-box"></div>
    </div>
</div>
<div class="sl-toast" id="slToast"></div>

    <script type="text/javascript">					
        const startBtn = document.getElementById('startBtn');
        const stopBtn = document.getElementById('stopBtn');
        const status = document.getElementById('status');
        const waveformCanvas = document.getElementById('waveform');
        const spectrumCanvas = document.getElementById('spectrum');
        const mfccCanvas = document.getElementById('mfcc'); // 新增 MFCC Canvas
        const audioPlayer = document.getElementById('audioPlayer');
        const recordingsList = document.getElementById('recordings');

        let audioContext, analyser, mediaRecorder, chunks = [];
        let isRecording = false;
        let isPlaying = false;
        let recordings = [];
        let mfccFeatures = []; // 存储 MFCC 特征
        let featureBuffer = []; // 存储完整特征序列
        let previousMFCC = null;
        let previousDelta = null;

        // 初始化分析器
        function initAnalyser(source) {
            analyser = audioContext.createAnalyser();
            analyser.fftSize = 2048;

            const gainNode = audioContext.createGain();
            gainNode.gain.value = 0; // 静音处理

            source.connect(analyser);
            analyser.connect(gainNode);
            gainNode.connect(audioContext.destination);
        }

        // 绘制波形
        function drawWaveform() {
            const ctx = waveformCanvas.getContext('2d');
            ctx.clearRect(0, 0, waveformCanvas.width, waveformCanvas.height);

            if (analyser) {
                const bufferLength = analyser.fftSize;
                const dataArray = new Uint8Array(bufferLength);
                analyser.getByteTimeDomainData(dataArray);

                ctx.beginPath();
                ctx.lineWidth = 2;
                ctx.strokeStyle = '#0f0';

                const sliceWidth = waveformCanvas.width * 1.0 / bufferLength;
                let x = 0;

                for (let i = 0; i < bufferLength; i++) {
                    const v = dataArray[i] / 128.0;
                    const y = v * waveformCanvas.height / 2;

                    if (i === 0) ctx.moveTo(x, y);
                    else ctx.lineTo(x, y);

                    x += sliceWidth;
                }

                ctx.stroke();
            }

            if (isRecording || isPlaying) {
                requestAnimationFrame(drawWaveform);
            }
        }

        // 绘制频谱
        function drawSpectrum() {
            const ctx = spectrumCanvas.getContext('2d');
            ctx.clearRect(0, 0, spectrumCanvas.width, spectrumCanvas.height);

            if (analyser) {
                const bufferLength = analyser.frequencyBinCount;
                const dataArray = new Uint8Array(bufferLength);
                analyser.getByteFrequencyData(dataArray);

                const barWidth = (spectrumCanvas.width / bufferLength) * 2.5;
                let x = 0;

                for (let i = 0; i < bufferLength; i++) {
                    const barHeight = dataArray[i];
                    ctx.fillStyle = `hsl(${i * 2}, 100%, 50%)`;
                    ctx.fillRect(x, spectrumCanvas.height - barHeight, barWidth, barHeight);
                    x += barWidth + 1;
                }
				
				//console.log("频谱",dataArray);
				// 将频域数据转换为线性幅值
				const spectrum = Array.from(dataArray).map(value => Math.pow(10, value / 20));
				// 计算 MFCC 特征
				mfccFeatures = calculateMFCC(spectrum, audioContext.sampleRate);
				//console.log("计算 MFCC 特征",mfccFeatures);
				
				// 计算 MFCC 特征
				//const mfccold = calculateMFCCold(spectrum, audioContext.sampleRate);
				//console.log("计算 MFCC old 特征",mfccold);
			
				drawMFCC();
            }

            if (isRecording || isPlaying) {
                requestAnimationFrame(drawSpectrum);
            }
        }

        // 计算 MFCC 特征
        function calculateMFCC(spectrum, sampleRate) {
            const numFilters = 26; // 梅尔滤波器数量
            const numCoefficients = 13; // MFCC 系数数量
            const mfcc = [];

            // 计算梅尔滤波器组
            const melFilters = createMelFilterBank(numFilters, spectrum.length, sampleRate);

            // 应用梅尔滤波器组
            for (let i = 0; i < numFilters; i++) {
                let sum = 0;
                for (let j = 0; j < spectrum.length; j++) {
                    sum += spectrum[j] * melFilters[i][j];
                }
                mfcc.push(Math.log(sum + 1e-6)); // 避免对零取对数
            }

            const logMelEnergies = mfcc;
			const dctCoefficients = dct(logMelEnergies);
			return dctCoefficients.slice(0, numCoefficients);
        }
		
		function dct(logMelEnergies) {
			const N = logMelEnergies.length;
			const coefficients = [];
			for (let k = 0; k < N; k++) {
				let sum = 0;
				for (let n = 0; n < N; n++) {
					sum += logMelEnergies[n] * Math.cos(Math.PI * k / N * (n + 0.5));
				}
				coefficients.push(sum);
			}
			return coefficients;
		}


        // 修正后的梅尔滤波器组生成
        function createMelFilterBank(numFilters, fftSize, sampleRate) {
            const melFilters = [];
            const lowMel = 0;
            const highMel = 2595 * Math.log10(1 + (sampleRate / 2) / 700);

            // 生成梅尔刻度上的点
            const melPoints = [];
            for (let i = 0; i <= numFilters + 1; i++) {
                melPoints.push(lowMel + (i / (numFilters + 1)) * (highMel - lowMel));
            }

            // 创建每个滤波器
            for (let i = 0; i < numFilters; i++) {
                const filter = new Array(fftSize).fill(0);
                // 转换为Hz
                const leftFreq = 700 * (Math.pow(10, melPoints[i] / 2595) - 1);
                const centerFreq = 700 * (Math.pow(10, melPoints[i+1] / 2595) - 1);
                const rightFreq = 700 * (Math.pow(10, melPoints[i+2] / 2595) - 1);

                // 转换为频点
                const leftBin = Math.floor((fftSize) * leftFreq / sampleRate);
                const centerBin = Math.floor((fftSize) * centerFreq / sampleRate);
                const rightBin = Math.floor((fftSize) * rightFreq / sampleRate);

                // 创建三角滤波器
				for (let j = leftBin; j <= centerBin; j++) {
					filter[j] = (j - leftBin) / (centerBin - leftBin);
				}
				for (let j = centerBin + 1; j <= rightBin; j++) {
					filter[j] = 1 - (j - centerBin) / (rightBin - centerBin);
				}

                melFilters.push(filter);
            }
            return melFilters;
        }

        // 绘制 MFCC 特征
        function drawMFCC() {
            const ctx = mfccCanvas.getContext('2d');
            ctx.clearRect(0, 0, mfccCanvas.width, mfccCanvas.height);

            if (mfccFeatures.length > 0) {
                const numCoefficients = mfccFeatures.length;
                const barWidth = mfccCanvas.width / numCoefficients;
                const maxHeight = mfccCanvas.height;

                for (let i = 0; i < numCoefficients; i++) {
                    const value = mfccFeatures[i];
                    const barHeight = (value + 10) * (maxHeight / 50); // 归一化到画布高度
                    ctx.fillStyle = `hsl(${i * 10}, 100%, 50%)`;
                    ctx.fillRect(i * barWidth, maxHeight - barHeight, barWidth, barHeight);
                }
            }

            if (isRecording || isPlaying) {
                requestAnimationFrame(drawMFCC);
            }
        }

        // 提取 MFCC 特征
        function extractMFCC() {
            if (!analyser) return;

            const bufferLength = analyser.frequencyBinCount;
            const dataArray = new Float32Array(bufferLength);
            analyser.getFloatFrequencyData(dataArray); // 获取频域数据

            // 将频域数据转换为线性幅值
            const spectrum = Array.from(dataArray).map(value => Math.pow(10, value / 20));

            // 计算 MFCC 特征
            const mfcc = calculateMFCC(spectrum, audioContext.sampleRate);
            console.log("计算 MFCC 特征",mfcc);
            mfccFeatures = mfcc;
            drawMFCC();
        }



        let recordnum = 0;

        // 添加录音到列表
        function addRecording(blob, duration) {
            recordnum++;
            const recording = {
                id: Date.now(),
                name: recordnum,
                blob: blob,
                duration: duration,
                timestamp: new Date().toLocaleString(),
                waveform: waveformCanvas.toDataURL(),
                spectrum: spectrumCanvas.toDataURL(),
                mfcc: mfccCanvas.toDataURL(), // 保存 MFCC 图像
                mfccFeature: mfccFeatures,                
                fullFeatures: featureBuffer // 存储完整特征序列
            };

            recordings.push(recording);
            //console.log(recording);
            renderRecordings();
            updateRecordingSelector();
            featureBuffer = []; // 清空特征缓存
        }

        // 渲染录音列表
        function renderRecordings() {
            recordingsList.innerHTML = recordings.map(rec => `
                <div class="recording-item">
                    <div class="recording-title">
                        <h4 contenteditable="true">录音 ${rec.name}</h4>
                        <div>${rec.timestamp}</div>
                        <div>${rec.duration.toFixed(2)}秒</div>
                    </div>
                    <div class="recording-img">
                        <img src="${rec.waveform}" title="波形图：振幅为响度"/>
                        <img src="${rec.spectrum}"  title="频谱图：振幅为频率"/>
                        <img src="${rec.mfcc}"  title="倒谱图：音色"/> <!-- 显示 MFCC 图像 -->
                    </div>
                    <div  class="recording-tool">
                        <button onclick="playRecording(${rec.id})">播放</button>
                        <button class="delete-btn" onclick="deleteRecording(${rec.id})">删除</button>
                    </div>
                </div>
            `).join('');
        }

        // 播放录音
        window.playRecording = function (id) {
            const recording = recordings.find(rec => rec.id === id);
            if (recording) {
                const url = URL.createObjectURL(recording.blob);
                audioPlayer.src = url;
                audioPlayer.hidden = true;
                audioPlayer.play();
            }
        };

        // 删除录音
        window.deleteRecording = function (id) {
            recordings = recordings.filter(rec => rec.id !== id);
            renderRecordings();
        };

        // 开始录音
        startBtn.addEventListener('click', async () => {
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
                audioContext = new (window.AudioContext || window.webkitAudioContext)();
                mediaRecorder = new MediaRecorder(stream);
                chunks = [];

                const startTime = Date.now();

                mediaRecorder.ondataavailable = e => chunks.push(e.data);
                mediaRecorder.onstop = async () => {
                    //extractMFCC(); // 实时提取 MFCC
                    const duration = (Date.now() - startTime) / 1000;
                    const blob = new Blob(chunks, { type: 'audio/webm' });
                    addRecording(blob, duration);//添加录音到列表
                    status.textContent = "录音已保存";
                };

                initAnalyser(audioContext.createMediaStreamSource(stream));
                mediaRecorder.start();
                isRecording = true;

                startBtn.disabled = true;
                stopBtn.disabled = false;
                status.textContent = "录音中...";
                drawWaveform();
                drawSpectrum();
                
                // 实时采集特征
                const featureInterval = setInterval(() => {
                    if (isRecording) {
                        const features = extractEnhancedMFCC();
                        featureBuffer.push(features);
                    } else {
                        clearInterval(featureInterval);
                    }
                }, 100); // 每100ms采集一次

            } catch (err) {
                status.textContent = "错误:没有找到麦克风，请确认并启用https访问！ ";
            }
        });


        // 修正后的增强特征提取
        function extractEnhancedMFCC() {
            if (!analyser) return;

            const bufferLength = analyser.frequencyBinCount;
            const dataArray = new Float32Array(bufferLength);
            analyser.getFloatFrequencyData(dataArray);
            
            // 转换为线性幅值
            const spectrum = Array.from(dataArray).map(value => Math.pow(10, value / 20));
            
            // 计算当前MFCC
            const currentMFCC = calculateMFCC(spectrum, audioContext.sampleRate);
            
            // 计算差分特征
            let delta = [];
            let deltaDelta = [];
            if (previousMFCC) {
                delta = currentMFCC.map((val, i) => val - previousMFCC[i]);
                if (previousDelta) {
                    deltaDelta = delta.map((val, i) => val - previousDelta[i]);
                }
            }
            
            // 组合特征向量
            const featureVector = [...currentMFCC, ...delta, ...deltaDelta];
            
            // 更新历史数据
            previousDelta = delta;
            previousMFCC = currentMFCC;
            
            return featureVector;
        }
        // 修正停止录音时的资源释放
        stopBtn.addEventListener('click', () => {
            mediaRecorder.stop();
            isRecording = false;
            
            // 关闭媒体流
            mediaRecorder.stream.getTracks().forEach(track => track.stop());
            
            startBtn.disabled = false;
            stopBtn.disabled = true;
            status.textContent = "保存中...";
        });

        // 播放控制
        audioPlayer.addEventListener('play', async () => {
            if (!audioPlayer.src) return;

            try {
                if (audioContext) audioContext.close();
                audioContext = new (window.AudioContext || window.webkitAudioContext)();
                isPlaying = true;
            } catch (err) {
                console.error('播放分析错误:', err);
            }
        });

        audioPlayer.addEventListener('pause', () => {
            isPlaying = false;
        });

        audioPlayer.addEventListener('ended', () => {
            isPlaying = false;
            URL.revokeObjectURL(audioPlayer.src);
        });



        // 修正选择器更新逻辑
        function updateRecordingSelector() {
            const selector1 = document.getElementById('recording1');
            const selector2 = document.getElementById('recording2');

            selector1.innerHTML = '<option value="">选择第一个录音</option>';
            selector2.innerHTML = '<option value="">选择第二个录音</option>';

            recordings.forEach(rec => {
                const optionText = `录音${rec.name} (${rec.duration.toFixed(1)}秒)`;
                
                const option1 = new Option(optionText, rec.id);
                const option2 = new Option(optionText, rec.id);
                
                selector1.add(option1);
                selector2.add(option2);
            });
        }


// 欧氏距离计算
window.euclideanDistance = function(vecA, vecB) {
    return Math.sqrt(
        vecA.reduce((sum, val, i) => sum + Math.pow(val - vecB[i], 2), 0)
    );
};

// 增强版比较函数
window.compareRecordings = function() {
    const resultDiv = document.getElementById('result');
    const id1 = document.getElementById('recording1').value;
    const id2 = document.getElementById('recording2').value;

    // 验证选择
    if (!id1 || !id2) {
        resultDiv.innerHTML = '<div class="dissimilar">请选择两个录音文件</div>';
        return;
    }

    // 获取录音数据
    const rec1 = recordings.find(r => r.id == id1);
    const rec2 = recordings.find(r => r.id == id2);

    // 特征校验
    if (!rec1?.mfccFeature?.length || !rec2?.mfccFeature?.length) {
        resultDiv.innerHTML = '<div class="dissimilar">特征数据不完整</div>';
        return;
    }

    try {
        // 执行DTW比较
        const rawDistance = euclideanDistance(
            rec1.mfccFeature, 
            rec2.mfccFeature
        );
        console.log("欧氏距离计算",rawDistance);
        // 生成可视化结果
        const similarity = (1 - rawDistance/100) * 100;
		
        renderComparisonResult(similarity, rec1, rec2);
        
    } catch (error) {
        console.error('比较出错:', error);
        resultDiv.innerHTML = '<div class="dissimilar">比较过程发生错误</div>';
    }
};

// 结果可视化渲染
function renderComparisonResult(similarity, rec1, rec2) {
    const resultDiv = document.getElementById('result');
	
	if(similarity < 0){
		similarity = 0;
	}
    const similarityText = similarity.toFixed(1) + '%';
    
    let resultClass = 'dissimilar';
    if (similarity > 75) resultClass = 'similar';
    else if (similarity > 50) resultClass = 'medium';
	if(similarity>0){
		resultDiv.innerHTML = `
			<div class="${resultClass}">
				<div class="similarity-meter">
					<div class="bar" style="text-align:center; width: ${similarity}%">${similarityText}相似度</div>
				</div>
			</div>
		`;
	}
	else{
		resultDiv.innerHTML = `
			<div class="${resultClass}">
				<div class="similarity-meter">
					<span>${similarityText}相似度</span>
				</div>
			</div>
		`;	
	}

}


    </script>
</body>
<script type="text/javascript">
function showToast(msg, type) {
    var t = document.getElementById('slToast');
    t.textContent = msg;
    t.className = 'sl-toast ' + (type || 'success') + ' show';
    clearTimeout(t._t);
    t._t = setTimeout(function(){ t.className = 'sl-toast ' + (type || 'success'); }, 2400);
}

var docurl = document.URL;
var ipurl = docurl.substring(0, docurl.lastIndexOf("/"));
var id = "<%=Id %>";
function returnurl() {
    if (confirm('是否要离开此页面？') == true) {
        window.location.href = "<%=Fpage %>"
    }
}

function savechat() { 
	var preview = document.getElementById("recordhistory");
    var htmlcode ="";// preview.innerHTML;使用缩略图预览
    if (recordings.length>0) {
        html2canvas(preview).then(pic => {					
        	var urls = '../student/uploadtopic.ashx?id=' + id;
			var title = "";
			var Cover = blob(pic.toDataURL("image/jpg",0.5)); 
			var Content = htmlcode;
			var Extension = "sound";
			var formData = new FormData();
			formData.append('title', title);
			formData.append('cover', Cover);
			formData.append('content', Content);
			formData.append('ext', Extension);

        	$.ajax({
        	    url: urls,
        	    type: 'POST',
        	    cache: false,
        	    data: formData,
        	    processData: false,
        	    contentType: false
        	}).done(function (res) {
        	    showToast('✓ 保存成功！', 'success');
        	}).fail(function (res) {
        	    console.log(res)
        	}); 	
            
        });		
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
    return new Blob([intArray], { type: mimeString });
}

</script>
</html>


