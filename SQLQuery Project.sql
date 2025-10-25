-- ============================================================
-- HOSPITAL MANAGEMENT SYSTEM - SQL SERVER VERSION
-- Compatible with Microsoft SQL Server 2012+
-- ============================================================

-- Create database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'hospital_db')
BEGIN
    CREATE DATABASE hospital_db;
END
GO

USE hospital_db;
GO

-- Drop tables if they exist (in correct order)
IF OBJECT_ID('Prescriptions', 'U') IS NOT NULL DROP TABLE Prescriptions;
IF OBJECT_ID('Lab_Tests', 'U') IS NOT NULL DROP TABLE Lab_Tests;
IF OBJECT_ID('Billing', 'U') IS NOT NULL DROP TABLE Billing;
IF OBJECT_ID('Medical_Records', 'U') IS NOT NULL DROP TABLE Medical_Records;
IF OBJECT_ID('Appointments', 'U') IS NOT NULL DROP TABLE Appointments;
IF OBJECT_ID('Room_Assignments', 'U') IS NOT NULL DROP TABLE Room_Assignments;
IF OBJECT_ID('Rooms', 'U') IS NOT NULL DROP TABLE Rooms;
IF OBJECT_ID('Inventory', 'U') IS NOT NULL DROP TABLE Inventory;
IF OBJECT_ID('Staff', 'U') IS NOT NULL DROP TABLE Staff;
IF OBJECT_ID('Doctors', 'U') IS NOT NULL DROP TABLE Doctors;
IF OBJECT_ID('Patients', 'U') IS NOT NULL DROP TABLE Patients;
IF OBJECT_ID('Departments', 'U') IS NOT NULL DROP TABLE Departments;
GO

-- ============================================================
-- TABLE CREATION
-- ============================================================

-- 1. Departments Table
CREATE TABLE Departments (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    department_head VARCHAR(100),
    location VARCHAR(100),
    contact_number VARCHAR(15),
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 2. Patients Table
CREATE TABLE Patients (
    patient_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    blood_group VARCHAR(5),
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    address VARCHAR(MAX),
    emergency_contact VARCHAR(15),
    insurance_id VARCHAR(50),
    registration_date DATE,
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 3. Doctors Table
CREATE TABLE Doctors (
    doctor_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    department_id INT,
    qualification VARCHAR(200),
    experience_years INT,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    consultation_fee DECIMAL(10, 2),
    availability_schedule VARCHAR(200),
    joined_date DATE,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);
GO

-- 4. Staff Table
CREATE TABLE Staff (
    staff_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    department_id INT,
    phone VARCHAR(15),
    email VARCHAR(100),
    salary DECIMAL(10, 2),
    hire_date DATE,
    shift_timing VARCHAR(50),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);
GO

-- 5. Rooms Table
CREATE TABLE Rooms (
    room_id INT IDENTITY(1,1) PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type VARCHAR(50) NOT NULL,
    department_id INT,
    bed_capacity INT DEFAULT 1,
    current_occupancy INT DEFAULT 0,
    daily_rate DECIMAL(10, 2),
    status VARCHAR(20) DEFAULT 'Available',
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);
GO

-- 6. Appointments Table
CREATE TABLE Appointments (
    appointment_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    reason VARCHAR(MAX),
    status VARCHAR(20) DEFAULT 'Scheduled',
    notes VARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);
GO

-- 7. Room Assignments Table
CREATE TABLE Room_Assignments (
    assignment_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    room_id INT NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE,
    reason VARCHAR(MAX),
    doctor_id INT,
    status VARCHAR(20) DEFAULT 'Active',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);
GO

-- 8. Medical Records Table
CREATE TABLE Medical_Records (
    record_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    visit_date DATE NOT NULL,
    diagnosis VARCHAR(MAX),
    symptoms VARCHAR(MAX),
    treatment VARCHAR(MAX),
    vital_signs VARCHAR(MAX),
    follow_up_date DATE,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);
GO

-- 9. Prescriptions Table
CREATE TABLE Prescriptions (
    prescription_id INT IDENTITY(1,1) PRIMARY KEY,
    record_id INT NOT NULL,
    medicine_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50),
    frequency VARCHAR(50),
    duration VARCHAR(50),
    instructions VARCHAR(MAX),
    FOREIGN KEY (record_id) REFERENCES Medical_Records(record_id)
);
GO

-- 10. Lab Tests Table
CREATE TABLE Lab_Tests (
    test_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    test_name VARCHAR(100) NOT NULL,
    test_date DATE NOT NULL,
    result VARCHAR(MAX),
    status VARCHAR(20) DEFAULT 'Pending',
    cost DECIMAL(10, 2),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);
GO

-- 11. Billing Table
CREATE TABLE Billing (
    bill_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT,
    room_assignment_id INT,
    consultation_fee DECIMAL(10, 2) DEFAULT 0,
    room_charges DECIMAL(10, 2) DEFAULT 0,
    lab_charges DECIMAL(10, 2) DEFAULT 0,
    medicine_charges DECIMAL(10, 2) DEFAULT 0,
    other_charges DECIMAL(10, 2) DEFAULT 0,
    total_amount AS (consultation_fee + room_charges + lab_charges + medicine_charges + other_charges),
    payment_status VARCHAR(20) DEFAULT 'Pending',
    payment_date DATE,
    payment_method VARCHAR(50),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id),
    FOREIGN KEY (room_assignment_id) REFERENCES Room_Assignments(assignment_id)
);
GO

