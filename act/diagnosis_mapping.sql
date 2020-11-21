-- diagnosis_mapping.sql
set echo on;
define metadata_schema=&1;
define shrine_ont_schema=&2;

whenever sqlerror continue
;
drop table "&&metadata_schema".ACT_ICD10CM_DX_2018AA purge;
drop table "&&metadata_schema".ACT_ICD9CM_DX_2018AA purge;
drop table "&&metadata_schema".NCATS_ICD10_ICD9_DX_V1 purge;
whenever sqlerror exit sql.sqlcode
;
create table "&&metadata_schema".ACT_ICD10CM_DX_2018AA  nologging as select * from "&&shrine_ont_schema".ACT_ICD10CM_DX_2018AA ;
create table "&&metadata_schema".ACT_ICD9CM_DX_2018AA  nologging as select * from "&&shrine_ont_schema".ACT_ICD9CM_DX_2018AA ;
create table "&&metadata_schema".NCATS_ICD10_ICD9_DX_V1  nologging as select * from "&&shrine_ont_schema".NCATS_ICD10_ICD9_DX_V1 ;


------------------------------------------------------------------------------
---------------- C_NAME       : ACT Diagnoses ICD-10
---------------- C_TABLE_NAME : ACT_ICD10CM_DX_2018AA
---------------- C_TABLE_CD   : ACT_DX_ICD10_2018
---------------- subtree      : mapping apply to entire tree
-------------------------------------------------------------------------------
insert /*+  APPEND */ into "&&metadata_schema".ACT_ICD10CM_DX_2018AA
with icd10_dx_id_map
as
(
SELECT
map10.code icd10,
map10.dx_id,
edg.dx_name
FROM
clarity.edg_current_icd10 map10
JOIN clarity.clarity_edg edg ON map10.dx_id = edg.dx_id
)
select
--map10.*,
C_HLEVEL +1 C_HLEVEL,
C_FULLNAME ||'kuh_dx_id_' || map10.dx_id || '\' C_FULLNAME ,
map10.dx_name c_name ,
C_SYNONYM_CD ,
C_VISUALATTRIBUTES ,
C_TOTALNUM ,
'KUH|DX_ID:' || map10.dx_id C_BASECODE ,
C_METADATAXML ,
C_FACTTABLECOLUMN ,
C_TABLENAME ,
C_COLUMNNAME ,
C_COLUMNDATATYPE ,
C_OPERATOR ,
C_FULLNAME ||'kuh_dx_id_' || map10.dx_id || '\' C_DIMCODE ,
C_COMMENT ,
C_TOOLTIP ||'kuh_dx_id_' || map10.dx_id || '\' C_TOOLTIP,
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
join icd10_dx_id_map map10
on 'ICD10CM:'||map10.icd10 = meta.c_basecode
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
with icd9_dx_id_map
as
(
SELECT
    map9.code icd9,
    map9.dx_id,
    edg.dx_name
FROM
clarity.edg_current_icd9 map9
    JOIN clarity.clarity_edg edg ON map9.dx_id = edg.dx_id
)
select
--map9.*,
C_HLEVEL +1 C_HLEVEL,
C_FULLNAME ||'kuh_dx_id_' || map9.dx_id || '\' C_FULLNAME ,
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
C_FULLNAME ||'kuh_dx_id_' || map9.dx_id || '\' C_DIMCODE ,
C_COMMENT ,
C_TOOLTIP ||'kuh_dx_id_' || map9.dx_id || '\' C_TOOLTIP,
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
join icd9_dx_id_map map9
on 'ICD9CM:'||map9.icd9 = meta.c_basecode
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
with icd9_dx_id_map
as
(
SELECT
    map9.code icd9,
    map9.dx_id,
    edg.dx_name
FROM
clarity.edg_current_icd9 map9
    JOIN clarity.clarity_edg edg ON map9.dx_id = edg.dx_id
)
select
--map9.*,
C_HLEVEL +1 C_HLEVEL,
C_FULLNAME ||'kuh_dx_id_' || map9.dx_id || '\' C_FULLNAME ,
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
C_FULLNAME ||'kuh_dx_id_' || map9.dx_id || '\' C_DIMCODE ,
C_COMMENT ,
C_TOOLTIP ||'kuh_dx_id_' || map9.dx_id || '\' C_TOOLTIP,
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
join icd9_dx_id_map map9
on 'ICD9CM:'||map9.icd9 = meta.c_basecode
;
-- 51,439,100 rows inserted.
commit;
--------------------------------------------------------------------------------------------------------------------------
insert /*+  APPEND */ into "&&metadata_schema".NCATS_ICD10_ICD9_DX_V1
with icd10_dx_id_map
as
(
SELECT
map10.code icd10,
map10.dx_id,
edg.dx_name
FROM
clarity.edg_current_icd10 map10
JOIN clarity.clarity_edg edg ON map10.dx_id = edg.dx_id
)
select
--map10.*,
C_HLEVEL +1 C_HLEVEL,
C_FULLNAME ||'kuh_dx_id_' || map10.dx_id || '\' C_FULLNAME ,
map10.dx_name c_name ,
C_SYNONYM_CD ,
C_VISUALATTRIBUTES ,
C_TOTALNUM ,
'KUH|DX_ID:' || map10.dx_id C_BASECODE ,
C_METADATAXML ,
C_FACTTABLECOLUMN ,
C_TABLENAME ,
C_COLUMNNAME ,
C_COLUMNDATATYPE ,
C_OPERATOR ,
C_FULLNAME ||'kuh_dx_id_' || map10.dx_id || '\' C_DIMCODE ,
C_COMMENT ,
C_TOOLTIP ||'kuh_dx_id_' || map10.dx_id || '\' C_TOOLTIP,
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
join icd10_dx_id_map map10
on 'ICD10CM:'||map10.icd10 = meta.c_basecode
;
--1,662,760 rows inserted
commit
;


