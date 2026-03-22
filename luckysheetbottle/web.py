from bottle import get, template, run,route,static_file, post, request,redirect,hook,response
from bottle.ext.websocket import GeventWebSocketServer
from bottle.ext.websocket import websocket
import json
import zlib
import threading
from urllib.parse import unquote
import pymongo
import queue

lucky_sheet_queue = queue.Queue()

conn = pymongo.MongoClient()
db = conn["luckysheet"]
mongodb = db["luckysheet"]

class WebSocketManager:
    #lock = threading.Lock()
    pool = {}
    index = 0

    def register(self,ctx):        
        name=request.query.name
        print(name)
        self.index += 1
        ip = request.environ.get('REMOTE_ADDR').split('.')[-1]            
        uid=f"{name}-{self.index}" 
		# uid=f"{name}" 
        self.pool[uid] = ctx
        print(f"{name} 已连接")
        #print(ip)
        return uid

    def delete(self,uid):
        self.pool.pop(uid, None)

    def notify(self, data, by):
        for uid, ctx in self.pool.items(): 
            if uid == by:
                continue
            #try:
            ctx.send(data)
            #except:
            #    self.pool.pop(uid, None)


wsm=WebSocketManager()

@get('/')
def index():
    return template('index')

@route('/favicon.ico')
def favicon_static():
    return static_file('favicon.ico', root='./static')

@route('/static/<filepath>')
def server_static(filepath):
    return static_file(filepath, root='./static')

@hook('after_request')
def enable_cors():
    response.headers['Access-Control-Allow-Origin'] = '*'


@get('/islive')
def islive():
    return("true")

@post('/load')
def load():
    document = mongodb.find_one({"name": "zhou"})
    data = document["data"]
    return(json.dumps(data))

@get('/update', apply=[websocket])
def update(ws):
    try:
        uid = wsm.register(ws)
        # 轮询获取消息
        while True:
            data = ws.receive()
            #print("获取消息")
            #print(data)
            
            if data == "rub":  # 心跳检测
                continue
            data_raw = data.encode('iso-8859-1')  # 转编码         
            #print("转编码")
            #print(data_raw)
            
            data_unzip =unquote(zlib.decompress(data_raw, 16).decode())
            #print("解压缩")
            #print(data_unzip)       
            json_data = json.loads(data_unzip)
            #print("将JSON字符串反序列化为Python字典")
            #print(json_data)
     
            resp_data = {
                'data': data_unzip,
                'id': uid,
                'returnMessage': 'success',
                'status': 0,
                'type': 3,
                'username': uid,
            }
            if json_data.get('t') != 'mv':
                resp_data['type'] = 2
                
                lucky_sheet_queue.put(json_data)  # luckysheet数据存储至数据库

            #print("修改消息")
            #print(resp_data)            
            resp = json.dumps(resp_data)
            
            print(f"{uid} 的消息")
            #print(resp)   
            
            wsm.notify(resp, uid)
    except:
        pass
    finally:
        print(f"{uid} 已退出")        
        wsm.delete(uid)



def update_worker():
    tablename="zhou"
    document = mongodb.find_one({"name": tablename})
    if not document:
        document = {
            "name": tablename,
            "data": [
                {
                    "name": "Sheet1",
                    "index": " ",
                    "order": 0,
                    "status": "1",
                    "column": 60,
                    "row": 84,
                    "config": {},
                    "pivotTable": None,
                    "isPivotTable": False,
                    "data": [[None for _ in range(60)] for _ in range(84)],
                    "celldata": [],
                    "color": "",
                }
            ]
        }
        mongodb.insert_one(document)
    while True:
        data = lucky_sheet_queue.get()
        typ = data["t"]
        index = data["i"]
        value = data["v"]

        if typ in ("v", "fu", "fm"):  # 单元格更新
            row = data["r"]
            col = data["c"]
            mongodb.update_one(
                {
                    "name": tablename,
                    "data": {
                        "$elemMatch": {
                            "index": index,
                        },
                    },
                },
                {
                    "$set": {
                        f"data.$.data.{row}.{col}": value,
                    },
                },
                upsert=True,
            )
        elif typ == "rv":  # 范围单元格数据更新
            row_0, row_1 = data["range"]["row"]
            col_0, col_1 = data["range"]["column"]
            for i in range(row_0, row_1 + 1):
                for j in range(col_0, col_1 + 1):
                    mongodb.update_one(
                        {
                            "name": tablename,
                            "data": {
                                "$elemMatch": {
                                    "index": index,
                                },
                            },
                        },
                        {
                            "$set": {
                                f"data.$.data.{i}.{j}": value[i - row_0][j - col_0],
                            },
                        },
                        upsert=True,
                    )
        elif typ in ("rv_end"):  # 忽略
            pass
        elif typ == "all":  # 通用更新
            key = data["k"]
            mongodb.update_one(
                {
                    "name": tablename,
                    "data": {
                        "$elemMatch": {
                            "index": index,
                        },
                    },
                },
                {
                    "$set": {
                        f"data.$.{key}": value,
                    },
                },
                upsert=True,
            )
        elif typ == "cg":  # 配置更新
            key = data["k"]
            mongodb.update_one(
                {
                    "name": tablename,
                    "data": {
                        "$elemMatch": {
                            "index": index,
                        },
                    },
                },
                {
                    "$set": {
                        f"data.$.config.{key}": value,
                    },
                },
                upsert=True,
            )
        elif typ == "sha":  # 新建页
            value["data"] = [[None for _ in range(value["column"])] for _ in range(value["row"])]
            mongodb.update_one(
                {
                    "name": tablename,
                },
                {
                    "$push": {
                        "data": value,
                    },
                },
                upsert=True,
            )
        else:
            pass
            #loggus.update(typ=typ, data=data).warning(f"暂不支持操作类型")


def start_update_worker():
    threading.Thread(
        target=update_worker,
        daemon=True,
    ).start()


start_update_worker()
run(host='3.37.38.158', port=8180, server=GeventWebSocketServer)