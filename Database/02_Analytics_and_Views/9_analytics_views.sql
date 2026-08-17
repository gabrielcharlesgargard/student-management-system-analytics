DROP VIEW IF EXISTS vw_StudentProfile;
DROP VIEW IF EXISTS vw_StudentAcademicPerformance;
DROP VIEW IF EXISTS vw_AttendanceSummary;
DROP VIEW IF EXISTS vw_FeeSummary;
DROP VIEW IF EXISTS vw_CoursePerformance;
DROP VIEW IF EXISTS vw_DepartmentPerformance;
DROP VIEW IF EXISTS vw_StudentRisk;

-- View 1: Comprehensive Academic Summary
-- Purpose: Denormalizes student performance for Power BI
CREATE VIEW vw_StudentProfile AS
SELECT s.StudentID, s.StudentNumber, s.FirstName, s.LastName,
       s.FirstName || ' ' || s.LastName AS FullName,
       s.DateOfBirth, s.Gender, s.Email, s.Phone, s.Address,
       d.DepartmentID, d.DepartmentCode, d.DepartmentName,
       s.EnrollmentDate, s.GraduationDate, s.StudentStatus, s.IsActive
FROM Students s
LEFT JOIN Departments d ON d.DepartmentID = s.DepartmentID;

CREATE VIEW vw_StudentAcademicPerformance AS
SELECT
    s.StudentID, s.StudentNumber, s.FirstName || ' ' || s.LastName AS FullName,
    d.DepartmentName, c.CourseID, c.CourseCode, c.CourseName, c.Credits,
    sem.SemesterID, sem.SemesterName, sem.AcademicYear,
    e.EnrollmentID, e.EnrollmentStatus,
    g.Percentage, g.GradeLetter, g.GradePoint, g.PassFail, g.AssessmentDate
FROM Enrollments e
JOIN Students s ON s.StudentID = e.StudentID
JOIN Courses c ON c.CourseID = e.CourseID
JOIN Departments d ON d.DepartmentID = s.DepartmentID
JOIN Semesters sem ON sem.SemesterID = e.SemesterID
LEFT JOIN Grades g ON g.EnrollmentID = e.EnrollmentID;

CREATE VIEW vw_AttendanceSummary AS
SELECT
    s.StudentID, s.StudentNumber, s.FirstName || ' ' || s.LastName AS FullName,
    d.DepartmentName, sem.SemesterID, sem.SemesterName, sem.AcademicYear,
    COUNT(a.AttendanceID) AS AttendanceRecords,
    SUM(CASE WHEN a.Status='P' THEN 1 ELSE 0 END) AS PresentCount,
    SUM(CASE WHEN a.Status='A' THEN 1 ELSE 0 END) AS AbsentCount,
    SUM(CASE WHEN a.Status='L' THEN 1 ELSE 0 END) AS LateCount,
    ROUND(100.0 * SUM(CASE WHEN a.Status='P' THEN 1 ELSE 0 END) /
          NULLIF(COUNT(a.AttendanceID),0), 2) AS AttendancePct
FROM Students s
LEFT JOIN Departments d ON d.DepartmentID = s.DepartmentID
LEFT JOIN Enrollments e ON e.StudentID = s.StudentID
LEFT JOIN Semesters sem ON sem.SemesterID = e.SemesterID
LEFT JOIN Attendance a ON a.EnrollmentID = e.EnrollmentID
GROUP BY s.StudentID, sem.SemesterID;

CREATE VIEW vw_FeeSummary AS
SELECT
    s.StudentID, s.StudentNumber, s.FirstName || ' ' || s.LastName AS FullName,
    d.DepartmentName,
    COUNT(f.FeeID) AS FeeItems,
    ROUND(COALESCE(SUM(f.Amount),0),2) AS TotalFees,
    ROUND(COALESCE(SUM(CASE WHEN f.Status='Paid' THEN f.Amount ELSE 0 END),0),2) AS CollectedFees,
    ROUND(COALESCE(SUM(CASE WHEN f.Status='Pending' THEN f.Amount ELSE 0 END),0),2) AS PendingFees,
    ROUND(COALESCE(SUM(CASE WHEN f.Status='Overdue' THEN f.Amount ELSE 0 END),0),2) AS OverdueFees,
    ROUND(100.0 * COALESCE(SUM(CASE WHEN f.Status='Paid' THEN f.Amount ELSE 0 END),0) /
          NULLIF(SUM(f.Amount),0),2) AS CollectionRatePct
FROM Students s
LEFT JOIN Departments d ON d.DepartmentID=s.DepartmentID
LEFT JOIN Fees f ON f.StudentID=s.StudentID
GROUP BY s.StudentID;

CREATE VIEW vw_CoursePerformance AS
SELECT
    c.CourseID, c.CourseCode, c.CourseName, c.Credits,
    d.DepartmentName,
    COUNT(e.EnrollmentID) AS Enrollments,
    COUNT(g.GradeID) AS GradedStudents,
    ROUND(AVG(g.Percentage),2) AS AvgPercentage,
    ROUND(AVG(g.GradePoint),2) AS AvgGradePoint,
    SUM(CASE WHEN g.PassFail='Pass' THEN 1 ELSE 0 END) AS Passed,
    SUM(CASE WHEN g.PassFail='Fail' THEN 1 ELSE 0 END) AS Failed,
    ROUND(100.0 * SUM(CASE WHEN g.PassFail='Pass' THEN 1 ELSE 0 END) /
          NULLIF(COUNT(g.GradeID),0),2) AS PassRatePct
