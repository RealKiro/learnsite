-- ============================================================
-- create-surveyfinish-table.sql
-- 创建调查问卷提交记录表（幂等脚本，可重复执行）
-- ============================================================

-- 第一批：创建表（如果不存在）
IF NOT EXISTS (
    SELECT 1 FROM sys.objects
    WHERE object_id = OBJECT_ID(N'dbo.SurveyFinish') AND type = 'U'
)
BEGIN
    CREATE TABLE [dbo].[SurveyFinish] (
        [Fid]    INT           IDENTITY(1,1) NOT NULL,
        [Fvid]   INT           NOT NULL,
        [Fsnum]  NVARCHAR(50)  NOT NULL,
        [Fsname] NTEXT         NULL,
        [Fscore] INT           NOT NULL CONSTRAINT DF_SurveyFinish_Fscore DEFAULT 0,
        [Ftime]  DATETIME      NOT NULL CONSTRAINT DF_SurveyFinish_Ftime  DEFAULT GETDATE(),
        CONSTRAINT PK_SurveyFinish PRIMARY KEY CLUSTERED ([Fid] ASC)
    )
    PRINT N'[OK] SurveyFinish 表创建成功'
END
ELSE
    PRINT N'[SKIP] SurveyFinish 表已存在，跳过创建'
GO

-- 第二批：索引 IX_SurveyFinish_Fvid
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.SurveyFinish')
      AND name = N'IX_SurveyFinish_Fvid'
)
BEGIN
    CREATE INDEX [IX_SurveyFinish_Fvid]
        ON [dbo].[SurveyFinish] ([Fvid])
    PRINT N'[OK] 索引 IX_SurveyFinish_Fvid 创建成功'
END
ELSE
    PRINT N'[SKIP] 索引 IX_SurveyFinish_Fvid 已存在'
GO

-- 第三批：索引 IX_SurveyFinish_Fsnum
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.SurveyFinish')
      AND name = N'IX_SurveyFinish_Fsnum'
)
BEGIN
    CREATE INDEX [IX_SurveyFinish_Fsnum]
        ON [dbo].[SurveyFinish] ([Fsnum])
    PRINT N'[OK] 索引 IX_SurveyFinish_Fsnum 创建成功'
END
ELSE
    PRINT N'[SKIP] 索引 IX_SurveyFinish_Fsnum 已存在'
GO

-- 第四批：索引 IX_SurveyFinish_Fvid_Fsnum（复合）
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.SurveyFinish')
      AND name = N'IX_SurveyFinish_Fvid_Fsnum'
)
BEGIN
    CREATE INDEX [IX_SurveyFinish_Fvid_Fsnum]
        ON [dbo].[SurveyFinish] ([Fvid], [Fsnum])
    PRINT N'[OK] 索引 IX_SurveyFinish_Fvid_Fsnum 创建成功'
END
ELSE
    PRINT N'[SKIP] 索引 IX_SurveyFinish_Fvid_Fsnum 已存在'
GO

-- 第五批：验证表结构
SELECT
    c.name                    AS ColumnName,
    TYPE_NAME(c.user_type_id) AS DataType,
    c.max_length,
    c.is_nullable
FROM sys.columns c
WHERE c.object_id = OBJECT_ID(N'dbo.SurveyFinish')
ORDER BY c.column_id
GO

PRINT N'[DONE] SurveyFinish 脚本执行完毕'
GO
