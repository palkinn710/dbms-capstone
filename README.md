# Librain - Modern Library Management System

A full-stack Library Management System built with **Flask**, **MySQL**, and a responsive, modern interface.

---

## Features

- **Dashboard**: Real-time KPI counters (active titles, physical copies, availability, active borrowers, overdue items, outstanding fines) with circulation logs and popularity leaderboards.
- **Catalogue & Inventory**: Register book titles with ISBN, publication year, category, author, publishing house, and automated accession numbering (`LIB-ACC-xx-xx`). Includes search and safe deletion.
- **Member Directory**: Patron registration with Indian contact details, active/inactive privileges toggle, and borrowing track records.
- **Circulation Desk (Transactions)**:
  - 14-day checkout with ACID transaction guarantees (`FOR UPDATE` locking).
  - Return processing with automated late penalty assessment (₹5.00/day).
- **Financial Accounts & Fines Ledger**: Real-time tracking of assessed penalties, collected payments, and outstanding balances.
- **Audit & Analytics Reports**: Pre-built operational intelligence for overdue accounts, high-frequency borrows, and active patrons.
- **Database Architecture & ER Model**: Live inspector for all 11 database tables with schema breakdown, row counts, live data view, and an interactive 3NF Entity-Relationship Diagram.
- **Self-Healing Startup**: Automatically checks for database and table presence on launch.

---

## Quick Start Guide

### 1. Requirements
- Python 3.10+
- MySQL 8.0+

### 2. Environment Configuration
Verify your MySQL database credentials in `.env`:
```ini
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=library_management_db
SECRET_KEY=library-capstone-secret-2026
```

### 3. Launch the Application
Activate the virtual environment and run:
```bash
python app.py
```

### 4. Access the Portal
Open **[http://127.0.0.1:5000](http://127.0.0.1:5000)** in your browser.
