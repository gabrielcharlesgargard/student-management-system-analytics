--Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- 1. Reference Tables
CREATE TABLE IF NOT EXISTS Departments (
    DepartmentID INTEGER PRIMARY KEY AUTOINCREMENT,
    DepartmentCode TEXT NOT NULL UNIQUE,
    DepartmentName TEXT NOT NULL UNIQUE,
    Description TEXT,
    IsActive INTEGER NOT NULL DEFAULT 1 CHECK (IsActive IN (0,1))
);

CREATE TABLE IF NOT EXISTS Semesters (
    SemesterID INTEGER PRIMARY KEY AUTOINCREMENT,
    SemesterName TEXT NOT NULL,
    AcademicYear INTEGER NOT NULL,
    StartDate TEXT NOT NULL,
    EndDate TEXT NOT NULL,
    IsCurrent INTEGER NOT NULL DEFAULT 0 CHECK (IsCurrent IN (0,1)),
    CHECK (date(EndDate) >= date(StartDate)),
    UNIQUE (SemesterName, AcademicYear)
);

-- 2. Entity Tables
CREATE TABLE IF NOT EXISTS Students (
    StudentID INTEGER PRIMARY KEY AUTOINCREMENT,
    StudentNumber TEXT NOT NULL UNIQUE,
    FirstName TEXT NOT NULL,
    LastName TEXT NOT NULL,
    DateOfBirth TEXT,
    Gender TEXT CHECK (Gender IN ('Male','Female','Other')),
    Email TEXT UNIQUE,
    Phone TEXT,
    Address TEXT,
    DepartmentID INTEGER,
    EnrollmentDate TEXT NOT NULL DEFAULT CURRENT_DATE,
    GraduationDate TEXT,
    StudentStatus TEXT NOT NULL CHECK (StudentStatus IN ('Active','Graduated','Suspended','Withdrawn','Inactive')),
    IsActive INTEGER NOT NULL DEFAULT 1 CHECK (IsActive IN (0,1)),
    CreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE IF NOT EXISTS Courses (
    CourseID INTEGER PRIMARY KEY AUTOINCREMENT,
    CourseCode TEXT NOT NULL UNIQUE,
    CourseName TEXT NOT NULL,
    Credits REAL NOT NULL CHECK (Credits > 0),
    DepartmentID INTEGER,
    CourseLevel TEXT CHECK (CourseLevel IN ('Undergraduate','Postgraduate')),
    IsActive INTEGER NOT NULL DEFAULT 1 CHECK (IsActive IN (0,1)),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- 3. Junction & Transaction Tables
CREATE TABLE IF NOT EXISTS Enrollments (
    EnrollmentID INTEGER PRIMARY KEY AUTOINCREMENT,
    StudentID INTEGER NOT NULL,
    CourseID INTEGER NOT NULL,
    SemesterID INTEGER NOT NULL,
    EnrollmentDate TEXT NOT NULL DEFAULT CURRENT_DATE,
    EnrollmentStatus TEXT NOT NULL CHECK (EnrollmentStatus IN ('Enrolled','Completed','Dropped','Withdrawn')),
    IsDropped INTEGER NOT NULL DEFAULT 0 CHECK (IsDropped IN (0,1)),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    FOREIGN KEY (SemesterID) REFERENCES Semesters(SemesterID),
    UNIQUE (StudentID, CourseID, SemesterID)
);

CREATE TABLE IF NOT EXISTS Attendance (
    AttendanceID INTEGER PRIMARY KEY AUTOINCREMENT,
    EnrollmentID INTEGER NOT NULL,
    AttendanceDate TEXT NOT NULL,
    Status TEXT NOT NULL CHECK (Status IN ('P','A','L')),
    Remarks TEXT,
    FOREIGN KEY (EnrollmentID) REFERENCES Enrollments(EnrollmentID),
    UNIQUE (EnrollmentID, AttendanceDate)
);

CREATE TABLE IF NOT EXISTS Grades (
    GradeID INTEGER PRIMARY KEY AUTOINCREMENT,
    EnrollmentID INTEGER NOT NULL UNIQUE,
    GradeLetter TEXT CHECK (GradeLetter IN ('A','A-','B+','B','B-','C+','C','C-','D','F')),
    GradePoint REAL CHECK (GradePoint >= 0 AND GradePoint <= 4),
    Percentage REAL CHECK (Percentage >= 0 AND Percentage <= 100),
    PassFail TEXT CHECK (PassFail IN ('Pass','Fail')),
    AssessmentDate TEXT DEFAULT CURRENT_DATE,
    FOREIGN KEY (EnrollmentID) REFERENCES Enrollments(EnrollmentID)
);

CREATE TABLE IF NOT EXISTS Fees (
    FeeID INTEGER PRIMARY KEY AUTOINCREMENT,
    StudentID INTEGER NOT NULL,
    FeeType TEXT NOT NULL CHECK (FeeType IN ('Tuition','Laboratory','Library','Sports','Examination','Hostel','Other')),
    Amount REAL NOT NULL CHECK (Amount > 0),
    DueDate TEXT NOT NULL,
    PaidDate TEXT,
    PaymentMethod TEXT CHECK (PaymentMethod IN ('Cash','Card','Bank Transfer','UPI','Mobile Money','Other')),
    Status TEXT NOT NULL CHECK (Status IN ('Paid','Pending','Overdue')),
    Remarks TEXT,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);

-- 4. Performance Optimization: Indexes
CREATE INDEX IF NOT EXISTS IDX_Students_Dept ON Students(DepartmentID);
CREATE INDEX IF NOT EXISTS IDX_Students_Status ON Students(StudentStatus);
CREATE INDEX IF NOT EXISTS IDX_Students_EnrollmentDate ON Students(EnrollmentDate);
CREATE INDEX IF NOT EXISTS IDX_Courses_Dept ON Courses(DepartmentID);
CREATE INDEX IF NOT EXISTS IDX_Enrollments_Student ON Enrollments(StudentID);
CREATE INDEX IF NOT EXISTS IDX_Enrollments_Course ON Enrollments(CourseID);
CREATE INDEX IF NOT EXISTS IDX_Enrollments_Semester ON Enrollments(SemesterID);
CREATE INDEX IF NOT EXISTS IDX_Attendance_EnrollmentDate ON Attendance(EnrollmentID, AttendanceDate);
CREATE INDEX IF NOT EXISTS IDX_Grades_Enrollment ON Grades(EnrollmentID);
CREATE INDEX IF NOT EXISTS IDX_Fees_StudentStatus ON Fees(StudentID, Status);
CREATE INDEX IF NOT EXISTS IDX_Fees_DueDate ON Fees(DueDate);
