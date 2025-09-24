# 🕵️ Fraud Detection Project

A project for detecting fraudulent financial transactions using data cleaning, outlier handling, and exploratory data analysis (EDA).  
Final insights are visualized in **Power BI** for interactive dashboards.

---

## 📂 Project Structure
- `notebooks/` → Jupyter notebooks for data cleaning, preprocessing, and EDA.
- `data/` → Raw and processed datasets (not fully uploaded due to size/privacy).
- `powerbi/` → Power BI dashboard file (`.pbix`).
- `README.md` → Project documentation.

---

## 🛠️ Workflow

### 1. Data Cleaning 🧹
- Handle missing values.
- Fix invalid entries in columns such as `birth_year` and `current_age`.
- Convert `date` column to proper datetime format.
- Remove or correct unrealistic values.

### 2. Outlier Handling 📊
- Applied **capping/transformation** methods on financial features:
  - `amount`
  - `yearly_income`
  - `credit_score`
  - `total_debt`
  - `credit_limit`
- Created log-transformed features (e.g., `amount_log`) for stability.

### 3. Exploratory Data Analysis 🔍
- Analyzed **categorical features** (e.g., merchant, card type, location).
- Explored **numerical features** distributions.
- Binary relationship analysis with target `is_fraud`.
- Key insights:
  - Houston city shows the highest online merchant activity.
  - Females perform more transactions than males.
  - No cards detected on the dark web.
  - California has the most active merchants.
  - Mastercard Debit transactions dominate, especially in restaurants & supermarkets.
  - Weekly transaction distribution is nearly uniform.

### 4. Visualization 📈
- Used **Matplotlib** & **Seaborn** for in-notebook plots.
- Built an **interactive Power BI dashboard** for business-level insights.

---

### 5. SQL Views & Modeling 🗄️

We also used SQL to prepare and model the data before analysis:

- **Views**:
  - Created SQL views to simplify repeated queries (e.g., clean transactions view with only valid ages, income, and amounts).
  - Example: `fraud_cleaned_view` containing cleaned records ready for BI tools.

- **Modeling Queries**:
  - Aggregated transactions per **merchant**, **card type**, **city**, and **time (weekly/monthly)**.
  - Built fraud rate KPIs using SQL joins and groupings.
  - Example queries:
    - Fraud transactions by city.
    - Top merchants by fraud count.
    - Distribution of card types used in fraud cases.
