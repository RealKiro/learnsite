-- ============================================
-- 学校校区功能 - 数据库初始化脚本
-- ============================================
-- 使用说明：
-- 1. 在 SQL Server Management Studio 中打开此脚本
-- 2. 选择正确的数据库
-- 3. 执行整个脚本
-- ============================================

-- 步骤1：创建 School 表（如果不存在）
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'School')
BEGIN
    PRINT '正在创建 School 表...'
    
    CREATE TABLE School (
        SchoolId INT PRIMARY KEY IDENTITY(1,1),
        SchoolName NVARCHAR(100) NOT NULL,
        SchoolCode NVARCHAR(50),
        SchoolAddress NVARCHAR(200),
        SchoolPhone NVARCHAR(50),
        SchoolNote NVARCHAR(500),
        IsActive BIT DEFAULT 1,
        CreateTime DATETIME DEFAULT GETDATE()
    )
    
    PRINT 'School 表创建成功！'
END
ELSE
BEGIN
    PRINT 'School 表已存在，跳过创建。'
END
GO

-- 步骤2：为 Students 表添加 SchoolId 字段（如果不存在）
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Students' 
    AND COLUMN_NAME = 'SchoolId'
)
BEGIN
    PRINT '正在为 Students 表添加 SchoolId 字段...'
    
    ALTER TABLE Students ADD SchoolId INT NULL
    
    PRINT 'SchoolId 字段添加成功！'
END
ELSE
BEGIN
    PRINT 'Students 表已有 SchoolId 字段，跳过添加。'
END
GO

-- 步骤3：验证表结构
PRINT ''
PRINT '============================================'
PRINT '数据库结构验证'
PRINT '============================================'

-- 检查 School 表
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'School')
BEGIN
    PRINT '✓ School 表存在'
    
    -- 显示 School 表字段
    SELECT 
        COLUMN_NAME AS 字段名,
        DATA_TYPE AS 数据类型,
        CHARACTER_MAXIMUM_LENGTH AS 最大长度,
        IS_NULLABLE AS 可为空
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'School'
    ORDER BY ORDINAL_POSITION
END
ELSE
BEGIN
    PRINT '✗ School 表不存在'
END

PRINT ''

-- 检查 Students 表的 SchoolId 字段
IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Students' 
    AND COLUMN_NAME = 'SchoolId'
)
BEGIN
    PRINT '✓ Students.SchoolId 字段存在'
END
ELSE
BEGIN
    PRINT '✗ Students.SchoolId 字段不存在'
END

PRINT ''
PRINT '============================================'
PRINT '初始化完成！'
PRINT '============================================'
PRINT ''
PRINT '下一步操作：'
PRINT '1. 访问管理后台 → 系统管理 → 学校设置'
PRINT '2. 添加学校/校区信息'
PRINT '3. 使用"学生校区批量设置.sql"为学生分配校区'
PRINT ''
GO

-- 步骤4：插入示例数据（可选，注释掉以跳过）
/*
PRINT '正在插入示例学校数据...'

-- 清空现有数据（谨慎使用！）
-- DELETE FROM School

-- 插入示例学校
INSERT INTO School (SchoolName, SchoolCode, SchoolAddress, SchoolPhone, IsActive)
VALUES 
    ('东校区', 'EAST', '东区路123号', '0551-12345678', 1),
    ('西校区', 'WEST', '西区路456号', '0551-87654321', 1),
    ('南校区', 'SOUTH', '南区路789号', '0551-11112222', 1)

PRINT '示例数据插入成功！'

-- 显示插入的数据
SELECT * FROM School
*/
