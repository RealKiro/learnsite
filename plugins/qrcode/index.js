/* global qrcanvas, Vue */
/* eslint-disable object-curly-newline */

const size = 256;

const QrCanvas = {
  props: {
    options: Object,
  },
  render: h => h('canvas', {
    attrs: { Id:'cv', width: size, height: size },
  }),
  methods: {
    update(options) {
      const qroptions = Object.assign({}, options, {
        canvas: this.$el,
      });
      qrcanvas.qrcanvas(qroptions);
    },
  },
  watch: {
    options: 'update',
  },
  mounted() {
    this.update(this.options);
  },
};

const themes = {
  黑码: {
    colorFore: '#000000',
    colorBack: '#ffffff',
    colorOut: '#000000',
    colorIn: '#000000',
  },
  绿码: {
    colorFore: '#00AC00',
    colorBack: '#ffffff',
    colorOut: '#00AC00',
    colorIn: '#00AC00',
  },
  红码: {
    colorFore: '#D00000',
    colorBack: '#ffffff',
    colorOut: '#D00000',
    colorIn: '#D00000',
  },
  蓝码: {
    colorFore: '#0000FF',
    colorBack: '#ffffff',
    colorOut: '#0000FF',
    colorIn: '#0000FF',
  },
};

const correctLevels = ['L', 'M', 'Q', 'H'];

const data = {
  settings: Object.assign({
    qrtext: words,
    cellSize: 12,
    padding: 0,
    effect: '',
    effectValue: 100,
    logo: false,
    logoType: 'image',
    logoText: '中国',
	logoFont: '微软雅黑',
	logoBold: 'true',
    logoClearEdges: 3,
    logoMargin: 0,
    logoColor: '#ff0000',
    correctLevel: 0,
  }, themes.黑码),
  effects: [
    { title: 'None', value: '' },
    { title: 'Fusion', value: 'fusion' },
    { title: 'Round', value: 'round' },
    { title: 'Spot', value: 'spot' },
  ],
  themes: Object.keys(themes),
  options: {},
};

new Vue({
  components: {
    QrCanvas,
  },
  data,
  watch: {
    settings: {
      deep: true,
      handler: 'update',
    },
  },
  methods: {
    update() {
      const { settings } = this;
      const {
        colorFore, colorBack, colorOut, colorIn,
      } = settings;
      const options = {
        cellSize: +settings.cellSize,
        padding: +settings.padding,
        foreground: [
          // foreground color
          { style: colorFore },
          // outer squares of the positioner
          { row: 0, rows: 7, col: 0, cols: 7, style: colorOut },
          { row: -7, rows: 7, col: 0, cols: 7, style: colorOut },
          { row: 0, rows: 7, col: -7, cols: 7, style: colorOut },
          // inner squares of the positioner
          { row: 2, rows: 3, col: 2, cols: 3, style: colorIn },
          { row: -5, rows: 3, col: 2, cols: 3, style: colorIn },
          { row: 2, rows: 3, col: -5, cols: 3, style: colorIn },
        ],
        background: colorBack,
        data: settings.qrtext,
        correctLevel: correctLevels[settings.correctLevel] || 'L',
      };
      if (settings.logo) {
        if (settings.logoType === 'image') {
          options.logo = {
            image: this.$refs.logo,
          };
        } else {
          options.logo = {
            text: settings.logoText,
            options: {
              fontStyle: [
                settings.logoBold && 'bold',
                settings.logoItalic && 'italic',
              ].filter(Boolean).join(' '),
              fontFamily: settings.logoFont,
              color: settings.logoColor,
            },
          };
        }
      }
      if (settings.effect) {
        options.effect = {
          type: settings.effect,
          value: settings.effectValue / 100,
        };
        if (settings.effect === 'spot') {
          options.background = [colorBack, this.$refs.effect];
        }
      }
      this.options = options;
    },
    loadImage(e, ref) {
      const file = e.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = () => {
        this.$refs[ref].src = reader.result;
        this.options = Object.assign({}, this.options);
      };
      reader.readAsDataURL(file);
    },
    loadTheme(key) {
      Object.assign(this.settings, themes[key]);
    },
  },
  mounted() {
    this.update();
  },
}).$mount('#app');


var canvas  = document.getElementById("cv");
canvas.title="双击下载二维码图片";
canvas.addEventListener("dblclick",function(){
	downpic();	
})
	
function deqrcode(){    	
	const ctx = canvas.getContext('2d');
	ctx.canvas.willReadFrequently = true;
	var w=canvas.width,
		h=canvas.height;
    // 从 canvas 中提取像素数据
    const imageData = ctx.getImageData(0, 0, w, h);
    //console.log(canvas.width, canvas.height)
    // 将像素数据作为输入，使用 jsQR 库进行解码
	var data = imageData.data;
	var avg = 0;// 将彩色图片转换成黑白图片,三个通道的平均值，然后把这个平均值赋值给r, g, b
	 for( var i = 0; i < data.length; i += 4 ) {
		 avg = ( data[i] + data[i+1] + data[i+2] ) / 3;
		 data[i] = avg;
		 data[i+1] = avg;
		 data[i+2] = avg;
	 }
    const code = jsQR(data, w, h)
    //code 就是解码后的数据
    console.log( code.data)
	document.getElementById("detext").value=code.data;
}

function downpic(){	
	var Cover=blob(canvas.toDataURL());
	var a= document.createElement("a");
	a.href = URL.createObjectURL(Cover);
	a.download = "qrcode.png" ;// 这里填保存成的文件名
	a.click();
	URL.revokeObjectURL(a.href);
　　a.remove();	
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
