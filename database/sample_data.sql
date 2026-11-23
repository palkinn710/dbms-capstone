USE library_management_db;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE fines;
TRUNCATE TABLE reservations;
TRUNCATE TABLE loans;
TRUNCATE TABLE book_copies;
TRUNCATE TABLE book_authors;
TRUNCATE TABLE books;
TRUNCATE TABLE authors;
TRUNCATE TABLE publishers;
TRUNCATE TABLE categories;
TRUNCATE TABLE members;
TRUNCATE TABLE digital_resources;
TRUNCATE TABLE admins;
SET FOREIGN_KEY_CHECKS = 1;

-- Administrators (admin / admin123)
INSERT INTO admins (admin_id, username, password_hash, is_active) VALUES
(1, 'admin', 'scrypt:32768:8:1$oL9ahuDAUoC09nny$3c77e6eabe4402b5a44d655362d907bd8aaccbc54ba9f09c30308ad6bd8446874f6c34cba1172b22d18c7cdbc6f65d7a4a39973c4e5c1dc85d30e2809862b713', 1),
(2, 'librarian', 'scrypt:32768:8:1$oL9ahuDAUoC09nny$3c77e6eabe4402b5a44d655362d907bd8aaccbc54ba9f09c30308ad6bd8446874f6c34cba1172b22d18c7cdbc6f65d7a4a39973c4e5c1dc85d30e2809862b713', 1);

-- Categories
INSERT INTO categories (category_id, category_name) VALUES
(1, 'Computer Science & IT'),
(2, 'Software Engineering & Architecture'),
(3, 'Data Science & Machine Learning'),
(4, 'Literature & Classic Fiction'),
(5, 'Biographies & Memoirs'),
(6, 'Personal Growth & Psychology'),
(7, 'Business & Economics'),
(8, 'Indian History & Heritage');

-- Publishers
INSERT INTO publishers (publisher_id, publisher_name, city) VALUES
(1, 'Pearson India', 'New Delhi'),
(2, 'McGraw-Hill Education India', 'Chennai'),
(3, 'Penguin Random House India', 'Gurugram'),
(4, 'Oxford University Press India', 'New Delhi'),
(5, 'HarperCollins Publishers India', 'Noida'),
(6, 'Universities Press', 'Hyderabad'),
(7, 'Rupa Publications India', 'New Delhi'),
(8, 'Shroff Publishers & Distributors', 'Mumbai'),
(9, 'Westland Publications', 'Chennai'),
(10, 'Aleph Book Company', 'New Delhi');

-- Authors
INSERT INTO authors (author_id, author_name, country) VALUES
(1, 'Thomas H. Cormen', 'USA'),
(2, 'Robert C. Martin', 'USA'),
(3, 'Abraham Silberschatz', 'USA'),
(4, 'Andrew S. Tanenbaum', 'Netherlands'),
(5, 'Stuart Russell & Peter Norvig', 'USA'),
(6, 'Martin Kleppmann', 'UK'),
(7, 'David Thomas & Andrew Hunt', 'USA'),
(8, 'Gayle Laakmann McDowell', 'USA'),
(9, 'Dr. A.P.J. Abdul Kalam', 'India'),
(10, 'Paulo Coelho', 'Brazil'),
(11, 'James Clear', 'USA'),
(12, 'Yuval Noah Harari', 'Israel'),
(13, 'Morgan Housel', 'USA'),
(14, 'Robert T. Kiyosaki', 'USA'),
(15, 'R.K. Narayan', 'India'),
(16, 'Khushwant Singh', 'India'),
(17, 'Amish Tripathi', 'India'),
(18, 'Aravind Adiga', 'India'),
(19, 'George Orwell', 'UK'),
(20, 'F. Scott Fitzgerald', 'USA'),
(21, 'Erich Gamma & Richard Helm', 'USA'),
(22, 'Eric Matthes', 'USA'),
(23, 'Daniel Kahneman', 'USA'),
(24, 'Ruskin Bond', 'India'),
(25, 'Sudha Murty', 'India');

