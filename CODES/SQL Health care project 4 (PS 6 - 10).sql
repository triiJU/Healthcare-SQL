use mydb;



-- PS 6

SELECT 
    a.city,
    COUNT(p.pharmacyID) AS num_pharmacies,
    COUNT(pr.prescriptionID) AS num_prescriptions,
    COUNT(pr.prescriptionID) / COUNT(DISTINCT p.pharmacyID) AS pharmacy_to_prescription_ratio
FROM 
    pharmacy p
JOIN 
    address a ON p.addressID = a.addressID
JOIN 
    prescription pr ON p.pharmacyID = pr.pharmacyID
GROUP BY 
    a.city
HAVING 
    num_prescriptions > 100
ORDER BY 
    pharmacy_to_prescription_ratio ASC
LIMIT 3;



-- PS 7

WITH CityDiseaseCount AS (
    SELECT 
        a.city,
        d.diseaseName,
        COUNT(t.patientID) AS patientCount
    FROM 
        Treatment t
        JOIN Disease d ON t.diseaseID = d.diseaseID
        JOIN Patient p ON t.patientID = p.patientID
        JOIN Person pe ON p.patientID = pe.personID
        JOIN Address a ON pe.addressID = a.addressID
    WHERE 
        a.state = 'AL'
    GROUP BY 
        a.city, d.diseaseName
),
MaxDiseasePerCity AS (
    SELECT
        city,
        diseaseName,
        patientCount,
        ROW_NUMBER() OVER (PARTITION BY city ORDER BY patientCount DESC) AS rn
    FROM
        CityDiseaseCount
)
SELECT
    city,
    diseaseName,
    patientCount
FROM
    MaxDiseasePerCity
WHERE
    rn = 1;
    
SHOW TABLES;



-- PS 8

WITH DiseaseInsuranceClaims AS (
  SELECT
    d.diseaseName AS disease,
    ip.planName AS insurance_plan,
    COUNT(*) AS num_claims
  FROM
    claim c
  JOIN
    treatment t ON c.claimID = t.claimID
  JOIN
    disease d ON t.diseaseID = d.diseaseID
  JOIN
    insuranceplan ip ON c.UIN = ip.UIN
  GROUP BY
    d.diseaseName, ip.planName
), RankedDiseaseInsuranceClaims AS (
  SELECT
    disease,
    insurance_plan,
    num_claims,
    RANK() OVER (PARTITION BY disease ORDER BY num_claims DESC) AS rank_desc,
    RANK() OVER (PARTITION BY disease ORDER BY num_claims ASC) AS rank_asc
  FROM
    DiseaseInsuranceClaims
)
SELECT
  disease,
  MAX(CASE WHEN rank_desc = 1 THEN insurance_plan END) AS most_claimed_plan,
  MAX(CASE WHEN rank_asc = 1 THEN insurance_plan END) AS least_claimed_plan
FROM
  RankedDiseaseInsuranceClaims
GROUP BY
  disease;
  


-- PS 9

SELECT 
    d.diseaseName,
    COUNT(DISTINCT a.addressID) AS households_count
FROM 
    Treatment t1
JOIN 
    Patient p1 ON t1.patientID = p1.patientID
JOIN 
    Person ps1 ON p1.patientID = ps1.personID
JOIN 
    Address a ON ps1.addressID = a.addressID
JOIN 
    Disease d ON t1.diseaseID = d.diseaseID
WHERE 
    EXISTS (
        SELECT 
            1
        FROM 
            Treatment t2
        JOIN 
            Patient p2 ON t2.patientID = p2.patientID
        JOIN 
            Person ps2 ON p2.patientID = ps2.personID
        WHERE 
            ps2.addressID = a.addressID
            AND t2.diseaseID = t1.diseaseID
            AND t2.treatmentID <> t1.treatmentID 
    )
GROUP BY 
    d.diseaseID, d.diseaseName;
    
    
    
-- PS 10

SELECT 
    a.state,
    COUNT(DISTINCT t.treatmentID) AS total_treatments,
    COUNT(DISTINCT c.claimID) AS total_claims,
    ROUND(
        COUNT(DISTINCT t.treatmentID) / NULLIF(COUNT(DISTINCT c.claimID), 0), 
        2
    ) AS treatment_to_claim_ratio
FROM 
    Treatment t
JOIN 
    Patient p ON t.patientID = p.patientID
JOIN 
    Person ps ON p.patientID = ps.personID
JOIN 
    Address a ON ps.addressID = a.addressID
LEFT JOIN 
    Claim c ON t.claimID = c.claimID
WHERE 
    t.date BETWEEN '2021-04-01' AND '2022-03-31'
GROUP BY 
    a.state;
