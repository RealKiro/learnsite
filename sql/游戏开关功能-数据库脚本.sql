-- 游戏开关功能 - 数据库脚本
-- 在 Room 表中添加游戏开关字段

-- 检查字段是否已存在
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Room]') AND name = 'Rgame')
BEGIN
    -- 添加游戏开关字段，默认值为 1（开启）
    ALTER TABLE [dbo].[Room]
    ADD [Rgame] bit NULL DEFAULT 1;
    
    PRINT '成功添加 Rgame 字段到 Room 表';
END
ELSE
BEGIN
    PRINT 'Rgame 字段已存在';
END
GO

-- 更新现有记录，将 NULL 值设置为 1（开启）
UPDATE [dbo].[Room]
SET [Rgame] = 1
WHERE [Rgame] IS NULL;
GO

PRINT '游戏开关功能数据库脚本执行完成';
GO