delete from nightherondata.concept_dimension
where concept_path like '\ACT\Diagnosis\%';

insert into nightherondata.concept_dimension(
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
 select * from blueheronmetadata.ACT_ICD10CM_DX_2018AA union all
 select * from blueheronmetadata.ACT_ICD9CM_DX_2018AA
) ib
where ib.c_basecode is not null
;

exit
;

-- generate SQL code for indexes. ISSUE: use stored procedures instead?
create or replace view act_dx_ix_code_gen as
with ix_cols as (
  select 'C_FULLNAME' acol, 'unique' arity from dual union all
  select 'M_EXCLUSION_CD', '' from dual union all
  select 'M_APPLIED_PATH', '' from dual union all
  select 'C_HLEVEL', '' from dual
), ea as (
  select c_table_cd, c_table_name
  from shrine_ont_act.table_access
  where c_table_name like '%_DX_%'
), mk_ix as (
  select lower('create ' || arity || ' index ' || c_table_cd || '_' || acol || ' on ' || c_table_name || '(' || acol || ') parallel 4;') sql
  from ix_cols cross join ea
), rm_ix as (
  select lower('drop index ' || c_table_cd || '_' || acol || ';') sql
  from ix_cols cross join ea
)
select * from rm_ix union all select * from mk_ix;
-- select * from act_dx_ix_code_gen;

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
create  index act_dx_icd10_2018_m_exclusion_cd on act_icd10cm_dx_2018aa(m_exclusion_cd) parallel 4;
create  index act_dx_icd10_2018_m_applied_path on act_icd10cm_dx_2018aa(m_applied_path) parallel 4;
create  index act_dx_icd10_2018_c_hlevel on act_icd10cm_dx_2018aa(c_hlevel) parallel 4;
create unique index act_dx_icd9_2018_c_fullname on act_icd9cm_dx_2018aa(c_fullname) parallel 4;
create  index act_dx_icd9_2018_m_exclusion_cd on act_icd9cm_dx_2018aa(m_exclusion_cd) parallel 4;
create  index act_dx_icd9_2018_m_applied_path on act_icd9cm_dx_2018aa(m_applied_path) parallel 4;
create  index act_dx_icd9_2018_c_hlevel on act_icd9cm_dx_2018aa(c_hlevel) parallel 4;
create unique index act_dx_10_9_c_fullname on ncats_icd10_icd9_dx_v1(c_fullname) parallel 4;
create  index act_dx_10_9_m_exclusion_cd on ncats_icd10_icd9_dx_v1(m_exclusion_cd) parallel 4;
create  index act_dx_10_9_m_applied_path on ncats_icd10_icd9_dx_v1(m_applied_path) parallel 4;
create  index act_dx_10_9_c_hlevel on ncats_icd10_icd9_dx_v1(c_hlevel) parallel 4;
