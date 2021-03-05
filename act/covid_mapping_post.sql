set echo on;
define metadata_schema=&1;
define shrine_ont_schema=&2;
define data_schema=&3;

/** fill in concept dimension */
delete from "&&data_schema".concept_dimension
where concept_path like '\ACT\UMLS_C0031437\SNOMED_3947185011\%';

insert /*+ APPEND */ into "&&data_schema".concept_dimension(
  concept_cd,
  concept_path,
  name_char,
  update_date,
  download_date,
  import_date,
  sourcesystem_cd
  )
select distinct
  ib.c_basecode,
  ib.c_fullname,
  ib.c_name,
  update_date,
  download_date,
  sysdate,
  'ACT'
from (
 select * from "&&metadata_schema".ACT_COVID
) ib
where ib.c_basecode is not null
;

/** Build COVID metadata table indexes. */
-- See diagnosis_mapping.sql for act_ix_code_gen
-- select sql from act_ix_code_gen where c_table_name like '%_COVID';
alter session set current_schema=&&metadata_schema;

whenever sqlerror continue;
drop index act_covid_v1_c_fullname;
drop index act_covid_v1_c_hlevel;
drop index act_covid_v1_m_applied_path;
drop index act_covid_v1_m_exclusion_cd;
whenever sqlerror exit sql.sqlcode;

create unique index act_covid_v1_c_fullname on act_covid(c_fullname) parallel 4;
create  index act_covid_v1_c_hlevel on act_covid(c_hlevel) parallel 4;
create  index act_covid_v1_m_applied_path on act_covid(m_applied_path) parallel 4;
create  index act_covid_v1_m_exclusion_cd on act_covid(m_exclusion_cd) parallel 4;
