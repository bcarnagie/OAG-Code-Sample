-- Screening and Preventive Mammographies Analysis - FY 2021

-- Step 1: Import & Clean Data
-- Extracts claims data from institutional and non-institutional sources,
-- keeping relevant fields like beneficiary ID, claim ID, service date, HCPCS codes, and modifiers.
CREATE TABLE mammography_clean AS
SELECT 
    bene_id,  -- Beneficiary ID
    clm_id,  -- Claim ID
    hcpcs_cd,  -- HCPCS code for screening mammography procedures
    first_srvc_dt,  -- Date of service
    bill_type,  -- Type of billing classification
    NCH_CLM_TYPE_CD,  -- Claim type code
    clm_source,  -- Indicates institutional or non-institutional source
    CONCAT_WS(',', hcpcs_1st_mdfr_cd, hcpcs_2nd_mdfr_cd, hcpcs_3rd_mdfr_cd, hcpcs_4th_mdfr_cd, hcpcs_5th_mdfr_cd) AS modifiers -- Merges all modifiers into a single field
FROM (
    SELECT 
        bene_id, 
        clm_id, 
        hcpcs_cd,
        first_srvc_dt,
        NULL AS bill_type,
        NCH_CLM_TYPE_CD,
        'NONINST' AS clm_source,
        hcpcs_1st_mdfr_cd, hcpcs_2nd_mdfr_cd, hcpcs_3rd_mdfr_cd, hcpcs_4th_mdfr_cd, hcpcs_5th_mdfr_cd
    FROM claims_data_noninst_2021
    WHERE hcpcs_cd IN ('77063', '77067') -- Filtering for relevant mammography HCPCS codes
        AND first_srvc_dt BETWEEN '2021-01-01' AND '2021-12-31' -- Restricting data to FY 2021

    UNION ALL

    SELECT 
        bene_id, 
        clm_id, 
        hcpcs_cd,
        first_srvc_dt,
        bill_type,
        NCH_CLM_TYPE_CD,
        'INST' AS clm_source,
        hcpcs_1st_mdfr_cd, hcpcs_2nd_mdfr_cd, hcpcs_3rd_mdfr_cd, hcpcs_4th_mdfr_cd, hcpcs_5th_mdfr_cd
    FROM claims_data_inst_2021
    WHERE hcpcs_cd IN ('77063', '77067') 
        AND first_srvc_dt BETWEEN '2021-01-01' AND '2021-12-31'
);

-- Step 2: Exclude claims with modifier '26'
-- Modifier 26 indicates professional component only, so we exclude these claims.
CREATE TABLE mammography_filtered AS
SELECT *
FROM mammography_clean
WHERE NOT FIND_IN_SET('26', modifiers) > 0;

-- Step 3: Use LAG function to group services within a 3-day window
-- This ensures multiple screenings within a short period for the same beneficiary are counted as one event.
CREATE TABLE mammography_lagged AS
SELECT 
    bene_id,
    clm_id,
    hcpcs_cd,
    first_srvc_dt,
    modifiers,
    LAG(first_srvc_dt) OVER (PARTITION BY bene_id ORDER BY first_srvc_dt) AS prev_service_date, -- Gets previous claim date for the same beneficiary
    CASE 
        WHEN first_srvc_dt <= LAG(first_srvc_dt) OVER (PARTITION BY bene_id ORDER BY first_srvc_dt) + INTERVAL 3 DAY 
        THEN 0 ELSE 1 -- If the gap is more than 3 days, mark as a new group
    END AS new_group_flag
FROM mammography_filtered;

-- Step 4: Assign group IDs using cumulative sum
-- Groups claims together that fall within the 3-day window.
CREATE TABLE mammography_grouped AS
SELECT 
    bene_id,
    SUM(new_group_flag) OVER (PARTITION BY bene_id ORDER BY first_srvc_dt) AS group_id, -- Assigns a group ID based on 3-day rule
    MIN(first_srvc_dt) AS grouped_service_date, -- Earliest service date in the group
    COUNT(DISTINCT clm_id) AS num_claims, -- Number of claims in the group
    GROUP_CONCAT(DISTINCT hcpcs_cd ORDER BY hcpcs_cd ASC) AS combined_hcpcs_codes, -- Collects all HCPCS codes in the group
    GROUP_CONCAT(DISTINCT modifiers ORDER BY modifiers ASC) AS combined_modifiers -- Collects all modifiers in the group
FROM mammography_lagged
GROUP BY bene_id, group_id;

-- Step 5: Classify claims based on HCPCS codes
-- Determines whether the grouped claim is for a screening mammogram, tomosynthesis, or both.
CREATE TABLE mammography_final AS
SELECT 
    bene_id,
    grouped_service_date AS first_srvc_dt, -- Date of grouped service event
    combined_hcpcs_codes,
    combined_modifiers,
    CASE 
        WHEN FIND_IN_SET('77067', combined_hcpcs_codes) > 0 AND FIND_IN_SET('77063', combined_hcpcs_codes) > 0 THEN 'Screening Mammography & Tomosynthesis'
        WHEN FIND_IN_SET('77067', combined_hcpcs_codes) > 0 AND FIND_IN_SET('77063', combined_hcpcs_codes) = 0 THEN 'Screening Mammography'
        WHEN FIND_IN_SET('77063', combined_hcpcs_codes) > 0 AND FIND_IN_SET('77067', combined_hcpcs_codes) = 0 THEN 'Screening Tomosynthesis'
        ELSE 'Uncategorized'
    END AS claim_type -- Categorization of screening type
FROM mammography_grouped;

-- Step 6: Final Output
-- Provides total count of claims and unique beneficiaries for each claim type.
SELECT 
    claim_type,
    COUNT(*) AS total_claims, -- Total number of claims per category
    COUNT(DISTINCT bene_id) AS distinct_beneficiaries -- Number of unique patients who received the screenings
FROM mammography_final
GROUP BY claim_type
ORDER BY claim_type;