-- 30 Books
INSERT INTO books (book_id, isbn, title, publisher_id, category_id, published_year) VALUES
(1, '978-0262046305', 'Introduction to Algorithms (CLRS)', 1, 1, 2022),
(2, '978-0132350884', 'Clean Code: A Handbook of Agile Software', 1, 2, 2008),
(3, '978-0078022159', 'Database System Concepts', 2, 1, 2019),
(4, '978-0137523658', 'Computer Networks', 1, 1, 2021),
(5, '978-1119456339', 'Operating System Concepts', 2, 1, 2018),
(6, '978-0134610993', 'Artificial Intelligence: A Modern Approach', 1, 3, 2020),
(7, '978-9352135240', 'Designing Data-Intensive Applications', 8, 2, 2017),
(8, '978-0135957059', 'The Pragmatic Programmer', 1, 2, 2019),
(9, '978-0984782857', 'Cracking the Coding Interview', 8, 2, 2016),
(10, '978-8173711463', 'Wings of Fire: An Autobiography', 6, 5, 1999),
(11, '978-0143424123', 'Ignited Minds', 3, 5, 2002),
(12, '978-0062315007', 'The Alchemist', 5, 4, 1993),
(13, '978-1847941831', 'Atomic Habits', 3, 6, 2018),
(14, '978-0062316097', 'Sapiens: A Brief History of Humankind', 5, 6, 2015),
(15, '978-9390166268', 'The Psychology of Money', 7, 7, 2020),
(16, '978-1612680194', 'Rich Dad Poor Dad', 3, 7, 2017),
(17, '978-8185986173', 'Malgudi Days', 4, 4, 1982),
(18, '978-0143065883', 'Train to Pakistan', 3, 8, 1956),
(19, '978-9380658018', 'The Immortals of Meluha', 7, 4, 2010),
(20, '978-0451524935', '1984', 5, 4, 1949),
(21, '978-0201633610', 'Design Patterns: Elements of Reusable Object-Oriented Software', 1, 2, 1994),
(22, '978-1718502703', 'Python Crash Course (3rd Edition)', 8, 1, 2023),
(23, '978-0374533557', 'Thinking, Fast and Slow', 3, 6, 2011),
(24, '978-8129115300', 'The Room on the Roof', 3, 4, 1956),
(25, '978-0143335832', 'Wise and Otherwise', 3, 5, 2002),
(26, '978-0743273565', 'The Great Gatsby', 4, 4, 1925),
(27, '978-0143105435', 'The White Tiger', 5, 4, 2008),
(28, '978-9386224194', 'Sita: Warrior of Mithila', 9, 4, 2017),
(29, '978-8172234980', 'The Guide', 4, 4, 1958),
(30, '978-0143428800', 'Three Thousand Stitches', 3, 5, 2017);

-- Book Authors Mapping
INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 3),
(6, 5),
(7, 6),
(8, 7),
(9, 8),
(10, 9),
(11, 9),
(12, 10),
(13, 11),
(14, 12),
(15, 13),
(16, 14),
(17, 15),
(18, 16),
(19, 17),
(20, 19),
(21, 21),
(22, 22),
(23, 23),
(24, 24),
(25, 25),
(26, 20),
(27, 18),
(28, 17),
(29, 15),
(30, 25);

