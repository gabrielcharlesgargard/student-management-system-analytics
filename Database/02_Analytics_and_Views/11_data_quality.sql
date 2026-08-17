-- Data Quality & Integrity Checks

-- 01 Duplicate student numbers
SELECT StudentNumber,COUNT(*) AS DuplicateCount
FROM Students GROUP BY StudentNumber HAVING COUNT(*)>1;

-- 02 Duplicate emails
SELECT Email,COUNT(*) AS DuplicateCount
FROM Students WHERE Email IS NOT NULL GROUP BY Email HAVING COUNT(*)>1;

-- 03 Orphaned enrollments
SELECT e.* FROM Enrollments e
LEFT JOIN Students s ON s.StudentID=e.StudentID
WHERE s.StudentID IS NULL;

-- 04 Orphaned grades
SELECT g.* FROM Grades g
LEFT JOIN Enrollments e ON e.EnrollmentID=g.EnrollmentID
WHERE e.EnrollmentID IS NULL;

-- 05 Invalid percentages
SELECT * FROM Grades WHERE Percentage<0 OR Percentage>100;

-- 06 Invalid GPA points
SELECT * FROM Grades WHERE GradePoint<0 OR GradePoint>4;

-- 07 Fee consistency
SELECT * FROM Fees
WHERE (Status='Paid' AND PaidDate IS NULL)
   OR (Status<>'Paid' AND PaidDate IS NOT NULL);

-- 08 Invalid date ranges
SELECT * FROM Semesters WHERE date(EndDate)<date(StartDate);

-- 09 Attendance status validation
SELECT * FROM Attendance WHERE Status NOT IN ('P','A','L');

-- 10 Foreign key violations
PRAGMA foreign_key_check;

-- 11 Enrollment duplicates
SELECT StudentID,CourseID,SemesterID,COUNT(*) AS DuplicateCount
FROM Enrollments GROUP BY StudentID,CourseID,SemesterID HAVING COUNT(*)>1;

-- 12 Missing department assignments
SELECT * FROM Students WHERE DepartmentID IS NULL;
