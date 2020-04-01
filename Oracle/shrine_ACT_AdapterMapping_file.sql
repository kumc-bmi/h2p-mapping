set echo on;
--------------------------------------------------------------------------
---------------- Adapter Mapping COVID diag parent with no ICD10CM
-------------------------------------------------------------------------- 
whenever sqlerror continue;
drop table temp_act_adapter_mapping2;
whenever sqlerror exit sql.sqlcode
;
create table temp_act_adapter_mapping2
parallel 15
NOLOGGING 
as
with t1 as
(
select c_fullname from BLUEHERONMETADATA.ACT_COVID
where c_fullname like '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0037088\%'
and c_basecode not like 'ICD10CM%'
)
,t2 as
(
select c_fullname from BLUEHERONMETADATA.ACT_COVID
where c_fullname like '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0037088\%'
)
,act_diag_folder_map as
(
select 
    '\\ACT_COVID_V1' ||t1.c_fullname shrine_term1,
    '\\ACT_COVID_V1' ||t2.c_fullname shrine_term2
from t1,t2
where t2.c_fullname like ( t1.c_fullname || '%')
)
,act_daig_map as
(
select /*+ parallel */
    '\\ACT_COVID_V1' || sh.C_FULLNAME shrine_term,
    '\\i2b2_Diagnoses'||he.C_FULLNAME heron_term
from shrine_ont_act.ACT_COVID sh
join BLUEHERONMETADATA.heron_terms he
  on replace(sh.c_basecode,'ICD10CM:','ICD10:') = he.c_basecode
where sh.c_basecode like '%ICD10CM%'
)
select 
    act_diag_folder_map.shrine_term1 shrine_term,
    act_daig_map.heron_term from act_diag_folder_map
join act_daig_map
    on act_daig_map.shrine_term=act_diag_folder_map.shrine_term2
;
--------------------------------------------------------------------------
---------------- Adapter Mapping
--------------------------------------------------------------------------  
whenever sqlerror continue;
drop table temp_act_adapter_mapping;
whenever sqlerror exit sql.sqlcode
;
create table temp_act_adapter_mapping
parallel 15
NOLOGGING 
as
--------------------------------------------------------------------------
---------------- Manual Mapping
-------------------------------------------------------------------------- 
select *
-- ACT_DEMO_MANUAL_MAPPING table is version controled 
-- at shrine_ACT_MANUAL_MAPPING_table.csv
from shrine_ont_act.ACT_MANUAL_MAPPING
union all
--------------------------------------------------------------------------
---------------- Demographics (NCATS_DEMOGRAPHICS)
-------------------------------------------------------------------------- 
-- Demographics is mapped with using metadata approach.
--------------------------------------------------------------------------
---------------- DX ICD 10-9 (NCATS_ICD10_ICD9_DX_V1)
--------------------------------------------------------------------------
select 
'\\ACT_DX_10_9' || sh.C_FULLNAME shrine_term,
'\\i2b2_Diagnoses'||he.C_FULLNAME heron_term
from shrine_ont_act.NCATS_ICD10_ICD9_DX_V1 sh
join BLUEHERONMETADATA.heron_terms he
  on replace(sh.c_basecode,'ICD9CM:','ICD9:') = he.c_basecode
where he.c_fullname like '\i2b2\Diagnoses\ICD9%'
--25239/16291 out of 25,393/16,438
union all
select 
'\\ACT_DX_10_9' || sh.C_FULLNAME shrine_term,
'\\i2b2_Diagnoses'||he.C_FULLNAME heron_term
from shrine_ont_act.NCATS_ICD10_ICD9_DX_V1 sh
join BLUEHERONMETADATA.heron_terms he
  on replace(sh.c_basecode,'ICD10CM:','ICD10:') = he.c_basecode
--102,531/91,310 out off --102,757/91,586
union all
--------------------------------------------------------------------------
---------------- DX ICD9 (ACT_ICD9CM_DX_2018AA)
--------------------------------------------------------------------------
select 
'\\ACT_DX_ICD9_2018' || sh.C_FULLNAME shrine_term,
'\\i2b2_Diagnoses'||he.C_FULLNAME heron_term
from shrine_ont_act.ACT_ICD9CM_DX_2018AA sh
inner join BLUEHERONMETADATA.HERON_TERMS he
  on replace(sh.C_BASECODE,'ICD9CM', 'ICD9') = he.c_basecode
  --79895
  where he.C_FULLNAME like '\i2b2\Diagnoses\ICD9\%'  
  --17736
