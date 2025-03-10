use mydb;


-- PS 16

WITH PrescriptionQuantities AS (
  SELECT
    p.prescriptionID,
    SUM(c.quantity) AS totalQuantity
  FROM Prescription p
  JOIN Pharmacy ph ON p.pharmacyID = ph.pharmacyID
  JOIN Contain c ON p.prescriptionID = c.prescriptionID
  WHERE ph.pharmacyName = 'Ally Scripts'
  GROUP BY p.prescriptionID
)
SELECT 
  prescriptionID,
  totalQuantity,
  CASE
    WHEN totalQuantity < 20 THEN 'Low Quantity'
    WHEN totalQuantity BETWEEN 20 AND 49 THEN 'Medium Quantity'
    ELSE 'High Quantity'
  END AS Tag
FROM PrescriptionQuantities;



-- PS 17

SELECT 
    m.productName,
    k.quantity,
    k.discount,
    CASE 
        WHEN k.quantity < 1000 THEN 'LOW QUANTITY'
        WHEN k.quantity > 7500 THEN 'HIGH QUANTITY'
        ELSE 'OTHER'
    END AS quantity_status,
    CASE 
        WHEN k.discount >= 30 THEN 'HIGH DISCOUNT'
        WHEN k.discount = 0 THEN 'NO DISCOUNT'
        ELSE 'OTHER'
    END AS discount_status
FROM 
    keep k
JOIN 
    pharmacy p ON k.pharmacyID = p.pharmacyID
JOIN 
    medicine m ON k.medicineID = m.medicineID
WHERE 
    p.pharmacyName = 'Spot Rx'
    AND (
        (k.quantity < 1000 AND k.discount >= 30) 
        OR (k.quantity > 7500 AND k.discount = 0)
    );



-- PS 18

WITH AvgMaxPrice AS (
    SELECT AVG(maxPrice) AS AvgMaxPrice
    FROM medicine
)
SELECT 
    m.medicineID,
    m.productName,
    m.maxPrice,
    'Affordable' AS PriceCategory
FROM 
    medicine m
JOIN 
    AvgMaxPrice a ON 1=1
WHERE 
    m.hospitalExclusive = 'S'
    AND m.maxPrice < 0.5 * (SELECT AvgMaxPrice FROM AvgMaxPrice)

UNION ALL

SELECT 
    m.medicineID,
    m.productName,
    m.maxPrice,
    'Costly' AS PriceCategory
FROM 
    medicine m
JOIN 
    AvgMaxPrice a ON 1=1
WHERE 
    m.hospitalExclusive = 'S'
    AND m.maxPrice > 2 * (SELECT AvgMaxPrice FROM AvgMaxPrice);



-- PS 19

SELECT 
    p.personName as patientName,
    p.gender,
    pa.dob as Date_of_Birth,
    
    CASE 
        WHEN YEAR(pa.dob) >= 2005 AND p.gender = 'male' THEN 'YoungMale'
        WHEN YEAR(pa.dob) >= 2005 AND p.gender = 'female' THEN 'YoungFemale'
        WHEN YEAR(pa.dob) >= 1985 AND p.gender = 'male' THEN 'AdultMale'
        WHEN YEAR(pa.dob) >= 1985 AND p.gender = 'female' THEN 'AdultFemale'
        WHEN YEAR(pa.dob) >= 1970 AND p.gender = 'male' THEN 'MidAgeMale'
        WHEN YEAR(pa.dob) >= 1970 AND p.gender = 'female' THEN 'MidAgeFemale'
        WHEN YEAR(pa.dob) < 1970 AND p.gender = 'male' THEN 'ElderMale'
        WHEN YEAR(pa.dob) < 1970 AND p.gender = 'female' THEN 'ElderFemale'
        ELSE 'Unknown'
    END AS category
FROM 
    patient pa
JOIN
    person p ON pa.patientID = p.personID;