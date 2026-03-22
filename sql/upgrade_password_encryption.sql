-- 密码加密升级脚本
-- 为Teacher和Students表添加盐值字段，支持密码加密存储

-- ========================================
-- 1. 添加盐值字段
-- ========================================

-- 教师表添加盐值字段
IF NOT EXISTS (SELECT * FROM syscolumns WHERE id=OBJECT_ID('Teacher') AND name='Hsalt')
BEGIN
    ALTER TABLE Teacher ADD Hsalt NVARCHAR(50) NULL
    PRINT '✓ 已添加 Teacher.Hsalt 字段'
END
ELSE
BEGIN
    PRINT '✓ Teacher.Hsalt 字段已存在'
END
GO

-- 学生表添加盐值字段
IF NOT EXISTS (SELECT * FROM syscolumns WHERE id=OBJECT_ID('Students') AND name='Ssalt')
BEGIN
    ALTER TABLE Students ADD Ssalt NVARCHAR(50) NULL
    PRINT '✓ 已添加 Students.Ssalt 字段'
END
ELSE
BEGIN
    PRINT '✓ Students.Ssalt 字段已存在'
END
GO

-- ========================================
-- 2. 说明
-- ========================================

PRINT ''
PRINT '========================================='
PRINT '密码加密升级完成！'
PRINT '========================================='
PRINT ''
PRINT '下一步操作：'
PRINT '1. 访问管理后台的"密码迁移工具"页面'
PRINT '2. 点击"迁移教师密码"按钮'
PRINT '3. 点击"迁移学生密码"按钮'
PRINT '4. 所有明文密码将自动加密存储'
PRINT ''
PRINT '注意事项：'
PRINT '- 迁移过程不会影响用户登录'
PRINT '- 迁移后密码将使用MD5+Salt加密'
PRINT '- 系统会自动兼容旧密码和新密码'
PRINT '- 建议在非高峰期进行迁移'
PRINT ''
GO
