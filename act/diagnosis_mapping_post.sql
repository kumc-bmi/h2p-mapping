-- diagnosis_mapping.sql
set echo on;
define metadata_schema=&1;
define shrine_ont_schema=&2;
define data_schema=&3;

whenever sqlerror exit sql.sqlcode;

delete from "&&data_schema".concept_dimension
where concept_path like '\ACT\Diagnosis\%'
or concept_path like '\Diagnoses\%';

insert /*+ APPEND */ into "&&data_schema".concept_dimension(
  concept_cd,
  concept_path,
  name_char,
  update_date,
  download_date,
  import_date,
  sourcesystem_cd
  )
select
  ib.c_basecode,
  ib.c_fullname,
  ib.c_name,
  update_date,
  download_date,
  sysdate,
  'ACT'
from (
 select * from "&&metadata_schema".ACT_ICD10CM_DX_2018AA union all
 select * from "&&metadata_schema".NCATS_ICD10_ICD9_DX_V1 union all
 select * from "&&metadata_schema".ACT_ICD9CM_DX_2018AA
) ib
where ib.c_basecode is not null and ib.c_synonym_cd = 'N'
;


alter session set current_schema=&&metadata_schema;

whenever sqlerror continue;
drop index act_dx_icd10_2018_c_fullname;
drop index act_dx_icd10_2018_c_hlevel;
drop index act_dx_icd10_2018_m_applied_pa;
drop index act_dx_icd10_2018_m_exclusion_;
drop index act_dx_icd9_2018_c_fullname;
drop index act_dx_icd9_2018_c_hlevel;
drop index act_dx_icd9_2018_m_applied_pat;
drop index act_dx_icd9_2018_m_exclusion_c;
drop index act_dx_10_9_c_fullname;
drop index act_dx_10_9_c_hlevel;
drop index act_dx_10_9_m_applied_path;
drop index act_dx_10_9_m_exclusion_cd;
whenever sqlerror exit sql.sqlcode;
create unique index act_dx_icd10_2018_c_fullname on act_icd10cm_dx_2018aa(c_fullname) parallel 4;
ccreate unique index act_dx_icd10_2018_c_fullname on act_icd10cm_dx_2018aa(c_fullname) parallel 4;
create  index act_dx_icd10_2018_c_hlevel on act_icd10cm_dx_2018aa(c_hlevel) parallel 4;
create  index act_dx_icd10_2018_m_applied_pa on act_icd10cm_dx_2018aa(m_applied_path) parallel 4;
create  index act_dx_icd10_2018_m_exclusion_ on act_icd10cm_dx_2018aa(m_exclusion_cd) parallel 4;
create unique index act_dx_icd9_2018_c_fullname on act_icd9cm_dx_2018aa(c_fullname) parallel 4;
create  index act_dx_icd9_2018_c_hlevel on act_icd9cm_dx_2018aa(c_hlevel) parallel 4;
create  index act_dx_icd9_2018_m_applied_pat on act_icd9cm_dx_2018aa(m_applied_path) parallel 4;
create  index act_dx_icd9_2018_m_exclusion_c on act_icd9cm_dx_2018aa(m_exclusion_cd) parallel 4;
create /* unique */ index act_dx_10_9_c_fullname on ncats_icd10_icd9_dx_v1(c_fullname) parallel 4;
create  index act_dx_10_9_c_hlevel on ncats_icd10_icd9_dx_v1(c_hlevel) parallel 4;
create  index act_dx_10_9_m_applied_path on ncats_icd10_icd9_dx_v1(m_applied_path) parallel 4;
create  index act_dx_10_9_m_exclusion_cd on ncats_icd10_icd9_dx_v1(m_exclusion_cd) parallel 4;
