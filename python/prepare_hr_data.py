import pandas as pd

df = pd.read_csv("data/raw/hr_attrition.csv")

department_map = {
    "Sales": 1,
    "Research & Development": 2,
    "Human Resources": 3
}

df["department_id"] = df["Department"].map(department_map)

def tenure_band(years):
    if years <= 2:
        return 1
    elif years <= 5:
        return 2
    elif years <= 10:
        return 3
    else:
        return 4

df["tenure_band_id"] = df["YearsAtCompany"].apply(tenure_band)

df.columns = [
    "age", "attrition", "business_travel", "daily_rate", "department",
    "distance_from_home", "education", "education_field", "employee_count",
    "employee_number", "environment_satisfaction", "gender", "hourly_rate",
    "job_involvement", "job_level", "job_role", "job_satisfaction",
    "marital_status", "monthly_income", "monthly_rate", "num_companies_worked",
    "over18", "overtime", "percent_salary_hike", "performance_rating",
    "relationship_satisfaction", "standard_hours", "stock_option_level",
    "total_working_years", "training_times_last_year", "work_life_balance",
    "years_at_company", "years_in_current_role", "years_since_last_promotion",
    "years_with_curr_manager", "department_id", "tenure_band_id"
]

drop_columns = ["employee_count", "standard_hours", "over18", "department"]
df = df.drop(columns=drop_columns)

df.to_csv("data/staging/hr_attrition_prepared.csv", index=False)

print(f"Total rows: {len(df)}")
print(df[["employee_number", "department_id", "years_at_company", "tenure_band_id"]].head(10))