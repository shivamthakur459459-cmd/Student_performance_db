CREATE DATABASE student_dashboard;
USE student_dashboard;


-- Drop tables if already exist (to avoid errors while testing)
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS marks;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS students;

-- 1. Students Table
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    class VARCHAR(20)
);

-- 2. Subjects Table
CREATE TABLE subjects (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(100)
);

-- 3. Marks Table
CREATE TABLE marks (
    mark_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    subject_id INT,
    marks_obtained INT,
    exam_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- 4. Attendance Table
CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    date DATE,
    status ENUM('Present', 'Absent'),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

-- -----------------------------
-- Insert Sample Data
-- -----------------------------

-- Students
INSERT INTO students VALUES
(1, 'Amit', '10A'),
(2, 'Riya', '10A'),
(3, 'Vikram', '10A');

-- Subjects
INSERT INTO subjects VALUES
(101, 'Math'),
(102, 'Science'),
(103, 'English');

-- Marks
INSERT INTO marks (student_id, subject_id, marks_obtained, exam_date) VALUES
(1, 101, 90, '2025-03-01'),
(1, 102, 78, '2025-03-02'),
(1, 103, 85, '2025-03-03'),
(2, 101, 65, '2025-03-01'),
(2, 102, 70, '2025-03-02'),
(2, 103, 60, '2025-03-03'),
(3, 101, 40, '2025-03-01'),
(3, 102, 55, '2025-03-02'),
(3, 103, 50, '2025-03-03');

-- Attendance
INSERT INTO attendance (student_id, date, status) VALUES
(1, '2025-03-01', 'Present'),
(1, '2025-03-02', 'Absent'),
(1, '2025-03-03', 'Present'),
(2, '2025-03-01', 'Present'),
(2, '2025-03-02', 'Present'),
(2, '2025-03-03', 'Present'),
(3, '2025-03-01', 'Absent'),
(3, '2025-03-02', 'Present'),
(3, '2025-03-03', 'Absent');

-- -----------------------------
-- Useful Queries
-- -----------------------------

-- 1. Average Marks per Student
SELECT s.student_id, s.name, AVG(m.marks_obtained) AS avg_marks
FROM students s
JOIN marks m ON s.student_id = m.student_id
GROUP BY s.student_id, s.name;

-- 2. Subject-wise Class Average
SELECT sub.subject_name, AVG(m.marks_obtained) AS avg_class_marks
FROM subjects sub
JOIN marks m ON sub.subject_id = m.subject_id
GROUP BY sub.subject_name;

-- 3. Attendance Percentage
SELECT 
    s.student_id, 
    s.name,
    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) * 100.0 / COUNT(*) AS attendance_percentage
FROM students s
JOIN attendance a ON s.student_id = a.student_id
GROUP BY s.student_id, s.name;

-- 4. Final Report with Grade
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
select * from student_performance;
