# 🌟 Power BI Semantic Model (Star Schema)

The dashboard utilizes a standard Kimball Star Schema architecture to ensure optimal DAX performance and intuitive filter context.

## 🏗️ Model Architecture

### Fact Tables
* **`Fact_Enrollments`**: Granular record of every student-course registration.
* **`Fact_Grades`**: 1-to-1 extension of Enrollments containing performance metrics.
* **`Fact_Financials`**: Transactional records of student invoices and payments.
* **`Fact_Attendance`**: Daily event logs of student presence.

### Dimension Tables
* **`Dim_Students`**: Contains biographic and demographic data.
* **`Dim_Courses`**: Contains curriculum metadata.
* **`Dim_Departments`**: Academic structural hierarchies.
* **`Dim_Semesters`**: Time dimension for academic term filtering.
* **`Dim_Calendar`**: Standard Power BI Date table for time-intelligence calculations.

## 🔗 Key Relationships
* `Dim_Students` (1) ─── (*) `Fact_Enrollments` (Cross-filter direction: Single)
* `Dim_Courses` (1) ─── (*) `Fact_Enrollments` (Cross-filter direction: Single)
* `Dim_Semesters` (1) ─── (*) `Fact_Enrollments` (Cross-filter direction: Single)