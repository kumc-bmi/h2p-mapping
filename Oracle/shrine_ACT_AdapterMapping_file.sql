set echo on;
--------------------------------------------------------------------------
---------------- Adapter Mapping
--------------------------------------------------------------------------  
whenever sqlerror continue;
drop table temp_act_adapter_mapping;
whenever sqlerror exit sql.sqlcode;
create table temp_act_adapter_mapping
parallel 15
NOLOGGING 
as
--------------------------------------------------------------------------
---------------- Demographics
-------------------------------------------------------------------------- 
select *
from shrine_ont_act.ACT_DEMO_MANUAL_MAPPING
union all
select '\\\\ACT_DEMO' || sh.c_fullname, '\\\\i2b2_Demographics' || he.c_fullname
from SHRINE_ONT_ACT.NCATS_DEMOGRAPHICS sh
join BLUEHERONMETADATA.HERON_TERMS he
  on sh.c_basecode = he.c_basecode
union all
--------------------------------------------------------------------------
---------------- DX ICD 10-9
--------------------------------------------------------------------------
select 
'\\\\ACT_DX_10_9' || sh.C_FULLNAME shrine_term,
'\\\\i2b2_Diagnoses'||he.C_FULLNAME heron_term
from shrine_ont_act.NCATS_ICD10_ICD9_DX_V1 sh
join BLUEHERONMETADATA.heron_terms he
  on replace(sh.c_basecode,'ICD9CM:','ICD9:') = he.c_basecode
where he.c_fullname like '\i2b2\Diagnoses\ICD9%'
--25239/16291 out of 25,393/16,438
union all
select 
'\\\\ACT_DX_10_9' || sh.C_FULLNAME shrine_term,
'\\\\i2b2_Diagnoses'||he.C_FULLNAME heron_term
from shrine_ont_act.NCATS_ICD10_ICD9_DX_V1 sh
join BLUEHERONMETADATA.heron_terms he
  on replace(sh.c_basecode,'ICD10CM:','ICD10:') = he.c_basecode
--102,531/91,310 out off --102,757/91,586
union all
--------------------------------------------------------------------------
---------------- DX ICD9
--------------------------------------------------------------------------
select 
'\\\\ACT_DX_ICD9_2018' || sh.C_FULLNAME shrine_term,
'\\\\i2b2_Diagnoses'||he.C_FULLNAME heron_term
from shrine_ont_act.ACT_ICD9CM_DX_2018AA sh
inner join BLUEHERONMETADATA.HERON_TERMS he
  on replace(sh.C_BASECODE,'ICD9CM', 'ICD9') = he.c_basecode
  --79895
  where he.C_FULLNAME like '\i2b2\Diagnoses\ICD9\%'  
  --17736
union all
select
'\\\\ACT_DX_ICD9_2018' || not_default_icd9.C_FULLNAME shrine_term,
'\\\\i2b2_Diagnoses'||ht.C_FULLNAME heron_term
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
---------------- Procedure ICD9
--------------------------------------------------------------------------
select
'\\\\ACT_PX_ICD9_2018' || sh.C_FULLNAME shrine_term,
'\\\\i2b2_Procedures'||he.C_FULLNAME heron_term
from shrine_ont_act.ACT_ICD9CM_PX_2018AA sh
inner join BLUEHERONMETADATA.HERON_TERMS he
  on replace(sh.C_BASECODE,'ICD9PROC', 'ICD9') = he.c_basecode
  where he.C_FULLNAME like '\i2b2\Procedures\%'
  -- 4323
union all
select
'\\\\ACT_PX_ICD9_2018' || not_default_proc.C_FULLNAME shrine_term,
'\\\\i2b2_Procedures'||ht.C_FULLNAME heron_term
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
---------------- LABS
--------------------------------------------------------------------------
select  
'\\\\ACT_LAB' || sh.C_FULLNAME shrine_term,
'\\\\i2b2_Laboratory Tests'||he.C_FULLNAME heron_term
from shrine_ont_act.ncats_labs sh
join BLUEHERONMETADATA.HERON_TERMS he
  on sh.c_basecode = he.c_basecode
--289 out of 288
;