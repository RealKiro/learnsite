-- 教师个人中心功能升级脚本
-- 添加教师邮箱字段

-- 检查并添加 Hemail 字段到 Teacher 表
IF NOT EXISTS (SELECT * FROM syscolumns WHERE id=OBJECT_ID('Teacher') AND name='Hemail')
BEGIN
    ALTER TABLE Teacher ADD Hemail NVARCHAR(100) NULL
    PRINT '已添加 Teacher.Hemail 字段'
END
ELSE
BEGIN
    PRINT 'Teacher.Hemail 字段已存在'
END
GO

-- 创建 images/avatars 目录的说明
-- 请手动创建以下目录：
-- /images/avatars/
-- 用于存储教师头像文件
-- 文件命名格式：{Hid}.{ext}  例如：1.jpg, 2.png

PRINT '教师个人中心功能升级完成！'
PRINT '请确保已创建 /images/avatars/ 目录用于存储头像'
GO