-- 12. Inventory Table
CREATE TABLE Inventory (
    item_id INT IDENTITY(1,1) PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2),
    supplier_name VARCHAR(100),
    expiry_date DATE,
    minimum_stock INT DEFAULT 10,
    last_restocked DATE,
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- ============================================================
-- INSERT SAMPLE DATA
-- ============================================================

-- Insert Departments
SET IDENTITY_INSERT Departments ON;
INSERT INTO Departments (department_id, department_name, department_head, location, contact_number) VALUES
(1, 'Cardiology', 'Dr. Sarah Johnson', 'Building A - Floor 3', '555-0101'),
(2, 'Neurology', 'Dr. Michael Chen', 'Building B - Floor 2', '555-0102'),
(3, 'Orthopedics', 'Dr. Robert Williams', 'Building A - Floor 1', '555-0103'),
(4, 'Pediatrics', 'Dr. Emily Davis', 'Building C - Floor 2', '555-0104'),
(5, 'Emergency', 'Dr. James Martinez', 'Building A - Ground Floor', '555-0105'),
(6, 'Radiology', 'Dr. Lisa Anderson', 'Building B - Basement', '555-0106'),
(7, 'Laboratory', 'Dr. David Thompson', 'Building B - Floor 1', '555-0107'),
(8, 'Pharmacy', 'Ms. Jennifer White', 'Building A - Ground Floor', '555-0108');
SET IDENTITY_INSERT Departments OFF;
GO

