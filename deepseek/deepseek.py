from flask import Flask, request, jsonify,Response, stream_with_context
from flask_cors import CORS  # 引入 CORS 支持
import requests
import re
import json
from urllib.parse import urlparse
import os
from gevent import pywsgi
import edge_tts
import random
import time
import cv2
import numpy as np
import easyocr
import base64
from translate import Translator

app = Flask(__name__)
CORS(app)

@app.route('/health')
def health():
    return "OK"

@app.route('/')
def index():
    with open("index.html", "r", encoding="utf-8") as f:
        return f.read()

DEEPSEEK_API_URL = "https://api.deepseek.com/v1/chat/completions"
DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY", "")
DEEPSEEK_MODEL = "deepseek-chat"

Qwen_API_URL = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions"
Qwen_API_KEY = os.getenv("QWEN_API_KEY", "sk-e2f0cdd2fd04446c83e698a4bea0e40f")
Qwen_MODEL = "qwen-max"

PHOTO_API_URL = "https://open.bigmodel.cn/api/paas/v4/images/generations"
PHOTO_API_KEY = os.getenv("PHOTO_API_KEY", "67121ff795f24159a4f2eaaabb89cc78.DDAMTxnDEFuiYR7f")

HostIp = os.getenv("HOST_IP", "0.0.0.0")
API_URL = DEEPSEEK_API_URL
API_KEY = DEEPSEEK_API_KEY
API_MODEL = DEEPSEEK_MODEL

@app.route('/config')
def get_config():
    return jsonify({
        "deepseek_configured": bool(DEEPSEEK_API_KEY),
        "qwen_configured": bool(Qwen_API_KEY and Qwen_API_KEY != "sk-e2f0cdd2fd04446c83e698a4bea0e40f"),
        "photo_configured": bool(PHOTO_API_KEY and PHOTO_API_KEY != "67121ff795f24159a4f2eaaabb89cc78.DDAMTxnDEFuiYR7f"),
    })

# markdown格式转换json
def markdown_to_special_json(md_text):
    lines = md_text.strip().split('\n')
    current_content = None
    cover_processed = False  # 添加封面处理标志
    
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
                
        # 处理一级标题（封面）- 只处理一次
        if line.startswith('# ') and not cover_processed:
            title = line[2:].strip()
            yield {
                "type": "cover",
                "data": {
                    "title": title,
                    "text": "副标题"  # 按照要求留空
                }
            }
            cover_processed = True
            i += 1
            continue
        
        # 处理二级标题（内容块）
        if line.startswith('## '):
            if current_content:
                yield current_content
            current_content = {
                "type": "content",
                "data": {
                    "title": line[3:].strip(),
                    "items": []
                }
            }
            i += 1
            continue
        
        # 处理列表项（使用-或*开头）
        if (line.startswith('- ') or line.startswith('* ')) and current_content:
            item_title = line[2:].strip()
            current_content["data"]["items"].append({
                "title": item_title,
                "text": "内容..."  # 按照要求固定文本
            })
            i += 1
            continue
        
        i += 1
    
    # 生成最后一个内容块
    if current_content:
        yield current_content




# 代理路由 PPT大纲生成
@app.route('/aippt', methods=['POST'])                
def aippt():
    try:
        data = request.json
        if not data or 'content' not in data:
            return jsonify({"error": "Missing 'content' in request"}), 400
        mdstr = data['content']

        def generate_stream():
            # 发送 JSON 对象和空行（分两次 yield）
            for chunk in markdown_to_special_json(mdstr):
                json_str = json.dumps(chunk, ensure_ascii=False)
                try:
                    data = json.loads(json_str)
                    # print("JSON 合法，解析结果:", data)
                except json.JSONDecodeError as e:
                    print("JSON 非法:", e)
                yield json_str + "\n"  # JSON 行
                time.sleep(2)
                yield "\n"  # 空行
                time.sleep(2)
            
            # 发送结束标记（单独一行）
            yield json.dumps({"type": "end"}, ensure_ascii=False) + "\n"
            time.sleep(2)

        return Response(
            stream_with_context(generate_stream()),
            mimetype="application/json; charset=utf-8"
        )

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# 代理路由 人工智能对话
@app.route('/aippt_outline', methods=['POST'])                
def aippt_outline():
    try:
        # 获取请求体中的 messages
        data = request.json
        data = data['content'] + '为主题的markdown格式PPT提示语，不超过6张，返回纯净文本提示语，前后不包含```标注。'
        
        message = [{'role': 'user', 'content': data}]
        # print(message)
        # 调用 DeepSeek API
        headers = {
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json"
        }
        payload = {
            "messages": message,
            "model": API_MODEL
        }
        response = requests.post(API_URL, headers=headers, json=payload)

        # 检查 API 响应是否成功
        if response.status_code != 200:
            return jsonify({"error": "Failed to call DeepSeek API"})

        # 返回 DeepSeek 的响应
        completion = response.json()
        result = completion['choices'][0]['message']['content']
        # print(result)
        
        return result

    except Exception as e:
        print(f"Error calling DeepSeek API: {e}")
        return jsonify({"error": "Failed to process the request"})
    
         
