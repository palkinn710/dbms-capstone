import os
from datetime import date, timedelta
from functools import wraps
from flask import Flask, render_template, request, redirect, url_for, flash, session
from werkzeug.security import generate_password_hash, check_password_hash
from dotenv import load_dotenv
import mysql.connector
from mysql.connector import Error

load_dotenv()
app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "library-capstone-secret-2026")

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "library_management_db"),
    "port": int(os.getenv("DB_PORT", "3306")),
}

def init_db_if_needed():
    """Ensure database, schema, and initial demo data are present on launch."""
    try:
        conn = mysql.connector.connect(
            host=DB_CONFIG["host"],
            user=DB_CONFIG["user"],
            password=DB_CONFIG["password"],
            port=DB_CONFIG["port"]
        )
        cur = conn.cursor()
        cur.execute(f"CREATE DATABASE IF NOT EXISTS `{DB_CONFIG['database']}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
        cur.close()
        conn.close()

        conn = mysql.connector.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute("SHOW TABLES LIKE 'admins'")
        exists = cur.fetchone()
        
        if not exists:
            schema_path = os.path.join(os.path.dirname(__file__), "database", "schema.sql")
            if os.path.exists(schema_path):
                with open(schema_path, "r", encoding="utf-8") as f:
                    for stmt in f.read().split(";"):
                        s = stmt.strip()
                        if s:
                            cur.execute(s)
                conn.commit()

            sample_path = os.path.join(os.path.dirname(__file__), "database", "sample_data.sql")
            if os.path.exists(sample_path):
                with open(sample_path, "r", encoding="utf-8") as f:
                    for stmt in f.read().split(";"):
                        lines = [l for l in stmt.splitlines() if not l.strip().startswith("--")]
                        s = "\n".join(lines).strip()
                        if s:
                            cur.execute(s)
                conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        print(f"[DB Initialization Note]: {e}")


init_db_if_needed()

def get_db():
    return mysql.connector.connect(**DB_CONFIG)

def query_db(sql, params=(), fetch=True):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute(sql, params)
        result = cur.fetchall() if fetch else None
        if not fetch:
            conn.commit()
        return result
    finally:
        cur.close()
        conn.close()

def login_required(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
        if "user_id" not in session:
            return redirect(url_for("login"))
        return fn(*args, **kwargs)
    return wrapper

@app.route("/")
def home():
    return redirect(url_for("dashboard") if "user_id" in session else url_for("login"))

@app.route("/login", methods=["GET", "POST"])
def login():
    if "user_id" in session:
        return redirect(url_for("dashboard"))

    if request.method == "POST":
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "")
        try:
            user = query_db("SELECT * FROM admins WHERE username=%s AND is_active=1", (username,))
            if user and check_password_hash(user[0]["password_hash"], password):
                session["user_id"] = user[0]["admin_id"]
                session["username"] = user[0]["username"]
                flash(f"Welcome back, {user[0]['username']}!", "success")
                return redirect(url_for("dashboard"))
            flash("Invalid username or password. Use demo credentials below.", "danger")
        except Error as e:
            flash(f"Database connection error: {e}", "danger")
    return render_template("login.html")

@app.route("/logout")
def logout():
    session.clear()
    flash("You have been signed out successfully.", "info")
    return redirect(url_for("login"))

@app.route("/dashboard")
@login_required
def dashboard():
    stats = {}
    for key, sql in {
        "books": "SELECT COUNT(*) n FROM books",
        "copies": "SELECT COUNT(*) n FROM book_copies",
        "available": "SELECT COUNT(*) n FROM book_copies WHERE status='AVAILABLE'",
        "members": "SELECT COUNT(*) n FROM members WHERE status='ACTIVE'",
        "issued": "SELECT COUNT(*) n FROM loans WHERE status='ISSUED'",
        "overdue": "SELECT COUNT(*) n FROM loans WHERE status='ISSUED' AND due_date < CURDATE()",
        "fines": "SELECT COALESCE(SUM(amount - paid_amount), 0) n FROM fines WHERE status <> 'WAIVED'"
    }.items():
        res = query_db(sql)
        stats[key] = res[0]["n"] if res else 0

    recent = query_db("""SELECT l.loan_id, m.full_name, m.member_no, b.title, bc.accession_no,
                         l.issue_date, l.due_date, l.status,
                         DATEDIFF(CURDATE(), l.due_date) AS days_overdue
                         FROM loans l
                         JOIN members m ON m.member_id = l.member_id
                         JOIN book_copies bc ON bc.copy_id = l.copy_id
                         JOIN books b ON b.book_id = bc.book_id
                         ORDER BY l.loan_id DESC LIMIT 6""")

    popular = query_db("""SELECT b.title, COALESCE(c.category_name, 'General') AS category_name,
                          COUNT(*) AS borrow_count
                          FROM loans l
                          JOIN book_copies bc ON bc.copy_id = l.copy_id
                          JOIN books b ON b.book_id = bc.book_id
                          LEFT JOIN categories c ON c.category_id = b.category_id
                          GROUP BY b.book_id, b.title, c.category_name
                          ORDER BY borrow_count DESC LIMIT 5""")

    return render_template("dashboard.html", stats=stats, recent=recent, popular=popular, active_page="dashboard")

@app.route("/books", methods=["GET", "POST"])
@login_required
def books():
    if request.method == "POST":
        title = request.form.get("title", "").strip()
        isbn = request.form.get("isbn", "").strip()
        author_name = request.form.get("author_name", "").strip()
        publisher_name = request.form.get("publisher_name", "").strip()
        category_id = request.form.get("category_id") or None
        published_year = request.form.get("published_year") or None
        copies = max(1, int(request.form.get("copies", 1)))

        if not title or not isbn:
            flash("Title and ISBN are required fields.", "danger")
        else:
            conn = get_db()
            cur = conn.cursor(dictionary=True)
            try:
                # Resolve or add publisher
                publisher_id = None
                if publisher_name:
                    cur.execute("SELECT publisher_id FROM publishers WHERE LOWER(publisher_name) = LOWER(%s)", (publisher_name,))
                    pub = cur.fetchone()
                    if pub:
                        publisher_id = pub["publisher_id"]
                    else:
                        cur.execute("INSERT INTO publishers(publisher_name) VALUES(%s)", (publisher_name,))
                        publisher_id = cur.lastrowid

                # Insert book
                cur.execute("""INSERT INTO books(isbn, title, publisher_id, category_id, published_year)
                               VALUES(%s, %s, %s, %s, %s)""",
                            (isbn, title, publisher_id, category_id, published_year))
                book_id = cur.lastrowid

                # Resolve or add author
                if author_name:
                    cur.execute("SELECT author_id FROM authors WHERE LOWER(author_name) = LOWER(%s)", (author_name,))
                    auth = cur.fetchone()
                    if auth:
                        author_id = auth["author_id"]
                    else:
                        cur.execute("INSERT INTO authors(author_name) VALUES(%s)", (author_name,))
                        author_id = cur.lastrowid
                    cur.execute("INSERT INTO book_authors(book_id, author_id) VALUES(%s, %s)", (book_id, author_id))

                # Create physical inventory copies
                for idx in range(copies):
                    cur.execute("INSERT INTO book_copies(book_id, accession_no, status) VALUES(%s, %s, 'AVAILABLE')",
                                (book_id, f"LIB-ACC-{book_id:02d}-{idx + 1:02d}"))
                conn.commit()
                flash(f"Book '{title}' with {copies} copies added successfully.", "success")
            except Error as e:
                conn.rollback()
                flash(f"Could not add book: {e}", "danger")
            finally:
                cur.close()
                conn.close()
        return redirect(url_for("books"))

    search = request.args.get("q", "").strip()
    rows = query_db("""SELECT b.book_id, b.isbn, b.title, b.published_year,
                       COALESCE(c.category_name, 'General') AS category_name,
                       COALESCE(p.publisher_name, 'Independent') AS publisher_name,
                       COALESCE(GROUP_CONCAT(DISTINCT a.author_name SEPARATOR ', '), 'Unspecified') AS authors_list,
                       COUNT(DISTINCT bc.copy_id) AS total_copies,
                       SUM(CASE WHEN bc.status='AVAILABLE' THEN 1 ELSE 0 END) AS available_copies
                       FROM books b
                       LEFT JOIN categories c ON c.category_id = b.category_id
                       LEFT JOIN publishers p ON p.publisher_id = b.publisher_id
                       LEFT JOIN book_authors ba ON ba.book_id = b.book_id
                       LEFT JOIN authors a ON a.author_id = ba.author_id
                       LEFT JOIN book_copies bc ON bc.book_id = b.book_id
                       WHERE b.title LIKE %s OR b.isbn LIKE %s OR a.author_name LIKE %s
                       GROUP BY b.book_id, b.isbn, b.title, b.published_year, c.category_name, p.publisher_name
                       ORDER BY b.book_id DESC""",
                    (f"%{search}%", f"%{search}%", f"%{search}%"))

    categories = query_db("SELECT category_id, category_name FROM categories ORDER BY category_name")
    return render_template("books.html", books=rows, categories=categories, q=search, active_page="books")

@app.route("/books/delete/<int:book_id>", methods=["POST"])
@login_required
def delete_book(book_id):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        # Check if any copy has circulation history
        cur.execute("""SELECT COUNT(*) AS active_loans FROM loans l
                       JOIN book_copies bc ON bc.copy_id = l.copy_id
                       WHERE bc.book_id = %s""", (book_id,))
        res = cur.fetchone()
        if res and res["active_loans"] > 0:
            flash("Cannot delete this book: it has active or historical circulation records.", "danger")
            return redirect(url_for("books"))

        cur.execute("DELETE FROM book_authors WHERE book_id=%s", (book_id,))
        cur.execute("DELETE FROM book_copies WHERE book_id=%s", (book_id,))
        cur.execute("DELETE FROM books WHERE book_id=%s", (book_id,))
        conn.commit()
        flash("Book deleted from catalogue.", "success")
    except Error as e:
        conn.rollback()
        flash(f"Cannot delete book: {e}", "danger")
    finally:
        cur.close()
        conn.close()
    return redirect(url_for("books"))

@app.route("/members", methods=["GET", "POST"])
@login_required
def members():
    if request.method == "POST":
        member_no = request.form.get("member_no", "").strip()
        full_name = request.form.get("full_name", "").strip()
        email = request.form.get("email", "").strip()
        phone = request.form.get("phone", "").strip()
        
        if not member_no or not full_name or not email:
            flash("Member ID, Full Name, and Email are required.", "danger")
        else:
            try:
                query_db("""INSERT INTO members(member_no, full_name, email, phone, joined_on, status)
                            VALUES(%s, %s, %s, %s, CURDATE(), 'ACTIVE')""",
                         (member_no, full_name, email, phone), fetch=False)
                flash(f"Member {full_name} registered successfully.", "success")
            except Error as e:
                flash(f"Could not register member: {e}", "danger")
        return redirect(url_for("members"))

    q = request.args.get("q", "").strip()
    rows = query_db("""SELECT m.*, 
                       COUNT(DISTINCT l.loan_id) AS total_borrows,
                       SUM(CASE WHEN l.status='ISSUED' THEN 1 ELSE 0 END) AS active_loans
                       FROM members m
                       LEFT JOIN loans l ON l.member_id = m.member_id
                       WHERE m.full_name LIKE %s OR m.member_no LIKE %s OR m.email LIKE %s
                       GROUP BY m.member_id
                       ORDER BY m.member_id DESC""", (f"%{q}%", f"%{q}%", f"%{q}%"))
    return render_template("members.html", members=rows, q=q, active_page="members")

@app.route("/members/status/<int:member_id>", methods=["POST"])
@login_required
def member_status(member_id):
    query_db("UPDATE members SET status=IF(status='ACTIVE','INACTIVE','ACTIVE') WHERE member_id=%s",
             (member_id,), fetch=False)
    flash("Member status updated.", "info")
    return redirect(url_for("members"))

@app.route("/loans", methods=["GET", "POST"])
@login_required
def loans():
    if request.method == "POST":
        member_id = request.form.get("member_id")
        copy_id = request.form.get("copy_id")
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        try:
            conn.start_transaction()
            cur.execute("SELECT status FROM members WHERE member_id=%s FOR UPDATE", (member_id,))
            member = cur.fetchone()
            cur.execute("SELECT status FROM book_copies WHERE copy_id=%s FOR UPDATE", (copy_id,))
            copy = cur.fetchone()

            if not member or member["status"] != "ACTIVE":
                raise ValueError("Selected member is not active or not found.")
            if not copy or copy["status"] != "AVAILABLE":
                raise ValueError("The selected book copy is not available.")

            issue_date = date.today()
            due_date = issue_date + timedelta(days=14)
            cur.execute("""INSERT INTO loans(member_id, copy_id, issue_date, due_date, status)
                           VALUES(%s, %s, %s, %s, 'ISSUED')""", (member_id, copy_id, issue_date, due_date))
            cur.execute("UPDATE book_copies SET status='ISSUED' WHERE copy_id=%s", (copy_id,))
            conn.commit()
            flash(f"Book issued successfully! Due return date: {due_date.strftime('%b %d, %Y')}", "success")
        except Exception as e:
            conn.rollback()
            flash(f"Loan issuance failed: {e}", "danger")
        finally:
            cur.close()
            conn.close()
        return redirect(url_for("loans"))

    members_list = query_db("SELECT member_id, member_no, full_name FROM members WHERE status='ACTIVE' ORDER BY full_name")
    copies = query_db("""SELECT bc.copy_id, bc.accession_no, b.title
                         FROM book_copies bc
                         JOIN books b ON b.book_id = bc.book_id
                         WHERE bc.status = 'AVAILABLE'
                         ORDER BY b.title, bc.accession_no""")
    rows = query_db("""SELECT l.loan_id, m.full_name, m.member_no, b.title, bc.accession_no,
                       l.issue_date, l.due_date, l.return_date, l.status,
                       DATEDIFF(CURDATE(), l.due_date) AS days_overdue
                       FROM loans l
                       JOIN members m ON m.member_id = l.member_id
                       JOIN book_copies bc ON bc.copy_id = l.copy_id
                       JOIN books b ON b.book_id = bc.book_id
                       ORDER BY l.loan_id DESC""")
    return render_template("loans.html", loans=rows, members=members_list, copies=copies, active_page="loans")

@app.route("/loans/return/<int:loan_id>", methods=["POST"])
@login_required
def return_loan(loan_id):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        conn.start_transaction()
        cur.execute("""SELECT loan_id, copy_id, due_date, status FROM loans
                       WHERE loan_id=%s FOR UPDATE""", (loan_id,))
        loan = cur.fetchone()
        if not loan or loan["status"] != "ISSUED":
            raise ValueError("Loan is not currently in ISSUED state.")

        today = date.today()
        cur.execute("UPDATE loans SET status='RETURNED', return_date=%s WHERE loan_id=%s", (today, loan_id))
        cur.execute("UPDATE book_copies SET status='AVAILABLE' WHERE copy_id=%s", (loan["copy_id"],))

        late_days = max(0, (today - loan["due_date"]).days)
        if late_days > 0:
            fine_amount = late_days * 5
            cur.execute("""INSERT INTO fines(loan_id, amount, paid_amount, status, created_on)
                           VALUES(%s, %s, 0, 'UNPAID', %s)
                           ON DUPLICATE KEY UPDATE amount=%s, status='UNPAID'""",
                        (loan_id, fine_amount, today, fine_amount))
            flash(f"Book returned. Overdue by {late_days} days. Fine generated: ₹{fine_amount:.2f}", "warning")
        else:
            flash("Book returned on time. No overdue fine accrued.", "success")
        conn.commit()
    except Exception as e:
        conn.rollback()
        flash(f"Return operation failed: {e}", "danger")
    finally:
        cur.close()
        conn.close()
    return redirect(url_for("loans"))

@app.route("/fines", methods=["GET", "POST"])
@login_required
def fines():
    if request.method == "POST":
        fine_id = request.form.get("fine_id")
        query_db("UPDATE fines SET paid_amount=amount, status='PAID' WHERE fine_id=%s", (fine_id,), fetch=False)
        flash("Fine marked as fully paid.", "success")
        return redirect(url_for("fines"))

    rows = query_db("""SELECT f.*, m.full_name, m.member_no, b.title, l.due_date, l.return_date
                       FROM fines f
                       JOIN loans l ON l.loan_id = f.loan_id
                       JOIN members m ON m.member_id = l.member_id
                       JOIN book_copies bc ON bc.copy_id = l.copy_id
                       JOIN books b ON b.book_id = bc.book_id
                       ORDER BY f.fine_id DESC""")

    totals = query_db("""SELECT 
                         COALESCE(SUM(amount), 0) AS total_fines,
                         COALESCE(SUM(paid_amount), 0) AS total_collected,
                         COALESCE(SUM(CASE WHEN status <> 'WAIVED' THEN (amount - paid_amount) ELSE 0 END), 0) AS total_outstanding
                         FROM fines""")[0]

    return render_template("fines.html", fines=rows, totals=totals, active_page="fines")

@app.route("/digital", methods=["GET", "POST"])
@login_required
def digital():
    if request.method == "POST":
        title = request.form.get("title", "").strip()
        resource_type = request.form.get("resource_type", "ARTICLE")
        url = request.form.get("url", "").strip()
        description = request.form.get("description", "").strip()

        if not title or not url:
            flash("Title and resource URL are required.", "danger")
        else:
            query_db("""INSERT INTO digital_resources(title, resource_type, url, description, added_on)
                        VALUES(%s, %s, %s, %s, CURDATE())""",
                     (title, resource_type, url, description), fetch=False)
            flash(f"Digital resource '{title}' added to catalogue.", "success")
        return redirect(url_for("digital"))

    rows = query_db("SELECT * FROM digital_resources ORDER BY resource_id DESC")
    return render_template("digital.html", resources=rows, active_page="digital")

@app.route("/digital/delete/<int:resource_id>", methods=["POST"])
@login_required
def delete_digital(resource_id):
    try:
        query_db("DELETE FROM digital_resources WHERE resource_id=%s", (resource_id,), fetch=False)
        flash("Digital resource removed.", "success")
    except Error as e:
        flash(f"Could not remove resource: {e}", "danger")
    return redirect(url_for("digital"))

@app.route("/reports")
@login_required
def reports():
    overdue = query_db("""SELECT m.full_name, m.member_no, b.title, l.due_date,
                          DATEDIFF(CURDATE(), l.due_date) AS late_days,
                          DATEDIFF(CURDATE(), l.due_date) * 5 AS estimated_fine
                          FROM loans l
                          JOIN members m ON m.member_id = l.member_id
                          JOIN book_copies bc ON bc.copy_id = l.copy_id
                          JOIN books b ON b.book_id = bc.book_id
                          WHERE l.status = 'ISSUED' AND l.due_date < CURDATE()
                          ORDER BY late_days DESC""")

    popular = query_db("""SELECT b.title, COALESCE(c.category_name, 'General') AS category_name,
                          COUNT(*) AS borrow_count
                          FROM loans l
                          JOIN book_copies bc ON bc.copy_id = l.copy_id
                          JOIN books b ON b.book_id = bc.book_id
                          LEFT JOIN categories c ON c.category_id = b.category_id
                          GROUP BY b.book_id, b.title, c.category_name
                          ORDER BY borrow_count DESC LIMIT 10""")

    active = query_db("""SELECT m.full_name, m.member_no, m.email, COUNT(*) AS borrow_count
                         FROM loans l
                         JOIN members m ON m.member_id = l.member_id
                         GROUP BY m.member_id, m.full_name, m.member_no, m.email
                         ORDER BY borrow_count DESC LIMIT 10""")

    return render_template("reports.html", overdue=overdue, popular=popular, active=active, active_page="reports")

@app.route("/database")
@login_required
def database_inspector():
    tables_list = [
        {"name": "books", "label": "Books", "desc": "Master catalogue containing titles, publishers, and categories."},
        {"name": "members", "label": "Members", "desc": "Registered patrons, students, faculty, and scholars."},
        {"name": "loans", "label": "Loans", "desc": "Active and historical book circulation and checkout transactions."},
        {"name": "fines", "label": "Fines", "desc": "Automated overdue penalty records, dues, and payment audit."},
        {"name": "book_copies", "label": "Book Copies", "desc": "Physical accessioned copies and shelf availability tracking."},
        {"name": "authors", "label": "Authors", "desc": "Writers, scholars, and biographical origins."},
        {"name": "publishers", "label": "Publishers", "desc": "Publication houses, imprints, and locations."},
        {"name": "categories", "label": "Categories", "desc": "Subject taxonomy, academic disciplines, and genres."},
        {"name": "book_authors", "label": "Book Authors", "desc": "Composite junction table representing many-to-many author mappings."},
        {"name": "reservations", "label": "Reservations", "desc": "Patron queue and reservation requests for held titles."},
        {"name": "admins", "label": "Admins", "desc": "Privileged staff accounts with hashed credentials."}
    ]

    selected_table = request.args.get("table", "books")
    if selected_table not in [t["name"] for t in tables_list]:
        selected_table = "books"

    counts = {}
    for t in tables_list:
        res = query_db(f"SELECT COUNT(*) AS n FROM `{t['name']}`")
        counts[t["name"]] = res[0]["n"] if res else 0

    columns_info = query_db(f"SHOW COLUMNS FROM `{selected_table}`")
    
    if selected_table == "admins":
        rows = query_db("SELECT admin_id, username, is_active, created_at, '••••••••' AS password_hash FROM admins")
    else:
        rows = query_db(f"SELECT * FROM `{selected_table}` LIMIT 100")

    current_meta = next(t for t in tables_list if t["name"] == selected_table)

    return render_template(
        "database.html",
        tables=tables_list,
        selected_table=selected_table,
        current_meta=current_meta,
        counts=counts,
        columns=columns_info,
        rows=rows,
        active_page="database"
    )

@app.errorhandler(404)
def not_found(_):
    return render_template("404.html", active_page="404"), 404

if __name__ == "__main__":
    app.run(debug=True)
