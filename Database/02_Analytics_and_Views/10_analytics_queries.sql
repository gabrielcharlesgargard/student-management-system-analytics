-- 20 Advanced SQLite Analytics Queries

-- 01. Top 10 students by GPA
WITH x AS (
 SELECT StudentNumber,FullName,AvgGPA,
        RANK() OVER(ORDER BY AvgGPA DESC) AS GPArank
 FROM vw_StudentRisk WHERE GradedCourses>0
) SELECT * FROM x WHERE GPArank<=10 ORDER BY GPArank;

-- 02. Department performance
SELECT * FROM vw_DepartmentPerformance ORDER BY AvgGPA DESC;

-- 03. Course pass rate
SELECT CourseCode,CourseName,GradedStudents,Passed,Failed,PassRatePct
FROM vw_CoursePerformance WHERE GradedStudents>5 ORDER BY PassRatePct;

-- 04. GPA quartile-style ranking by department
SELECT DepartmentName,StudentNumber,FullName,AvgGPA,
       NTILE(4) OVER(PARTITION BY DepartmentName ORDER BY AvgGPA DESC) AS GPAQuartile
FROM vw_StudentRisk WHERE GradedCourses>0;

-- 05. Students below attendance threshold
SELECT * FROM vw_StudentRisk WHERE AttendancePct<75 ORDER BY AttendancePct;

-- 06. High-risk students with financial exposure
SELECT StudentNumber,FullName,AvgGPA,AttendancePct,FailedCourses,OverdueFees
FROM vw_StudentRisk WHERE RiskClassification='High Risk' ORDER BY OverdueFees DESC;

-- 07. Fee collection by department
SELECT DepartmentName,TotalFees,CollectedFees,
       ROUND(100.0*CollectedFees/NULLIF(TotalFees,0),2) AS CollectionRatePct
FROM vw_DepartmentPerformance ORDER BY CollectionRatePct;

-- 08. Overdue fees by type
SELECT FeeType,COUNT(*) AS Items,SUM(Amount) AS OverdueAmount
FROM Fees WHERE Status='Overdue' GROUP BY FeeType ORDER BY OverdueAmount DESC;

-- 09. Enrollment trends by semester
SELECT sem.AcademicYear,sem.SemesterName,COUNT(*) AS Enrollments
FROM Enrollments e JOIN Semesters sem ON sem.SemesterID=e.SemesterID
GROUP BY sem.AcademicYear,sem.SemesterName ORDER BY sem.AcademicYear,sem.SemesterName;

-- 10. Most popular courses
SELECT c.CourseCode,c.CourseName,COUNT(e.EnrollmentID) AS EnrollmentCount
FROM Courses c LEFT JOIN Enrollments e ON e.CourseID=c.CourseID
GROUP BY c.CourseID ORDER BY EnrollmentCount DESC LIMIT 10;

-- 11. Grade distribution
SELECT GradeLetter,COUNT(*) AS CountOfGrades,
       ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM Grades),2) AS SharePct
FROM Grades GROUP BY GradeLetter ORDER BY CountOfGrades DESC;

-- 12. Students with repeated failures
SELECT s.StudentNumber,s.FirstName||' '||s.LastName AS FullName,
       COUNT(*) AS FailedCourses
FROM Students s JOIN Enrollments e ON e.StudentID=s.StudentID
JOIN Grades g ON g.EnrollmentID=e.EnrollmentID
WHERE g.PassFail='Fail'
GROUP BY s.StudentID HAVING COUNT(*)>=2 ORDER BY FailedCourses DESC;

-- 13. GPA vs attendance correlation-ready dataset
SELECT r.StudentNumber,r.AvgGPA,r.AttendancePct,r.FailedCourses
FROM vw_StudentRisk r WHERE r.GradedCourses>0;

-- 14. Fee aging buckets
SELECT
 CASE
  WHEN julianday('now')-julianday(DueDate)<=30 THEN '0-30 days'
  WHEN julianday('now')-julianday(DueDate)<=60 THEN '31-60 days'
  WHEN julianday('now')-julianday(DueDate)<=90 THEN '61-90 days'
  ELSE '90+ days' END AS AgingBucket,
 SUM(Amount) AS Amount
FROM Fees WHERE Status='Overdue' GROUP BY AgingBucket ORDER BY AgingBucket;

-- 15. Active students by department
SELECT d.DepartmentName,COUNT(*) AS ActiveStudents
FROM Students s JOIN Departments d ON d.DepartmentID=s.DepartmentID
WHERE s.StudentStatus='Active' GROUP BY d.DepartmentID ORDER BY ActiveStudents DESC;

-- 16. Course difficulty index
SELECT CourseCode,CourseName,
       ROUND(100.0*Failed/NULLIF(GradedStudents,0),2) AS FailureRatePct,
       ROUND(AvgPercentage,2) AS AvgPercentage
FROM vw_CoursePerformance WHERE GradedStudents>0
ORDER BY FailureRatePct DESC;

-- 17. Semester GPA
SELECT sem.AcademicYear,sem.SemesterName,ROUND(AVG(g.GradePoint),2) AS AvgGPA
FROM Semesters sem JOIN Enrollments e ON e.SemesterID=sem.SemesterID
JOIN Grades g ON g.EnrollmentID=e.EnrollmentID
GROUP BY sem.SemesterID ORDER BY sem.AcademicYear,sem.SemesterName;

-- 18. Students with outstanding balances
SELECT StudentNumber,FullName,TotalFees,PendingFees,OverdueFees
FROM vw_FeeSummary WHERE PendingFees+OverdueFees>0
ORDER BY (PendingFees+OverdueFees) DESC;

-- 19. Department student risk mix
SELECT DepartmentName,RiskClassification,COUNT(*) AS Students
FROM vw_StudentRisk GROUP BY DepartmentName,RiskClassification
ORDER BY DepartmentName,Students DESC;

-- 20. Data completeness score
SELECT
 ROUND(100.0*SUM(CASE WHEN FirstName IS NOT NULL AND LastName IS NOT NULL
                       AND Email IS NOT NULL AND DepartmentID IS NOT NULL THEN 1 ELSE 0 END)
       /COUNT(*),2) AS StudentCompletenessPct
FROM Students;
