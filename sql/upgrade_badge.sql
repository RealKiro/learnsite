-- =============================================
-- 学生荣誉徽章系统 - 数据库升级脚本
-- 使用前请先备份数据库
-- =============================================

-- 1. 徽章定义表
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Badge' AND xtype='U')
BEGIN
CREATE TABLE [dbo].[Badge](
	[Bid] [int] IDENTITY(1,1) NOT NULL,
	[Bname] [nvarchar](100) NULL,
	[Bicon] [nvarchar](500) NULL,
	[Bdesc] [nvarchar](500) NULL,
	[Bcategory] [nvarchar](50) NULL,
	[Bpoints] [int] NULL,
	[Bhid] [int] NULL,
	[Bdate] [datetime] NULL,
	[Bsort] [int] NULL,
	[Bactive] [bit] NULL,
PRIMARY KEY CLUSTERED ([Bid] ASC)
) ON [PRIMARY]

ALTER TABLE [dbo].[Badge] ADD DEFAULT ((0)) FOR [Bpoints]
ALTER TABLE [dbo].[Badge] ADD DEFAULT ((0)) FOR [Bsort]
ALTER TABLE [dbo].[Badge] ADD DEFAULT ((1)) FOR [Bactive]
END
GO

-- 2. 徽章颁发记录表
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BadgeAward' AND xtype='U')
BEGIN
CREATE TABLE [dbo].[BadgeAward](
	[Aid] [int] IDENTITY(1,1) NOT NULL,
	[Abid] [int] NULL,
	[Asid] [int] NULL,
	[Ahid] [int] NULL,
	[Areason] [nvarchar](200) NULL,
	[Adate] [datetime] NULL,
	[Agrade] [int] NULL,
	[Aclass] [int] NULL,
PRIMARY KEY CLUSTERED ([Aid] ASC)
) ON [PRIMARY]

ALTER TABLE [dbo].[BadgeAward] ADD DEFAULT ((0)) FOR [Abid]
ALTER TABLE [dbo].[BadgeAward] ADD DEFAULT ((0)) FOR [Asid]
ALTER TABLE [dbo].[BadgeAward] ADD DEFAULT ((0)) FOR [Ahid]
ALTER TABLE [dbo].[BadgeAward] ADD DEFAULT ((0)) FOR [Agrade]
ALTER TABLE [dbo].[BadgeAward] ADD DEFAULT ((0)) FOR [Aclass]
END
GO

-- 3. 徽章商城兑换项目表
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BadgeShopItem' AND xtype='U')
BEGIN
CREATE TABLE [dbo].[BadgeShopItem](
	[Sid] [int] IDENTITY(1,1) NOT NULL,
	[Sname] [nvarchar](100) NULL,
	[Sdesc] [nvarchar](500) NULL,
	[Sicon] [nvarchar](500) NULL,
	[Scost] [int] NULL,
	[Sstock] [int] NULL,
	[Shid] [int] NULL,
	[Sdate] [datetime] NULL,
	[Sactive] [bit] NULL,
PRIMARY KEY CLUSTERED ([Sid] ASC)
) ON [PRIMARY]

ALTER TABLE [dbo].[BadgeShopItem] ADD DEFAULT ((0)) FOR [Scost]
ALTER TABLE [dbo].[BadgeShopItem] ADD DEFAULT ((-1)) FOR [Sstock]
ALTER TABLE [dbo].[BadgeShopItem] ADD DEFAULT ((1)) FOR [Sactive]
END
GO

-- 4. 兑换申请记录表
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BadgeExchange' AND xtype='U')
BEGIN
CREATE TABLE [dbo].[BadgeExchange](
	[Eid] [int] IDENTITY(1,1) NOT NULL,
	[Esid] [int] NULL,
	[Eitemid] [int] NULL,
	[Epoints] [int] NULL,
	[Estatus] [int] NULL,
	[Edate] [datetime] NULL,
	[Ereviewdate] [datetime] NULL,
	[Ereviewhid] [int] NULL,
	[Enote] [nvarchar](200) NULL,
	[Egrade] [int] NULL,
	[Eclass] [int] NULL,
PRIMARY KEY CLUSTERED ([Eid] ASC)
) ON [PRIMARY]

ALTER TABLE [dbo].[BadgeExchange] ADD DEFAULT ((0)) FOR [Esid]
ALTER TABLE [dbo].[BadgeExchange] ADD DEFAULT ((0)) FOR [Eitemid]
ALTER TABLE [dbo].[BadgeExchange] ADD DEFAULT ((0)) FOR [Epoints]
ALTER TABLE [dbo].[BadgeExchange] ADD DEFAULT ((0)) FOR [Estatus]
ALTER TABLE [dbo].[BadgeExchange] ADD DEFAULT ((0)) FOR [Ereviewhid]
ALTER TABLE [dbo].[BadgeExchange] ADD DEFAULT ((0)) FOR [Egrade]
ALTER TABLE [dbo].[BadgeExchange] ADD DEFAULT ((0)) FOR [Eclass]
END
GO

-- 5. 徽章类别表
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BadgeCategory' AND xtype='U')
BEGIN
CREATE TABLE [dbo].[BadgeCategory](
	[Cid] [int] IDENTITY(1,1) NOT NULL,
	[Cname] [nvarchar](50) NULL,
	[Csort] [int] NULL,
	[Cdate] [datetime] NULL,
PRIMARY KEY CLUSTERED ([Cid] ASC)
) ON [PRIMARY]

ALTER TABLE [dbo].[BadgeCategory] ADD DEFAULT ((0)) FOR [Csort]

-- 插入默认类别
INSERT INTO [dbo].[BadgeCategory](Cname,Csort,Cdate) VALUES(N'学业',1,GETDATE())
INSERT INTO [dbo].[BadgeCategory](Cname,Csort,Cdate) VALUES(N'品德',2,GETDATE())
INSERT INTO [dbo].[BadgeCategory](Cname,Csort,Cdate) VALUES(N'特长',3,GETDATE())
INSERT INTO [dbo].[BadgeCategory](Cname,Csort,Cdate) VALUES(N'创新',4,GETDATE())
INSERT INTO [dbo].[BadgeCategory](Cname,Csort,Cdate) VALUES(N'合作',5,GETDATE())
INSERT INTO [dbo].[BadgeCategory](Cname,Csort,Cdate) VALUES(N'其他',6,GETDATE())
END
GO
