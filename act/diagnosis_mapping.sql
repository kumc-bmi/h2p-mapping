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



delete from nightherondata.concept_dimension
where concept_path like '\ACT\Diagnosis\%'
or concept_path like '\Diagnoses\%';

insert /*+ APPEND */ into nightherondata.concept_dimension(
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
 select * from blueheronmetadata.ACT_ICD10CM_DX_2018AA union all
 select * from blueheronmetadata.NCATS_ICD10_ICD9_DX_V1 union all
 select * from blueheronmetadata.ACT_ICD9CM_DX_2018AA
) ib
where ib.c_basecode is not null
;


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
), mk_ix as (
  select c_table_name, lower('create ' || arity || ' index ' || substr(c_table_cd || '_' || acol, 1, 30) || ' on ' || c_table_name || '(' || acol || ') parallel 4;') sql
  from ix_cols cross join ea
), rm_ix as (
  select c_table_name, lower('drop index ' || c_table_cd || '_' || acol || ';') sql
  from ix_cols cross join ea
)
select * from rm_ix union all select * from mk_ix;
-- select sql from act_ix_code_gen where c_table_name like '%_DX_%';

alter session set current_schema=&&metadata_schema;

whenever sqlerror continue;
drop index act_dx_icd10_2018_c_fullname;
drop index act_dx_icd10_2018_m_exclusion_cd;
drop index act_dx_icd10_2018_m_applied_path;
drop index act_dx_icd10_2018_c_hlevel;
drop index act_dx_icd9_2018_c_fullname;
drop index act_dx_icd9_2018_m_exclusion_cd;
drop index act_dx_icd9_2018_m_applied_path;
drop index act_dx_icd9_2018_c_hlevel;
drop index act_dx_10_9_c_fullname;
drop index act_dx_10_9_m_exclusion_cd;
drop index act_dx_10_9_m_applied_path;
drop index act_dx_10_9_c_hlevel;
whenever sqlerror exit sql.sqlcode;
create unique index act_dx_icd10_2018_c_fullname on act_icd10cm_dx_2018aa(c_fullname) parallel 4;
create  index act_dx_icd10_2018_m_exclusion_ on act_icd10cm_dx_2018aa(m_exclusion_cd) parallel 4;
create  index act_dx_icd10_2018_m_applied_pa on act_icd10cm_dx_2018aa(m_applied_path) parallel 4;
create  index act_dx_icd10_2018_c_hlevel on act_icd10cm_dx_2018aa(c_hlevel) parallel 4;
create unique index act_dx_icd9_2018_c_fullname on act_icd9cm_dx_2018aa(c_fullname) parallel 4;
create  index act_dx_icd9_2018_m_exclusion_c on act_icd9cm_dx_2018aa(m_exclusion_cd) parallel 4;
create  index act_dx_icd9_2018_m_applied_pat on act_icd9cm_dx_2018aa(m_applied_path) parallel 4;
create  index act_dx_icd9_2018_c_hlevel on act_icd9cm_dx_2018aa(c_hlevel) parallel 4;
create unique index act_dx_10_9_c_fullname on ncats_icd10_icd9_dx_v1(c_fullname) parallel 4;
create  index act_dx_10_9_m_exclusion_cd on ncats_icd10_icd9_dx_v1(m_exclusion_cd) parallel 4;
create  index act_dx_10_9_m_applied_path on ncats_icd10_icd9_dx_v1(m_applied_path) parallel 4;
create  index act_dx_10_9_c_hlevel on ncats_icd10_icd9_dx_v1(c_hlevel) parallel 4;
