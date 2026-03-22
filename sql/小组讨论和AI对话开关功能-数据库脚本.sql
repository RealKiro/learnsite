-- =============================================
-- 小组讨论和AI对话开关功能 - 数据库脚本
-- 功能说明：在Room表添加两个开关字段，控制学生端的小组讨论和AI对话功能
-- 创建时间：2026-03-05
-- 说明：请在正确的数据库中执行此脚本
-- =============================================

-- 1. 检查并添加 Rdiscuss 字段（小组讨论开关，默认开启）
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Room]') AND name = 'Rdiscuss')
BEGIN
    ALTER TABLE [dbo].[Room] ADD [Rdiscuss] bit NOT NULL DEFAULT 1
    PRINT '✓ 已添加 Rdiscuss 字段（小组讨论开关）'
END
ELSE
BEGIN
    PRINT '○ Rdiscuss 字段已存在'
END
GO

-- 2. 检查并添加 Rai 字段（AI对话开关，默认开启）
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Room]') AND name = 'Rai')
BEGIN
    ALTER TABLE [dbo].[Room] ADD [Rai] bit NOT NULL DEFAULT 1
    PRINT '✓ 已添加 Rai 字段（AI对话开关）'
END
ELSE
BEGIN
    PRINT '○ Rai 字段已存在'
END
GO

-- 3. 为现有记录设置默认值（开启状态）
UPDATE [dbo].[Room] 
SET [Rdiscuss] = 1 
WHERE [Rdiscuss] IS NULL OR [Rdiscuss] = 0
GO

UPDATE [dbo].[Room] 
SET [Rai] = 1 
WHERE [Rai] IS NULL OR [Rai] = 0
GO

PRINT ''
PRINT '========================================='
PRINT '数据库脚本执行完成！'
PRINT '========================================='
PRINT '已添加字段：'
PRINT '  - Rdiscuss (bit): 小组讨论开关，默认值 1（开启）'
PRINT '  - Rai (bit): AI对话开关，默认值 1（开启）'
PRINT ''
PRINT '使用说明：'
PRINT '  1. 教师可在上课页面控制这两个开关'
PRINT '  2. 学生端会根据开关状态显示/隐藏对应功能'
PRINT '  3. 默认状态为开启，保持向后兼容'
PRINT '========================================='
GO