# 代理路由 人工智能对话（流式输出）
@app.route('/chat', methods=['POST'])                
def chat():
    try:
        # 获取请求体中的 messages
        data = request.json
        messages = data.get('messages', [{'role': 'system', 'content': 'You are a helpful assistant.'}])
        
        # 调用 DeepSeek API（流式）
        headers = {
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json",
            "Accept": "text/event-stream"  # 重要：告诉API我们需要流式响应
        }
        payload = {
            "messages": messages,
            "model": API_MODEL,
            "stream": True  # 重要：告诉API启用流式
        }
        
        # 发起流式请求
        api_response = requests.post(API_URL, headers=headers, json=payload, stream=True)
        
        # 检查 API 响应是否成功
        if api_response.status_code != 200:
            error_detail = api_response.text
            print(f"DeepSeek API error: {api_response.status_code} - {error_detail}")
            return jsonify({"error": f"Failed to call DeepSeek API: {api_response.status_code}", "detail": error_detail})
        
        # 定义生成器函数来处理流式响应
        def generate():
            try:
                for chunk in api_response.iter_lines():
                    # 处理每个chunk（这里需要根据DeepSeek API的实际流格式调整）
                    if chunk:
                        decoded_chunk = chunk.decode('utf-8')
                        if decoded_chunk.startswith('data:'):
                            # 提取JSON数据
                            json_data = decoded_chunk[5:].strip()
                            if json_data != '[DONE]':
                                try:
                                    data = json.loads(json_data)
                                    # 提取内容（根据DeepSeek API的实际响应结构调整）
                                    if 'choices' in data and len(data['choices']) > 0:
                                        delta = data['choices'][0].get('delta', {})
                                        content = delta.get('content', '')
                                        if content:
                                            yield f"data: {json.dumps({'content': content})}\n\n"
                                except json.JSONDecodeError:
                                    continue
            except Exception as e:
                print(f"Stream error: {e}")
            finally:
                api_response.close()
        
        # 返回流式响应
        return Response(
            stream_with_context(generate()),
            mimetype='text/event-stream',
            headers={
                'Cache-Control': 'no-cache',
                'Connection': 'keep-alive'
            }
        )

    except Exception as e:
        print(f"Error calling DeepSeek API: {e}")
        return jsonify({"error": "Failed to process the request"})


# 代理路由 文本生成图片
@app.route('/photo', methods=['POST'])
def photo():
    try:
        data = request.json
        print(data)
        # 兼容两种格式：{content: "..."} 或 {messages: {content: "..."}}
        if 'messages' in data:
            messages = data['messages']
            if isinstance(messages, dict):
                prompt = messages.get('content', '')
            elif isinstance(messages, list) and len(messages) > 0:
                prompt = messages[0].get('content', '')
            else:
                prompt = ''
        else:
            prompt = data.get('content', '')
        
        if not prompt:
            return jsonify({"error": "Missing content"}), 400
            
        print(prompt)
        # Image details
        # prompt = 'A beautiful landscape'
        width = 640
        height = 480
        seed = 42 # Each seed generates a new image variation
        model = 'flux' # Using 'flux' as default if model is not provided
        
        # 对提示词进行URL编码        
        encoded_prompt = requests.utils.quote(prompt)
        
        image_url = f"https://pollinations.ai/p/{encoded_prompt}?width={width}&height={height}&seed={seed}&model={model}&nologo=true&safe=true"
        
        response = requests.get(image_url)
        if response.status_code == 200:
            # print(image_url)
            # 高并发场景 使用 ‌微秒级时间戳‌ + 随机数，确保唯一性
            timestamp_micro = int(time.time() * 10**6)  # 微秒级
            random_suffix = random.randint(1000, 9999)
            a = f"{timestamp_micro}_{random_suffix}.jpg"
            
            path = os.getcwd() + '\\download\\'        
            file_name = os.path.basename(a)
            file_path = path+file_name
            file_url = 'download/'+file_name
            imghtml = '<img src="'+file_url+'"  class="photo"/>'
            
            with open(file_path, 'wb') as file:
                file.write(response.content)
            return jsonify({"response": file_url})
        else:
            print('请求出错:', response.text)
            return jsonify({"error": response.text})
    except Exception as e:
        print(f"Error calling pollinations API: {e}")
        return jsonify({"error": "Failed to process the request"})
    

