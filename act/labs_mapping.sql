/** ACT Laboratory Tests

table_cd: ACT_LAB_LOINC_2018
table_name: ACT_LOINC_LAB_2018AA

*/

set echo on;
define metadata_schema=&1;
define shrine_ont_schema=&2;
define closure_schema=&3;

/** Start with a copy of the ACT Labs metadata table. */
whenever sqlerror continue;
drop table "&&metadata_schema".ACT_LOINC_LAB_2018AA purge;
whenever sqlerror exit sql.sqlcode;
create table "&&metadata_schema".ACT_LOINC_LAB_2018AA nologging as select * from "&&shrine_ont_schema".ACT_LOINC_LAB_2018AA;

select * from BLUEHERONMETADATA.HERON_TERMS
where c_fullname like '\i2b2\Laboratory Tests\%' -- HERON LOINC hierarchy
and c_hlevel <= 2
;

create table loinc_to_component_id (
  std, parent_code, path_seg, child_code, c_name
, primary key ( parent_code, child_code )
)
compress nologging as
select 'LOINC' std, std.c_basecode   parent_code, loc.c_basecode || '\' path_seg, loc.c_basecode child_code
     , (select c_name
        from blueheronmetadata.heron_terms ht
        where ht.c_fullname = loc.c_fullname
        and rownum <= 1) c_name
from "&&closure_schema".metadata_closure mc
join "&&closure_schema".metadata_hash std on std.c_fullname_hash = mc.ancestor_hash
join "&&closure_schema".metadata_hash loc on loc.c_fullname_hash = mc.descendant_hash
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

