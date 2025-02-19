# Screening and Preventive Mammographies Analysis – FY 2021

## Author: Brianna Carnagie  
**Organization:** Centers for Medicare and Medicaid Services 

## Data Disclaimer
⚠️ **This project does NOT include real CMS data.**  
For security and compliance reasons, all data references have been replaced with **synthetic placeholders**.

## Objective  
This analysis aims to determine the total number of **screening and preventive mammograms** performed in **Fiscal Year 2021**. The goal is to understand the utilization of these services and identify trends in healthcare access and preventive care.

## Background  
Mammography is a critical tool in the early detection of **breast cancer**, with **screening mammograms** recommended for early detection in asymptomatic patients. Medicare and other health programs cover screening mammograms to promote **preventive healthcare**. By analyzing claims data, we can evaluate the **volume and accessibility** of these services across different patient populations.

## Methodology  
1. **Extracting Relevant Claims:** Claims are filtered using **Healthcare Common Procedure Coding System (HCPCS) codes** that identify mammography procedures.
2. **Filtering Data:** Claims that only bill for the **professional component (modifier ‘26’)** are removed to focus on complete service events.
3. **Grouping Services:** Services performed within **three days** for the same patient are considered a single screening event to avoid duplicate counts.
4. **Classifying Claims:** Claims are categorized into different **screening types** based on HCPCS codes:
   - **Screening Mammography & Tomosynthesis** (both codes present)
   - **Screening Mammography Only** (mammography code only)
   - **Screening Tomosynthesis Only** (tomosynthesis code only)
5. **Aggregating Data:** The final dataset provides:
   - Total number of **screening mammograms performed** in FY 2021.
   - Total **unique beneficiaries** who received screening services.

## HCPCS Codes Used  
- **77063** – Digital breast tomosynthesis (3D mammogram).
- **77067** – Screening mammography (standard 2D mammogram).

## Expected Outcome  
This analysis will help policymakers, healthcare providers, and researchers:
- Understand the **utilization rates** of screening mammography services.
- Assess **preventive healthcare access** across different patient demographics.
- Identify **potential gaps in preventive screening coverage**.

## 🔄 How This Works

This repository consists of **two main components**:

1. **Python Script (`generate_synthetic_data.py`)**  
   - Generates a **synthetic dataset** that mimics Medicare claims data.  
   - Saves the dataset as **`synthetic_mammography_claims_sql_compatible.csv`**.  
   - This dataset serves as the **source table** for SQL analysis.

2. **SQL Analysis (`mammography_analysis.sql`)**  
   - Runs queries on the **synthetic dataset** to analyze **screening mammographies**.  
   - The dataset is **imported into SQL as `mammography_claims`** before running queries.  

**🛠 Workflow:**
1. **Run the Python script** to generate `synthetic_mammography_claims_sql_compatible.csv`.  
2. **Import the CSV into your SQL database**.  
3. **Run the SQL script**, which queries `mammography_claims`.

## Generating Synthetic Data

### Run Locally (VS Code, Terminal, Jupyter)

1. Ensure Python is installed.

2. Install dependencies:

`pip install pandas`

3. Run the script:

`python generate_synthetic_data.py`

4. The dataset will be saved to your local machine.

  * Windows Users: The file will be in your current directory. If you get a permission error, update the script to save in `C:\Users\YourName\Documents\:`

    `df.to_csv("C:/Users/YourName/Documents/synthetic_mammography_claims.csv", index=False)`

  * Mac/Linux Users: Use a valid writable directory, such as:

    `df.to_csv("/Users/yourname/Documents/synthetic_mammography_claims.csv", index=False)`

### Run in Google Colab (No Installation Needed)

1. Click the button below to run the script in the cloud.

2. After running, download the CSV manually:

`from google.colab import files`
`files.download("/content/synthetic_mammography_claims_sql_compatible.csv")`

### 🛠 Troubleshooting

❌ Permission Denied / Read-Only Error?
✔️ Ensure the script saves the file in a writable folder on your machine.

## Additional Notes  
- This analysis follows **Medicare guidelines** for preventive screening services.
- The methodology ensures an accurate count by **removing duplicates** and grouping related services.