# 代理路由 智谱AI图片生成
@app.route('/photos', methods=['POST'])
def photos():
    try:
        data = request.json
        # 兼容两种格式
        if 'messages' in data:
            messages = data['messages']
            if isinstance(messages, dict):
                prompt = messages.get('content', '')
            elif isinstance(messages, list) and len(messages) > 0:
                prompt = messages[0].get('content', '')
            else:
                prompt = ''
        else:
            prompt = data.get('content', '')
            
        if not prompt:
            return jsonify({"error": "Missing content"}), 400
            
        print(prompt)
        request_body = {
            "model": "cogview-4",
            "prompt": prompt,
            # 你可以根据需要添加其他参数，例如：
            # "size": "512x512",
            # "num_images": 1
        }

        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {PHOTO_API_KEY}'
        }
        
        response = requests.post(PHOTO_API_URL, headers=headers, data=json.dumps(request_body))

        if response.status_code == 200:
            result = response.json()
            imgurl = result['data'][0]['url']
            print('生成的图片数据:', imgurl)
            a = urlparse(imgurl)
            path = os.getcwd() + '\\download\\'
            
            file_name = os.path.basename(a.path)
            file_path = path+file_name
            file_url = 'download/'+file_name
            imghtml = '<img src="'+file_url+'"  class="photo"/>'
            
            resp = requests.get(imgurl)
            with open(file_path, 'wb') as file:
                file.write(resp.content)
            return jsonify({"response": imghtml})
        else:
            print('请求出错:', response.text)
            return jsonify({"error": response.text})
        
    except Exception as e:
        print(f"Error calling zhupuAI API: {e}")
        return jsonify({"error": "Failed to process the request"})

# 代理路由 文本转语音
@app.route('/voice', methods=['POST'])                
def voice():
    try:
        timestamp = str(int(time.time()))
        savefile = f"downmp3/{timestamp}.mp3" 
        data = request.json
        
        # 兼容两种格式
        if 'messages' in data:
            message = data['messages']
            if isinstance(message, dict):
                speaker = message.get('role', 'zh-CN-XiaoxiaoNeural')
                text = message.get('content', '')
            elif isinstance(message, list) and len(message) > 0:
                speaker = message[0].get('role', 'zh-CN-XiaoxiaoNeural')
                text = message[0].get('content', '')
            else:
                speaker = 'zh-CN-XiaoxiaoNeural'
                text = ''
        else:
            speaker = data.get('role', 'zh-CN-XiaoxiaoNeural')
            text = data.get('content', '')
            
        if not text:
            return jsonify({"error": "Missing content"}), 400
            
        print(speaker)
        print(text)
        
        # 调用 edge_tts
        communicate = edge_tts.Communicate(text=text,
                voice=speaker,
                rate='+0%',
                volume='+0%',
                pitch='+0Hz')

        communicate.save_sync(savefile)
        
        return jsonify({"response": savefile})

    except Exception as e:
        print(f"Error calling edge_tts API: {e}")
        return jsonify({"error": "Failed to process the request"})

# 代理路由 图片上传
@app.route('/upload', methods=['POST'])                
def upload():
    # 检查请求中是否包含文件
    if 'file' not in request.files:
        return jsonify({'response': '没有文件在请求中'})
    
    file = request.files['file']
    filename = file.filename
    print(filename)
    if filename == '':
        return jsonify({"response":'没有选择文件'})
        
    savepath = 'uploads'
    if not os.path.exists(savepath):
        os.makedirs(savepath)
    file.save(os.path.join(savepath,filename))
    return jsonify({"response": filename})

# 代理路由 文字识别
@app.route('/ocr', methods=['POST'])                
def ocr():
    try:
        data = request.json
        
        # 兼容两种格式
        if 'messages' in data:
            message = data['messages']
            if isinstance(message, dict):
                image_name = message.get('content', '')
            elif isinstance(message, list) and len(message) > 0:
                image_name = message[0].get('content', '')
            else:
                image_name = ''
        else:
            image_name = data.get('content', '')
            
        if not image_name:
            return jsonify({"error": "Missing content"}), 400

        # 调用 EasyOCR
        reader = easyocr.Reader(['ch_sim', 'en'], gpu=False, verbose=False)
        image_path = 'uploads/'+image_name
        
        # 使用 EasyOCR 进行文本检测
        result = reader.readtext(image_path)

        texts = []
        for detection in result:
            text = detection[1]
            texts.append(text)
                   
        return jsonify({"response": texts})

    except Exception as e:
        print(f"Error calling EasyOCR: {e}")
        return jsonify({"error": "Failed to process the request"})

# 代理路由 中英翻译
@app.route('/translator', methods=['POST'])                
def translator():
    try:
        data = request.json
        
        # 兼容两种格式
        if 'messages' in data:
            message = data['messages']
            if isinstance(message, dict):
                text = message.get('content', '')
            elif isinstance(message, list) and len(message) > 0:
                text = message[0].get('content', '')
            else:
                text = ''
        else:
            text = data.get('content', '')
            
        if not text:
            return jsonify({"error": "Missing content"}), 400
          
        print(text)
        
        translator = Translator(from_lang="zh", to_lang="en")
        translation = translator.translate(text)
        print(translation)
        
        return jsonify({"response":translation})

    except Exception as e:
        print(f"Error calling Translator API: {e}")
        return jsonify({"error": "Failed to process the request"})

# 启动服务器
if __name__ == '__main__':
    #app.run(host=HostIp, port=2000)
    server = pywsgi.WSGIServer((HostIp, 2000), app)
    print("* Running on http://"+HostIp+":2000")
    server.serve_forever()