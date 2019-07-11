/* There are 15 tables:
Affiliated_with
Department
Trained_in
Physician
Procedure
Patient
Prescribes
Room
Appointment
Medication
Block
Undergoes
Stay
On_Call
Nurse 

1. Obtain the names of all physicians that have performed a medical procedure 
they have never been certified to perform. */


SELECT Name 
FROM Physician 
WHERE EmployeeID IN 
       (
         SELECT Physician 
         FROM Undergoes AS U 
         WHERE NOT EXISTS 
            (
               SELECT * 
	       FROM Trained_In 
               WHERE Treatment = Procedure 
               AND Physician = U.Physician
            )
       );


SELECT P.Name 
FROM Physician AS P,    
 (SELECT Physician, Procedure FROM Undergoes 
    EXCEPT 
    SELECT Physician, Treatment FROM Trained_in) AS Pe
WHERE P.EmployeeID=Pe.Physician;


SELECT Name 
FROM Physician
WHERE EmployeeID IN
   (
      SELECT Undergoes.Physician
      FROM Undergoes 
      LEFT JOIN Trained_In ON Undergoes.Physician=Trained_In.Physician
                           AND Undergoes.Procedures=Trained_In.Treatment
      WHERE Treatment IS NULL
   );

/* 2. Same as the previous query, but include the following information in the results:
Physician name, name of procedure, date when the procedure was carried out, name of 
the patient the procedure was carried out on. */


SELECT P.Name AS Physician, Pr.Name AS Procedure, U.Date, Pt.Name AS Patient 
FROM Physician AS P, Undergoes AS U, Patient AS Pt, Procedure AS Pr
WHERE U.Patient = Pt.SSN
AND U.Procedure = Pr.Code
AND U.Physician = P.EmployeeID
AND NOT EXISTS 
        (
                SELECT * 
                FROM Trained_In AS T
                WHERE T.Treatment = U.Procedure 
                AND T.Physician = U.Physician
        );

SELECT P.Name,Pr.Name,U.Date,Pt.Name 
FROM Physician AS P, Procedure AS Pr, Undergoes AS U, Patient AS Pt,
    (  SELECT Physician, Procedure 
       FROM Undergoes 
       EXCEPT 
       SELECT Physician, Treatment FROM Trained_in) AS Pe  
       WHERE P.EmployeeID=Pe.Physician 
       AND Pe.Procedure=Pr.Code 
       AND Pe.Physician=U.Physician 
       AND Pe.Procedure=U.Procedure 
       AND U.Patient=Pt.SSN ;  


/* 3. Obtain the names of all physicians that have performed a medical procedure that 
they are certified to perform, but such that the procedure was done at a date 
(Undergoes.Date) after the physician's certification expired (Trained_In.CertificationExpires). */


SELECT Name 
FROM Physician 
WHERE EmployeeID IN 
       (
          SELECT Physician 
          FROM Undergoes AS U 
          WHERE Date > 
               (
                  SELECT CertificationExpires 
                  FROM Trained_In AS T 
                  WHERE T.Physician = U.Physician 
                  AND T.Treatment = U.Procedure
               )
       );


SELECT P.Name 
FROM Physician AS P, Trained_In AS T, Undergoes AS U
WHERE T.Physician=U.Physician 
AND T.Treatment=U.Procedure 
AND U.Date>T.CertificationExpires 
AND P.EmployeeID=U.Physician

/* 4. Same as the previous query, but include the following information in the results: 
Physician name, name of procedure, date when the procedure was carried out, name of the patient 
the procedure was carried out on, and date when the certification expired.  */


SELECT P.Name AS Physician, Pr.Name AS Procedure, U.Date, Pt.Name AS Patient, T.CertificationExpires
FROM Physician AS P, Undergoes AS U, Patient AS Pt, Procedure AS Pr, Trained_In AS T
WHERE U.Patient = Pt.SSN
    AND U.Procedure = Pr.Code
    AND U.Physician = P.EmployeeID
    AND Pr.Code = T.Treatment
    AND P.EmployeeID = T.Physician
    AND U.Date > T.CertificationExpires;

/* 5. Obtain the information for appointments where a patient met with a physician other than his/her 
primary care physician. Show the following information: Patient name, physician name, nurse name (if any), 
start and end time of appointment, examination room, and the name of the patient's primary care physician. */


SELECT Pt.Name AS Patient, Ph.Name AS Physician, N.Name AS Nurse, A.Start, A.End, A.ExaminationRoom, PhPCP.Name AS PCP
FROM Patient AS Pt, Physician AS Ph, Physician AS PhPCP, Appointment AS A 
LEFT JOIN Nurse N ON A.PrepNurse = N.EmployeeID
WHERE A.Patient = Pt.SSN
   AND A.Physician = Ph.EmployeeID
   AND Pt.PCP = PhPCP.EmployeeID
   AND A.Physician <> Pt.PCP;

/* 6. The Patient field in Undergoes is redundant, since we can obtain it from the Stay table. 
There are no constraints in force to prevent inconsistencies between these two tables. 
More specifically, the Undergoes table may include a row where the patient ID does not match the one 
we would obtain from the Stay table through the Undergoes.Stay foreign key. Select all rows from 
Undergoes that exhibit this inconsistency. */


SELECT * 
FROM Undergoes U
WHERE Patient <> 
   (
     SELECT Patient 
     FROM Stay AS S
     WHERE U.Stay = S.StayID
   );

/* 7. Obtain the names of all the nurses who have ever been on call for room 123. */

SELECT N.Name 
FROM Nurse AS N
WHERE EmployeeID IN
   (
     SELECT OC.Nurse 
     FROM On_Call AS OC, Room AS R
     WHERE OC.BlockFloor = R.BlockFloor
     AND OC.BlockCode = R.BlockCode
     AND R.Number = 123
   );

/* 8. The hospital has several examination rooms where appointments take place. Obtain the 
number of appointments that have taken place in each examination room. */

SELECT ExaminationRoom, COUNT(AppointmentID) AS Number 
FROM Appointment
GROUP BY ExaminationRoom;

/* 9. Obtain the names of all patients (also include, for each patient, the name of the 
patient's primary care physician), such that \emph{all} the following are true:
- The patient has been prescribed some medication by his/her primary care physician.
- The patient has undergone a procedure with a cost larger that $5,000
- The patient has had at least two appointment where the nurse who prepped the appointment was a registered nurse.
- The patient's primary care physician is not the head of any department. */


SELECT Pt.Name, PhPCP.Name 
FROM Patient AS Pt, Physician AS PhPCP
WHERE Pt.PCP = PhPCP.EmployeeID
AND EXISTS
       (
         SELECT * 
         FROM Prescribes AS Pr
         WHERE Pr.Patient = Pt.SSN
         AND Pr.Physician = Pt.PCP
       )
AND EXISTS
       (
         SELECT * 
         FROM Undergoes AS U, Procedure AS Pr
         WHERE U.Procedure = Pr.Code
            AND U.Patient = Pt.SSN
            AND Pr.Cost > 5000
       )
AND 2 <=
       (
         SELECT COUNT(A.AppointmentID) 
         FROM Appointment AS A, Nurse AS N
         WHERE A.PrepNurse = N.EmployeeID
         AND N.Registered = 1
       )
AND NOT Pt.PCP IN
       (
         SELECT Head 
         FROM Department
       );
