# luckysheet 在线协同编辑

一、安装依赖环境：

`安装python-3.10.7-amd64.exe`

`pip install bottle -i https://pypi.tuna.tsinghua.edu.cn/simple/`

`pip install bottle-websocket -i https://pypi.tuna.tsinghua.edu.cn/simple/`

`pip install pymongo -i https://pypi.tuna.tsinghua.edu.cn/simple/`

`安装mongodb-windows-x86_64-7.0.1-signed.msi`

打开MongoDBCompass连接localhost，创建数据集名称为luckysheet

修改web.py最后一行IP地址为你的服务器网站IP
（run(host='192.168.1.3', port=8180, server=GeventWebSocketServer)）

二、启动后端服务：`python web.py`

三、浏览器访问地址：[http://localhost:8180](http://localhost:8180)

四、打开多个浏览器端口，即可完成在线编辑

