use mydb;



-- PS 11

SELECT 
    p.pharmacyName,
    COUNT(*) AS total_prescriptions
FROM 
    pharmacy p
JOIN 
    prescription pr ON p.pharmacyID = pr.pharmacyID
JOIN 
    contain c ON pr.prescriptionID = c.prescriptionID
JOIN 
    medicine m ON c.medicineID = m.medicineID
JOIN 
    treatment t ON pr.treatmentID = t.treatmentID
WHERE 
    m.hospitalExclusive = 'S'
    AND t.date BETWEEN '2021-01-01' AND '2022-12-31'
GROUP BY 
    p.pharmacyName
ORDER BY 
    total_prescriptions DESC;
    
    

-- PS 12

SELECT IP.planName,IC.companyName, COUNT(T.treatmentID) AS numTreatments FROM InsurancePlan IP
JOIN InsuranceCompany IC ON IP.companyID = IC.companyID
JOIN Claim CL ON IP.UIN = CL.UIN
JOIN Treatment T ON CL.claimID = T.claimID
GROUP BY IP.planName, IC.companyName ORDER BY numTreatments DESC;



-- PS 13

WITH ClaimCounts AS (
    SELECT 
        c.uin,
        ic.companyName,
        COUNT(*) AS claim_count
    FROM Claim c
    JOIN InsurancePlan ip ON c.uin = ip.uin
    JOIN InsuranceCompany ic ON ip.companyID = ic.companyID
    GROUP BY c.uin, ic.companyName
), RankedClaims AS (
    SELECT
        cc.uin,
        cc.companyName,
        cc.claim_count,
        RANK() OVER (PARTITION BY cc.companyName ORDER BY cc.claim_count DESC) AS rank_desc,
        RANK() OVER (PARTITION BY cc.companyName ORDER BY cc.claim_count ASC) AS rank_asc
    FROM ClaimCounts cc
)
SELECT 
    rc.companyName,
    rc.uin AS most_claimed_plan,
    rc.claim_count AS most_claimed_count,
    rc.uin AS least_claimed_plan,
    rc.claim_count AS least_claimed_count
FROM RankedClaims rc
WHERE rc.rank_desc = 1 OR rc.rank_asc = 1
ORDER BY rc.companyName;



-- PS 14

WITH StateCounts AS (
    SELECT
        a.state,
        COUNT(DISTINCT p.personID) AS registered_people,
        COUNT(DISTINCT pa.patientID) AS registered_patients
    FROM Address a
    JOIN Person p ON a.addressID = p.addressID
    LEFT JOIN Patient pa ON p.personID = pa.patientID
    GROUP BY a.state
)
SELECT
    sc.state,
    sc.registered_people,
    sc.registered_patients,
    sc.registered_people / sc.registered_patients AS people_to_patient_ratio
FROM StateCounts sc
ORDER BY people_to_patient_ratio;




-- PS 15

SELECT P.pharmacyName, SUM(C.quantity) AS totalQuantity FROM Pharmacy P
JOIN Prescription Pres ON P.pharmacyID = Pres.pharmacyID
JOIN Treatment T ON Pres.treatmentID = T.treatmentID
JOIN Contain C ON Pres.prescriptionID = C.prescriptionID
JOIN Medicine M ON C.medicineID = M.medicineID
JOIN Address A ON P.addressID = A.addressID
WHERE A.state = 'AZ' AND M.taxCriteria = 'I' AND YEAR(T.date) = 2021 GROUP BY P.pharmacyName ORDER BY totalQuantity DESC;

SET GLOBAL max_allowed_packet = 1073741824; -- 1 GB
SET GLOBAL wait_timeout = 28800; -- 8 hours
