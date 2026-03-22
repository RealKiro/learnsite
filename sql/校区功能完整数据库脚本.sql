-- =============================================
-- 校区功能完整数据库脚本
-- 功能说明：创建Campus表，添加Scampus字段，设置示例数据
-- 创建时间：2026-03-05
-- =============================================

-- ========================================
-- 第一步：创建 Campus 表（校区表）
-- ========================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Campus]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Campus](
        [Cid] [int] IDENTITY(1,1) NOT NULL,
        [Cname] [nvarchar](50) NOT NULL,
        [Caddress] [nvarchar](200) NULL,
        [Cphone] [nvarchar](20) NULL,
        [Cdesc] [nvarchar](500) NULL,
        [Cdelete] [bit] NOT NULL DEFAULT 0,
        [Ccreate] [datetime] NULL DEFAULT GETDATE(),
        CONSTRAINT [PK_Campus] PRIMARY KEY CLUSTERED ([Cid] ASC)
    )
    PRINT '✓ 已创建 Campus 表（校区表）'
END
ELSE
BEGIN
    PRINT '○ Campus 表已存在'
END
GO

-- ========================================
-- 第二步：在 Students 表添加 Scampus 字段
-- ========================================

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Students]') AND name = 'Scampus')
BEGIN
    ALTER TABLE [dbo].[Students] ADD [Scampus] int NULL DEFAULT 0
    PRINT '✓ 已在 Students 表添加 Scampus 字段（校区ID）'
END
ELSE
BEGIN
    PRINT '○ Students 表的 Scampus 字段已存在'
END
GO

-- ========================================
-- 第三步：在 Teacher 表添加 Tcampus 字段
-- ========================================

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Teacher]') AND name = 'Tcampus')
BEGIN
    ALTER TABLE [dbo].[Teacher] ADD [Tcampus] int NULL DEFAULT 0
    PRINT '✓ 已在 Teacher 表添加 Tcampus 字段（校区ID）'
END
ELSE
BEGIN
    PRINT '○ Teacher 表的 Tcampus 字段已存在'
END
GO

-- ========================================
-- 第四步：插入示例校区数据
-- ========================================

-- 检查是否已有数据
IF NOT EXISTS (SELECT * FROM [dbo].[Campus] WHERE Cid = 1)
BEGIN
    SET IDENTITY_INSERT [dbo].[Campus] ON
    
    INSERT INTO [dbo].[Campus] ([Cid], [Cname], [Caddress], [Cphone], [Cdesc], [Cdelete], [Ccreate])
    VALUES 
        (1, N'总校区', N'主校区地址', N'', N'学校总部校区', 0, GETDATE()),
        (2, N'分校区A', N'分校区A地址', N'', N'第一分校区', 0, GETDATE()),
        (3, N'分校区B', N'分校区B地址', N'', N'第二分校区', 0, GETDATE())
    
    SET IDENTITY_INSERT [dbo].[Campus] OFF
    
    PRINT '✓ 已插入示例校区数据（3个校区）'
    PRINT '  - 校区1: 总校区'
    PRINT '  - 校区2: 分校区A'
    PRINT '  - 校区3: 分校区B'
END
ELSE
BEGIN
    PRINT '○ Campus 表已有数据，跳过示例数据插入'
END
GO

-- ========================================
-- 第五步：创建索引（可选，提升查询性能）
-- ========================================

-- 为 Students.Scampus 创建索引
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Students]') AND name = N'IX_Students_Scampus')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Students_Scampus] ON [dbo].[Students]
    (
        [Scampus] ASC
    )
    PRINT '✓ 已为 Students.Scampus 创建索引'
END
ELSE
BEGIN
    PRINT '○ Students.Scampus 索引已存在'
END
GO

-- 为 Teacher.Tcampus 创建索引
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Teacher]') AND name = N'IX_Teacher_Tcampus')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Teacher_Tcampus] ON [dbo].[Teacher]
    (
        [Tcampus] ASC
    )
    PRINT '✓ 已为 Teacher.Tcampus 创建索引'
END
ELSE
BEGIN
    PRINT '○ Teacher.Tcampus 索引已存在'
END
GO

-- ========================================
-- 完成信息
-- ========================================

PRINT ''
PRINT '========================================='
PRINT '校区功能数据库脚本执行完成！'
PRINT '========================================='
PRINT ''
PRINT '已完成的操作：'
PRINT '  1. 创建 Campus 表（校区表）'
PRINT '  2. 在 Students 表添加 Scampus 字段'
PRINT '  3. 在 Teacher 表添加 Tcampus 字段'
PRINT '  4. 插入示例校区数据（如果表为空）'
PRINT '  5. 创建性能优化索引'
PRINT ''
PRINT '下一步操作：'
PRINT '  1. 访问 /manager/campus.aspx 管理校区'
PRINT '  2. 使用批量设置脚本为学生分配校区'
PRINT '  3. 在班级选择页面使用校区筛选功能'
PRINT ''
PRINT '相关文档：'
PRINT '  - 说明必读/学校校区功能快速开始.md'
PRINT '  - 说明必读/学生校区批量设置.sql'
PRINT '  - 说明必读/班级选择页面校区筛选功能说明.md'
PRINT '========================================='
GO

-- ========================================
-- 查看当前校区数据
-- ========================================

SELECT 
    Cid AS '校区ID',
    Cname AS '校区名称',
    Caddress AS '地址',
    Cphone AS '电话',
    Cdesc AS '描述',
    CASE WHEN Cdelete = 1 THEN '已删除' ELSE '正常' END AS '状态',
    Ccreate AS '创建时间'
FROM [dbo].[Campus]
WHERE Cdelete = 0 OR Cdelete IS NULL
ORDER BY Cid
GO
