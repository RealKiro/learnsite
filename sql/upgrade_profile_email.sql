-- =============================================
-- LearnSite 升级脚本：个人中心 & 邮箱找回密码
-- 请在 SQL Server Management Studio 中执行
-- =============================================

-- 1. Teacher 表新增 邮箱 字段
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Teacher') AND name = 'Hemail')
BEGIN
    ALTER TABLE [dbo].[Teacher] ADD [Hemail] [nvarchar](100) NULL;
END
GO

-- 2. Teacher 表新增 头像路径 字段
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Teacher') AND name = 'Havatar')
BEGIN
    ALTER TABLE [dbo].[Teacher] ADD [Havatar] [nvarchar](200) NULL;
END
GO

-- 3. 新建 邮箱验证码 表
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.EmailVerifyCode') AND type = 'U')
BEGIN
    CREATE TABLE [dbo].[EmailVerifyCode](
        [Id] [int] IDENTITY(1,1) NOT NULL,
        [Email] [nvarchar](100) NOT NULL,
        [Code] [nvarchar](10) NOT NULL,
        [Hname] [nvarchar](50) NULL,
        [CreatedAt] [datetime] NOT NULL DEFAULT(GETDATE()),
        [Used] [bit] NOT NULL DEFAULT(0),
    PRIMARY KEY CLUSTERED ([Id] ASC)
    ) ON [PRIMARY];
END
GO
