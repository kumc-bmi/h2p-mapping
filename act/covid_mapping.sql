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


/** COVID Prodcedures: replace CPT4 with CPT
 1. only 1 cpt in in act covid, and heron has 1 and that' patient count is 0
*/
update blueheronmetadata.act_covid
set c_basecode = replace(c_basecode, 'CPT4', 'CPT')
where c_basecode like 'CPT4:%'
;
commit
;

update blueheronmetadata.act_covid
set c_basecode = 'COVID-xyz-test:NEGATIVE'
where c_basecode = 'LOINC:94310-0 NEGATIVE';
commit;

update blueheronmetadata.act_covid
set c_basecode = 'COVID-xyz-test:POSITIVE'
where c_basecode = 'LOINC:94310-0 POSITIVE';
commit;


/** LABS UMLS
-- Is folder(or leaf) which could have one to many relationsship.

from:Morris, Michele <mim18@pitt.edu>
Yes map the labs to the derived facts. I think that is what most sites are doing at this point. Your version of the files may
have an error where Positive and Negative have the same code but that is fixed in the updated version of the files which I am
getting ready to repost.
ANY Negative Lab Test  UMLS:C1334932
ANY Positive Lab Test  UMLS:C1335447
ANY Pending Lab Test  UMLS:C1611271
ANY Equivocal Lab Test  UMLS:C4303880
If you cannot map the lab to one of the 4 values you should map to Laboratory Testing
Laboratory Testing  UMLS:C0022885


Lab Orders	UMLS:C0086143
ANY Positive Lab Test	UMLS:C1444714
ANY Negative Lab Test	UMLS:C1444714
ANY Pending Lab Test	UMLS:C1611271
ANY Equivocal Lab Test	UMLS:C4303880
*/


/** fill in concept dimension */
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
