# 📖 System Data Dictionary

This document outlines the schema definitions, data types, constraints, and business logic for the core tables within the Student Management System database.

## 1. Reference Dimensions

### `Departments`
Defines the academic divisions within the institution.
| Column | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `DepartmentID` | INTEGER | PK, Auto-increment | Unique identifier for the department. |
| `DepartmentCode` | TEXT | Not Null, Unique | Short alphanumeric code (e.g., 'CS', 'BA'). |
| `DepartmentName` | TEXT | Not Null | Full official name of the department. |

### `Semesters`
Tracks academic terms for historical and current enrollment filtering.
| Column | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `SemesterID` | INTEGER | PK, Auto-increment | Unique identifier for the term. |
| `TermName` | TEXT | Not Null | Descriptive nomenclature (e.g., 'Spring 2026'). |
| `StartDate` | DATE | Not Null | Official commencement date of the term. |
| `EndDate` | DATE | Not Null | Official conclusion date of the term. |
| `IsActive` | BOOLEAN | Default 0 | Binary flag indicating the current ongoing term. |

## 2. Core Entities

### `Students`
Stores primary biographical and academic standing data.
| Column | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `StudentID` | INTEGER | PK, Auto-increment | Unique identifier for the student. |
| `FirstName` | TEXT | Not Null | Student's legal first name. |
| `LastName` | TEXT | Not Null | Student's legal last name. |
| `Email` | TEXT | Not Null, Unique | Institutional email address. |
| `DepartmentID` | INTEGER | FK | Links to `Departments(DepartmentID)`. |
| `StudentStatus` | TEXT | Check constraint | Restricted to: 'Active', 'Suspended', 'Graduated', 'Dropped'. |

### `Courses`
Details the academic curriculum offerings.
| Column | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `CourseID` | INTEGER | PK, Auto-increment | Unique identifier for the course. |
| `CourseCode` | TEXT | Not Null, Unique | Subject and number designation (e.g., 'CS101'). |
| `Credits` | INTEGER | Check (> 0) | Academic credit value towards graduation. |
| `DepartmentID` | INTEGER | FK | Links to `Departments(DepartmentID)`. |

## 3. Transactional & Junction Tables

### `Enrollments`
The central junction mapping students to classes per term.
| Column | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `EnrollmentID` | INTEGER | PK, Auto-increment | Unique identifier for the class registration. |
| `StudentID` | INTEGER | FK | Links to `Students`. |
| `CourseID` | INTEGER | FK | Links to `Courses`. |
| `SemesterID` | INTEGER | FK | Links to `Semesters`. |
*(Note: A composite UNIQUE constraint exists on StudentID, CourseID, and SemesterID to prevent duplicate registrations).*

### `Grades`
Records academic performance. Maintains a 1-to-1 relationship with Enrollments.
| Column | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `GradeID` | INTEGER | PK, Auto-increment | Unique identifier for the grade record. |
| `EnrollmentID` | INTEGER | FK, Unique | Links to `Enrollments`. |
| `GPAPoints` | REAL | Check (0.0 - 4.0) | Standardized 4.0 scale point system for analytics. |

### `Fees`
Tracks student financial accounts independent of specific courses.
| Column | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `FeeID` | INTEGER | PK, Auto-increment | Unique identifier for the invoice. |
| `StudentID` | INTEGER | FK | Links to `Students`. |
| `AmountOwed` | REAL | Check (>= 0) | Total invoice amount. |
| `AmountPaid` | REAL | Default 0 | Amount credited to the account. |
| `PaymentStatus`| TEXT | Check constraint | Restricted to: 'Paid', 'Pending', 'Overdue'. |