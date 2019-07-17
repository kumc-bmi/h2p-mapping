-------------------------------------------------------------------------------
-- TABLE_ACCESS
-------------------------------------------------------------------------------
DELETE from 
"BLUEHERONMETADATA"."TABLE_ACCESS"
where c_name like 'ACT%';

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

commit;


-------------------------------------------------------------------------------
-- LESS_THAN_10 HERON_TERMS
-------------------------------------------------------------------------------
DELETE from 
"BLUEHERONMETADATA"."HERON_TERMS"
where C_FULLNAME = '\i2b2\Demographics\LESS_THAN_10\';

-- TERM_ID need to be max+1 eg. select max(term_id)+1 from BLUEHERONMETADATA.HERON_TERMS;
INSERT INTO "BLUEHERONMETADATA"."HERON_TERMS" (C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_BASECODE, C_FACTTABLECOLUMN, C_TABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, M_APPLIED_PATH, UPDATE_DATE, DOWNLOAD_DATE, IMPORT_DATE, SOURCESYSTEM_CD, TERM_ID) VALUES ('4', '\i2b2\Demographics\LESS_THAN_10\', 'LESS THAN 10', 'N', 'LH ', 'LESS_THAN_10', 'concept_cd', 'concept_dimension', 'concept_path', 'T', 'LIKE', '\i2b2\Demographics\LESS_THAN_10\', '@', TO_DATE('2019-07-17 19:43:10', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2019-07-17 19:43:10', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2019-07-17 19:43:10', 'YYYY-MM-DD HH24:MI:SS'), 'ACT SHRINE MANUAL', '7448115');


-------------------------------------------------------------------------------
-- LESS_THAN_10 CONCEPT_DIMENSION
-------------------------------------------------------------------------------
DELETE FROM
BlueHeronData.concept_dimension
where concept_path = '\i2b2\Demographics\LESS_THAN_10\';

insert into BlueHeronData.concept_dimension(
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
  &&upload_id upload_id
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
