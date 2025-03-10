use mydb;

SHOW TABLES;



-- PS 25

SELECT 
    ph.pharmacyID,
    ph.pharmacyName,
    
    SUM(c.Quantity) AS totalQuantity2022,
    SUM(c.Quantity * (m.hospitalExclusive = 'S')) AS hospitalExclusiveQuantity2022,
    (SUM(c.Quantity * (m.hospitalExclusive = 'S')) * 100.0 / SUM(c.Quantity)) AS hospitalExclusivePercentage
FROM 
    Pharmacy ph
INNER JOIN 
    Prescription pr ON ph.pharmacyID = pr.pharmacyID
INNER JOIN 
    Contain c ON pr.prescriptionID = c.prescriptionID
INNER JOIN 
    Medicine m ON c.medicineID = m.medicineID
INNER JOIN 
    Treatment t ON pr.treatmentID = t.treatmentID
WHERE 
    YEAR(t.date) = 2022
GROUP BY 
    ph.pharmacyID, ph.pharmacyName
HAVING 
    totalQuantity2022 > 0
ORDER BY 
    hospitalExclusivePercentage DESC;




-- PS 26

SELECT 
    a.state,
    COUNT(t.treatmentID) AS totalTreatments,
    SUM(c.claimID IS NULL) AS treatmentsWithoutClaims,
    (SUM(c.claimID IS NULL) * 100.0 / COUNT(t.treatmentID)) AS percentageWithoutClaims
FROM 
    Treatment t
INNER JOIN 
    Patient p ON t.patientID = p.patientID
INNER JOIN 
    Person pe ON p.patientID = pe.personID
INNER JOIN 
    Address a ON pe.addressID = a.addressID
LEFT JOIN 
    Claim c ON t.claimID = c.claimID
GROUP BY 
    a.state
ORDER BY 
    percentageWithoutClaims DESC;



-- PS 27

WITH disease_counts AS (
  SELECT
    a.state,  
    d.diseaseName AS disease, 
    COUNT(*) AS disease_count
  FROM treatment t
  INNER JOIN patient p ON t.patientID = p.patientID
  INNER JOIN person per ON p.patientID = per.personID  
  INNER JOIN address a ON per.addressID = a.addressID 
  INNER JOIN disease d ON t.diseaseID = d.diseaseid 
  GROUP BY a.state, d.diseaseName
)
SELECT
  dc.state,
  dc.disease,
  dc.disease_count
FROM disease_counts dc
INNER JOIN (
  SELECT state, MAX(disease_count) AS max_count, MIN(disease_count) AS min_count
  FROM disease_counts
  GROUP BY state
) AS state_extremes ON dc.state = state_extremes.state
WHERE dc.disease_count IN (state_extremes.max_count, state_extremes.min_count);



-- PS 28

  SELECT
  a.city,
  COUNT(DISTINCT p.personid) AS total_registered,
  COUNT(DISTINCT t.patientid) AS total_patients,
  (COUNT(DISTINCT t.patientid) * 100.0 / COUNT(DISTINCT p.personid)) AS percentage_patients
FROM
  address a
INNER JOIN person p ON a.addressid = p.addressid
LEFT JOIN treatment t ON p.personid = t.patientid
GROUP BY
  a.city
HAVING
  COUNT(DISTINCT p.personid) >= 10;
  
  

-- PS 29

SELECT
    companyName,
    COUNT(*) AS usage_count
FROM
    medicine
WHERE
    substanceName = 'ranitidina'
GROUP BY
    companyName
ORDER BY
    usage_count DESC
LIMIT 3;