-- ============================================
-- 学生校区批量设置 SQL 脚本
-- ============================================
-- 使用说明：
-- 1. 先执行"学校校区数据库初始化.sql"创建表和字段
-- 2. 在"学校设置"页面添加学校/校区
-- 3. 记录学校的 SchoolId（在学校列表中可以看到）
-- 4. 根据需要修改下面的 SQL 语句
-- 5. 在 SQL Server Management Studio 中执行
-- ============================================

-- 前置检查：验证数据库结构
PRINT '============================================'
PRINT '前置检查'
PRINT '============================================'

-- 检查 School 表
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'School')
BEGIN
    PRINT '✗ 错误：School 表不存在！'
    PRINT '   请先执行"学校校区数据库初始化.sql"'
    RAISERROR('School 表不存在', 16, 1)
    RETURN
END
ELSE
BEGIN
    PRINT '✓ School 表存在'
END

-- 检查 Students.SchoolId 字段
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Students' 
    AND COLUMN_NAME = 'SchoolId'
)
BEGIN
    PRINT '✗ 错误：Students 表没有 SchoolId 字段！'
    PRINT '   请先执行"学校校区数据库初始化.sql"'
    RAISERROR('Students.SchoolId 字段不存在', 16, 1)
    RETURN
END
ELSE
BEGIN
    PRINT '✓ Students.SchoolId 字段存在'
END

PRINT ''
PRINT '前置检查通过，可以继续执行批量设置。'
PRINT '============================================'
PRINT ''
GO

-- 查看所有学校
SELECT SchoolId, SchoolName, SchoolCode, IsActive 
FROM School 
ORDER BY SchoolId;

-- 查看学生校区分布情况
SELECT 
    ISNULL(s.SchoolName, '未分配') AS 校区,
    COUNT(*) AS 学生数
FROM Students st
LEFT JOIN School s ON st.SchoolId = s.SchoolId
GROUP BY s.SchoolName
ORDER BY 学生数 DESC;

-- ============================================
-- 批量设置示例
-- ============================================

-- 示例1：将所有一年级学生分配到校区1
-- UPDATE Students SET SchoolId = 1 WHERE Sgrade = 1;

-- 示例2：将特定班级分配到校区2
-- UPDATE Students SET SchoolId = 2 WHERE Sgrade = 2 AND Sclass = 1;

-- 示例3：将特定入学年度的学生分配到校区3
-- UPDATE Students SET SchoolId = 3 WHERE Syear = 2024;

-- 示例4：按年级范围分配
-- UPDATE Students SET SchoolId = 1 WHERE Sgrade >= 1 AND Sgrade <= 3;  -- 1-3年级到校区1
-- UPDATE Students SET SchoolId = 2 WHERE Sgrade >= 4 AND Sgrade <= 6;  -- 4-6年级到校区2

-- 示例5：按学号范围分配
-- UPDATE Students SET SchoolId = 1 WHERE Snum >= 2024001 AND Snum <= 2024100;

-- 示例6：清空所有学生的校区设置
-- UPDATE Students SET SchoolId = NULL;

-- 示例7：将未分配校区的学生分配到默认校区
-- UPDATE Students SET SchoolId = 1 WHERE SchoolId IS NULL;

-- ============================================
-- 验证查询
-- ============================================

-- 查看各年级的校区分布
SELECT 
    Sgrade AS 年级,
    ISNULL(s.SchoolName, '未分配') AS 校区,
    COUNT(*) AS 学生数
FROM Students st
LEFT JOIN School s ON st.SchoolId = s.SchoolId
GROUP BY Sgrade, s.SchoolName
ORDER BY Sgrade, s.SchoolName;

-- 查看各班级的校区分布
SELECT 
    Sgrade AS 年级,
    Sclass AS 班级,
    ISNULL(s.SchoolName, '未分配') AS 校区,
    COUNT(*) AS 学生数
FROM Students st
LEFT JOIN School s ON st.SchoolId = s.SchoolId
GROUP BY Sgrade, Sclass, s.SchoolName
ORDER BY Sgrade, Sclass;

-- 查看未分配校区的学生
SELECT 
    Snum AS 学号,
    Sname AS 姓名,
    Sgrade AS 年级,
    Sclass AS 班级
FROM Students
WHERE SchoolId IS NULL
ORDER BY Sgrade, Sclass, Snum;