-- Insert Patients
SET IDENTITY_INSERT Patients ON;
INSERT INTO Patients (patient_id, first_name, last_name, date_of_birth, gender, blood_group, phone, email, address, emergency_contact, insurance_id, registration_date) VALUES
(1, 'John', 'Smith', '1985-03-15', 'Male', 'O+', '555-1001', 'john.smith@email.com', '123 Main St, City', '555-1002', 'INS001', '2024-01-10'),
(2, 'Mary', 'Johnson', '1990-07-22', 'Female', 'A+', '555-1003', 'mary.j@email.com', '456 Oak Ave, City', '555-1004', 'INS002', '2024-02-15'),
(3, 'Robert', 'Brown', '1978-11-30', 'Male', 'B+', '555-1005', 'rbrown@email.com', '789 Pine Rd, City', '555-1006', 'INS003', '2024-03-20'),
(4, 'Patricia', 'Davis', '1995-05-18', 'Female', 'AB+', '555-1007', 'pdavis@email.com', '321 Elm St, City', '555-1008', 'INS004', '2024-04-12'),
(5, 'Michael', 'Wilson', '1982-09-25', 'Male', 'O-', '555-1009', 'mwilson@email.com', '654 Maple Dr, City', '555-1010', 'INS005', '2024-05-08'),
(6, 'Linda', 'Moore', '1988-12-10', 'Female', 'A-', '555-1011', 'lmoore@email.com', '987 Cedar Ln, City', '555-1012', 'INS006', '2024-06-14'),
(7, 'William', 'Taylor', '1975-04-08', 'Male', 'B-', '555-1013', 'wtaylor@email.com', '147 Birch Ave, City', '555-1014', 'INS007', '2024-07-19'),
(8, 'Barbara', 'Anderson', '1992-08-14', 'Female', 'AB-', '555-1015', 'banderson@email.com', '258 Spruce St, City', '555-1016', 'INS008', '2024-08-22'),
(9, 'James', 'Thomas', '1980-01-20', 'Male', 'O+', '555-1017', 'jthomas@email.com', '369 Willow Rd, City', '555-1018', 'INS009', '2024-09-05'),
(10, 'Susan', 'Jackson', '1987-06-05', 'Female', 'A+', '555-1019', 'sjackson@email.com', '741 Ash Dr, City', '555-1020', 'INS010', '2024-10-11');
SET IDENTITY_INSERT Patients OFF;
GO

-- Insert Doctors
SET IDENTITY_INSERT Doctors ON;
INSERT INTO Doctors (doctor_id, first_name, last_name, specialization, department_id, qualification, experience_years, phone, email, consultation_fee, availability_schedule, joined_date) VALUES
(1, 'Sarah', 'Johnson', 'Cardiologist', 1, 'MD, FACC', 15, '555-2001', 'sjohnson@hospital.com', 250.00, 'Mon-Fri 9AM-5PM', '2010-01-15'),
(2, 'Michael', 'Chen', 'Neurologist', 2, 'MD, PhD', 12, '555-2002', 'mchen@hospital.com', 300.00, 'Mon-Fri 10AM-6PM', '2012-03-20'),
(3, 'Robert', 'Williams', 'Orthopedic Surgeon', 3, 'MD, FAAOS', 18, '555-2003', 'rwilliams@hospital.com', 275.00, 'Mon-Sat 8AM-4PM', '2008-05-10'),
(4, 'Emily', 'Davis', 'Pediatrician', 4, 'MD, FAAP', 10, '555-2004', 'edavis@hospital.com', 200.00, 'Mon-Fri 8AM-6PM', '2014-08-15'),
(5, 'James', 'Martinez', 'Emergency Medicine', 5, 'MD, FACEP', 14, '555-2005', 'jmartinez@hospital.com', 350.00, '24/7 Rotation', '2011-02-28'),
(6, 'Lisa', 'Anderson', 'Radiologist', 6, 'MD, FACR', 11, '555-2006', 'landerson@hospital.com', 225.00, 'Mon-Fri 7AM-3PM', '2013-11-05'),
(7, 'David', 'Thompson', 'Pathologist', 7, 'MD, PhD', 16, '555-2007', 'dthompson@hospital.com', 200.00, 'Mon-Fri 9AM-5PM', '2009-07-12'),
(8, 'Jennifer', 'White', 'General Physician', 4, 'MBBS, MD', 8, '555-2008', 'jwhite@hospital.com', 150.00, 'Mon-Sat 10AM-7PM', '2016-04-20');
SET IDENTITY_INSERT Doctors OFF;
GO