-- 70 Book Copies
INSERT INTO book_copies (copy_id, book_id, accession_no, status) VALUES
(1, 1, 'LIB-ACC-01-A', 'AVAILABLE'),
(2, 1, 'LIB-ACC-01-B', 'AVAILABLE'),
(3, 1, 'LIB-ACC-01-C', 'AVAILABLE'),
(4, 2, 'LIB-ACC-02-A', 'AVAILABLE'),
(5, 2, 'LIB-ACC-02-B', 'AVAILABLE'),
(6, 2, 'LIB-ACC-02-C', 'AVAILABLE'),
(7, 3, 'LIB-ACC-03-A', 'AVAILABLE'),
(8, 3, 'LIB-ACC-03-B', 'AVAILABLE'),
(9, 3, 'LIB-ACC-03-C', 'AVAILABLE'),
(10, 4, 'LIB-ACC-04-A', 'AVAILABLE'),
(11, 4, 'LIB-ACC-04-B', 'AVAILABLE'),
(12, 4, 'LIB-ACC-04-C', 'AVAILABLE'),
(13, 5, 'LIB-ACC-05-A', 'AVAILABLE'),
(14, 5, 'LIB-ACC-05-B', 'AVAILABLE'),
(15, 6, 'LIB-ACC-06-A', 'AVAILABLE'),
(16, 6, 'LIB-ACC-06-B', 'AVAILABLE'),
(17, 7, 'LIB-ACC-07-A', 'AVAILABLE'),
(18, 7, 'LIB-ACC-07-B', 'AVAILABLE'),
(19, 7, 'LIB-ACC-07-C', 'AVAILABLE'),
(20, 8, 'LIB-ACC-08-A', 'AVAILABLE'),
(21, 8, 'LIB-ACC-08-B', 'AVAILABLE'),
(22, 9, 'LIB-ACC-09-A', 'AVAILABLE'),
(23, 9, 'LIB-ACC-09-B', 'AVAILABLE'),
(24, 9, 'LIB-ACC-09-C', 'AVAILABLE'),
(25, 10, 'LIB-ACC-10-A', 'AVAILABLE'),
(26, 10, 'LIB-ACC-10-B', 'AVAILABLE'),
(27, 10, 'LIB-ACC-10-C', 'AVAILABLE'),
(28, 11, 'LIB-ACC-11-A', 'AVAILABLE'),
(29, 11, 'LIB-ACC-11-B', 'AVAILABLE'),
(30, 12, 'LIB-ACC-12-A', 'AVAILABLE'),
(31, 12, 'LIB-ACC-12-B', 'AVAILABLE'),
(32, 12, 'LIB-ACC-12-C', 'AVAILABLE'),
(33, 13, 'LIB-ACC-13-A', 'AVAILABLE'),
(34, 13, 'LIB-ACC-13-B', 'AVAILABLE'),
(35, 13, 'LIB-ACC-13-C', 'AVAILABLE'),
(36, 14, 'LIB-ACC-14-A', 'AVAILABLE'),
(37, 14, 'LIB-ACC-14-B', 'AVAILABLE'),
(38, 15, 'LIB-ACC-15-A', 'AVAILABLE'),
(39, 15, 'LIB-ACC-15-B', 'AVAILABLE'),
(40, 15, 'LIB-ACC-15-C', 'AVAILABLE'),
(41, 16, 'LIB-ACC-16-A', 'AVAILABLE'),
(42, 16, 'LIB-ACC-16-B', 'AVAILABLE'),
(43, 17, 'LIB-ACC-17-A', 'AVAILABLE'),
(44, 17, 'LIB-ACC-17-B', 'AVAILABLE'),
(45, 18, 'LIB-ACC-18-A', 'AVAILABLE'),
(46, 18, 'LIB-ACC-18-B', 'AVAILABLE'),
(47, 19, 'LIB-ACC-19-A', 'AVAILABLE'),
(48, 19, 'LIB-ACC-19-B', 'AVAILABLE'),
(49, 20, 'LIB-ACC-20-A', 'AVAILABLE'),
(50, 20, 'LIB-ACC-20-B', 'AVAILABLE'),
(51, 21, 'LIB-ACC-21-A', 'AVAILABLE'),
(52, 21, 'LIB-ACC-21-B', 'AVAILABLE'),
(53, 22, 'LIB-ACC-22-A', 'AVAILABLE'),
(54, 22, 'LIB-ACC-22-B', 'AVAILABLE'),
(55, 23, 'LIB-ACC-23-A', 'AVAILABLE'),
(56, 23, 'LIB-ACC-23-B', 'AVAILABLE'),
(57, 24, 'LIB-ACC-24-A', 'AVAILABLE'),
(58, 24, 'LIB-ACC-24-B', 'AVAILABLE'),
(59, 25, 'LIB-ACC-25-A', 'AVAILABLE'),
(60, 25, 'LIB-ACC-25-B', 'AVAILABLE'),
(61, 26, 'LIB-ACC-26-A', 'AVAILABLE'),
(62, 26, 'LIB-ACC-26-B', 'AVAILABLE'),
(63, 27, 'LIB-ACC-27-A', 'AVAILABLE'),
(64, 27, 'LIB-ACC-27-B', 'AVAILABLE'),
(65, 28, 'LIB-ACC-28-A', 'AVAILABLE'),
(66, 28, 'LIB-ACC-28-B', 'AVAILABLE'),
(67, 29, 'LIB-ACC-29-A', 'AVAILABLE'),
(68, 29, 'LIB-ACC-29-B', 'AVAILABLE'),
(69, 30, 'LIB-ACC-30-A', 'AVAILABLE'),
(70, 30, 'LIB-ACC-30-B', 'AVAILABLE');

