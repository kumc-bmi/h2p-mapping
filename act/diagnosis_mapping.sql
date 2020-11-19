-- diagnosis_mapping.sql
set echo on;
define metadata_schema=&1;

whenever sqlerror continue
;
drop table "&&metadata_schema".ACT_ICD10CM_DX_2018AA purge;
drop table "&&metadata_schema".ACT_ICD9CM_DX_2018AA purge;
whenever sqlerror exit sql.sqlcode
;
create table "&&metadata_schema".ACT_ICD10CM_DX_2018AA  nologging as select * from "&&shrine_ont_schema".ACT_ICD10CM_DX_2018AA ;
create table "&&metadata_schema".ACT_ICD9CM_DX_2018AA  nologging as select * from "&&shrine_ont_schema".ACT_ICD9CM_DX_2018AA ;


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
exit
;