union all
select
'\\ACT_DX_ICD9_2018' || not_default_icd9.C_FULLNAME shrine_term,
'\\i2b2_Diagnoses'||ht.C_FULLNAME heron_term
from
(
  select * 
  from shrine_ont_act.ACT_ICD9CM_DX_2018AA 
  where c_basecode not in 
    (
    select 
    distinct (sh.C_BASECODE)
    from shrine_ont_act.ACT_ICD9CM_DX_2018AA sh
    inner join BLUEHERONMETADATA.HERON_TERMS he
      on replace(sh.C_BASECODE,'ICD9CM', 'ICD9') = he.c_basecode
      --79895
      where he.C_FULLNAME like '\i2b2\Diagnoses\ICD9\%'
      --17736
    )
)not_default_icd9
--127
left join BLUEHERONMETADATA.HERON_TERMS ht
  on replace(not_default_icd9.C_BASECODE,'ICD9CM', 'ICD9') = ht.c_basecode
  where ht.C_FULLNAME like '\i2b2\Diagnoses\%'
--126
--DX ICD9 17,862 out of 17866
union all
--------------------------------------------------------------------------
---------------- ACT Diagnoses ICD-10	(ACT_ICD10CM_DX_2018AA)
--------------------------------------------------------------------------
-- join based on ICD10
select /*+ parallel */
'\\ACT_DX_ICD10_2018' || sh.C_FULLNAME shrine_term,
'\\i2b2_Diagnoses'||he.C_FULLNAME heron_term
from shrine_ont_act.ACT_ICD10CM_DX_2018AA sh
join BLUEHERONMETADATA.heron_terms he
  on replace(sh.c_basecode,'ICD10CM:','ICD10:') = he.c_basecode
--91830 out of 94505
union all
-- which are not joined based on ICD10 will be mapped less than 10
select /*+ parallel */ 
'\\ACT_DX_ICD10_2018' || sh.C_FULLNAME shrine_term,
'\\i2b2_Demographics' || '\i2b2\Demographics\LESS_THAN_10\' heron_term
from shrine_ont_act.ACT_ICD10CM_DX_2018AA sh
where c_basecode NOT in
  (
  select /*+ parallel */ sh.c_basecode
  from shrine_ont_act.ACT_ICD10CM_DX_2018AA sh
  join BLUEHERONMETADATA.heron_terms he
    on replace(sh.c_basecode,'ICD10CM:','ICD10:') = he.c_basecode
  )
union all
--------------------------------------------------------------------------
---------------- ACT_COVID_V1	(ACT_COVID)
--------------------------------------------------------------------------
select /*+ parallel */
'\\ACT_COVID_V1' || sh.C_FULLNAME shrine_term,
'\\i2b2_Diagnoses'||he.C_FULLNAME heron_term
from shrine_ont_act.ACT_COVID sh
join BLUEHERONMETADATA.heron_terms he
  on replace(sh.c_basecode,'ICD10CM:','ICD10:') = he.c_basecode
where sh.c_basecode like '%ICD10CM%'
union all
-- which are not joined based on ICD10 will be mapped less than 10
select /*+ parallel */ 
'\\ACT_COVID_V1' || sh.C_FULLNAME shrine_term,
'\\i2b2_Demographics' || '\i2b2\Demographics\LESS_THAN_10\' heron_term
from shrine_ont_act.ACT_COVID sh
where c_basecode like '%ICD10CM%'
    and sh.c_basecode NOT in
  (
  select /*+ parallel */ sh.c_basecode
  from shrine_ont_act.ACT_COVID sh
  join BLUEHERONMETADATA.heron_terms he
    on replace(sh.c_basecode,'ICD10CM:','ICD10:') = he.c_basecode
  )