FROM Courses c
LEFT JOIN Departments d ON d.DepartmentID=c.DepartmentID
LEFT JOIN Enrollments e ON e.CourseID=c.CourseID
LEFT JOIN Grades g ON g.EnrollmentID=e.EnrollmentID
GROUP BY c.CourseID;

CREATE VIEW vw_DepartmentPerformance AS
WITH acad AS (
    SELECT d.DepartmentID,
           ROUND(AVG(g.GradePoint),2) AS AvgGPA,
           ROUND(100.0*SUM(CASE WHEN g.PassFail='Pass' THEN 1 ELSE 0 END)/
                 NULLIF(COUNT(g.GradeID),0),2) AS PassRatePct
    FROM Departments d
    LEFT JOIN Students s ON s.DepartmentID=d.DepartmentID
    LEFT JOIN Enrollments e ON e.StudentID=s.StudentID
    LEFT JOIN Grades g ON g.EnrollmentID=e.EnrollmentID
    GROUP BY d.DepartmentID
),
fee_agg AS (
    SELECT d.DepartmentID,
           ROUND(COALESCE(SUM(f.Amount),0),2) AS TotalFees,
           ROUND(COALESCE(SUM(CASE WHEN f.Status='Paid' THEN f.Amount ELSE 0 END),0),2) AS CollectedFees
    FROM Departments d
    LEFT JOIN Students s ON s.DepartmentID=d.DepartmentID
    LEFT JOIN Fees f ON f.StudentID=s.StudentID
    GROUP BY d.DepartmentID
)
SELECT d.DepartmentID,d.DepartmentCode,d.DepartmentName,
       COUNT(DISTINCT s.StudentID) AS TotalStudents,
       a.AvgGPA,a.PassRatePct,f.TotalFees,f.CollectedFees,
       ROUND(100.0*fa.CollectedFees/NULLIF(fa.TotalFees,0),2) AS CollectionRatePct
FROM Departments d
LEFT JOIN Students s ON s.DepartmentID=d.DepartmentID
LEFT JOIN acad a ON a.DepartmentID=d.DepartmentID
LEFT JOIN fee_agg fa ON fa.DepartmentID=d.DepartmentID
GROUP BY d.DepartmentID;

CREATE VIEW vw_StudentRisk AS
WITH acad AS (
    SELECT s.StudentID,
           COALESCE(AVG(g.GradePoint),0) AS AvgGPA,
           SUM(CASE WHEN g.PassFail='Fail' THEN 1 ELSE 0 END) AS FailedCourses,
           COUNT(g.GradeID) AS GradedCourses
    FROM Students s
    LEFT JOIN Enrollments e ON e.StudentID=s.StudentID
    LEFT JOIN Grades g ON g.EnrollmentID=e.EnrollmentID
    GROUP BY s.StudentID
),
att AS (
    SELECT s.StudentID,
           100.0*SUM(CASE WHEN a.Status='P' THEN 1 ELSE 0 END)/
           NULLIF(COUNT(a.AttendanceID),0) AS AttendancePct
    FROM Students s
    LEFT JOIN Enrollments e ON e.StudentID=s.StudentID
    LEFT JOIN Attendance a ON a.EnrollmentID=e.EnrollmentID
    GROUP BY s.StudentID
),
fee_agg AS (
    SELECT s.StudentID,
           COALESCE(SUM(CASE WHEN f.Status='Overdue' THEN f.Amount ELSE 0 END),0) AS OverdueFees
    FROM Students s LEFT JOIN Fees f ON f.StudentID=s.StudentID
    GROUP BY s.StudentID
)
SELECT s.StudentID,s.StudentNumber,s.FirstName||' '||s.LastName AS FullName,
       d.DepartmentName, s.StudentStatus,
       ROUND(a.AvgGPA,2) AS AvgGPA,
       a.FailedCourses, a.GradedCourses,
       ROUND(COALESCE(t.AttendancePct,100),2) AS AttendancePct,
       ROUND(fa.OverdueFees,2) AS OverdueFees,
       CASE
         WHEN a.AvgGPA < 2.0 OR a.FailedCourses >= 2 OR COALESCE(t.AttendancePct,100) < 60 THEN 'High Risk'
         WHEN a.AvgGPA < 2.5 OR COALESCE(t.AttendancePct,100) < 75 OR fa.OverdueFees > 50000 THEN 'Medium Risk'
         ELSE 'Low Risk'
       END AS RiskClassification
FROM Students s
LEFT JOIN Departments d ON d.DepartmentID=s.DepartmentID
JOIN acad a ON a.StudentID=s.StudentID
JOIN att t ON t.StudentID=s.StudentID
JOIN fee_agg fa ON fa.StudentID=s.StudentID;
