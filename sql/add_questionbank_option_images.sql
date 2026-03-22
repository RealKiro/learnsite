-- 为题库题目表添加选项图片字段
-- 用于存储选择题各选项的图片路径
-- 执行日期：2026-03-02
-- 说明：请在目标数据库中执行此脚本

IF OBJECT_ID('dbo.QuestionBankItem', 'U') IS NULL
BEGIN
    PRINT '未找到表 dbo.QuestionBankItem，跳过题库选项图片字段升级。'
    RETURN
END
GO

-- 检查并添加选项A图片字段
IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('QuestionBankItem') AND name='Qoption_a_img')
BEGIN
    ALTER TABLE [dbo].[QuestionBankItem]
    ADD [Qoption_a_img] NVARCHAR(500) NULL
    PRINT '已添加字段: Qoption_a_img'
END
ELSE
BEGIN
    PRINT '字段已存在: Qoption_a_img'
END
GO

-- 检查并添加选项B图片字段
IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('QuestionBankItem') AND name='Qoption_b_img')
BEGIN
    ALTER TABLE [dbo].[QuestionBankItem]
    ADD [Qoption_b_img] NVARCHAR(500) NULL
    PRINT '已添加字段: Qoption_b_img'
END
ELSE
BEGIN
    PRINT '字段已存在: Qoption_b_img'
END
GO

-- 检查并添加选项C图片字段
IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('QuestionBankItem') AND name='Qoption_c_img')
BEGIN
    ALTER TABLE [dbo].[QuestionBankItem]
    ADD [Qoption_c_img] NVARCHAR(500) NULL
    PRINT '已添加字段: Qoption_c_img'
END
ELSE
BEGIN
    PRINT '字段已存在: Qoption_c_img'
END
GO

-- 检查并添加选项D图片字段
IF NOT EXISTS (SELECT 1 FROM syscolumns WHERE id=OBJECT_ID('QuestionBankItem') AND name='Qoption_d_img')
BEGIN
    ALTER TABLE [dbo].[QuestionBankItem]
    ADD [Qoption_d_img] NVARCHAR(500) NULL
    PRINT '已添加字段: Qoption_d_img'
END
ELSE
BEGIN
    PRINT '字段已存在: Qoption_d_img'
END
GO

-- 查看表结构
SELECT 
    COLUMN_NAME AS '字段名',
    DATA_TYPE AS '数据类型',
    CHARACTER_MAXIMUM_LENGTH AS '最大长度',
    IS_NULLABLE AS '允许空值'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'QuestionBankItem'
    AND COLUMN_NAME LIKE 'Qoption%'
ORDER BY ORDINAL_POSITION
GO

PRINT '选项图片字段添加完成！'
PRINT '字段说明：'
PRINT '  Qoption_a_img - 选项A的图片路径'
PRINT '  Qoption_b_img - 选项B的图片路径'
PRINT '  Qoption_c_img - 选项C的图片路径'
PRINT '  Qoption_d_img - 选项D的图片路径'
PRINT '存储格式：upload/questionbank/[题库ID]/options/[文件名]'
GO