union all
--example
--\\ACT_COVID_V1\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0037088\SNOMED_3947197012\ICD10CM_J22\	\\i2b2_Diagnoses\i2b2\Diagnoses\ICD10\A20098492\A18916341\A18913759\J22\
--\\ACT_COVID_V1\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0037088\SNOMED_3947183016\ICD10CM_U07.1\	\\i2b2_Demographics\i2b2\Demographics\LESS_THAN_10\
-- for parent folder without ICD10 code.
--------------------------------------------------------------------------
---------------- Procedure ICD9 (ACT_ICD9CM_PX_2018AA)
--------------------------------------------------------------------------
select
'\\ACT_PX_ICD9_2018' || sh.C_FULLNAME shrine_term,
'\\i2b2_Procedures'||he.C_FULLNAME heron_term
from shrine_ont_act.ACT_ICD9CM_PX_2018AA sh
inner join BLUEHERONMETADATA.HERON_TERMS he
  on replace(sh.C_BASECODE,'ICD9PROC', 'ICD9') = he.c_basecode
  where he.C_FULLNAME like '\i2b2\Procedures\%'
  -- 4323
union all
select
'\\ACT_PX_ICD9_2018' || not_default_proc.C_FULLNAME shrine_term,
'\\i2b2_Procedures'||ht.C_FULLNAME heron_term
from 
  (
  select 
  *
  from shrine_ont_act.ACT_ICD9CM_PX_2018AA sh
  where sh.c_basecode not in 
    (
    select 
    distinct (sh.c_basecode)
    from shrine_ont_act.ACT_ICD9CM_PX_2018AA sh
    inner join BLUEHERONMETADATA.HERON_TERMS he
      on replace(sh.C_BASECODE,'ICD9PROC', 'ICD9') = he.c_basecode
      where he.C_FULLNAME like '\i2b2\Procedures\%'
      -- 4323
    )
  )not_default_proc
--343
join BLUEHERONMETADATA.HERON_TERMS ht
  on replace(not_default_proc.C_BASECODE,'ICD9PROC', 'ICD9') = ht.c_basecode
--341
-- union all 4664 out of 4666
union all
--------------------------------------------------------------------------
---------------- ACT Procedures ICD-10-PCS	
---------------- table_cd: ACT_PX_ICD10_2018	
---------------- table_name: ACT_ICD10PCS_PX_2018AA
--------------------------------------------------------------------------
-- join based on ICD10
select /*+ parallel */
'\\ACT_PX_ICD10_2018' || sh.C_FULLNAME shrine_term,
'\\PCORI_PROCEDURE'||he.C_FULLNAME heron_term
from shrine_ont_act.ACT_ICD10PCS_PX_2018AA sh
inner join BLUEHERONMETADATA.HERON_TERMS he
  on replace(sh.C_BASECODE,'ICD10PCS', 'ICD10') = he.c_basecode
  where he.C_FULLNAME like '\PCORI\PROCEDURE\%'
  -- count/distinct
  -- 176544/176544 out of 190177/190176
union all
-- which are not joined based on ICD10 will be mapped less than 10
select /*+ parallel */ 
'\\ACT_PX_ICD10_2018' || sh.C_FULLNAME shrine_term,
'\\i2b2_Demographics' || '\i2b2\Demographics\LESS_THAN_10\' heron_term
from shrine_ont_act.ACT_ICD10PCS_PX_2018AA sh
where c_basecode not in
(
select /*+ parallel */
sh.c_basecode
from shrine_ont_act.ACT_ICD10PCS_PX_2018AA sh
inner join BLUEHERONMETADATA.HERON_TERMS he
  on replace(sh.C_BASECODE,'ICD10PCS', 'ICD10') = he.c_basecode
  where he.C_FULLNAME like '\PCORI\PROCEDURE\%'
  -- count/distinct
  -- 176544/176544 out of 190177/190176
)
union all
--------------------------------------------------------------------------
---------------- ACT Procedures CPT-4	
---------------- table_cd: ACT_PX_CPT_2018
---------------- table_name: ACT_CPT_PX_2018AA
--------------------------------------------------------------------------
select /*+ parallel */
'\\ACT_PX_CPT_2018' || sh.C_FULLNAME shrine_term,
'\\PCORI_PROCEDURE'||he.C_FULLNAME heron_term
from shrine_ont_act.ACT_CPT_PX_2018AA sh
inner join BLUEHERONMETADATA.HERON_TERMS he
  on replace(sh.C_BASECODE,'CPT4', 'CPT') = he.c_basecode
  where he.C_FULLNAME like '\PCORI\PROCEDURE\%'
  -- count/distinct
  --12750/12750 out of 13754/13754
