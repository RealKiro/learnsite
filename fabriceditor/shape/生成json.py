import os
import json

root="shape/"
basedir={"geometry":"几何","icon":"图标","vector":"矢量"}

jsdata=[]
for key in basedir:   
    data=[]
    if os.path.isdir(key):
        filelist=os.listdir(key)
        num=0
        value=key+str(num)
        for ret in filelist:
            label=basedir[key]+str(num)
            fname = os.path.basename(ret)         
            url=root+key+"/"+fname
            pic={'label':label,'value':value,'tempUrl':url,'src':url}
            #print(pic)
            data.append(pic)
            num=num+1
            
    
    jsp={'label':basedir[key],'value':key,'list':data}
    jsdata.append(jsp)

res={'data':jsdata}
typestr=json.dumps(res,ensure_ascii=False)

basefname="type.json"
with open(basefname,'w',encoding='utf-8') as wf:
    wf.write(typestr)


