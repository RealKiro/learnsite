-- 修复 Listmenu 表中调查问卷任务的 Lcid 字段
-- 使其与 SurveyQuestion 表中的 Qcid 字段一致

-- 步骤1：查看当前状态
SELECT 
    L.Lid,
    L.Lcid AS '当前课程ID',
    L.Lxid AS '问卷ID',
    L.Ltype AS '类型',
    L.Ltitle AS '标题',
    Q.Qcid AS '正确的课程ID'
FROM Listmenu L
LEFT JOIN (
    SELECT DISTINCT Qvid, Qcid 
    FROM SurveyQuestion
) Q ON L.Lxid = Q.Qvid
WHERE L.Ltype = '14'
ORDER BY L.Lid;

-- 步骤2：更新 Lcid 字段
-- 将 Listmenu 表的 Lcid 更新为 SurveyQuestion 表中的 Qcid
UPDATE L
SET L.Lcid = Q.Qcid
FROM Listmenu L
INNER JOIN (
    SELECT DISTINCT Qvid, Qcid 
    FROM SurveyQuestion
) Q ON L.Lxid = Q.Qvid
WHERE L.Ltype = '14'
  AND (L.Lcid IS NULL OR L.Lcid <> Q.Qcid);

-- 步骤3：验证修复结果
SELECT 
    L.Lid,
    L.Lcid AS '课程ID',
    L.Lxid AS '问卷ID',
    L.Ltitle AS '标题',
    Q.Qcid AS 'SurveyQuestion中的课程ID',
    CASE 
        WHEN L.Lcid = Q.Qcid THEN '✓ 一致'
        ELSE '✗ 不一致'
    END AS '状态'
FROM Listmenu L
LEFT JOIN (
    SELECT DISTINCT Qvid, Qcid 
    FROM SurveyQuestion
) Q ON L.Lxid = Q.Qvid
WHERE L.Ltype = '14'
ORDER BY L.Lid;

-- 步骤4：显示修复统计
SELECT 
    COUNT(*) AS '总记录数',
    SUM(CASE WHEN L.Lcid = Q.Qcid THEN 1 ELSE 0 END) AS '一致的记录',
    SUM(CASE WHEN L.Lcid <> Q.Qcid OR L.Lcid IS NULL THEN 1 ELSE 0 END) AS '不一致的记录'
FROM Listmenu L
LEFT JOIN (
    SELECT DISTINCT Qvid, Qcid 
    FROM SurveyQuestion
) Q ON L.Lxid = Q.Qvid
WHERE L.Ltype = '14';
