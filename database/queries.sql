USE library_management_db;
-- 1. Overdue loans view
SELECT * FROM vw_overdue_loans;
-- 2. Frequently borrowed books
SELECT b.title,COUNT(*) AS borrow_count
FROM loans l JOIN book_copies bc ON bc.copy_id=l.copy_id
JOIN books b ON b.book_id=bc.book_id
GROUP BY b.book_id,b.title ORDER BY borrow_count DESC;
-- 3. Members with unpaid fines (JOIN + aggregate)
SELECT m.full_name,SUM(f.amount-f.paid_amount) outstanding
FROM fines f JOIN loans l ON l.loan_id=f.loan_id
JOIN members m ON m.member_id=l.member_id
WHERE f.status IN ('UNPAID','PARTIAL')
GROUP BY m.member_id,m.full_name;
-- 4. Books never borrowed 
SELECT b.title FROM books b
WHERE NOT EXISTS (SELECT 1 FROM book_copies bc JOIN loans l ON l.copy_id=bc.copy_id
                  WHERE bc.book_id=b.book_id);
-- 5. Members who borrowed more than average
SELECT m.full_name,COUNT(*) total_borrows
FROM members m JOIN loans l ON l.member_id=m.member_id
GROUP BY m.member_id,m.full_name
HAVING COUNT(*) > (SELECT AVG(borrow_count) FROM
  (SELECT COUNT(*) borrow_count FROM loans GROUP BY member_id) x);

-- 6. Window function
SELECT title,borrow_count,
       RANK() OVER(ORDER BY borrow_count DESC) AS popularity_rank
FROM (SELECT b.title,COUNT(l.loan_id) borrow_count
      FROM books b LEFT JOIN book_copies bc ON bc.book_id=b.book_id
      LEFT JOIN loans l ON l.copy_id=bc.copy_id
      GROUP BY b.book_id,b.title) x;

-- 7. CTE: monthly borrowing trends
WITH monthly AS (
  SELECT DATE_FORMAT(issue_date,'%Y-%m') month,COUNT(*) total_issues
  FROM loans GROUP BY DATE_FORMAT(issue_date,'%Y-%m')
)
SELECT month,total_issues,
       SUM(total_issues) OVER(ORDER BY month) cumulative_issues
FROM monthly ORDER BY month;

-- 8. INNER JOIN
SELECT m.full_name,b.title,l.issue_date
FROM loans l INNER JOIN members m ON m.member_id=l.member_id
INNER JOIN book_copies bc ON bc.copy_id=l.copy_id
INNER JOIN books b ON b.book_id=bc.book_id;

-- 9. LEFT JOIN
SELECT m.full_name,COUNT(l.loan_id) total_loans
FROM members m LEFT JOIN loans l ON l.member_id=m.member_id
GROUP BY m.member_id,m.full_name;

-- 10. RIGHT JOIN
SELECT b.title,bc.accession_no
FROM loans l RIGHT JOIN book_copies bc ON bc.copy_id=l.copy_id
JOIN books b ON b.book_id=bc.book_id;

-- 11. SELF JOIN
SELECT a.full_name,b.full_name
FROM members a JOIN members b ON SUBSTRING_INDEX(a.email,'@',-1)=SUBSTRING_INDEX(b.email,'@',-1)
AND a.member_id<b.member_id;

-- 12. UNION
SELECT full_name AS person_name FROM members
UNION
SELECT username FROM admins;

-- 13. INTERSECT
SELECT DISTINCT m.member_id,m.full_name FROM members m
JOIN loans l ON l.member_id=m.member_id;

-- 14. EXCEPT
SELECT m.member_id,m.full_name FROM members m
WHERE NOT EXISTS (SELECT 1 FROM loans l WHERE l.member_id=m.member_id);

