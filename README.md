# Why Are Employees Leaving? Attrition Risk Analysis

Which roles, departments, and employee profiles carry the highest attrition risk, and which interventions would be worth funding?

## The question

Replacing an employee costs 6-9 months of their salary in recruiting and training. This project builds a data-driven risk profile of employee attrition, identifying which factors actually predict who leaves, and quantifying which combinations of factors matter most.

## Data source

**Dataset:** IBM HR Analytics Employee Attrition & Performance
**Source:** Kaggle (originally IBM Watson Analytics sample data)
**Size:** 1,470 employee records, 35 columns, single flat file

Note: this is a synthetic-but-realistic dataset built by IBM to mirror real HR attrition patterns, not real company data.

## Pipeline

```
Raw Kaggle CSV (single flat file, 35 columns)
        |
        v
Python (pandas): map department/tenure to IDs, rename columns, drop constants
        |
        v
SQLite (fact_employees + dim_department + dim_tenure_band)
        |
        v
SQL views (joins, NTILE window function, composite risk scoring)
        |
        v
Power BI single-page dashboard
```

**1. Python** (`python/prepare_hr_data.py`)
The source file is a single flat table with no natural joins. To deliberately practice relational design and join logic, this script maps each employee's department and years-at-company into foreign keys against two manually-built dimension tables, rather than leaving everything in one wide table.

**2. SQL schema** (`sql/create_tables.sql`)
- `fact_employees` — one row per employee, all HR attributes
- `dim_department` — manually built lookup (Sales, R&D, HR)
- `dim_tenure_band` — manually built lookup (0-2, 3-5, 6-10, 10+ years)

**3. Analysis views** (`sql/analysis_views.sql`)
- `vw_attrition_by_department` — attrition rate by department and job role (join to `dim_department`)
- `vw_employee_risk_score` — a composite risk score (overtime, low satisfaction, no recent promotion, poor work-life balance) split into quartiles using `NTILE(4)`
- `vw_risk_quartile_summary` — validates the risk score against real attrition outcomes per quartile
- `vw_attrition_by_tenure` — attrition rate by tenure band (join to `dim_tenure_band`)
- `vw_income_attrition_analysis` — average income of leavers vs. stayers, by job role
- `vw_overtime_satisfaction_risk` — attrition rate for every combination of overtime status and job satisfaction level

**4. Power BI dashboard**
A single-page dashboard with 4 KPI cards, 3 comparison charts, and a risk quartile breakdown table, all built on DAX measures referencing the SQL views above.

## Key findings

- **Overtime plus low job satisfaction is the strongest combined predictor of attrition**, at 36.6%, compared to 8.46% for employees with no overtime and high satisfaction — a 4.3x difference. Notably, overtime alone (27% attrition even among satisfied employees) matters more than satisfaction alone (13.46% attrition even without overtime), suggesting overtime is the dominant driver.
- **Sales Representatives have the highest attrition rate of any role (39.76%)**, more than double the next-highest role (Laboratory Technician, 23.94%), and over 15x the lowest-risk role (Research Director, 2.5%).
- **The composite risk score meaningfully separates real outcomes**: employees in the highest-risk quartile show a 26.36% attrition rate, versus 7.08% in the lowest-risk quartile, a 3.7x spread, confirming the scoring logic has genuine predictive value on this dataset.
- **Attrition drops steadily with tenure**: 29.82% in an employee's first 2 years, falling to 8.13% at 10+ years.
- **The income-attrition relationship reverses by seniority.** In junior/mid-level roles, employees who left earned less than those who stayed, consistent with pay dissatisfaction driving exits. In senior roles (Research Director, Sales Executive, Healthcare Representative), the pattern flips: leavers were paid *more* than stayers, suggesting senior departures may be driven by competing offers rather than being underpaid.

## Methodology note

The composite risk score weights four factors (overtime: 3 points, low job satisfaction: 2 points, no promotion in 4+ years: 2 points, poor work-life balance: 1 point) based on judgment rather than a statistically fitted model (e.g., logistic regression). The weights were chosen to reflect the brief's stated hypotheses, then validated after the fact against actual attrition outcomes per quartile. This is a reasonable approach for a rules-based risk-tiering system, but a production HR analytics tool would likely validate and tune these weights with a proper statistical model rather than fixed point values.

## Tools used

Python (pandas) - SQLite - SQL (joins, window functions, CTEs) - Power BI (DAX measures, single-page dashboard design)

## Folder structure

```
hr-attrition/
|-- data/
|   |-- raw/          <- download the Kaggle dataset here (not committed)
|   |-- staging/       <- cleaned/mapped CSV after Python processing
|   `-- processed/     <- SQLite database file
|-- sql/
|   |-- create_tables.sql
|   `-- analysis_views.sql
|-- python/
|   `-- prepare_hr_data.py
|-- powerbi/
|   `-- hr_attrition_dashboard.pbix
|-- docs/
`-- README.md
```