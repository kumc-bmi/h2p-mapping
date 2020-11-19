set echo on;
define metadata_schema=&1;
define shrine_ont_schema=&2;

-- sql generator: select  'drop table "&&metadata_schema".'||c_table_name || 'purge ;' sql from "&&shrine_ont_schema".table_access order by sql;
whenever sqlerror continue
;
drop table "&&metadata_schema".ACT_COVID purge;
whenever sqlerror exit sql.sqlcode
;
create table "&&metadata_schema".ACT_COVID  nologging as select * from "&&shrine_ont_schema".ACT_COVID ;

------------------------------------------------------------------------------
---------------- C_NAME       : ACT COVID-19
---------------- C_TABLE_NAME : ACT_COVID
---------------- C_TABLE_CD   : ACT_COVID_V1
---------------- subtree      : mapping apply to sub  tree of ACT Phenotype\COVID-19 Related Terms\Diagnosis
-------------------------------------------------------------------------------
insert /*+  APPEND */ into "&&metadata_schema".act_covid
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
M_APPLIED_PATH ,
UPDATE_DATE ,
DOWNLOAD_DATE ,
IMPORT_DATE ,
'ACT_ETL'SOURCESYSTEM_CD ,
VALUETYPE_CD ,
M_EXCLUSION_CD ,
C_PATH ,
C_SYMBOL
from "&&metadata_schema".act_covid meta
join icd10_dx_id_map map10
on 'ICD10CM:'||map10.icd10 = meta.c_basecode
where c_fullname like '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0037088\%'
-- 729 rows inserted.
;
commit
;

delete from nightherondata.concept_dimension
where concept_path like '\ACT\UMLS_C0031437\SNOMED_3947185011\%';

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
 select * from blueheronmetadata.ACT_COVID
) ib
where ib.c_basecode is not null
;