-- 25 Indian Members
INSERT INTO members (member_id, member_no, full_name, email, phone, joined_on, status) VALUES
(1, 'MEM-2024-001', 'Aarav Sharma', 'aarav.sharma@gmail.com', '+91 98765 43210', '2024-01-15', 'ACTIVE'),
(2, 'MEM-2024-002', 'Priya Patel', 'priya.patel@gmail.com', '+91 98234 56789', '2024-02-10', 'ACTIVE'),
(3, 'MEM-2024-003', 'Rohan Verma', 'rohan.verma@gmail.com', '+91 97123 45678', '2024-03-05', 'ACTIVE'),
(4, 'MEM-2024-004', 'Ananya Iyer', 'ananya.iyer@gmail.com', '+91 99887 76655', '2024-03-22', 'ACTIVE'),
(5, 'MEM-2024-005', 'Vikram Malhotra', 'vikram.malhotra@gmail.com', '+91 98112 23344', '2024-04-12', 'ACTIVE'),
(6, 'MEM-2024-006', 'Sneha Kulkarni', 'sneha.kulkarni@gmail.com', '+91 97654 32109', '2024-05-01', 'ACTIVE'),
(7, 'MEM-2024-007', 'Aditya Nair', 'aditya.nair@gmail.com', '+91 99456 78123', '2023-09-10', 'ACTIVE'),
(8, 'MEM-2024-008', 'Neha Deshmukh', 'neha.deshmukh@gmail.com', '+91 98345 67890', '2024-06-18', 'ACTIVE'),
(9, 'MEM-2024-009', 'Siddharth Mehta', 'sid.mehta@gmail.com', '+91 98901 23456', '2024-07-02', 'ACTIVE'),
(10, 'MEM-2024-010', 'Tanvi Joshi', 'tanvi.joshi@gmail.com', '+91 98450 11223', '2024-07-15', 'ACTIVE'),
(11, 'MEM-2024-011', 'Kunal Kapoor', 'kunal.kapoor@gmail.com', '+91 97234 55667', '2024-08-01', 'ACTIVE'),
(12, 'MEM-2024-012', 'Pooja Hegde', 'pooja.hegde@gmail.com', '+91 99123 88776', '2024-08-19', 'ACTIVE'),
(13, 'MEM-2024-013', 'Arjun Rao', 'arjun.rao@gmail.com', '+91 98665 44332', '2024-09-05', 'ACTIVE'),
(14, 'MEM-2024-014', 'Meera Nambiar', 'meera.nambiar@gmail.com', '+91 98440 99887', '2024-09-20', 'ACTIVE'),
(15, 'MEM-2024-015', 'Varun Dhawan', 'varun.dhawan@gmail.com', '+91 97334 22110', '2024-10-10', 'INACTIVE'),
(16, 'MEM-2024-016', 'Shruti Haasan', 'shruti.haasan@gmail.com', '+91 98110 55443', '2024-10-25', 'ACTIVE'),
(17, 'MEM-2024-017', 'Deepak Sen', 'deepak.sen@gmail.com', '+91 98221 44556', '2024-11-01', 'ACTIVE'),
(18, 'MEM-2024-018', 'Ishita Banerji', 'ishita.b@gmail.com', '+91 99332 11223', '2024-11-05', 'ACTIVE'),
(19, 'MEM-2024-019', 'Gaurav Gill', 'gaurav.gill@gmail.com', '+91 97445 66778', '2024-11-12', 'ACTIVE'),
(20, 'MEM-2024-020', 'Kavita Pillai', 'kavita.p@gmail.com', '+91 98556 77889', '2024-11-18', 'ACTIVE'),
(21, 'MEM-2024-021', 'Nikhil Reddy', 'nikhil.reddy@gmail.com', '+91 99667 88990', '2024-11-20', 'ACTIVE'),
(22, 'MEM-2024-022', 'Rhea Chakraborty', 'rhea.c@gmail.com', '+91 98778 99001', '2024-11-25', 'ACTIVE'),
(23, 'MEM-2024-023', 'Manoj Bajpayee', 'manoj.b@gmail.com', '+91 97889 00112', '2024-12-01', 'ACTIVE'),
(24, 'MEM-2024-024', 'Anuradha Roy', 'anu.roy@gmail.com', '+91 98990 11223', '2024-12-05', 'INACTIVE'),
(25, 'MEM-2024-025', 'Harsh Goenka', 'harsh.g@gmail.com', '+91 99001 22334', '2024-12-10', 'ACTIVE');

