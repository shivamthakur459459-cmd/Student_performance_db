# Student_performance_db
Student Dashboard Database: Comprehensive Explanation
This document provides a detailed breakdown of the student_dashboard database script. It covers the purpose of each component, from table creation to data insertion and a step-by-step analysis of the SQL queries.

1. Script Overview
This SQL script is designed to create a simple student dashboard system. It performs the following key functions:

Creates four core tables: students, subjects, marks, and attendance.

Inserts sample data to populate the tables for demonstration and testing purposes.

Executes useful queries to derive valuable insights like average marks and attendance percentages.

Generates a database view named student_performance, which consolidates student data into a single, easy-to-query report.

2. Table-by-Table Breakdown
The script begins by dropping existing tables to ensure a clean slate for testing. The order of deletion is crucial: child tables (attendance and marks) are dropped first to avoid foreign-key constraint errors.

students Table
This table stores basic student information.

SQL

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    class VARCHAR(20)
);
student_id: A unique identifier for each student, serving as the primary key.

name and class: Basic descriptive information.

subjects Table
This table lists all the subjects offered.

SQL

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(100)
);
subject_id: A unique identifier for each subject, the primary key.

marks Table
This is a transactional table that records the marks a student obtained in a specific subject.

SQL

CREATE TABLE marks (
    mark_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    subject_id INT,
    marks_obtained INT,
    exam_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);
mark_id: An auto-incrementing primary key that uniquely identifies each mark entry.

student_id and subject_id: These are foreign keys that link to the students and subjects tables, ensuring that a mark entry always corresponds to a valid student and subject.

marks_obtained: The numerical score.

attendance Table
This table tracks a student's attendance on a daily basis.

SQL

CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    date DATE,
    status ENUM('Present', 'Absent'),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);
attendance_id: An auto-incrementing primary key.

student_id: A foreign key linking to the students table.

status: An ENUM data type that restricts values to either 'Present' or 'Absent'. This is efficient but less flexible for future changes (e.g., adding a 'Late' status).

3. Sample Data
The script inserts sample data for three students (Amit, Riya, Vikram) and three subjects (Math, Science, English). Each student has three mark entries (one per subject) and three attendance entries. This data is essential for the queries to produce meaningful results.

4. Detailed Query Analysis
Query 1: Average Marks per Student
This query calculates the average marks for each student.

SQL

SELECT s.student_id, s.name, AVG(m.marks_obtained) AS avg_marks
FROM students s
JOIN marks m ON s.student_id = m.student_id
GROUP BY s.student_id, s.name;
JOIN: It combines rows from the students and marks tables based on matching student_id values.

GROUP BY: This clause groups all the mark records for a single student, allowing the AVG() function to calculate a separate average for each student.

Manual Calculation Example (Amit):

Amit's marks: 90, 78, 85

Sum = 253

Count = 3

Average = 253 / 3 = 84.33

Query 2: Subject-wise Class Average
This query calculates the average marks for the entire class for each subject.

SQL

SELECT sub.subject_name, AVG(m.marks_obtained) AS avg_class_marks
FROM subjects sub
JOIN marks m ON sub.subject_id = m.subject_id
GROUP BY sub.subject_name;
GROUP BY: It groups all mark records by subject_name to calculate the average for each subject.

Manual Calculation Example (Math):

Math marks for all students: 90, 65, 40

Sum = 195

Count = 3

Average = 195 / 3 = 65.0

Query 3: Attendance Percentage
This query calculates the attendance percentage for each student.

SQL

SELECT 
    s.student_id, 
    s.name,
    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) * 100.0 / COUNT(*) AS attendance_percentage
FROM students s
JOIN attendance a ON s.student_id = a.student_id
GROUP BY s.student_id, s.name;
COUNT(CASE WHEN ... THEN 1 END): This is a powerful technique to count only the rows where the condition is met. The CASE statement returns 1 for 'Present' and NULL for 'Absent'. The COUNT function then only tallies the non-NULL values.

COUNT(*): This counts the total number of attendance records for each student.

* 100.0 /: Multiplying by 100.0 ensures the result is a decimal, preventing integer division.

Manual Calculation Example (Amit):

Amit's attendance: Present, Absent, Present

Number of Present entries = 2

Total entries = 3

Attendance Percentage = (2 * 100.0) / 3 = 66.67%

5. Final Report View (student_performance)
This view is the final piece of the dashboard. It consolidates all the key metrics into a single, reusable report.

SQL

CREATE OR REPLACE VIEW student_performance AS
SELECT 
    s.student_id,
    s.name,
    AVG(m.marks_obtained) AS avg_marks,
    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) * 100.0 / COUNT(*) AS attendance_percentage,
    CASE 
        WHEN AVG(m.marks_obtained) >= 85 THEN 'A'
        WHEN AVG(m.marks_obtained) >= 70 THEN 'B'
        WHEN AVG(m.marks_obtained) >= 50 THEN 'C'
        ELSE 'D'
    END AS grade
FROM students s
JOIN marks m ON s.student_id = m.student_id
JOIN attendance a ON s.student_id = a.student_id
GROUP BY s.student_id, s.name;
CREATE OR REPLACE VIEW: This command creates a virtual table. If a view with the same name already exists, it will be replaced.

JOIN marks and JOIN attendance: It combines data from all three tables (students, marks, attendance) to pull all necessary information for the report.

CASE ... END: This is a conditional statement that assigns a grade based on a student's average marks.

Output: Running SELECT * FROM student_performance; will produce a clean, comprehensive report for each student, including their average marks, attendance percentage, and a calculated grade.

Expected Output for Sample Data:

Amit:

Average Marks: 84.33

Attendance %: 66.67

Grade: 'B'

Riya:

Average Marks: 65.00

Attendance %: 100.00

Grade: 'C'

Vikram:

Average Marks: 48.33

Attendance %: 33.33

Grade: 'D'
