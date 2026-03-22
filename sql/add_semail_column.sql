-- 为Students表添加Semail字段（学生邮箱）
-- 执行日期: 2026-02-28
-- 说明: 用于学生邮箱绑定和密码找回功能
-- 请在目标数据库中执行此脚本

-- 检查字段是否已存在，如果不存在则添加
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Students]') AND name = 'Semail')
BEGIN
    ALTER TABLE [dbo].[Students]
    ADD [Semail] [nvarchar](100) NULL
    
    PRINT '成功添加Semail字段到Students表'
END
ELSE
BEGIN
    PRINT 'Semail字段已存在，无需添加'
END
GO

-- 为Semail字段添加说明
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Students]') AND name = 'Semail')
BEGIN
    -- 检查是否已存在说明
    IF NOT EXISTS (
        SELECT * FROM sys.extended_properties 
        WHERE major_id = OBJECT_ID(N'[dbo].[Students]') 
        AND minor_id = (SELECT column_id FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Students]') AND name = 'Semail')
        AND name = 'MS_Description'
    )
    BEGIN
        EXEC sys.sp_addextendedproperty 
            @name=N'MS_Description', 
            @value=N'学生邮箱地址，用于密码找回和通知' , 
            @level0type=N'SCHEMA',
            @level0name=N'dbo', 
            @level1type=N'TABLE',
            @level1name=N'Students', 
            @level2type=N'COLUMN',
            @level2name=N'Semail'
        
        PRINT '成功添加Semail字段说明'
    END
    ELSE
    BEGIN
        PRINT 'Semail字段说明已存在，无需添加'
    END
END
GO

-- 查询验证
SELECT TOP 5 Sid, Snum, Sname, Semail FROM Students
GO

PRINT '脚本执行完成！'
PRINT '提示：学生可以在"个人设置"页面绑定邮箱'
GO
