-- diagnosis_mapping.sql
set echo on;
define metadata_schema=&1;
define shrine_ont_schema=&2;

whenever sqlerror continue
;
drop table "&&metadata_schema".ACT_ICD10CM_DX_2018AA purge;
drop table "&&metadata_schema".ACT_ICD9CM_DX_2018AA purge;
drop table "&&metadata_schema".NCATS_ICD10_ICD9_DX_V1 purge;
drop table icd_to_dx_id;
whenever sqlerror exit sql.sqlcode
;

create table "&&metadata_schema".ACT_ICD10CM_DX_2018AA  nologging as select * from "&&shrine_ont_schema".ACT_ICD10CM_DX_2018AA ;
create table "&&metadata_schema".ACT_ICD9CM_DX_2018AA  nologging as select * from "&&shrine_ont_schema".ACT_ICD9CM_DX_2018AA ;
create table "&&metadata_schema".NCATS_ICD10_ICD9_DX_V1  nologging as select * from "&&shrine_ont_schema".NCATS_ICD10_ICD9_DX_V1 ;


create table icd_to_dx_id (
  std, std_code, parent_code, path_seg, child_code, dx_id, dx_name
  , primary key(parent_code, child_code)
) compress nologging as
select distinct 'ICD10' std, map10.code std_code
     , 'ICD10CM:' || map10.code parent_code
     , 'kuh_dx_id_' || edg.dx_id || '\' path_seg
     , 'KUH|DX_ID:' || edg.dx_id child_code, edg.dx_id, edg.dx_name
from clarity.edg_current_icd10 map10
join clarity.clarity_edg edg on map10.dx_id = edg.dx_id
union all
select distinct 'ICD9' std, map9.code std_code
     , 'ICD9CM:' || map9.code parent_code
     , 'kuh_dx_id_' || edg.dx_id || '\' path_seg
     , 'KUH|DX_ID:' || edg.dx_id child_code, edg.dx_id, edg.dx_name
from clarity.edg_current_icd9 map9
join clarity.clarity_edg edg on map9.dx_id = edg.dx_id
;

