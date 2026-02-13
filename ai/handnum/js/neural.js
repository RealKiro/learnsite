

function Neural() {

    var self = this;
    var layerArr = [];
    var axisArr = {};
    var activationArr = [];

    this.width = 600;
    this.height = 400;
    this.model = null;
    this.setModel = function(model) {
        this.model = model;
    }

    this.setSize = function(w, h) {
        this.width = w;
        this.height = h;
    }

    this.update = function(model) {
        layerArr = [];
        activationArr = [];

        for(var i = 0; i < model.layers.length; i ++) {
            var tfData = model.layers[i].getWeights();
            var weights = tfData[0].dataSync();
            var bias = tfData[1].dataSync();
    
            // console.log("w:" + weights + " - b:" + bias);
            layerArr.push({"weights":weights, "bias":bias});

            //记录激活
            activationArr.push(model.layers[i].activation.constructor);
        
        }


       
    }

    //设置训练数据
    this.setTrainData = function() {
        //layerArr = JSON.parse(this.getData());
        // console.log(layerArr);

        for(var i = 0; i < layerArr.length; i ++ ) {
            
            console.log(layerArr[i].weights);
            var w = [];

            var b = [];
            for(var key in layerArr[i].bias) {
                b.push(layerArr[i].bias[key]);
            }

            for(var key in layerArr[i].weights) {
                w.push(layerArr[i].weights[key]);
            }
        
            if(w.length != b.length) {
                var nw = [];
                for(var j = 0; j < w.length; j += b.length) {
                    var mw = [];
                    for(var k = j; k < j + b.length; k ++) {
                        mw.push(w[k]);
                    }
                    nw.push(mw);
                }
                w = nw;
            } else {
                w = [w];
            }

            self.model.layers[i].setWeights([tf.tensor(w), tf.tensor(b)]);
        }

        // model.layers[1].setWeights([tf.tensor([weights]), tf.tensor(bias)]);
    }

    this.saveData = function() {
        localStorage.setItem("2-2—trainData", JSON.stringify(layerArr));
        console.log(JSON.stringify(layerArr));
    }

    this.getData = function() {
        layerArr = JSON.parse(localStorage.getItem("2-2—trainData"));
        this.setTrainData();
    }

    this.setData = function(json) {
        layerArr = JSON.parse(json);
        this.setTrainData();
    }

    this.show = function() {
        
        var html = "";
        
        html += `<div style="display: flex; flex-direction: row; justify-content: space-around; width:` + self.width + `px; height:` + self.height + `px;background-color:#1a535c;align-items: center;">`;
        
        //输入层
        html += `<div style="width:70px;height:360px;background-color:#4ecdc4; display:flex; justify-content: space-around;align-content: space-around;flex-direction: column;align-content: space-around;border-radius:5px;align-items: center;border:0px solid #222266">`;
        //输入参数个数
        // console.log(tfModel.inputLayer);
        for(var i = 0; i < self.model.inputs[0].shape[1]; i ++) {
            html += `<div style="width:60px;min-height:60px;background-color:#c5efec;font-size:12px;border-radius:5px;text-align:center;line-height:60px">`;
            html += `输入`;
            html += `</div>`;
        }
       
        html += `</div>`;          
        
        for(var i = 0; i < layerArr.length; i ++) {

            var color = "#ff6b6b";
            if(i == layerArr.length - 1) {
                color = "#F0D07B";
            }

            //隐藏层
            html += `<div style="width:70px;height:360px;background-color:` + color + `; display:flex; justify-content: space-around;align-content: space-around;flex-direction: column;align-content: space-around;border-radius:5px;align-items: center;border:0px solid #222266">`;

            for(var j = 0; j < layerArr[i].bias.length; j ++) {
                html += `<div style="width:60px;min-height:60px;background-color:#1a535c;font-size:12px;border-radius:5px;color:#fff;align-items: center;display:flex;flex-wrap: wrap">`;
                //b
                html += `<div>`;
                html += `b:`;
                html += `<input type="text" id="b_` + i + `_` + j + `" onchange="changeTFb('b_` + i + `_` + j + `')" style="width:36px" value="` + layerArr[i].bias[j].toFixed(2) + `" />`;
                html += `</div>`;

                //w
                for(var k = j; k < layerArr[i].weights.length; k += layerArr[i].bias.length) {
                    html += `<div>`;
                    html += `w:`;
                    html += `<input type="text" id="w_` + i + `_` + k + `" onchange="changeTFw('w_` + i + `_` + k + `')" style="width:36px" value="` + layerArr[i].weights[k].toFixed(2) + `" />`;
                    html += `</div>`;
                }
                
                html += `</div>`;
            }

            
            html += `</div>`;
            
        }
        html += `</div>`;

        return html;

    }

    this.predict = function(inputArr) {

        for(var i = 0; i < layerArr.length; i ++) {
            var outputArr = this.layerPredict(i, inputArr);
            inputArr = outputArr;

            // for(var j = 0; j < outputArr.length; j ++) {
            //     var key = i + "_" + j;

            // }
        }

        return inputArr;
    }

    //拟合
    this.nihe = function(inputArr) {
        //只处理一层神经元的拟合
        if(layerArr.length == 2) {
            return this.layerPredict(0, inputArr);
        }
        return null;
    }

    //计算各个层的输入输出
    this.layerPredict = function(layerIndex, inputArr) {
        //{"weights":weights, "bias":bias}
        var weights = layerArr[layerIndex].weights;
        var bias = layerArr[layerIndex].bias;

        var reArr = [];

        //多个神经元多个结果
        for(var i = 0; i < bias.length; i ++) {
            var re = 0;
            var b = bias[i];
            re += b;

            var k = 0;
            for(var j = i; j < weights.length; j += bias.length) {
                var w = weights[j];

                re += w * inputArr[k];

                k ++;
            }

            //激活
            if(activationArr[layerIndex].className == "tanh") {

                re = tanh(re);
            }

            //存放结果
            reArr.push(re);
        }

        return reArr;
    }

    this.updateW = function(layerIndex, dataIndex, value) {

        var layer = layerArr[layerIndex];
        var weights = layer.weights;
        weights[dataIndex] = value;
        layer.weights = weights;
        layerArr[layerIndex] = layer;

    }

    this.updateB = function(layerIndex, dataIndex, value) {

        var layer = layerArr[layerIndex];
        var bias = layer.bias;
        bias[dataIndex] = value;
        layer.bias = bias;
        layerArr[layerIndex] = layer;

    }

    this.wbCallBack = null
    this.setWBCallBack = function(func) {
        this.wbCallBack = func;
    }

    this.runCallBack = function() {
        self.wbCallBack();
    }

}

function tanh(x) {
    // return x;
    var y = Math.exp(2 * x);
    // return y;
    return (y - 1) / (y + 1);
}


//##########################
//修改神经元 b
function changeTFb(id) {

    var value = parseFloat(document.getElementById(id).value);
    var i = parseInt(id.split("_")[1]); //layerIndex
    var j = parseInt(id.split("_")[2]); //dataIndex

    neural.updateB(i, j, value);
    neural.setTrainData();
    neural.show();
    try {
        updateAxis();
        showNihe();
    } catch(e) {
       
    }

    neural.runCallBack();
}

//修改神经元 w
function changeTFw(id) {

    var value = parseFloat(document.getElementById(id).value);
    var i = parseInt(id.split("_")[1]); //layerIndex
    var j = parseInt(id.split("_")[2]); //dataIndex

    neural.updateW(i, j, value);
    neural.setTrainData();
    neural.show();
    try {
        updateAxis();
        showNihe();
    } catch(e) {
       
    }

    neural.runCallBack();
}

