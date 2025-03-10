USE mydb;
SHOW TABLES;


-- PS 1
SELECT
  CASE
    WHEN (YEAR(CURDATE()) - YEAR(p.dob)) < 15 THEN 'Children'
    WHEN (YEAR(CURDATE()) - YEAR(p.dob)) BETWEEN 15 AND 24 THEN 'Youth'
    WHEN (YEAR(CURDATE()) - YEAR(p.dob)) BETWEEN 25 AND 64 THEN 'Adults'
    ELSE 'Seniors'
  END AS age_category,
  COUNT(*) AS treatment_count
FROM Patient p
INNER JOIN Treatment t ON p.patientID = t.patientID
WHERE YEAR(t.date) = 2022
GROUP BY age_category
ORDER BY age_category;



-- PS 2
SELECT
    t.diseaseID ,
    SUM(CASE WHEN pr.gender = 'Male' THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN pr.gender = 'Female' THEN 1 ELSE 0 END) AS female_count,
    (SUM(CASE WHEN pr.gender = 'Male' THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN pr.gender = 'Female' THEN 1 ELSE 0 END), 0)) AS male_to_female_ratio
FROM Treatment t
JOIN Patient pa ON t.patientID = pa.patientID
JOIN Person pr ON pa.patientID = pr.personID
GROUP BY t.diseaseID
ORDER BY male_to_female_ratio DESC;


WITH TreatmentCounts AS (
  SELECT
    per.gender,
    COUNT(DISTINCT t.treatmentid) AS total_treatments
  FROM treatment AS t
  JOIN patient AS p ON t.patientID = p.patientID
  JOIN person AS per ON p.patientID = per.personID
  GROUP BY per.gender
),
ClaimCounts AS (
  SELECT
    per.gender,
    COUNT(DISTINCT c.claimid) AS total_claims
  FROM treatment AS t
  JOIN patient AS p ON t.patientID = p.patientID
  JOIN claim AS c ON t.claimID = c.claimID
  JOIN person AS per ON p.patientID = per.personID
  GROUP BY per.gender
)
SELECT
  tc.gender,
  tc.total_treatments,
  cc.total_claims,
  tc.total_treatments / cc.total_claims AS treatment_to_claim_ratio
FROM TreatmentCounts AS tc
JOIN ClaimCounts AS cc ON tc.gender = cc.gender
ORDER BY tc.gender



-- PS 4
SELECT DISTINCT
    p.pharmacyName,
    m.productName,
    i.quantity,
    i.quantity * m.maxPrice AS total_max_retail_price,
    i.quantity * m.maxPrice * (1 - i.discount / 100) AS total_price_after_discount
FROM 
    keep i
JOIN 
    pharmacy p ON i.pharmacyID = p.pharmacyID
JOIN 
    medicine m ON i.medicineID = m.medicineID
ORDER BY 
    p.pharmacyName, m.productName;
    
    
-- PS 5
SELECT 
    p.pharmacyName,
    MAX(pr.quantity) AS max_medicines,
    MIN(pr.quantity) AS min_medicines,
    AVG(pr.quantity) AS avg_medicines
FROM 
    keep pr
JOIN 
    pharmacy p ON pr.pharmacyID = p.pharmacyID
GROUP BY 
    p.pharmacyName