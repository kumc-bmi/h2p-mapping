-- update_concept_dimension.sql
set echo on;
define upload_id=&1;
define heron_data_schema=&2;
define metadata_schema=&3;
--define upload_id=987654321;
--define heron_data_schema=NIGHTHERONDATA;
--define metadata_schema=BLUEHERONMETADATA;
-------------------------------------------------------------------------------
-- CONCEPT_DIMENSION
-------------------------------------------------------------------------------
whenever sqlerror continue;
drop INDEX "&&heron_data_schema"."SOURCESYSTEM_CD_IDX";
whenever sqlerror exit sql.sqlcode;
CREATE INDEX "&&heron_data_schema"."SOURCESYSTEM_CD_IDX" ON "&&heron_data_schema"."CONCEPT_DIMENSION" ("SOURCESYSTEM_CD") nologging parallel 12 compress;

DELETE  /*+  PARALLEL (20) */ FROM
"&&heron_data_schema".concept_dimension
where SOURCESYSTEM_CD in ('NCATS', 'ACT_ETL')
	and upload_id='&&upload_id'
;
commit
;
alter table "&&heron_data_schema".concept_dimension nologging;
insert  /*+  APPEND */ into "&&heron_data_schema".concept_dimension(
  concept_cd, 
  concept_path, 
  name_char,
  update_date, 
  download_date, 
  import_date, 
  sourcesystem_cd,
  upload_id
  )
select 
  -- distinct --asuming if not distinct it will fail by pk
  ib.c_basecode,
  -- Previously, ib.c_fullname was selected instead of ib.c_dimcode.  
  -- This was incorrect, because concept searches look for c_dimcode, 
  -- but it wasn't a huge problem because c_fullname and c_dimcode were  
  -- always identical. The SCILHS-based procedures ontology update (#26) 
  -- introduced terms where that is not true, which shed light on the error 
  -- and resulted in the change from ib.c_fullname to ib.c_dimcode.
  -- HERE I am using c_fullname again as C_dimecode has date in it.
  ib.c_fullname, 
  max(ib.c_name), 
  update_date, 
  download_date, 
  sysdate, 
  'NCATS' sourcesystem_cd,
  '&&upload_id' upload_id
from 
(
-- sql generator: select  'select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".' ||c_table_name ||' union all'  sql from shrine_ont_act.table_access order by sql;
select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".ACT_COVID union all
--select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".ACT_CPT_PX_2018AA union all
--select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".ACT_HCPCS_PX_2018AA union all
select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".ACT_ICD10CM_DX_2018AA union all
--select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".ACT_ICD10PCS_PX_2018AA union all
select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".ACT_ICD9CM_DX_2018AA union all
--select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".ACT_ICD9CM_PX_2018AA union all
--select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".ACT_LOINC_LAB_2018AA union all
--select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".ACT_MED_ALPHA_V2_121318 union all
--select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".ACT_MED_VA_V2_092818 union all
--select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".NCATS_DEMOGRAPHICS union all
select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".NCATS_ICD10_ICD9_DX_V1 union all
--select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".NCATS_LABS union all
select C_BASECODE, C_FULLNAME, C_NAME, UPDATE_DATE, DOWNLOAD_DATE, sourcesystem_cd, C_DIMCODE from "&&metadata_schema".NCATS_VISIT_DETAILS
) ib
where ib.c_basecode is not null
group by ib.c_basecode, ib.c_fullname
     , update_date, download_date, sysdate, sourcesystem_cd
;
commit;
