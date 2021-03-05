/** ACT Laboratory Tests

select * from shrine_ont_act.table_access where c_table_cd like '%_LAB%';
*/

set echo on;
define metadata_schema=&1;
define data_schema=&2;

/** fill in concept dimension */
delete from "&&data_schema".concept_dimension
where concept_path like '\ACT\Lab%';

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
  sysdate import_date,
  'ACT' sourcesystem_cd
from (
 select * from "&&metadata_schema".ACT_LOINC_LAB_2018AA
 union all
 select * from "&&metadata_schema".NCATS_LABS
) ib
where ib.c_basecode is not null;
-- 163,753 rows inserted.
commit;


/** Build LAB metadata table indexes. */
-- See diagnosis_mapping.sql for act_ix_code_gen
-- select sql from act_ix_code_gen where c_table_name like '%_LAB%';
alter session set current_schema=&&metadata_schema;

whenever sqlerror continue;
drop index act_lab_loinc_2018_c_fullname;
drop index act_lab_loinc_2018_c_hlevel;
drop index act_lab_loinc_2018_m_applied_p;
drop index act_lab_loinc_2018_m_exclusion;
drop index act_lab_c_fullname;
drop index act_lab_c_hlevel;
drop index act_lab_m_applied_path;
drop index act_lab_m_exclusion_cd;
whenever sqlerror exit sql.sqlcode;

create unique index act_lab_loinc_2018_c_fullname on act_loinc_lab_2018aa(c_fullname) parallel 4;
create  index act_lab_loinc_2018_c_hlevel on act_loinc_lab_2018aa(c_hlevel) parallel 4;
create  index act_lab_loinc_2018_m_applied_p on act_loinc_lab_2018aa(m_applied_path) parallel 4;
create  index act_lab_loinc_2018_m_exclusion on act_loinc_lab_2018aa(m_exclusion_cd) parallel 4;
create unique index act_lab_c_fullname on ncats_labs(c_fullname) parallel 4;
create  index act_lab_c_hlevel on ncats_labs(c_hlevel) parallel 4;
create  index act_lab_m_applied_path on ncats_labs(m_applied_path) parallel 4;
create  index act_lab_m_exclusion_cd on ncats_labs(m_exclusion_cd) parallel 4;
