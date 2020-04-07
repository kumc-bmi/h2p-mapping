set echo on;
define heron_data_schema=&2;
-------------------------------------------------------------------------------
-- Create BLUEHERONMETADATA.ont tables
-------------------------------------------------------------------------------
whenever sqlerror continue;
--select '||''''|| 'drop table BLUEHERONMETADATA.'||c_table_name ||''''|| ';' sql from SHRINE_ONT_ACT.table_access order by sql;
drop table BLUEHERONMETADATA.ACT_CPT_PX_2018AA;
-- Following table ACT_HCPCS_PX_2018AA is using metadata approach,but does not require changes.
drop table BLUEHERONMETADATA.ACT_HCPCS_PX_2018AA;
drop table BLUEHERONMETADATA.ACT_ICD10CM_DX_2018AA;
drop table BLUEHERONMETADATA.ACT_ICD10PCS_PX_2018AA;
drop table BLUEHERONMETADATA.ACT_ICD9CM_DX_2018AA;
drop table BLUEHERONMETADATA.ACT_ICD9CM_PX_2018AA;
drop table BLUEHERONMETADATA.ACT_LOINC_LAB_2018AA;
-- Following tables are using metadata approach,but require changes.
-- drop table BLUEHERONMETADATA.ACT_MED_ALPHA_V2_121318;
--drop table BLUEHERONMETADATA.ACT_MED_VA_V2_092818;
drop table BLUEHERONMETADATA.NCATS_DEMOGRAPHICS;
drop table BLUEHERONMETADATA.NCATS_ICD10_ICD9_DX_V1;
drop table BLUEHERONMETADATA.NCATS_LABS;
drop table BLUEHERONMETADATA.NCATS_VISIT_DETAILS;
whenever sqlerror exit sql.sqlcode;

--select '||''''|| 'create table BLUEHERONMETADATA.'||c_table_name ||' as select * from SHRINE_ONT_ACT.'|| c_table_name ||''''||' ;' sql from SHRINE_ONT_ACT.table_access order by sql;
create table BLUEHERONMETADATA.ACT_CPT_PX_2018AA as select * from SHRINE_ONT_ACT.ACT_CPT_PX_2018AA;
-- Following table ACT_HCPCS_PX_2018AA is using metadata approach,but does not require changes.
create table BLUEHERONMETADATA.ACT_HCPCS_PX_2018AA as select * from SHRINE_ONT_ACT.ACT_HCPCS_PX_2018AA;
create table BLUEHERONMETADATA.ACT_ICD10CM_DX_2018AA as select * from SHRINE_ONT_ACT.ACT_ICD10CM_DX_2018AA;
create table BLUEHERONMETADATA.ACT_ICD10PCS_PX_2018AA as select * from SHRINE_ONT_ACT.ACT_ICD10PCS_PX_2018AA;
create table BLUEHERONMETADATA.ACT_ICD9CM_DX_2018AA as select * from SHRINE_ONT_ACT.ACT_ICD9CM_DX_2018AA;
create table BLUEHERONMETADATA.ACT_ICD9CM_PX_2018AA as select * from SHRINE_ONT_ACT.ACT_ICD9CM_PX_2018AA;
create table BLUEHERONMETADATA.ACT_LOINC_LAB_2018AA as select * from SHRINE_ONT_ACT.ACT_LOINC_LAB_2018AA;
-- Following tables are using metadata approach,but require changes.
-- create table BLUEHERONMETADATA.ACT_MED_ALPHA_V2_121318 as select * from SHRINE_ONT_ACT.ACT_MED_ALPHA_V2_121318;
--create table BLUEHERONMETADATA.ACT_MED_VA_V2_092818 as select * from SHRINE_ONT_ACT.ACT_MED_VA_V2_092818;
--create table BLUEHERONMETADATA.NCATS_DEMOGRAPHICS as select * from SHRINE_ONT_ACT.NCATS_DEMOGRAPHICS;
create table BLUEHERONMETADATA.NCATS_ICD10_ICD9_DX_V1 as select * from SHRINE_ONT_ACT.NCATS_ICD10_ICD9_DX_V1;
create table BLUEHERONMETADATA.NCATS_LABS as select * from SHRINE_ONT_ACT.NCATS_LABS;
create table BLUEHERONMETADATA.NCATS_VISIT_DETAILS as select * from SHRINE_ONT_ACT.NCATS_VISIT_DETAILS;