-- 22 Loans (active/overdue)
INSERT INTO loans (loan_id, member_id, copy_id, issue_date, due_date, return_date, status) VALUES
-- Overdue 1: 14 days overdue
(1, 1, 1, DATE_SUB(CURDATE(), INTERVAL 28 DAY), DATE_SUB(CURDATE(), INTERVAL 14 DAY), NULL, 'ISSUED'),
-- Overdue 2: 7 days overdue
(2, 3, 4, DATE_SUB(CURDATE(), INTERVAL 21 DAY), DATE_SUB(CURDATE(), INTERVAL 7 DAY), NULL, 'ISSUED'),
-- Overdue 3: 4 days overdue
(3, 5, 7, DATE_SUB(CURDATE(), INTERVAL 18 DAY), DATE_SUB(CURDATE(), INTERVAL 4 DAY), NULL, 'ISSUED'),
-- Active on-time loans
(4, 2, 10, DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY), NULL, 'ISSUED'),
(5, 4, 13, DATE_SUB(CURDATE(), INTERVAL 4 DAY), DATE_ADD(CURDATE(), INTERVAL 10 DAY), NULL, 'ISSUED'),
(6, 6, 17, DATE_SUB(CURDATE(), INTERVAL 3 DAY), DATE_ADD(CURDATE(), INTERVAL 11 DAY), NULL, 'ISSUED'),
(7, 7, 22, DATE_SUB(CURDATE(), INTERVAL 2 DAY), DATE_ADD(CURDATE(), INTERVAL 12 DAY), NULL, 'ISSUED'),
(8, 8, 25, DATE_SUB(CURDATE(), INTERVAL 1 DAY), DATE_ADD(CURDATE(), INTERVAL 13 DAY), NULL, 'ISSUED'),
(9, 9, 30, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL, 'ISSUED'),
(10, 10, 33, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL, 'ISSUED'),
(11, 17, 51, DATE_SUB(CURDATE(), INTERVAL 3 DAY), DATE_ADD(CURDATE(), INTERVAL 11 DAY), NULL, 'ISSUED'),
(12, 18, 53, DATE_SUB(CURDATE(), INTERVAL 2 DAY), DATE_ADD(CURDATE(), INTERVAL 12 DAY), NULL, 'ISSUED'),
(13, 19, 55, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL, 'ISSUED'),
(14, 20, 57, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL, 'ISSUED'),
-- Returned loans (original)
(15, 11, 36, DATE_SUB(CURDATE(), INTERVAL 40 DAY), DATE_SUB(CURDATE(), INTERVAL 26 DAY), DATE_SUB(CURDATE(), INTERVAL 27 DAY), 'RETURNED'),
(16, 12, 38, DATE_SUB(CURDATE(), INTERVAL 35 DAY), DATE_SUB(CURDATE(), INTERVAL 21 DAY), DATE_SUB(CURDATE(), INTERVAL 18 DAY), 'RETURNED'),
(17, 13, 41, DATE_SUB(CURDATE(), INTERVAL 50 DAY), DATE_SUB(CURDATE(), INTERVAL 36 DAY), DATE_SUB(CURDATE(), INTERVAL 35 DAY), 'RETURNED'),
(18, 14, 43, DATE_SUB(CURDATE(), INTERVAL 45 DAY), DATE_SUB(CURDATE(), INTERVAL 31 DAY), DATE_SUB(CURDATE(), INTERVAL 25 DAY), 'RETURNED'),
(19, 1, 47, DATE_SUB(CURDATE(), INTERVAL 60 DAY), DATE_SUB(CURDATE(), INTERVAL 46 DAY), DATE_SUB(CURDATE(), INTERVAL 45 DAY), 'RETURNED'),
(20, 2, 49, DATE_SUB(CURDATE(), INTERVAL 55 DAY), DATE_SUB(CURDATE(), INTERVAL 41 DAY), DATE_SUB(CURDATE(), INTERVAL 40 DAY), 'RETURNED'),
(21, 21, 59, DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_SUB(CURDATE(), INTERVAL 16 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 'RETURNED'),
(22, 22, 61, DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_SUB(CURDATE(), INTERVAL 11 DAY), DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'RETURNED'),

-- ======================================================
-- EXTRA RETURNED LOANS for realistic borrow counts
-- copy_id 2 = book 1 (CLRS), 3 = book 2 (Clean Code)
-- copy_id 5 = book 3 (DB Concepts), 6 = book 3 B-copy
-- copy_id 11 = book 6 (AI), 12 = book 6 B
-- copy_id 14 = book 7 (Dsgn Data), 15 = book 7 B
-- copy_id 19 = book 10 (Wings of Fire), 20 B
-- copy_id 23 = book 12 (Alchemist), 24 B
-- copy_id 27 = book 14 (Sapiens), 28 B
-- ======================================================

-- CLRS (book 1, copies 2) — 8 total borrows
(23, 3,  2, DATE_SUB(CURDATE(), INTERVAL 90 DAY),  DATE_SUB(CURDATE(), INTERVAL 76 DAY),  DATE_SUB(CURDATE(), INTERVAL 75 DAY),  'RETURNED'),
(24, 5,  2, DATE_SUB(CURDATE(), INTERVAL 75 DAY),  DATE_SUB(CURDATE(), INTERVAL 61 DAY),  DATE_SUB(CURDATE(), INTERVAL 62 DAY),  'RETURNED'),
(25, 7,  2, DATE_SUB(CURDATE(), INTERVAL 60 DAY),  DATE_SUB(CURDATE(), INTERVAL 46 DAY),  DATE_SUB(CURDATE(), INTERVAL 47 DAY),  'RETURNED'),
(26, 9,  2, DATE_SUB(CURDATE(), INTERVAL 45 DAY),  DATE_SUB(CURDATE(), INTERVAL 31 DAY),  DATE_SUB(CURDATE(), INTERVAL 30 DAY),  'RETURNED'),
(27, 11, 2, DATE_SUB(CURDATE(), INTERVAL 30 DAY),  DATE_SUB(CURDATE(), INTERVAL 16 DAY),  DATE_SUB(CURDATE(), INTERVAL 17 DAY),  'RETURNED'),
(28, 13, 2, DATE_SUB(CURDATE(), INTERVAL 15 DAY),  DATE_SUB(CURDATE(), INTERVAL 1 DAY),   DATE_SUB(CURDATE(), INTERVAL 2 DAY),   'RETURNED'),
(29, 15, 2, DATE_SUB(CURDATE(), INTERVAL 110 DAY), DATE_SUB(CURDATE(), INTERVAL 96 DAY),  DATE_SUB(CURDATE(), INTERVAL 95 DAY),  'RETURNED'),

-- Clean Code (book 2, copy 3) — 7 total borrows
(30, 2,  3, DATE_SUB(CURDATE(), INTERVAL 85 DAY),  DATE_SUB(CURDATE(), INTERVAL 71 DAY),  DATE_SUB(CURDATE(), INTERVAL 70 DAY),  'RETURNED'),
(31, 4,  3, DATE_SUB(CURDATE(), INTERVAL 70 DAY),  DATE_SUB(CURDATE(), INTERVAL 56 DAY),  DATE_SUB(CURDATE(), INTERVAL 57 DAY),  'RETURNED'),
(32, 6,  3, DATE_SUB(CURDATE(), INTERVAL 55 DAY),  DATE_SUB(CURDATE(), INTERVAL 41 DAY),  DATE_SUB(CURDATE(), INTERVAL 40 DAY),  'RETURNED'),
(33, 8,  3, DATE_SUB(CURDATE(), INTERVAL 40 DAY),  DATE_SUB(CURDATE(), INTERVAL 26 DAY),  DATE_SUB(CURDATE(), INTERVAL 27 DAY),  'RETURNED'),
(34, 10, 3, DATE_SUB(CURDATE(), INTERVAL 25 DAY),  DATE_SUB(CURDATE(), INTERVAL 11 DAY),  DATE_SUB(CURDATE(), INTERVAL 12 DAY),  'RETURNED'),
(35, 16, 3, DATE_SUB(CURDATE(), INTERVAL 100 DAY), DATE_SUB(CURDATE(), INTERVAL 86 DAY),  DATE_SUB(CURDATE(), INTERVAL 85 DAY),  'RETURNED'),

-- The Alchemist (book 12, copy 23) — 6 borrows
(36, 1,  23, DATE_SUB(CURDATE(), INTERVAL 80 DAY), DATE_SUB(CURDATE(), INTERVAL 66 DAY),  DATE_SUB(CURDATE(), INTERVAL 67 DAY),  'RETURNED'),
(37, 3,  23, DATE_SUB(CURDATE(), INTERVAL 65 DAY), DATE_SUB(CURDATE(), INTERVAL 51 DAY),  DATE_SUB(CURDATE(), INTERVAL 52 DAY),  'RETURNED'),
(38, 5,  23, DATE_SUB(CURDATE(), INTERVAL 50 DAY), DATE_SUB(CURDATE(), INTERVAL 36 DAY),  DATE_SUB(CURDATE(), INTERVAL 35 DAY),  'RETURNED'),
(39, 7,  23, DATE_SUB(CURDATE(), INTERVAL 35 DAY), DATE_SUB(CURDATE(), INTERVAL 21 DAY),  DATE_SUB(CURDATE(), INTERVAL 22 DAY),  'RETURNED'),
(40, 9,  23, DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 6 DAY),   DATE_SUB(CURDATE(), INTERVAL 7 DAY),   'RETURNED'),