-- Insert Staff
INSERT INTO Staff (first_name, last_name, role, department_id, phone, email, salary, hire_date, shift_timing) VALUES
('Alice', 'Brown', 'Head Nurse', 1, '555-3001', 'abrown@hospital.com', 65000.00, '2015-03-10', 'Day Shift'),
('Tom', 'Green', 'Nurse', 2, '555-3002', 'tgreen@hospital.com', 55000.00, '2017-06-15', 'Night Shift'),
('Emma', 'Wilson', 'Receptionist', 5, '555-3003', 'ewilson@hospital.com', 40000.00, '2018-09-20', 'Day Shift'),
('Chris', 'Lee', 'Lab Technician', 7, '555-3004', 'clee@hospital.com', 50000.00, '2016-12-05', 'Day Shift'),
('Nancy', 'Hall', 'Pharmacist', 8, '555-3005', 'nhall@hospital.com', 70000.00, '2014-08-25', 'Day Shift'),
('Kevin', 'Young', 'Radiographer', 6, '555-3006', 'kyoung@hospital.com', 58000.00, '2019-01-30', 'Day Shift');
GO

-- Insert Rooms
INSERT INTO Rooms (room_number, room_type, department_id, bed_capacity, daily_rate, status) VALUES
('101', 'General', 1, 4, 500.00, 'Available'),
('102', 'General', 1, 4, 500.00, 'Occupied'),
('201', 'Private', 2, 1, 1500.00, 'Available'),
('202', 'Private', 2, 1, 1500.00, 'Occupied'),
('301', 'ICU', 5, 1, 3000.00, 'Available'),
('302', 'ICU', 5, 1, 3000.00, 'Occupied'),
('401', 'Emergency', 5, 2, 2000.00, 'Available'),
('501', 'Operation Theater', 3, 1, 5000.00, 'Available'),
('103', 'General', 4, 3, 450.00, 'Available'),
('203', 'Private', 1, 1, 1500.00, 'Maintenance');
GO

-- Insert Appointments
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, appointment_time, reason, status) VALUES
(1, 1, '2024-11-01', '10:00:00', 'Chest pain and irregular heartbeat', 'Completed'),
(2, 4, '2024-11-02', '14:30:00', 'Child vaccination', 'Completed'),
(3, 3, '2024-11-03', '09:00:00', 'Knee pain after accident', 'Completed'),
(4, 2, '2024-11-04', '11:00:00', 'Severe headaches and dizziness', 'Scheduled'),
(5, 5, '2024-11-04', '16:00:00', 'Emergency - Accident victim', 'Completed'),
(6, 1, '2024-11-05', '10:30:00', 'Follow-up cardiac check', 'Scheduled'),
(7, 8, '2024-11-05', '15:00:00', 'General health checkup', 'Scheduled'),
(8, 4, '2024-11-06', '09:30:00', 'Child fever and cough', 'Scheduled'),
(9, 3, '2024-11-06', '13:00:00', 'Back pain', 'Cancelled'),
(10, 2, '2024-11-07', '11:30:00', 'Memory issues', 'Scheduled');
GO

-- Insert Room Assignments
INSERT INTO Room_Assignments (patient_id, room_id, admission_date, discharge_date, reason, doctor_id, status) VALUES
(1, 2, '2024-10-28', '2024-11-01', 'Cardiac monitoring', 1, 'Discharged'),
(5, 6, '2024-11-04', NULL, 'Critical injuries from accident', 5, 'Active'),
(2, 4, '2024-11-02', NULL, 'Post-surgery recovery', 4, 'Active');
GO

