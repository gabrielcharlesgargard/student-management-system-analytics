BEGIN TRANSACTION;

-- Insert reference data into Departments
INSERT INTO Departments(DepartmentCode,DepartmentName,Description) VALUES
('CS','Computer Science','Programming, software engineering and computing'),
('ME','Mechanical Engineering','Machines, design and thermofluids'),
('BA','Business Administration','Commerce, management and entrepreneurship'),
('MATH','Mathematics','Pure and applied mathematics');

-- Insert reference data into Semesters
INSERT INTO Semesters(SemesterName,AcademicYear,StartDate,EndDate,IsCurrent) VALUES
('Fall',2024,'2024-09-01','2024-12-15',0),
('Spring',2025,'2025-01-15','2025-05-15',1),
('Fall',2025,'2025-09-01','2025-12-15',0),
('Spring',2026,'2026-01-15','2026-05-15',0);

COMMIT;
