-- 检查 Teacher 表结构
-- 用途：验证 Teacher 表的字段定义，特别是检查 Hemail 和 Hsalt 字段是否存在
-- 执行方式：在 SQL Server Management Studio 中执行，或通过 dbupgrade.aspx 执行

-- 查询 Teacher 表的所有字段信息
SELECT 
    COLUMN_NAME AS '字段名',
    DATA_TYPE AS '数据类型',
    CHARACTER_MAXIMUM_LENGTH AS '最大长度',
    IS_NULLABLE AS '允许为空',
    COLUMN_DEFAULT AS '默认值',
    ORDINAL_POSITION AS '位置'
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Teacher'
ORDER BY ORDINAL_POSITION;
GO

-- 检查关键字段是否存在
PRINT '========================================'
PRINT 'Teacher 表结构检查结果：'
PRINT '========================================'

-- 检查 Hemail 字段
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Teacher' AND COLUMN_NAME = 'Hemail')
BEGIN
    PRINT '✓ Hemail 字段存在'
END
ELSE
BEGIN
    PRINT '✗ Hemail 字段不存在 - 需要执行 upgrade_teacher_profile.sql'
END

-- 检查 Hsalt 字段
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Teacher' AND COLUMN_NAME = 'Hsalt')
BEGIN
    PRINT '✓ Hsalt 字段存在'
END
ELSE
BEGIN
    PRINT '✗ Hsalt 字段不存在 - 需要执行 upgrade_password_encryption.sql'
END

-- 检查基本字段
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Teacher' AND COLUMN_NAME = 'Hid')
BEGIN
    PRINT '✓ Hid 字段存在'
END
ELSE
BEGIN
    PRINT '✗ Hid 字段不存在 - 表结构异常！'
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Teacher' AND COLUMN_NAME = 'Hname')
BEGIN
    PRINT '✓ Hname 字段存在'
END
ELSE
BEGIN
    PRINT '✗ Hname 字段不存在 - 表结构异常！'
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Teacher' AND COLUMN_NAME = 'Hnum')
BEGIN
    PRINT '✓ Hnum 字段存在'
END
ELSE
BEGIN
    PRINT '✗ Hnum 字段不存在 - 表结构异常！'
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Teacher' AND COLUMN_NAME = 'Hpwd')
BEGIN
    PRINT '✓ Hpwd 字段存在'
END
ELSE
BEGIN
    PRINT '✗ Hpwd 字段不存在 - 表结构异常！'
END

PRINT '========================================'
GO