-- Insert Medical Records
INSERT INTO Medical_Records (patient_id, doctor_id, visit_date, diagnosis, symptoms, treatment, vital_signs, follow_up_date) VALUES
(1, 1, '2024-11-01', 'Atrial Fibrillation', 'Irregular heartbeat, chest pain, fatigue', 'Prescribed beta-blockers and blood thinners', 'BP: 140/90, Pulse: 95, Temp: 98.6F', '2024-11-15'),
(2, 4, '2024-11-02', 'Common Cold', 'Runny nose, mild fever', 'Rest and fluids, paracetamol', 'BP: 110/70, Pulse: 80, Temp: 99.2F', '2024-11-09'),
(3, 3, '2024-11-03', 'Knee Ligament Injury', 'Severe knee pain, swelling', 'Physiotherapy, pain medication', 'BP: 120/80, Pulse: 75, Temp: 98.4F', '2024-11-17'),
(5, 5, '2024-11-04', 'Multiple Fractures', 'Broken ribs, leg fracture', 'Emergency surgery, ICU care', 'BP: 130/85, Pulse: 88, Temp: 99.0F', '2024-11-11');
GO

-- Insert Prescriptions
INSERT INTO Prescriptions (record_id, medicine_name, dosage, frequency, duration, instructions) VALUES
(1, 'Metoprolol', '50mg', 'Twice daily', '30 days', 'Take with food'),
(1, 'Warfarin', '5mg', 'Once daily', '30 days', 'Take at same time daily'),
(2, 'Paracetamol', '500mg', 'Three times daily', '5 days', 'After meals'),
(3, 'Ibuprofen', '400mg', 'Twice daily', '7 days', 'With food'),
(4, 'Morphine', '10mg', 'Every 4 hours', '3 days', 'For severe pain only');
GO

-- Insert Lab Tests
INSERT INTO Lab_Tests (patient_id, doctor_id, test_name, test_date, result, status, cost) VALUES
(1, 1, 'ECG', '2024-11-01', 'Abnormal - AFib detected', 'Completed', 150.00),
(1, 1, 'Blood Test - Complete', '2024-11-01', 'Normal range', 'Completed', 200.00),
(3, 3, 'X-Ray Knee', '2024-11-03', 'Ligament tear confirmed', 'Completed', 250.00),
(4, 2, 'MRI Brain', '2024-11-04', 'Pending', 'Pending', 800.00),
(5, 5, 'CT Scan Full Body', '2024-11-04', 'Multiple fractures', 'Completed', 1200.00);
GO

-- Insert Billing
INSERT INTO Billing (patient_id, appointment_id, room_assignment_id, consultation_fee, room_charges, lab_charges, medicine_charges, other_charges, payment_status, payment_date, payment_method) VALUES
(1, 1, 1, 250.00, 2000.00, 350.00, 180.00, 100.00, 'Paid', '2024-11-01', 'Insurance'),
(2, 2, NULL, 200.00, 0, 0, 25.00, 0, 'Paid', '2024-11-02', 'Cash'),
(3, 3, NULL, 275.00, 0, 250.00, 85.00, 50.00, 'Pending', NULL, NULL),
(5, 5, 2, 350.00, 9000.00, 1200.00, 500.00, 2000.00, 'Partial', '2024-11-04', 'Insurance');
GO

-- Insert Inventory
INSERT INTO Inventory (item_name, category, quantity, unit_price, supplier_name, expiry_date, minimum_stock, last_restocked) VALUES
('Paracetamol 500mg', 'Medicine', 5000, 0.50, 'PharmaCorp', '2026-12-31', 1000, '2024-10-01'),
('Surgical Gloves', 'Medical Supplies', 2000, 2.50, 'MedSupply Inc', NULL, 500, '2024-10-15'),
('Syringes 10ml', 'Medical Supplies', 3000, 0.75, 'MedSupply Inc', NULL, 500, '2024-10-15'),
('Bandages', 'Medical Supplies', 1500, 1.20, 'HealthGoods Ltd', NULL, 300, '2024-09-20'),
('Insulin', 'Medicine', 200, 25.00, 'PharmaCorp', '2025-06-30', 50, '2024-10-01'),
('X-Ray Films', 'Radiology', 500, 5.00, 'RadioMed', '2027-01-31', 100, '2024-10-10'),
('Blood Bags', 'Laboratory', 300, 15.00, 'BloodBank Co', '2025-03-31', 100, '2024-10-20'),
('Oxygen Cylinders', 'Emergency', 50, 150.00, 'OxygenSupply', NULL, 10, '2024-10-05');
GO

