/** ACT Laboratory Tests

select * from shrine_ont_act.table_access where c_table_cd like '%_LAB%';
*/

set echo on;
define metadata_schema=&1;
define shrine_ont_schema=&2;
define closure_schema=&3;

/** Start with a copy of the ACT Labs metadata table. */
whenever sqlerror continue;
drop table "&&metadata_schema".ACT_LOINC_LAB_2018AA purge;
drop table "&&metadata_schema".NCATS_LABS purge;
drop table loinc_to_component_id purge;
drop table metadata_closure purge;
drop table metadata_hash purge;
whenever sqlerror exit sql.sqlcode;
create table "&&metadata_schema".ACT_LOINC_LAB_2018AA nologging as select * from "&&shrine_ont_schema".ACT_LOINC_LAB_2018AA;
create table "&&metadata_schema".NCATS_LABS nologging as select * from "&&shrine_ont_schema".NCATS_LABS;

/* Map LOINC codes to COMPONENT_ID using metadata_closure from HERON ETL. */
create table metadata_closure as select * from "&&closure_schema".metadata_closure@deid;
create table metadata_hash as select * from "&&closure_schema".metadata_hash@deid;

create table loinc_to_component_id (
  std, parent_code, path_seg, child_code, c_name
, primary key ( parent_code, child_code )
)
compress nologging as
select 'LOINC' std, std.c_basecode   parent_code, loc.c_basecode || '\' path_seg, loc.c_basecode child_code
     , (select c_name
        from "&&metadata_schema".heron_terms ht
        where ht.c_fullname = loc.c_fullname
        and rownum <= 1) c_name
from metadata_closure mc
join metadata_hash std on std.c_fullname_hash = mc.ancestor_hash
join metadata_hash loc on loc.c_fullname_hash = mc.descendant_hash
-- HERON LOINC hierarchy
where std.c_fullname like '\i2b2\Laboratory Tests\%'
and std.c_basecode like 'LOINC:%'
and loc.c_basecode like 'KUH|COMPONENT_ID:%'
;

/** mapped: 134,866 / 142,860 94.4% */
create or replace view lab_check_q as
select sh.C_FULLNAME shrine_term
     , case when exists (
         select 1 from loinc_to_component_id m
         where m.parent_code = sh.c_basecode) then 1
       else 0 end ok
from shrine_ont_act.ACT_LOINC_LAB_2018AA sh;
-- drop table lab_check purge;
-- create table lab_check compress nologging as select * from lab_check_q;
-- select ok, count(*) from lab_check group by ok order by ok;
-- select round(134866 / 142860 * 100, 1) from dual;


/** Insert COMPONENT_ID terms under LOINC terms. */
insert /*+  APPEND */ into "&&metadata_schema".ACT_LOINC_LAB_2018AA
select c_hlevel + 1 c_hlevel
     , c_fullname || mt.path_seg c_fullname
     , mt.c_name
     , c_synonym_cd, c_visualattributes, c_totalnum
     , mt.child_code   c_basecode
     , c_metadataxml, c_facttablecolumn, c_tablename, c_columnname, c_columndatatype, c_operator
     , c_fullname || mt.path_seg c_dimcode
     , c_comment
     , c_tooltip || mt.path_seg c_tooltip
     , update_date, download_date, import_date
     , 'ACT_ETL' sourcesystem_cd
     , valuetype_cd, m_applied_path, m_exclusion_cd, c_path, c_symbol
  from "&&metadata_schema".ACT_LOINC_LAB_2018AA meta
  join loinc_to_component_id mt on mt.parent_code = meta.c_basecode
;
-- 19,293 rows inserted
commit;

/** Insert COMPONENT_ID terms under LOINC terms. */
insert /*+  APPEND */ into "&&metadata_schema".NCATS_LABS
select c_hlevel + 1 c_hlevel
     , c_fullname || mt.path_seg c_fullname
     , mt.c_name
     , c_synonym_cd, c_visualattributes, c_totalnum
     , mt.child_code   c_basecode
     , c_metadataxml, c_facttablecolumn, c_tablename, c_columnname, c_columndatatype, c_operator
     , c_fullname || mt.path_seg c_dimcode
     , c_comment
     , c_tooltip || mt.path_seg c_tooltip
     , update_date, download_date, import_date
     , 'ACT_ETL' sourcesystem_cd
     , valuetype_cd, m_applied_path, m_exclusion_cd, c_path, c_symbol
  from "&&metadata_schema".NCATS_LABS meta
  join loinc_to_component_id mt on mt.parent_code = meta.c_basecode
;
-- 1,315 rows inserted.
commit;
