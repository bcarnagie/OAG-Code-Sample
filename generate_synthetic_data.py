import pandas as pd
import random
from datetime import datetime, timedelta

# Number of records to generate
num_records = 5000  

# Generate random beneficiary IDs
bene_ids = [random.randint(100000, 999999) for _ in range(num_records)]

# Generate random claim IDs
clm_ids = [random.randint(1000000, 9999999) for _ in range(num_records)]

# Assign HCPCS codes based on screening types in SQL
hcpcs_codes = random.choices(['77063', '77067'], weights=[0.4, 0.6], k=num_records)

# Generate service dates, some falling outside FY 2021 for added variety
start_date = datetime(2020, 10, 1)
end_date = datetime(2022, 3, 31)
service_dates = [start_date + timedelta(days=random.randint(0, 547)) for _ in range(num_records)]

# Introduce some beneficiaries receiving multiple services within a 3-day window
additional_dates = []
for i in range(num_records):
    if random.random() < 0.2:  # 20% chance a beneficiary gets another service within 3 days
        additional_dates.append(service_dates[i] + timedelta(days=random.randint(1, 3)))
    else:
        additional_dates.append(service_dates[i])

# Randomly assign institutional or non-institutional claim sources
claim_sources = random.choices(['INST', 'NONINST'], k=num_records)

# Random bill type for institutional claims (set NULL for non-institutional claims)
bill_types = [random.choice(['0111', '0123', None]) if claim_sources[i] == 'INST' else None for i in range(num_records)]

# Random claim type codes (Medicare Part B claims classification)
nch_clm_type_codes = random.choices(['11', '12', '13', '81', '82'], k=num_records)

# Generate random modifiers, some needing exclusion (like '26')
modifiers_list = ['26', 'GG', 'TC', '']
modifiers = [random.choices(modifiers_list, weights=[0.2, 0.2, 0.2, 0.4])[0] for _ in range(num_records)]

# Create DataFrame to match SQL schema
df = pd.DataFrame({
    'bene_id': bene_ids,
    'clm_id': clm_ids,
    'hcpcs_cd': hcpcs_codes,
    'first_srvc_dt': [date.strftime('%Y-%m-%d') for date in additional_dates],
    'bill_type': bill_types,
    'NCH_CLM_TYPE_CD': nch_clm_type_codes,
    'clm_source': claim_sources,
    'modifiers': modifiers
})


# Save file
df.to_csv("synthetic_mammography_claims_sql.csv", index=False)

print("✅ Synthetic dataset created: synthetic_mammography_claims_sql.csv")
