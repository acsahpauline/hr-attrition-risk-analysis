CREATE TABLE dim_department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50)
);

CREATE TABLE dim_tenure_band (
    tenure_band_id INT PRIMARY KEY,
    band_label VARCHAR(20),
    min_years INT,
    max_years INT
);

CREATE TABLE fact_employees (
    employee_number INT PRIMARY KEY,
    age INT,
    attrition VARCHAR(5),
    business_travel VARCHAR(30),
    daily_rate INT,
    distance_from_home INT,
    education INT,
    education_field VARCHAR(30),
    environment_satisfaction INT,
    gender VARCHAR(10),
    hourly_rate INT,
    job_involvement INT,
    job_level INT,
    job_role VARCHAR(30),
    job_satisfaction INT,
    marital_status VARCHAR(20),
    monthly_income INT,
    monthly_rate INT,
    num_companies_worked INT,
    overtime VARCHAR(5),
    percent_salary_hike INT,
    performance_rating INT,
    relationship_satisfaction INT,
    stock_option_level INT,
    total_working_years INT,
    training_times_last_year INT,
    work_life_balance INT,
    years_at_company INT,
    years_in_current_role INT,
    years_since_last_promotion INT,
    years_with_curr_manager INT,
    department_id INT REFERENCES dim_department(department_id),
    tenure_band_id INT REFERENCES dim_tenure_band(tenure_band_id)
);