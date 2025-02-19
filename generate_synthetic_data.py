import pandas as pd
import random
from datetime import datetime, timedelta

# Number of records to generate
num_records = 5000

# Generate random beneficiary IDs
bene_ids = [random.randint(100000, 999999) for _ in range(num_records)]

# Generate random claim IDs
clm_ids = [random.randint(1000000, 9999999) for _ in range(num_records)]

# Randomly assign HCPCS codes for mammography
hcpcs_codes = random.choices(['77063', '77067'], weights=[0.4, 0.6], k=num_records)

# Generate service dates within FY 2021
start_date = datetime(2021, 1, 1)
end_date = datetime(2021, 12, 31)
service_dates = [start_date + timedelta(days=random.randint(0, 364)) for _ in range(num_records)]

# Random claim types (institutional or non-institutional)
nch_clm_type_codes = random.choices(['11', '12', '13', '81', '82'], k=num_records)

# Random modifiers (some '26' need to be filtered out)
modifiers = random.choices(['', '26', 'GG', 'TC'], weights=[0.6, 0.2, 0.1, 0.1], k=num_records)

# Create DataFrame
df = pd.DataFrame({
    'bene_id': bene_ids,
    'clm_id': clm_ids,
    'hcpcs_cd': hcpcs_codes,
    'first_srvc_dt': [date.strftime('%Y-%m-%d') for date in service_dates],
    'NCH_CLM_TYPE_CD': nch_clm_type_codes,
    'modifiers': modifiers
})

# Save file
df.to_csv("synthetic_mammography_claims.csv", index=False)

print("✅ Synthetic dataset created: synthetic_mammography_claims.csv")
