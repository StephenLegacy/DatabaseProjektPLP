-- Library Management System Database
-- Created by STEPHEN OLOO
-- Date: 2 May 2025

-- Database creation
DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

-- Members table - tracks library patrons
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    membership_date DATE NOT NULL,
    membership_expiry DATE NOT NULL,
    status ENUM('active', 'expired', 'suspended') DEFAULT 'active',
    CONSTRAINT chk_expiry CHECK (membership_expiry > membership_date)
) COMMENT 'Stores library member information';

-- Books table - tracks library inventory
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    publisher VARCHAR(100),
    publication_year INT,
    genre VARCHAR(50),
    edition VARCHAR(20),
    quantity INT NOT NULL DEFAULT 1,
    available_quantity INT NOT NULL,
    shelf_location VARCHAR(20),
    CONSTRAINT chk_quantity CHECK (available_quantity <= quantity AND quantity >= 0),
    CONSTRAINT chk_year CHECK (publication_year BETWEEN 1000 AND YEAR(CURDATE()))
) COMMENT 'Stores book inventory information';

-- Authors table (for many-to-many relationship with books)
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    bio TEXT,
    nationality VARCHAR(50)
) COMMENT 'Stores author details';

-- Book-Author relationship (M-M)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
) COMMENT 'Relates books to their authors (M-M relationship)';

-- Staff table - library employees
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    status ENUM('active', 'on_leave', 'terminated') DEFAULT 'active'
) COMMENT 'Stores library staff information';

-- Loans table - tracks book borrowings
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    staff_id INT NOT NULL,
    loan_date DATE NOT NULL DEFAULT (CURDATE()),
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('active', 'returned', 'overdue') DEFAULT 'active',
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    CONSTRAINT chk_due_date CHECK (due_date > loan_date),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= loan_date)
) COMMENT 'Tracks book loans and returns';

-- Fines table - tracks overdue penalties
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    issue_date DATE NOT NULL DEFAULT (CURDATE()),
    payment_date DATE,
    status ENUM('pending', 'paid') DEFAULT 'pending',
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id),
    CONSTRAINT chk_amount CHECK (amount >= 0),
    CONSTRAINT chk_payment_date CHECK (payment_date IS NULL OR payment_date >= issue_date)
) COMMENT 'Tracks fines for overdue books';

-- Triggers for automatic updates

-- Update book availability when loaned
DELIMITER //
CREATE TRIGGER after_loan_insert
AFTER INSERT ON loans
FOR EACH ROW
BEGIN
    UPDATE books 
    SET available_quantity = available_quantity - 1
    WHERE book_id = NEW.book_id;
END//
DELIMITER ;

-- Update book availability when returned
DELIMITER //
CREATE TRIGGER after_loan_update
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        UPDATE books 
        SET available_quantity = available_quantity + 1
        WHERE book_id = NEW.book_id;
    END IF;
END//
DELIMITER ;

-- Create fine when book is overdue
DELIMITER //
CREATE TRIGGER check_overdue_books
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN
    IF NEW.return_date IS NULL AND NEW.due_date < CURDATE() THEN
        UPDATE loans SET status = 'overdue' WHERE loan_id = NEW.loan_id;
        
        INSERT INTO fines (loan_id, amount)
        VALUES (NEW.loan_id, 
                DATEDIFF(CURDATE(), NEW.due_date) * 0.50); -- $0.50 per day fine
    END IF;
END//
DELIMITER ;

-- Sample data insertion (optional)
INSERT INTO members (first_name, last_name, email, phone, membership_date, membership_expiry)
VALUES 
('John', 'Doe', 'john.doe@email.com', '555-0101', '2023-01-15', '2024-01-15'),
('Jane', 'Smith', 'jane.smith@email.com', '555-0102', '2023-02-20', '2024-02-20');

INSERT INTO staff (first_name, last_name, email, position, hire_date)
VALUES 
('Robert', 'Johnson', 'r.johnson@library.org', 'Librarian', '2020-05-10'),
('Emily', 'Williams', 'e.williams@library.org', 'Assistant Librarian', '2021-08-15');

INSERT INTO books (isbn, title, author, quantity, available_quantity)
VALUES 
('978-0061120084', 'To Kill a Mockingbird', 'Harper Lee', 5, 5),
('978-0451524935', '1984', 'George Orwell', 3, 3);
