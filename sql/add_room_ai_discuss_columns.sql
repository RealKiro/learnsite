-- =============================================
-- AI对话和小组讨论开关功能 - 数据库升级脚本
-- 功能说明：在Room表添加Rai（AI对话开关）和Rdiscuss（小组讨论开关）字段
-- 说明：使用IF NOT EXISTS，可安全重复执行
-- =============================================

-- 1. 添加 Rdiscuss 字段（小组讨论开关，默认开启）
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Room]') AND name = 'Rdiscuss')
BEGIN
    ALTER TABLE [dbo].[Room] ADD [Rdiscuss] bit NOT NULL DEFAULT 1
    PRINT '已添加 Rdiscuss 字段（小组讨论开关）'
END
ELSE
BEGIN
    PRINT 'Rdiscuss 字段已存在，跳过'
END
GO

-- 2. 添加 Rai 字段（AI对话开关，默认开启）
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Room]') AND name = 'Rai')
BEGIN
    ALTER TABLE [dbo].[Room] ADD [Rai] bit NOT NULL DEFAULT 1
    PRINT '已添加 Rai 字段（AI对话开关）'
END
ELSE
BEGIN
    PRINT 'Rai 字段已存在，跳过'
END
GO

-- 3. 添加 Rgame 字段（游戏开关，默认开启）
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Room]') AND name = 'Rgame')
BEGIN
    ALTER TABLE [dbo].[Room] ADD [Rgame] bit NOT NULL DEFAULT 1
    PRINT '已添加 Rgame 字段（游戏开关）'
END
ELSE
BEGIN
    PRINT 'Rgame 字段已存在，跳过'
END
GO

PRINT '数据库升级完成！'
GO
