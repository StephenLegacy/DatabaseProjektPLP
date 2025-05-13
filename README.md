# Library Management System - MySQL Database

## Project Overview
I'll create a comprehensive Library Management System database that tracks books, members, loans, and other essential library operations. This system will handle:
- Book inventory management
- Member registrations
- Loan tracking with due dates
- Fines for overdue books
- Library staff management

## Database Schema (ERD)


- CHECK dbImplementation.sql for complete project code

## How to Use This Database

1. **Installation**:
   - Ensure MySQL Server is installed
   - Create a new database or use an existing one

2. **Setup**:
   - Save the SQL script to a file (e.g., `library_management.sql`)
   - Execute the script in MySQL:
     ```
     mysql -u username -p < library_management.sql
     ```

3. **Features**:
   - Automatic quantity management via triggers
   - Overdue fine calculation
   - Data integrity constraints
   - Relationship enforcement

4. **ERD Generation**:
   - Use MySQL Workbench's reverse engineering feature
   - Or import into a modeling tool like Lucidchart

## Key Design Decisions

1. **Normalization**:
   - Separated authors into their own table for M-M relationships
   - Normalized loan and fine tracking

2. **Constraints**:
   - Added CHECK constraints for data validation
   - Used appropriate data types for each field

3. **Automation**:
   - Implemented triggers for:
     - Book availability updates
     - Overdue detection
     - Fine calculation

4. **Scalability**:
   - Designed for easy expansion (additional tables can be added)
   - Used appropriate indexing (PKs and FKs)
