import os
import json

basedir=["geometry","icon","vector"]
for base in basedir:
    data=[]
    if os.path.isdir(base):
        filelist=os.listdir(base)
        num=1
        for ret in filelist:
            root, extension = os.path.splitext(ret)
            path = base+"/"
            newfname=base[0]+ str(num)+extension
            os.rename(os.path.join(path,ret),os.path.join(path,newfname))

            num = num + 1