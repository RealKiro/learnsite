
# 一。LearnSite介绍
## 关于 LearnSite 信息技术学习平台

[LearnSite](https://www.openlearnsite.com) 是一个专为中小学信息技术课堂设计的**开源教学辅助平台**。它通过整合新课教学、作业提交、作品互评、课堂测验及资源管理等功能，将教师从繁重的批改与统计中解放出来，让教学更聚焦于课堂本身。

平台支持**高度定制**：教师可按需开关功能模块、调整界面，甚至绑定学生IP实现精细化管理。同时，活跃的社区持续推动其进化——2026年初的更新已加入**网页课件活动、物联网/人工智能体验（如人脸识别、AI绘画）及在线协作工具**，紧跟技术前沿。

## 信息技术教学平台功能结构与特色
- 平台结构： 
    - 学生平台：网站首页、我的课程、我的作品、常识测验、打字练习、资源下载。 
    - 教师平台：上课、备课、作品、签到、学生、测验、打字、资源、信息、状态。 
    - 系统后台：系统设置、班级设置、教师管理、新生导入、空间生成、学年升班、系统退出。
    

# 二。其它
- LearnSite学习平台讨论QQ群： 5847120
- [OpenLearnSite](https://www.openlearnsite.com/)
- [原作者：温州水乡 Github](https://github.com/WaterCountry/Learnsite)
* [Gitee：LearnSite主仓库源码](https://gitee.com/jnschool/learnsite-wz)
* [Gitee：LearnSite成都版分支源码](https://gitee.com/jnschool/game/tree/master/LearnSite_ChengDu)
* [Github：learnsite-docker](https://github.com/RealKiro/learnsite-docker)
* [Gitee：learnsite-docker(同步Github镜像)](https://gitee.com/realiy/learnsite-docker)
* [Docker仓库：learnsite-web](https://hub.docker.com/r/orzg/learnsite-web)
* [Docker仓库：mssql-learnsite](https://hub.docker.com/r/orzg/mssql-learnsite)
* [Github：LearnSite 编译版](https://github.com/RealKiro/learnsite)
  * 提示：主仓库源码需编译，故从官网下载编译版后重新上传作为临时仓库以供Docker克隆使用
* [Gitee：LearnSite 编译版(同步Github镜像)](https://gitee.com/realiy/learnsite)

- [x] LearnSite信息技术学习平台当前最新版本：
![Gitee 最新发行版](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fgitee.com%2Fapi%2Fv5%2Frepos%2Fjnschool%2Flearnsite-wz%2Ftags%3F%26per_page%3D1%26direction%3Ddesc%26sort%3Dupdated&query=%24%5B0%5D.name&logo=gitee&label=%E6%9C%80%E6%96%B0%E7%89%88%E6%9C%AC&color=c71d23)
- [x] learnsite-web Docker仓库最新更新时间：
![Docker latest 更新](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fhub.docker.com%2Fv2%2Frepositories%2Forzg%2Flearnsite-web%2Ftags%2Flatest&query=%24.last_updated&logo=docker&label=latest%20更新&color=2496ED)

- TODO：
  - [ ] learnsite3.0 + postgresql 敬请期待

# 三。项目结构
```
learnsite
  -- ai 人工智能初步
        -- ai.html 访问入口
  -- App_Themes 主题背景
  -- backupdb 数据库备份目录
  -- bin 依赖文件
  -- blockly 图像化小游戏
        -- index.html 访问入口
  -- code 
        -- index.html Python开发与集成环境
        -- mqtt.html 物联网实验室
        -- htmleditor.html 在线网页设计
        -- blockpy.html Python Blokly积木编程
        -- block.html Python拼图编程

  -- deepseek 人工智能会话助手
        -- deepseek.html AI会话
        -- aidraw.html AI绘画
        -- ocr.html OCR文字识别
        -- soundlab.html 语音识别
        -- speek.html 语音合成
        -- tic-tac-toe.html 井字棋游戏
  -- fabriceditor 在线图片设计
  -- faceai 人脸识别
        -- index.html 人脸识别探秘
        -- meme.html 魔法表情包
        -- video.html 视频捕捉人脸
        -- webcam.html 扫脸应用
  -- images 缓存图库
  -- js 前端运行框架？
  -- kindeditor 学案设计编辑器
  -- LearnSiteServer 运行于Windows系统的主程序？
        -- LearnSiteServer.exe
  -- lessons 课堂活动相关设置
  -- luckysheetbottle 在线协作表格
  -- machine 机器学习
  -- manager 管理员设置界面
  -- markdown MarkDown写作
        -- index.html 访问入口
  -- mxgraph 流程图绘制工具
  -- Piano 自由钢琴
        -- index.html 访问入口
  -- pixelartmaker 像素画
        -- index.html 访问入口
  -- plugins 插件库？
  -- plupload 文件上传
  -- profile 学生个人界面
  -- python Python绘画编程
  -- quiz 试题测验
  -- scratch Scratch积木编程
        -- index.html 访问入口
  -- seat 座位相关设置
  -- sokoban 推箱子小游戏
  -- spec ？
  -- sql 初始数据库
        -- learnsite.sql
  -- student 学生相关设置
  -- survey 问卷调查
  -- teacher 教师相关设置
  -- weboffice 在线文档编辑器
  -- wuziqi AI五子棋
        -- index.html 访问入口
  -- ztype 太空打字游戏
        -- index.html 访问入口
  -- en.aspx
  -- en.xls
  -- error.aspx
  -- favicon.ico
  -- filenotfound.htm
  -- index.aspx
  -- indexno.html
  -- noaccess.htm
  -- sound.html
  -- test.aspx
  -- test.htm
  -- upgrade.aspx
  -- web.config 用户配置文件
  -- website.xml
```