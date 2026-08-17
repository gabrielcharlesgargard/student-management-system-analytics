# 🎓 Capstone Analytics & Project Report

**Lead Analyst & Engineer:** Gabriel Charles Gargard  
**Academic Program:** Bachelor of Computer Applications (BCA)  
**Project Scope:** End-to-End Business Intelligence & Relational Database Architecture

## 1. Project Objectives
The primary objective of this project was to design a robust, scalable data architecture capable of transforming raw institutional records into a centralized source of truth. The system was engineered to answer complex business questions regarding academic performance variance, financial risk, and student retention.

## 2. Methodology & Implementation
* **Phase 1: Architecture:** Designed a fully normalized (3NF) relational database utilizing SQLite, enforcing strict referential integrity and optimized indexing.
* **Phase 2: Data Engineering:** Developed comprehensive SQL DDL and DML scripts to scaffold the schema and populate synthetic institutional data.
* **Phase 3: Analytical Modeling:** Engineered complex SQL views utilizing Common Table Expressions (CTEs) and Window Functions to create pre-aggregated data marts.
* **Phase 4: Business Intelligence:** Ingested the SQL data marts into Power BI, constructing a Kimball Star Schema and deploying advanced DAX measures for dynamic time-intelligence and risk classification.

## 3. Key Outcomes & Insights
* **Risk Mitigation:** Successfully correlated attendance drop-offs with GPA decline, providing a predictive framework for early intervention.
* **Financial Forecasting:** Automated the tracking of overdue accounts, delivering a clear 30-day revenue recovery pipeline.
* **System Scalability:** The decoupled nature of the SQL backend and the Power BI semantic model ensures the system can seamlessly scale to handle millions of rows without performance degradation.