-- ========================================
-- 手动添加调查选项 SQL 脚本
-- ========================================
-- 由于 surveyitem.aspx 页面的后端代码存在bug，
-- 可以使用此SQL脚本直接在数据库中添加选项
-- ========================================

-- 表结构说明：
-- SurveyItem 表字段：
--   Mid - 选项ID (自增)
--   Mqid - 题目ID
--   Mvid - 调查ID
--   Mitem - 选项内容 (ntext类型)
--   Mscore - 分值
--   Mcount - 计数
--   Mcid - 课程ID
--   Mblack - 是否填空
--
-- SurveyQuestion 表字段：
--   Qid - 题目ID
--   Qvid - 调查ID
--   Qcid - 课程ID
--   Qtitle - 题目标题 (ntext类型)
--   Qcount - 计数
--   Qblack - 是否填空

-- ========================================
-- 1. 查看所有调查
-- ========================================
SELECT Vid, Vtitle, Vdate 
FROM Survey 
ORDER BY Vdate DESC;

-- ========================================
-- 2. 查看指定调查的所有题目
-- ========================================
-- 替换 2 为实际的调查ID
SELECT Qid, Qcid, Qcount, Qblack 
FROM SurveyQuestion 
WHERE Qvid = 2 
ORDER BY Qid;

-- 注意：Qtitle 是 ntext 类型，不能直接在 SELECT 中显示
-- 如果需要查看题目内容，使用：
SELECT Qid, CAST(Qtitle AS NVARCHAR(MAX)) AS 题目内容, Qcid, Qcount, Qblack 
FROM SurveyQuestion 
WHERE Qvid = 2 
ORDER BY Qid;

-- ========================================
-- 3. 查看指定题目的现有选项
-- ========================================
-- 替换 2 为实际的题目ID
SELECT Mid, CAST(Mitem AS NVARCHAR(MAX)) AS 选项内容, Mscore, Mcount 
FROM SurveyItem 
WHERE Mqid = 2;

-- ========================================
-- 添加选项示例
-- ========================================

-- 示例1：为题目2添加单选题选项
-- 题目ID: 2, 调查ID: 2, 课程ID: 4
-- 选项内容: A、B、C、D
-- 分值: 第一个选项5分，其他0分

-- 选项A（正确答案，5分）
INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (2, 2, N'A. 选项A的内容', 5, 0, 4, 0);

-- 选项B（0分）
INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (2, 2, N'B. 选项B的内容', 0, 0, 4, 0);

-- 选项C（0分）
INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (2, 2, N'C. 选项C的内容', 0, 0, 4, 0);

-- 选项D（0分）
INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (2, 2, N'D. 选项D的内容', 0, 0, 4, 0);

-- ========================================
-- 示例2：为题目3添加判断题选项
-- ========================================

-- 正确（5分）
INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (3, 2, N'正确', 5, 0, 4, 0);

-- 错误（0分）
INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (3, 2, N'错误', 0, 0, 4, 0);

-- ========================================
-- 示例3：为题目4添加多选题选项
-- ========================================
-- 多选题可以有多个正确答案，每个正确答案给部分分数

-- 选项A（正确，2分）
INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (4, 2, N'A. 选项A', 2, 0, 4, 0);

-- 选项B（正确，2分）
INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (4, 2, N'B. 选项B', 2, 0, 4, 0);

-- 选项C（错误，0分）
INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (4, 2, N'C. 选项C', 0, 0, 4, 0);

-- 选项D（正确，1分）
INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (4, 2, N'D. 选项D', 1, 0, 4, 0);

-- ========================================
-- 示例4：为题目5添加问答题选项（参考答案）
-- ========================================

INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (5, 2, N'参考答案：这是问答题的参考答案内容...', 10, 0, 4, 0);

-- ========================================
-- 示例5：为题目6添加填空题选项（答案）
-- ========================================

-- 第一个填空的答案
INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (6, 2, N'答案1', 3, 0, 4, 1);

-- 第二个填空的答案
INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (6, 2, N'答案2', 2, 0, 4, 1);

-- ========================================
-- 批量添加选项的通用模板
-- ========================================