-- Atomic Habits (book 13, copy 27 = book 14... let me use copy 25 = book 13 B)
-- book 13 = Atomic Habits, copies 25 & 26
(41, 2,  26, DATE_SUB(CURDATE(), INTERVAL 78 DAY), DATE_SUB(CURDATE(), INTERVAL 64 DAY),  DATE_SUB(CURDATE(), INTERVAL 63 DAY),  'RETURNED'),
(42, 4,  26, DATE_SUB(CURDATE(), INTERVAL 63 DAY), DATE_SUB(CURDATE(), INTERVAL 49 DAY),  DATE_SUB(CURDATE(), INTERVAL 50 DAY),  'RETURNED'),
(43, 6,  26, DATE_SUB(CURDATE(), INTERVAL 48 DAY), DATE_SUB(CURDATE(), INTERVAL 34 DAY),  DATE_SUB(CURDATE(), INTERVAL 33 DAY),  'RETURNED'),
(44, 8,  26, DATE_SUB(CURDATE(), INTERVAL 33 DAY), DATE_SUB(CURDATE(), INTERVAL 19 DAY),  DATE_SUB(CURDATE(), INTERVAL 20 DAY),  'RETURNED'),
(45, 12, 26, DATE_SUB(CURDATE(), INTERVAL 18 DAY), DATE_SUB(CURDATE(), INTERVAL 4 DAY),   DATE_SUB(CURDATE(), INTERVAL 5 DAY),   'RETURNED'),

