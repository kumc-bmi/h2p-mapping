set echo on;
--------------------------------------------------------------------------
---------------- Adapter Mapping COVID diag parent with no ICD10CM
-------------------------------------------------------------------------- 

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
