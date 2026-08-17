# 🧩 Entity Relationship Diagram (ERD)

The following diagram illustrates the normalized relational architecture (3NF) of the Student Management System. It highlights the primary key (PK) and foreign key (FK) mappings that ensure referential integrity across the data model.

```mermaid
erDiagram
    Departments {
        INTEGER DepartmentID PK
        TEXT DepartmentCode
        TEXT DepartmentName
    }
    Students {
        INTEGER StudentID PK
        TEXT FirstName
        TEXT LastName
        INTEGER DepartmentID FK
    }
    Courses {
        INTEGER CourseID PK
        TEXT CourseCode
        INTEGER DepartmentID FK
    }
    Semesters {
        INTEGER SemesterID PK
        TEXT TermName
    }
    Enrollments {
        INTEGER EnrollmentID PK
        INTEGER StudentID FK
        INTEGER CourseID FK
        INTEGER SemesterID FK
    }
    Grades {
        INTEGER GradeID PK
        INTEGER EnrollmentID FK
        REAL GPAPoints
    }
    Attendance {
        INTEGER AttendanceID PK
        INTEGER EnrollmentID FK
        TEXT AttendanceStatus
    }
    Fees {
        INTEGER FeeID PK
        INTEGER StudentID FK
        REAL AmountOwed
    }

    Departments ||--o{ Students : "houses"
    Departments ||--o{ Courses : "offers"
    Students ||--o{ Enrollments : "undertakes"
    Courses ||--o{ Enrollments : "includes"
    Semesters ||--o{ Enrollments : "hosts"
    Enrollments ||--|| Grades : "earns"
    Enrollments ||--o{ Attendance : "tracks"
    Students ||--o{ Fees : "owes"
```