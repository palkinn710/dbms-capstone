CREATE DATABASE IF NOT EXISTS library_management_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE library_management_db;

CREATE TABLE admins (
  admin_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE members (
  member_id INT AUTO_INCREMENT PRIMARY KEY,
  member_no VARCHAR(20) NOT NULL UNIQUE,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(20),
  joined_on DATE NOT NULL,
  status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE publishers (
  publisher_id INT AUTO_INCREMENT PRIMARY KEY,
  publisher_name VARCHAR(120) NOT NULL UNIQUE,
  city VARCHAR(80)
);

CREATE TABLE authors (
  author_id INT AUTO_INCREMENT PRIMARY KEY,
  author_name VARCHAR(120) NOT NULL,
  country VARCHAR(80),
  UNIQUE KEY uq_author_name_country(author_name,country)
);

CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE books (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  isbn VARCHAR(20) NOT NULL UNIQUE,
  title VARCHAR(200) NOT NULL,
  publisher_id INT,
  category_id INT,
  published_year SMALLINT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_book_publisher FOREIGN KEY(publisher_id) REFERENCES publishers(publisher_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_book_category FOREIGN KEY(category_id) REFERENCES categories(category_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CHECK (published_year IS NULL OR published_year BETWEEN 1400 AND 2100),
  INDEX idx_books_title(title),
  INDEX idx_books_category(category_id)
);

CREATE TABLE book_authors (
  book_id INT NOT NULL,
  author_id INT NOT NULL,
  PRIMARY KEY(book_id,author_id),
  FOREIGN KEY(book_id) REFERENCES books(book_id) ON DELETE CASCADE,
  FOREIGN KEY(author_id) REFERENCES authors(author_id) ON DELETE RESTRICT
);

CREATE TABLE book_copies (
  copy_id INT AUTO_INCREMENT PRIMARY KEY,
  book_id INT NOT NULL,
  accession_no VARCHAR(30) NOT NULL UNIQUE,
  status ENUM('AVAILABLE','ISSUED','LOST','DAMAGED') NOT NULL DEFAULT 'AVAILABLE',
  FOREIGN KEY(book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
  INDEX idx_copy_status(status)
);

CREATE TABLE loans (
  loan_id INT AUTO_INCREMENT PRIMARY KEY,
  member_id INT NOT NULL,
  copy_id INT NOT NULL,
  issue_date DATE NOT NULL,
  due_date DATE NOT NULL,
  return_date DATE,
  status ENUM('ISSUED','RETURNED','LOST') NOT NULL DEFAULT 'ISSUED',
  FOREIGN KEY(member_id) REFERENCES members(member_id) ON DELETE RESTRICT,
  FOREIGN KEY(copy_id) REFERENCES book_copies(copy_id) ON DELETE RESTRICT,
  CHECK (due_date >= issue_date),
  INDEX idx_loan_due_status(status,due_date),
  INDEX idx_loan_member(member_id)
);

CREATE TABLE reservations (
  reservation_id INT AUTO_INCREMENT PRIMARY KEY,
  member_id INT NOT NULL,
  book_id INT NOT NULL,
  reserved_on DATE NOT NULL,
  status ENUM('PENDING','FULFILLED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  FOREIGN KEY(member_id) REFERENCES members(member_id),
  FOREIGN KEY(book_id) REFERENCES books(book_id),
  INDEX idx_reservation_status(status)
);

CREATE TABLE fines (
  fine_id INT AUTO_INCREMENT PRIMARY KEY,
  loan_id INT NOT NULL UNIQUE,
  amount DECIMAL(10,2) NOT NULL,
  paid_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  status ENUM('UNPAID','PARTIAL','PAID','WAIVED') NOT NULL DEFAULT 'UNPAID',
  created_on DATE NOT NULL,
  FOREIGN KEY(loan_id) REFERENCES loans(loan_id),
  CHECK(amount >= 0 AND paid_amount >= 0 AND paid_amount <= amount)
);

CREATE TABLE digital_resources (
  resource_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  resource_type ENUM('EBOOK','JOURNAL','ARTICLE','VIDEO','OTHER') NOT NULL,
  url VARCHAR(500) NOT NULL,
  description TEXT,
  added_on DATE NOT NULL,
  INDEX idx_resource_type(resource_type)
);

CREATE OR REPLACE VIEW vw_available_books AS
SELECT b.book_id,b.isbn,b.title,c.category_name,
       COUNT(bc.copy_id) AS available_copies
FROM books b
LEFT JOIN categories c ON c.category_id=b.category_id
LEFT JOIN book_copies bc ON bc.book_id=b.book_id AND bc.status='AVAILABLE'
GROUP BY b.book_id,b.isbn,b.title,c.category_name;

CREATE OR REPLACE VIEW vw_overdue_loans AS
SELECT l.loan_id,m.member_no,m.full_name,b.title,l.issue_date,l.due_date,
       DATEDIFF(CURDATE(),l.due_date) AS late_days
FROM loans l JOIN members m ON m.member_id=l.member_id
JOIN book_copies bc ON bc.copy_id=l.copy_id
JOIN books b ON b.book_id=bc.book_id
WHERE l.status='ISSUED' AND l.due_date<CURDATE();