-- Sapiens (book 14, copies 27 & 28)
(46, 11, 28, DATE_SUB(CURDATE(), INTERVAL 72 DAY), DATE_SUB(CURDATE(), INTERVAL 58 DAY),  DATE_SUB(CURDATE(), INTERVAL 59 DAY),  'RETURNED'),
(47, 13, 28, DATE_SUB(CURDATE(), INTERVAL 57 DAY), DATE_SUB(CURDATE(), INTERVAL 43 DAY),  DATE_SUB(CURDATE(), INTERVAL 42 DAY),  'RETURNED'),
(48, 15, 28, DATE_SUB(CURDATE(), INTERVAL 42 DAY), DATE_SUB(CURDATE(), INTERVAL 28 DAY),  DATE_SUB(CURDATE(), INTERVAL 29 DAY),  'RETURNED'),
(49, 17, 28, DATE_SUB(CURDATE(), INTERVAL 27 DAY), DATE_SUB(CURDATE(), INTERVAL 13 DAY),  DATE_SUB(CURDATE(), INTERVAL 12 DAY),  'RETURNED'),

-- Wings of Fire (book 10, copies 19 & 20)
(50, 10, 20, DATE_SUB(CURDATE(), INTERVAL 95 DAY), DATE_SUB(CURDATE(), INTERVAL 81 DAY),  DATE_SUB(CURDATE(), INTERVAL 80 DAY),  'RETURNED'),
(51, 12, 20, DATE_SUB(CURDATE(), INTERVAL 79 DAY), DATE_SUB(CURDATE(), INTERVAL 65 DAY),  DATE_SUB(CURDATE(), INTERVAL 66 DAY),  'RETURNED'),
(52, 14, 20, DATE_SUB(CURDATE(), INTERVAL 64 DAY), DATE_SUB(CURDATE(), INTERVAL 50 DAY),  DATE_SUB(CURDATE(), INTERVAL 49 DAY),  'RETURNED'),
(53, 16, 20, DATE_SUB(CURDATE(), INTERVAL 49 DAY), DATE_SUB(CURDATE(), INTERVAL 35 DAY),  DATE_SUB(CURDATE(), INTERVAL 36 DAY),  'RETURNED'),
(54, 18, 20, DATE_SUB(CURDATE(), INTERVAL 34 DAY), DATE_SUB(CURDATE(), INTERVAL 20 DAY),  DATE_SUB(CURDATE(), INTERVAL 19 DAY),  'RETURNED'),
(55, 20, 20, DATE_SUB(CURDATE(), INTERVAL 19 DAY), DATE_SUB(CURDATE(), INTERVAL 5 DAY),   DATE_SUB(CURDATE(), INTERVAL 6 DAY),   'RETURNED');

-- Mark issued copies as ISSUED
UPDATE book_copies SET status = 'ISSUED' WHERE copy_id IN (1, 4, 7, 10, 13, 17, 22, 25, 30, 33, 51, 53, 55, 57);

-- Fines
INSERT INTO fines (fine_id, loan_id, amount, paid_amount, status, created_on) VALUES
(1, 1, 70.00, 0.00, 'UNPAID', DATE_SUB(CURDATE(), INTERVAL 14 DAY)),
(2, 2, 35.00, 0.00, 'UNPAID', DATE_SUB(CURDATE(), INTERVAL 7 DAY)),
(3, 3, 20.00, 0.00, 'UNPAID', DATE_SUB(CURDATE(), INTERVAL 4 DAY)),
(4, 16, 15.00, 15.00, 'PAID', DATE_SUB(CURDATE(), INTERVAL 18 DAY)),
(5, 18, 30.00, 30.00, 'PAID', DATE_SUB(CURDATE(), INTERVAL 25 DAY)),
(6, 21, 5.00, 5.00, 'PAID', DATE_SUB(CURDATE(), INTERVAL 15 DAY));