-- 步骤1：设置变量
DECLARE @QuestionId INT = 2;  -- 题目ID
DECLARE @SurveyId INT = 2;    -- 调查ID
DECLARE @CourseId INT = 4;    -- 课程ID

-- 步骤2：添加选项（根据需要修改内容、分值）
INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (@QuestionId, @SurveyId, N'选项1内容', 5, 0, @CourseId, 0);

INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (@QuestionId, @SurveyId, N'选项2内容', 0, 0, @CourseId, 0);

INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (@QuestionId, @SurveyId, N'选项3内容', 0, 0, @CourseId, 0);

INSERT INTO SurveyItem (Mqid, Mvid, Mitem, Mscore, Mcount, Mcid, Mblack)
VALUES (@QuestionId, @SurveyId, N'选项4内容', 0, 0, @CourseId, 0);

-- 步骤3：验证添加结果
SELECT Mid, CAST(Mitem AS NVARCHAR(MAX)) AS 选项内容, Mscore, Mcount 
FROM SurveyItem 
WHERE Mqid = @QuestionId;

-- ========================================
-- 修改选项
-- ========================================

-- 修改选项内容
UPDATE SurveyItem 
SET Mitem = N'新的选项内容' 
WHERE Mid = 1; -- 替换为实际的选项ID

-- 修改选项分值
UPDATE SurveyItem 
SET Mscore = 10 
WHERE Mid = 1;

-- ========================================
-- 删除选项
-- ========================================

-- 删除指定选项
DELETE FROM SurveyItem WHERE Mid = 1; -- 替换为实际的选项ID

-- 删除题目的所有选项
DELETE FROM SurveyItem WHERE Mqid = 2; -- 替换为实际的题目ID

-- ========================================
-- 常用查询
-- ========================================

-- 查看所有题目及其选项数量
SELECT 
    q.Qid,
    CAST(q.Qtitle AS NVARCHAR(100)) AS 题目标题,
    q.Qcount,
    COUNT(i.Mid) AS 选项数量
FROM SurveyQuestion q
LEFT JOIN SurveyItem i ON q.Qid = i.Mqid
WHERE q.Qvid = 2 -- 替换为实际的调查ID
GROUP BY q.Qid, CAST(q.Qtitle AS NVARCHAR(100)), q.Qcount
ORDER BY q.Qid;

-- 查看没有选项的题目
SELECT 
    q.Qid,
    CAST(q.Qtitle AS NVARCHAR(100)) AS 题目标题
FROM SurveyQuestion q
LEFT JOIN SurveyItem i ON q.Qid = i.Mqid
WHERE q.Qvid = 2 -- 替换为实际的调查ID
AND i.Mid IS NULL;

-- 查看题目和所有选项的详细信息
SELECT 
    q.Qid AS 题目ID,
    CAST(q.Qtitle AS NVARCHAR(200)) AS 题目内容,
    i.Mid AS 选项ID,
    CAST(i.Mitem AS NVARCHAR(200)) AS 选项内容,
    i.Mscore AS 分值,
    i.Mcount AS 计数
FROM SurveyQuestion q
LEFT JOIN SurveyItem i ON q.Qid = i.Mqid
WHERE q.Qvid = 2 -- 替换为实际的调查ID
ORDER BY q.Qid, i.Mid;

-- ========================================
-- 注意事项
-- ========================================
-- 1. Mqid 必须是有效的题目ID（存在于 SurveyQuestion 表中）
-- 2. Mvid 是调查ID，应该与题目的 Qvid 一致
-- 3. Mcid 是课程ID，应该与题目的 Qcid 一致
-- 4. Mscore 是分值，正确答案设置为正数，错误答案设置为0
-- 5. Mcount 通常设置为0，系统会自动统计
-- 6. Mblack 是否填空：0=否，1=是
-- 7. Mitem 是 ntext 类型，插入时需要使用 N'...' 前缀
-- 8. 查询 ntext 字段时需要使用 CAST 转换为 NVARCHAR
-- 9. 单选题通常只有一个选项的分值大于0
-- 10. 多选题可以有多个选项的分值大于0
-- 11. 判断题通常只有两个选项：正确和错误
-- 12. 填空题的选项是标准答案，Mblack 设置为1
-- 13. 问答题的选项是参考答案
