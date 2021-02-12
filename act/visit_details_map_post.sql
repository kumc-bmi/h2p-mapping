set echo on;
define metadata_schema=&1;
define shrine_ont_schema=&2;
define heron_data_schema=&3;
whenever sqlerror exit sql.sqlcode;

delete from "&&heron_data_schema".concept_dimension
where concept_path like '\ACT\Visit Details\%';
insert /*+ APPEND */ into "&&heron_data_schema".concept_dimension(
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
 select * from "&&metadata_schema".NCATS_VISIT_DETAILS
) ib
where ib.c_basecode is not null and ib.c_synonym_cd != 'Y';
commit;

/** visit LOS
*/
MERGE
INTO    "&&heron_data_schema".visit_dimension trg
USING   (
        SELECT  t1.rowid AS rid, t2.nval_num
        FROM    "&&heron_data_schema".visit_dimension t1
        JOIN    "&&heron_data_schema".observation_fact t2
        ON      t1.encounter_num = t2.encounter_num
        WHERE   t2.concept_cd='UHC|LOS:1'
        ) src
ON      (trg.rowid = src.rid)
WHEN MATCHED THEN UPDATE
    SET trg.length_of_stay = src.nval_num;
commit;
--342,973 rows merged.

/** Indexes */
alter session set current_schema="&&metadata_schema";
-- select sql from act_ix_code_gen where c_table_name like '%_VISIT%';
whenever sqlerror continue;
drop index act_visit_c_fullname;
drop index act_visit_c_hlevel;
drop index act_visit_m_applied_path;
drop index act_visit_m_exclusion_cd;
whenever sqlerror exit sql.sqlcode;
create unique index act_visit_c_fullname on ncats_visit_details(c_fullname) parallel 4;
create  index act_visit_c_hlevel on ncats_visit_details(c_hlevel) parallel 4;
create  index act_visit_m_applied_path on ncats_visit_details(m_applied_path) parallel 4;
create  index act_visit_m_exclusion_cd on ncats_visit_details(m_exclusion_cd) parallel 4;