-------------------------------------------------------------------------------
-- update BLUEHERONMETADATA.ont tables which are using metdatada approach
-------------------------------------------------------------------------------
-- for medication, look at shrine_act_medication_mapping.sql

create table blueheronmetadata.ncats_demographics
as
with mto1
as
(
select shrine_fullname
from shrine_ont_act.act_meta_manual_mapping
group by shrine_fullname
having count(*)>1
) 
, upduplicated_parent as
(
select 
tbl.C_HLEVEL ,
tbl.C_FULLNAME ,
tbl.C_NAME ,
tbl.C_SYNONYM_CD ,
'F' || substr(tbl.C_VISUALATTRIBUTES,2) C_VISUALATTRIBUTES ,
tbl.C_TOTALNUM ,
null C_BASECODE,
tbl.C_METADATAXML ,
tbl.C_FACTTABLECOLUMN ,
tbl.C_TABLENAME ,
tbl.C_COLUMNNAME ,
tbl.C_COLUMNDATATYPE ,
tbl.C_OPERATOR ,
tbl.C_DIMCODE ,
tbl.C_COMMENT ,
tbl.C_TOOLTIP ,
tbl.UPDATE_DATE ,
tbl.DOWNLOAD_DATE ,
tbl.IMPORT_DATE ,
tbl.SOURCESYSTEM_CD ,
tbl.VALUETYPE_CD ,
tbl.M_APPLIED_PATH ,
tbl.M_EXCLUSION_CD ,
tbl.C_PATH ,
tbl.C_SYMBOL 
from SHRINE_ONT_ACT.ncats_demographics tbl
where c_fullname
in
    (
    select shrine_fullname
    from mto1
    )
)
, all_data as
(
select
    CASE
        WHEN mto1.shrine_fullname is not null then tbl.C_HLEVEL +1
        ELSE tbl.C_HLEVEL
    END
C_HLEVEL ,
    CASE
        WHEN mto1.shrine_fullname is not null then tbl.C_FULLNAME || bmap.heron_basecode
        ELSE tbl.C_FULLNAME
    END
C_FULLNAME,
tbl.C_NAME ,
tbl.C_SYNONYM_CD ,
tbl.C_VISUALATTRIBUTES ,
tbl.C_TOTALNUM ,
COALESCE (bmap.heron_basecode,tbl.C_BASECODE) C_BASECODE,
tbl.C_METADATAXML ,
tbl.C_FACTTABLECOLUMN ,
tbl.C_TABLENAME ,
tbl.C_COLUMNNAME ,
tbl.C_COLUMNDATATYPE ,
tbl.C_OPERATOR ,
    CASE
        WHEN mto1.shrine_fullname is not null then tbl.C_DIMCODE || bmap.heron_basecode
        ELSE tbl.C_DIMCODE
    END
C_DIMCODE,
tbl.C_COMMENT ,
tbl.C_TOOLTIP ,
tbl.UPDATE_DATE ,
tbl.DOWNLOAD_DATE ,
tbl.IMPORT_DATE ,
tbl.SOURCESYSTEM_CD ,
tbl.VALUETYPE_CD ,
tbl.M_APPLIED_PATH ,
tbl.M_EXCLUSION_CD ,
tbl.C_PATH ,
tbl.C_SYMBOL
--,mto1.shrine_fullname
from SHRINE_ONT_ACT.ncats_demographics tbl
left join shrine_ont_act.act_meta_manual_mapping bmap
    on tbl.c_basecode=bmap.shrine_basecode
left join mto1 
    on tbl.c_fullname=mto1.shrine_fullname
)
, output as
(
select * from upduplicated_parent
union all 
select * from all_data
)
select
*
--count(*), count (distinct(c_basecode)) --, count (distinct(heron_basecode)), count (distinct(shrine_basecode)), count(distinct (COALESCE (bmap.heron_basecode,tbl.C_BASECODE)))
-- 166	143 vs 164	142
-- 1 code maps to 2 code
-- so, 143 looks ok
-- so, 164 + 2 childs = 166 (look ok)
from output
;
-------------------------------------------------------------------------------------------------------------------------------
--- COVID LABS CPT4
-- 1. only 1 cpt in in act covid, and heron has 1 and that' patient count is 0
------------------------------------------------------------------------------------------------------------------------------
insert into blueheronmetadata.act_covid
select
C_HLEVEL ,
C_FULLNAME ,
C_NAME ,
C_SYNONYM_CD ,
C_VISUALATTRIBUTES ,
C_TOTALNUM ,
replace(C_BASECODE,'CPT4','CPT') ,
C_METADATAXML ,
C_FACTTABLECOLUMN ,
C_TABLENAME ,
C_COLUMNNAME ,
C_COLUMNDATATYPE ,
C_OPERATOR ,
C_DIMCODE ,
C_COMMENT ,
C_TOOLTIP ,
M_APPLIED_PATH ,
UPDATE_DATE ,
DOWNLOAD_DATE ,
IMPORT_DATE ,
SOURCESYSTEM_CD ,
VALUETYPE_CD ,
M_EXCLUSION_CD ,
C_PATH ,
C_SYMBOL 
from blueheronmetadata.act_covid
where c_basecode like 'CPT4:%'
;
delete from blueheronmetadata.act_covid
where c_basecode like 'CPT:%'
;
commit
;
-------------------------------------------------------------------------------------------------------------------------------
--- COVID LABS HCPCS
--- same formate (no need to map, 0/2 avialbe in HERON) 
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
-- COVID LABS LOINC
-- TODO: Find out derived facts for LOINC
------------------------------------------------------------------------------------------------------------------------------
/*
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
*/
-------------------------------------------------------------------------------------------------------------------------------
--- LABS UMLS
-- Is folder(or leaf) which could have one to many relationsship.
------------------------------------------------------------------------------------------------------------------------------
/*
Lab Orders	UMLS:C0086143
ANY Positive Lab Test	UMLS:C1444714
ANY Negative Lab Test	UMLS:C1444714
ANY Pending Lab Test	UMLS:C1611271
ANY Equivocal Lab Test	UMLS:C4303880
*/
-------------------------------------------------------------------------------
-- TABLE_ACCESS
-------------------------------------------------------------------------------
DELETE from 
"BLUEHERONMETADATA"."TABLE_ACCESS"
where c_name like 'ACT%'
;
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_DEMO', 'NCATS_DEMOGRAPHICS', 'N', '1', '\ACT\Demographics\', 'ACT Demographics', 'N', 'CH ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\ACT\Demographics\', 'ACT Demographics');
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_DX_ICD10_2018', 'ACT_ICD10CM_DX_2018AA', 'N', '1', '\ACT\Diagnosis\ICD10\V2_2018AA\A20098492\', 'ACT Diagnoses ICD-10', 'N', 'FH ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\ACT\Diagnosis\ICD10\V2_2018AA\A20098492\', 'ACT Diagnoses ICD-10');
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_DX_ICD9_2018', 'ACT_ICD9CM_DX_2018AA', 'N', '1', '\ACT\Diagnosis\ICD9\V2_2018AA\A18090800\', 'ACT Diagnoses  ICD-9-CM', 'N', 'FH ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\ACT\Diagnosis\ICD9\V2_2018AA\A18090800\', 'ACT Diagnoses ICD-9CM');
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_LAB_LOINC_2018', 'ACT_LOINC_LAB_2018AA', 'N', '1', '\ACT\Lab\LOINC\V2_2018AA\A6321000\A23478825\A28298479\', 'ACT Laboratory Tests (Provisional)', 'N', 'FH ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\ACT\Lab\LOINC\V2_2018AA\A6321000\A23478825\A28298479\', 'ACT Lab LOINC (Full List)');
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_LAB', 'NCATS_LABS', 'N', '1', '\ACT\Labs\', 'ACT Laboratory Tests', 'N', 'CH ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\ACT\Labs\', 'ACT Laboratory Tests');
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_MED_ALPHA_2018', 'ACT_MED_ALPHA_V2_121318', 'N', '1', '\ACT\Medications\MedicationsByAlpha\V2_12112018\RxNormUMLSRxNav\', 'ACT Medications Alphabetical', 'N', 'FH ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\ACT\Medications\MedicationsByAlpha\V2_11262018\N0000010582\', 'ACT Medications New');
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_MED_VA_2018', 'ACT_MED_VA_V2_092818', 'N', '1', '\ACT\Medications\MedicationsByVaClass\V2_09302018\', 'ACT Medications VA Classes', 'N', 'FH ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\ACT\Medications\MedicationsByVaClass\V2_09302018\', 'ACT Medications');
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_PX_CPT_2018', 'ACT_CPT_PX_2018AA', 'N', '1', '\ACT\Procedures\CPT4\V2_2018AA\A23576389\', 'ACT Procedures CPT-4', 'N', 'FH ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\ACT\Procedures\CPT4\V2_2018AA\A23576389\', 'ACT Diagnoses ICD9');
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_PX_HCPCS_2018', 'ACT_HCPCS_PX_2018AA', 'N', '1', '\ACT\Procedures\HCPCS\V2_2018AA\A13475665\', 'ACT Procedures HCPCS', 'N', 'FH ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\ACT\Procedures\HCPCS\V2_2018AA\A13475665\', 'ACT Procedures HCPCS');
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_PX_ICD10_2018', 'ACT_ICD10PCS_PX_2018AA', 'N', '1', '\ACT\Procedures\ICD10\V2_2018AA\A16077350\', 'ACT Procedures ICD-10-PCS', 'N', 'FH ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\ACT\Procedures\ICD10\V2_2018AA\A16077350\', 'ACT Procedures ICD10');
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_PX_ICD9_2018', 'ACT_ICD9CM_PX_2018AA', 'N', '1', '\ACT\Procedures\ICD9\V2_2018AA\A18090800\A8352133\', 'ACT Procedures   ICD-9-Proc', 'N', 'FH ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\ACT\Procedures\ICD9\V2_2018AA\A18090800\A8352133\', 'ACT Procedures ICD9');
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_VISIT', 'NCATS_VISIT_DETAILS', 'N', '1', '\ACT\Visit Details\', 'ACT Visit Details', 'N', 'CH ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\ACT\Visit Details\', 'ACT Visit Details');
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_DX_10_9', 'NCATS_ICD10_ICD9_DX_V1', 'N', '1', '\Diagnoses\', 'ACT Diagnoses ICD10-ICD9', 'N', 'FH ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\Diagnoses\', 'ACT Diagnoses ICD10/9 Integrated');
INSERT INTO "BLUEHERONMETADATA"."TABLE_ACCESS" (C_TABLE_CD, C_TABLE_NAME, C_PROTECTED_ACCESS, C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_FACTTABLECOLUMN, C_DIMTABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, C_TOOLTIP) VALUES ('ACT_COVID_V1', 'ACT_COVID', 'N', '1', '\ACT\UMLS_C0031437\SNOMED_3947185011\', 'ACT COVID-19', 'N', 'CA ', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\ACT\C0031437\', 'ACT COVID-19');

commit;
-------------------------------------------------------------------------------
-- LESS_THAN_10 HERON_TERMS
-------------------------------------------------------------------------------
DELETE /*+ PARALLEL */ from 
"BLUEHERONMETADATA"."HERON_TERMS"
where C_FULLNAME = '\i2b2\Demographics\LESS_THAN_10\'
;
-- TERM_ID need to be max+1 eg. select max(term_id)+1 from BLUEHERONMETADATA.HERON_TERMS;
INSERT INTO "BLUEHERONMETADATA"."HERON_TERMS" (C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_BASECODE, C_FACTTABLECOLUMN, C_TABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, M_APPLIED_PATH, UPDATE_DATE, DOWNLOAD_DATE, IMPORT_DATE, SOURCESYSTEM_CD)
  VALUES ('4', '\i2b2\Demographics\LESS_THAN_10\', 'LESS THAN 10', 'N', 'LH ', 'LESS_THAN_10', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\i2b2\Demographics\LESS_THAN_10\', '@', SYSDATE,SYSDATE,SYSDATE, 'NCATS_LESS_THAN_10'
  )
;
-------------------------------------------------------------------------------
-- LESS_THAN_10 CONCEPT_DIMENSION
-------------------------------------------------------------------------------
DELETE  /*+ PARALLEL */ FROM
"&&heron_data_schema".concept_dimension
where concept_path = '\i2b2\Demographics\LESS_THAN_10\'
;
insert /*+ PARALLEL */ into "&&heron_data_schema".concept_dimension(
  concept_cd, 
  concept_path, 
  name_char,
  update_date, 
  download_date, 
  import_date, 
  sourcesystem_cd,
  upload_id
  )
select /*+ PARALLEL */ distinct 
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
  '&1' upload_id
from 
(
select C_BASECODE, C_FULLNAME , C_NAME , UPDATE_DATE , DOWNLOAD_DATE,sourcesystem_cd, C_DIMCODE
from BLUEHERONMETADATA.HERON_TERMS
where C_FULLNAME = '\i2b2\Demographics\LESS_THAN_10\'
) ib
where ib.c_basecode is not null
group by ib.c_basecode, ib.c_fullname
     , update_date, download_date, sysdate, sourcesystem_cd
;
commit;


-------------------------------------------------------------------------------
-- visit, med, HCPCS, demo CONCEPT_DIMENSION
-------------------------------------------------------------------------------
DELETE  /*+ PARALLEL */ FROM
"&&heron_data_schema".concept_dimension
where SOURCESYSTEM_CD='NCATS'
	and upload_id='&1'
;


insert  /*+ PARALLEL */ into "&&heron_data_schema".concept_dimension(
  concept_cd, 
  concept_path, 
  name_char,
  update_date, 
  download_date, 
  import_date, 
  sourcesystem_cd,
  upload_id
  )
select distinct 
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
  '&1' upload_id
from 
(
-- remove following table(HERON_TERMS) during normal heron release.
select C_BASECODE, C_FULLNAME , C_NAME , UPDATE_DATE , DOWNLOAD_DATE,sourcesystem_cd, C_DIMCODE
from BLUEHERONMETADATA.HERON_TERMS
union all
select C_BASECODE, C_FULLNAME , C_NAME , UPDATE_DATE , DOWNLOAD_DATE,sourcesystem_cd, C_DIMCODE
from BLUEHERONMETADATA.NCATS_DEMOGRAPHICS
union all
--select C_BASECODE, C_FULLNAME , C_NAME , UPDATE_DATE , DOWNLOAD_DATE,sourcesystem_cd, C_DIMCODE
--from BLUEHERONMETADATA.NCATS_ICD9_DIAG_HERON
--union all
--select C_BASECODE, C_FULLNAME , C_NAME , UPDATE_DATE , DOWNLOAD_DATE,sourcesystem_cd, C_DIMCODE
--from BLUEHERONMETADATA.NCATS_ICD9_PROC_HERON
--union all
--select C_BASECODE, C_FULLNAME , C_NAME , UPDATE_DATE , DOWNLOAD_DATE,sourcesystem_cd, C_DIMCODE
--from BLUEHERONMETADATA.NCATS_ICD10_ICD9_DX_V1_HERON
--union all
--union all
--select C_BASECODE, C_FULLNAME , C_NAME , UPDATE_DATE , DOWNLOAD_DATE,sourcesystem_cd, C_DIMCODE
--from BLUEHERONMETADATA.ncats_labs
select C_BASECODE, C_FULLNAME , C_NAME , UPDATE_DATE , DOWNLOAD_DATE,sourcesystem_cd, C_DIMCODE
from BLUEHERONMETADATA.ncats_visit_details
union all
select C_BASECODE, C_FULLNAME , C_NAME , UPDATE_DATE , DOWNLOAD_DATE,sourcesystem_cd, C_DIMCODE
from BLUEHERONMETADATA.ACT_MED_VA_V2_092818
union all
select C_BASECODE, C_FULLNAME , C_NAME , UPDATE_DATE , DOWNLOAD_DATE,sourcesystem_cd, C_DIMCODE
from BLUEHERONMETADATA.ACT_MED_ALPHA_V2_121318
union all
select C_BASECODE, C_FULLNAME , C_NAME , UPDATE_DATE , DOWNLOAD_DATE,sourcesystem_cd, C_DIMCODE
from BLUEHERONMETADATA.ACT_HCPCS_PX_2018AA
) ib
where ib.c_basecode is not null
group by ib.c_basecode, ib.c_fullname
     , update_date, download_date, sysdate, sourcesystem_cd
;
commit;

-------------------------------------------------------------------------------
-- visit LOS
-------------------------------------------------------------------------------
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

exit;