------------------------------------------------------------------------------
---------------- C_NAME       : ACT Diagnoses ICD-10
---------------- C_TABLE_NAME : ACT_ICD10CM_DX_2018AA
---------------- C_TABLE_CD   : ACT_DX_ICD10_2018
---------------- subtree      : mapping apply to entire tree
-------------------------------------------------------------------------------
insert /*+  APPEND */ into "&&metadata_schema".ACT_ICD10CM_DX_2018AA
select
--map10.*,
C_HLEVEL +1 C_HLEVEL,
C_FULLNAME || map10.path_seg C_FULLNAME ,
map10.dx_name c_name ,
C_SYNONYM_CD ,
C_VISUALATTRIBUTES ,
C_TOTALNUM ,
map10.child_code C_BASECODE ,
C_METADATAXML ,
C_FACTTABLECOLUMN ,
C_TABLENAME ,
C_COLUMNNAME ,
C_COLUMNDATATYPE ,
C_OPERATOR ,
C_FULLNAME || map10.path_seg C_DIMCODE ,
C_COMMENT ,
C_TOOLTIP || map10.path_seg C_TOOLTIP,
UPDATE_DATE ,
DOWNLOAD_DATE ,
IMPORT_DATE ,
'ACT_ETL'SOURCESYSTEM_CD ,
VALUETYPE_CD ,
M_APPLIED_PATH ,
M_EXCLUSION_CD ,
C_PATH ,
C_SYMBOL
from "&&metadata_schema".ACT_ICD10CM_DX_2018AA meta
join icd_to_dx_id map10
on map10.parent_code = meta.c_basecode
where map10.std = 'ICD10'
;
--1,434,745 rows inserted
commit
;
------------------------------------------------------------------------------
---------------- C_NAME       : ACT Diagnoses  ICD-9-CM
---------------- C_TABLE_NAME : ACT_ICD9CM_DX_2018AA
---------------- C_TABLE_CD   : ACT_DX_ICD9_2018
---------------- subtree      : mapping apply to entire tree
-------------------------------------------------------------------------------
insert /*+  APPEND */ into "&&metadata_schema".ACT_ICD9CM_DX_2018AA
select
C_HLEVEL +1 C_HLEVEL,
C_FULLNAME || map9.path_seg C_FULLNAME ,
map9.dx_name c_name ,
C_SYNONYM_CD ,
C_VISUALATTRIBUTES ,
C_TOTALNUM ,
map9.child_code C_BASECODE ,
C_METADATAXML ,
C_FACTTABLECOLUMN ,
C_TABLENAME ,
C_COLUMNNAME ,
C_COLUMNDATATYPE ,
C_OPERATOR ,
C_FULLNAME || map9.path_seg C_DIMCODE ,
C_COMMENT ,
C_TOOLTIP || map9.path_seg C_TOOLTIP,
UPDATE_DATE ,
DOWNLOAD_DATE ,
IMPORT_DATE ,
'ACT_ETL'SOURCESYSTEM_CD ,
VALUETYPE_CD ,
M_APPLIED_PATH ,
M_EXCLUSION_CD ,
C_PATH ,
C_SYMBOL
from "&&metadata_schema".ACT_ICD9CM_DX_2018AA meta
join icd_to_dx_id map9
on map9.parent_code = meta.c_basecode
where map9.std = 'ICD9'
;
-- 1,716,461 rows inserted.
commit
;
------------------------------------------------------------------------------
---------------- C_NAME       : ACT Diagnoses ICD10-ICD9
---------------- C_TABLE_NAME : NCATS_ICD10_ICD9_DX_V1
---------------- C_TABLE_CD   : ACT_DX_10_9
---------------- subtree      : mapping apply to entire tree
-------------------------------------------------------------------------------
insert /*+  APPEND */ into "&&metadata_schema".NCATS_ICD10_ICD9_DX_V1
select
C_HLEVEL +1 C_HLEVEL,
C_FULLNAME || map9.path_seg C_FULLNAME ,
map9.dx_name c_name ,
C_SYNONYM_CD ,
C_VISUALATTRIBUTES ,
C_TOTALNUM ,
'KUH|DX_ID:' || map9.dx_id C_BASECODE ,
C_METADATAXML ,
C_FACTTABLECOLUMN ,
C_TABLENAME ,
C_COLUMNNAME ,
C_COLUMNDATATYPE ,
C_OPERATOR ,
C_FULLNAME || map9.path_seg C_DIMCODE ,
C_COMMENT ,
C_TOOLTIP || map9.path_seg C_TOOLTIP,
UPDATE_DATE ,
DOWNLOAD_DATE ,
IMPORT_DATE ,
'ACT_ETL'SOURCESYSTEM_CD ,
VALUETYPE_CD ,
M_APPLIED_PATH ,
M_EXCLUSION_CD ,
C_PATH ,
C_SYMBOL
from "&&metadata_schema".NCATS_ICD10_ICD9_DX_V1 meta
join icd_to_dx_id map9
on map9.parent_code = meta.c_basecode
;
-- 53,066,967 rows inserted.
commit;

-- generate SQL code for indexes. ISSUE: use stored procedures instead?
create or replace view act_ix_code_gen as
with ix_cols as (
  select 'C_FULLNAME' acol, 'unique' arity from dual union all
  select 'M_EXCLUSION_CD', '' from dual union all
  select 'M_APPLIED_PATH', '' from dual union all
  select 'C_HLEVEL', '' from dual
), ea as (
  select c_table_cd, c_table_name
  from shrine_ont_act.table_access
), ix_parts as (
  select c_table_name, arity, substr(c_table_cd || '_' || acol, 1, 30) ix_name, acol
  from ix_cols cross join ea
)
select * from (
  select 2 step, c_table_name, acol
       , lower('create ' || arity || ' index ' || ix_name || ' on ' || c_table_name || '(' || acol || ') parallel 4;') sql
  from ix_parts
) union all (
  select 1 step, c_table_name, acol, lower('drop index ' || ix_name || ';') sql from ix_parts
)
order by 1, 2, 3;
-- select sql from act_ix_code_gen where c_table_name like '%_DX_%';
