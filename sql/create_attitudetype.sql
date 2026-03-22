-- 评分类型表
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='AttitudeType' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[AttitudeType](
        [Tid] [int] IDENTITY(1,1) NOT NULL,
        [Tname] [nvarchar](50) NULL,
        [Tscore] [int] NULL DEFAULT(0),
        [Tsort] [int] NULL DEFAULT(0),
        [Tactive] [bit] NULL DEFAULT(1),
        [Tdate] [datetime] NULL,
        PRIMARY KEY CLUSTERED ([Tid] ASC)
    )

    -- 插入默认评分类型
    INSERT INTO AttitudeType(Tname,Tscore,Tsort,Tactive,Tdate) VALUES(N'乐于助人',2,1,1,GETDATE())
    INSERT INTO AttitudeType(Tname,Tscore,Tsort,Tactive,Tdate) VALUES(N'表现优秀',1,2,1,GETDATE())
    INSERT INTO AttitudeType(Tname,Tscore,Tsort,Tactive,Tdate) VALUES(N'有开小差',-1,3,1,GETDATE())
    INSERT INTO AttitudeType(Tname,Tscore,Tsort,Tactive,Tdate) VALUES(N'乱扔垃圾',-2,4,1,GETDATE())
    INSERT INTO AttitudeType(Tname,Tscore,Tsort,Tactive,Tdate) VALUES(N'上课迟到',-3,5,1,GETDATE())
    INSERT INTO AttitudeType(Tname,Tscore,Tsort,Tactive,Tdate) VALUES(N'损坏公物',-4,6,1,GETDATE())
END
