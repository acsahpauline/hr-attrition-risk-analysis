CREATE VIEW vw_attrition_by_department AS
SELECT
    d.department_name,
    f.job_role,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN f.attrition = 'Yes' THEN 1 ELSE 0 END) AS attritions,
    ROUND(100.0 * SUM(CASE WHEN f.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM fact_employees f
JOIN dim_department d ON f.department_id = d.department_id
GROUP BY d.department_name, f.job_role
ORDER BY attrition_rate_pct DESC;

CREATE VIEW vw_employee_risk_score AS
SELECT
    employee_number,
    job_role,
    overtime,
    job_satisfaction,
    monthly_income,
    years_at_company,
    (
        CASE WHEN overtime = 'Yes' THEN 3 ELSE 0 END +
        CASE WHEN job_satisfaction <= 2 THEN 2 ELSE 0 END +
        CASE WHEN years_since_last_promotion >= 4 THEN 2 ELSE 0 END +
        CASE WHEN work_life_balance <= 2 THEN 1 ELSE 0 END
    ) AS raw_risk_score,
    NTILE(4) OVER (
        ORDER BY (
            CASE WHEN overtime = 'Yes' THEN 3 ELSE 0 END +
            CASE WHEN job_satisfaction <= 2 THEN 2 ELSE 0 END +
            CASE WHEN years_since_last_promotion >= 4 THEN 2 ELSE 0 END +
            CASE WHEN work_life_balance <= 2 THEN 1 ELSE 0 END
        ) DESC
    ) AS risk_quartile
FROM fact_employees;

CREATE VIEW vw_attrition_by_tenure AS
SELECT
    t.band_label,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN f.attrition = 'Yes' THEN 1 ELSE 0 END) AS attritions,
    ROUND(100.0 * SUM(CASE WHEN f.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM fact_employees f
JOIN dim_tenure_band t ON f.tenure_band_id = t.tenure_band_id
GROUP BY t.band_label
ORDER BY t.tenure_band_id;

CREATE VIEW vw_income_attrition_analysis AS
SELECT
    job_role,
    ROUND(AVG(CASE WHEN attrition = 'Yes' THEN monthly_income END), 0) AS avg_income_left,
    ROUND(AVG(CASE WHEN attrition = 'No' THEN monthly_income END), 0) AS avg_income_stayed,
    ROUND(AVG(CASE WHEN attrition = 'No' THEN monthly_income END) - AVG(CASE WHEN attrition = 'Yes' THEN monthly_income END), 0) AS income_gap
FROM fact_employees
GROUP BY job_role
ORDER BY income_gap DESC;

CREATE VIEW vw_overtime_satisfaction_risk AS
SELECT
    overtime,
    CASE WHEN job_satisfaction <= 2 THEN 'Low Satisfaction' ELSE 'High Satisfaction' END AS satisfaction_group,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS attritions,
    ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM fact_employees
GROUP BY overtime, satisfaction_group
ORDER BY attrition_rate_pct DESC;

CREATE VIEW vw_risk_quartile_summary AS
SELECT
    r.risk_quartile,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN f.attrition = 'Yes' THEN 1 ELSE 0 END) AS actual_attritions,
    ROUND(100.0 * SUM(CASE WHEN f.attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM vw_employee_risk_score r
JOIN fact_employees f ON r.employee_number = f.employee_number
GROUP BY r.risk_quartile;