union all
select /*+ parallel */ 
'\\ACT_PX_CPT_2018' || sh.C_FULLNAME shrine_term,
'\\i2b2_Demographics' || '\i2b2\Demographics\LESS_THAN_10\'heron_term
from shrine_ont_act.ACT_CPT_PX_2018AA sh
where c_basecode not in
  (
  select /*+ parallel */
  sh.c_basecode
  from shrine_ont_act.ACT_CPT_PX_2018AA sh
  inner join BLUEHERONMETADATA.HERON_TERMS he
    on replace(sh.C_BASECODE,'CPT4', 'CPT') = he.c_basecode
    where he.C_FULLNAME like '\PCORI\PROCEDURE\%'
     -- count/distinct
     --12750/12750 out of 13754/13754
  )
union all
--------------------------------------------------------------------------
---------------- ACT Procedures HCPCS	
---------------- table_cd: ACT_PX_HCPCS_2018
---------------- table_name: ACT_HCPCS_PX_2018AA
--------------------------------------------------------------------------
-- C_BASECODE prefix (HCPCS) is the same on HERON and SHRINE
-- No Need to do this mapping and will do 1 to 1 mapping
-- blueheronmetadata.ACT_HCPCS_PX_2018AA will able to query childs as well.
--------------------------------------------------------------------------
---------------- LABS (ncats_labs)
--------------------------------------------------------------------------
select  
'\\ACT_LAB' || sh.C_FULLNAME shrine_term,
'\\i2b2_Laboratory Tests'||he.C_FULLNAME heron_term
from shrine_ont_act.ncats_labs sh
join BLUEHERONMETADATA.HERON_TERMS he
  on sh.c_basecode = he.c_basecode
--289 out of 288
union all
--------------------------------------------------------------------------
---------------- ACT Laboratory Tests (Provisional)		
---------------- table_cd: ACT_LAB_LOINC_2018
---------------- table_name: ACT_LOINC_LAB_2018AA
--------------------------------------------------------------------------
select 
'\\ACT_LAB_LOINC_2018' || sh.C_FULLNAME shrine_term,
'\\i2b2_Laboratory Tests'||he.C_FULLNAME heron_term
from shrine_ont_act.ACT_LOINC_LAB_2018AA sh
join BLUEHERONMETADATA.HERON_TERMS he
  on sh.c_basecode = he.c_basecode
  -- 121423/62727 out of 142860/79347
union all
select /*+ parallel */ 
'\\ACT_LAB_LOINC_2018' || sh.C_FULLNAME shrine_term,
'\\i2b2_Demographics' || '\i2b2\Demographics\LESS_THAN_10\'heron_term
from shrine_ont_act.ACT_LOINC_LAB_2018AA sh
where c_basecode not in
  (
  select /*+ parallel */
  sh.c_basecode
  from shrine_ont_act.ACT_LOINC_LAB_2018AA sh
  join BLUEHERONMETADATA.HERON_TERMS he
    on sh.c_basecode = he.c_basecode
    -- 121423/62727 out of 142860/79347
  )
--23899
--------------------------------------------------------------------------
---------------- ACT Visit Details	ACT_VISIT	NCATS_VISIT_DETAILS
---------------- table_cd: ACT_VISIT
---------------- table_name: NCATS_VISIT_DETAILS
--------------------------------------------------------------------------
/*
1. Dan: DEM|AGEATV (concept_dimension) are pre calculated version of visit_dimension.
2. No need to do any mapping for `\ACT\Visit Details\Age at visit\%` as it depends on 
   visit_dimension and it works out of the box with HERON.
3. Length of stay is on avialbe from UHC (HOSPTAL LOS) and it stored in obs_fact as 
nval_num which I dont know how to map, and we dont have that info in vist dimension (ACT 
expects to be in visit dimension)
4. \\ACT_VISIT\ACT\Visit Details\Visit type\  need to be mapped manually and they are in
  shrine_ACT_MANUAL_MAPPING_table.csv
5. All Visit 1 to 1 mapping are alos stored in shrine_ACT_MANUAL_MAPPING_table.csv 
   to make tracking easier.
*/
;
exit;
