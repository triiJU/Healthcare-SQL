use mydb;


-- PS 20

SELECT 
    p.personName AS PatientName,
    COUNT(t.treatmentID) AS NumberOfTreatments,
    TIMESTAMPDIFF(YEAR, pat.dob, CURDATE()) AS Age
FROM 
    Patient pat
INNER JOIN 
    Treatment t ON pat.patientID = t.patientID
INNER JOIN 
    Person p ON pat.patientID = p.personID
GROUP BY 
    p.personName, pat.dob
HAVING 
    COUNT(t.treatmentID) > 1
ORDER BY 
    NumberOfTreatments DESC;



-- PS 21

SELECT 
    d.diseaseName AS Disease,
    SUM(CASE WHEN p.gender = 'Male' THEN 1 ELSE 0 END) AS MaleCount,
    SUM(CASE WHEN p.gender = 'Female' THEN 1 ELSE 0 END) AS FemaleCount,
    ROUND(SUM(CASE WHEN p.gender = 'Male' THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN p.gender = 'Female' THEN 1 ELSE 0 END), 0), 2) AS MaleToFemaleRatio
FROM 
    Treatment t
JOIN 
    Disease d ON t.diseaseID = d.diseaseID
JOIN 
    Patient pa ON t.patientID = pa.patientID
JOIN 
    Person p ON pa.patientID = p.personID
WHERE 
    YEAR(t.date) = 2021
GROUP BY 
    d.diseaseName;



-- PS 22

WITH TreatmentCount AS (
    SELECT 
        d.diseaseName AS Disease,
        a.city AS City,
        COUNT(t.treatmentID) AS TreatmentCount,
        DENSE_RANK() OVER (PARTITION BY d.diseaseName ORDER BY COUNT(t.treatmentID) DESC) AS CityRank
    FROM 
        Treatment t
    JOIN 
        Disease d ON t.diseaseID = d.diseaseID
    JOIN 
        Patient pa ON t.patientID = pa.patientID
    JOIN 
        Person p ON pa.patientID = p.personID
    JOIN 
        Address a ON p.addressID = a.addressID
    GROUP BY 
        d.diseaseName, a.city
)
SELECT 
    Disease, 
    City, 
    TreatmentCount
FROM 
    TreatmentCount
WHERE 
    CityRank <= 3;



-- PS 23

SELECT
    p.pharmacyName,
    d.diseaseName,
    SUM(CASE WHEN YEAR(t.Date) = 2021 THEN 1 ELSE 0 END) AS prescriptions_2021,
    SUM(CASE WHEN YEAR(t.Date) = 2022 THEN 1 ELSE 0 END) AS prescriptions_2022
FROM
    Pharmacy p
    JOIN Prescription pr ON p.pharmacyID = pr.pharmacyID
    JOIN Treatment t ON pr.treatmentID = t.treatmentID
    JOIN Disease d ON t.diseaseID = d.diseaseID
GROUP BY
    p.pharmacyName,
    d.diseaseName
ORDER BY
    p.pharmacyName,
    d.diseaseName;
    
    
-- PS 24

SELECT 
    ic.companyName AS InsuranceCompany,
    a.state AS State,
    COUNT(c.claimID) AS NumberOfClaims
FROM 
    Claim c
JOIN 
    InsurancePlan ip ON c.UIN = ip.UIN
JOIN 
    InsuranceCompany ic ON ip.companyID = ic.companyID
JOIN 
    Treatment t ON c.claimID = t.claimID
JOIN 
    Patient pa ON t.patientID = pa.patientID
JOIN 
    Person p ON pa.patientID = p.personID
JOIN 
    Address a ON p.addressID = a.addressID
GROUP BY 
    ic.companyName, a.state
ORDER BY 
    NumberOfClaims DESC;