-- ============================================================
-- USEFUL QUERIES FOR SQL SERVER
-- ============================================================

-- Query 1: View all patients with appointments
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS Patient_Name,
    p.phone,
    a.appointment_date,
    a.appointment_time,
    CONCAT(d.first_name, ' ', d.last_name) AS Doctor_Name,
    a.status
FROM Patients p
LEFT JOIN Appointments a ON p.patient_id = a.patient_id
LEFT JOIN Doctors d ON a.doctor_id = d.doctor_id
ORDER BY a.appointment_date DESC;
GO

-- Query 2: Room occupancy status
SELECT 
    room_number,
    room_type,
    bed_capacity,
    current_occupancy,
    status,
    daily_rate
FROM Rooms
ORDER BY room_type, room_number;
GO

-- Query 3: Patient billing summary
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS Patient_Name,
    b.bill_id,
    b.total_amount,
    b.payment_status,
    b.payment_date
FROM Patients p
JOIN Billing b ON p.patient_id = b.patient_id
ORDER BY b.created_at DESC;
GO

-- Query 4: Currently admitted patients
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS Patient_Name,
    r.room_number,
    r.room_type,
    ra.admission_date,
    DATEDIFF(DAY, ra.admission_date, GETDATE()) AS Days_Admitted,
    CONCAT(d.first_name, ' ', d.last_name) AS Doctor_Name
FROM Room_Assignments ra
JOIN Patients p ON ra.patient_id = p.patient_id
JOIN Rooms r ON ra.room_id = r.room_id
JOIN Doctors d ON ra.doctor_id = d.doctor_id
WHERE ra.status = 'Active';
GO

-- Query 5: Low stock inventory alert
SELECT 
    item_name,
    category,
    quantity,
    minimum_stock,
    (minimum_stock - quantity) AS Shortage
FROM Inventory
WHERE quantity < minimum_stock
ORDER BY Shortage DESC;
GO

-- Query 6: Pending payments report
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS Patient_Name,
    p.phone,
    b.total_amount,
    b.created_at AS Bill_Date,
    DATEDIFF(DAY, b.created_at, GETDATE()) AS Days_Pending
FROM Billing b
JOIN Patients p ON b.patient_id = p.patient_id
WHERE b.payment_status = 'Pending'
ORDER BY Days_Pending DESC;
GO

-- Query 7: Department-wise statistics
SELECT 
    dep.department_name,
    COUNT(DISTINCT d.doctor_id) AS Total_Doctors,
    COUNT(DISTINCT s.staff_id) AS Total_Staff,
    COUNT(DISTINCT r.room_id) AS Total_Rooms
FROM Departments dep
LEFT JOIN Doctors d ON dep.department_id = d.department_id
LEFT JOIN Staff s ON dep.department_id = s.department_id
LEFT JOIN Rooms r ON dep.department_id = r.department_id
GROUP BY dep.department_name;
GO

-- Query 8: Monthly revenue report
SELECT 
    FORMAT(created_at, 'yyyy-MM') AS Month,
    COUNT(bill_id) AS Total_Bills,
    SUM(total_amount) AS Total_Revenue,
    SUM(CASE WHEN payment_status = 'Paid' THEN total_amount ELSE 0 END) AS Collected,
    SUM(CASE WHEN payment_status = 'Pending' THEN total_amount ELSE 0 END) AS Pending
FROM Billing
GROUP BY FORMAT(created_at, 'yyyy-MM')
ORDER BY Month DESC;
GO

-- Success message
PRINT 'Hospital Management System Database Created Successfully!';
