-- =============================================
-- 教师表添加学校字段
-- 功能：为 Teacher 表添加 SchoolId 字段，支持教师关联到校区
-- 版本：v3.1.0
-- 日期：2026年3月
-- =============================================

-- 检查并添加 SchoolId 字段
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Teacher' AND COLUMN_NAME = 'SchoolId'
)
BEGIN
    ALTER TABLE Teacher ADD SchoolId INT NULL;
    PRINT '✓ 已添加 Teacher.SchoolId 字段';
END
ELSE
BEGIN
    PRINT '○ Teacher.SchoolId 字段已存在，跳过';
END
GO

-- 验证字段是否添加成功
SELECT 
    COLUMN_NAME AS '字段名',
    DATA_TYPE AS '数据类型',
    IS_NULLABLE AS '允许空值',
    COLUMN_DEFAULT AS '默认值'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Teacher' AND COLUMN_NAME = 'SchoolId';

PRINT '';
PRINT '========================================';
PRINT '教师表学校字段添加完成！';
PRINT '========================================';
PRINT '';
PRINT '后续操作：';
PRINT '1. 在教师编辑页面（teacheredit.aspx）添加学校选择功能';
PRINT '2. 在教师添加页面（teacheradd.aspx）添加学校选择功能';
PRINT '3. 可以批量设置教师的学校归属';
PRINT '';
