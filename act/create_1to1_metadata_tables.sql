-- TODO: BLUEHERONMETADATA to variable
-------------------------------------------------------------------------------
-- DROP and Create metadata.ont tables
-------------------------------------------------------------------------------
-- SQL statements to drop table:
-- select  'drop table BLUEHERONMETADATA.'||c_table_name || ';' sql from SHRINE_ONT_ACT.table_access order by sql;
whenever sqlerror continue
;
drop table BLUEHERONMETADATA.ACT_COVID;
drop table BLUEHERONMETADATA.ACT_CPT_PX_2018AA;
drop table BLUEHERONMETADATA.ACT_HCPCS_PX_2018AA;
drop table BLUEHERONMETADATA.ACT_ICD10CM_DX_2018AA;
drop table BLUEHERONMETADATA.ACT_ICD10PCS_PX_2018AA;
drop table BLUEHERONMETADATA.ACT_ICD9CM_DX_2018AA;
drop table BLUEHERONMETADATA.ACT_ICD9CM_PX_2018AA;
drop table BLUEHERONMETADATA.ACT_LOINC_LAB_2018AA;
-- TODO: see following comment is still relvant : Following tables are using metadata approach,but require changes.
drop table BLUEHERONMETADATA.ACT_MED_ALPHA_V2_121318;
drop table BLUEHERONMETADATA.ACT_MED_VA_V2_092818;
drop table BLUEHERONMETADATA.NCATS_DEMOGRAPHICS;
drop table BLUEHERONMETADATA.NCATS_ICD10_ICD9_DX_V1;
drop table BLUEHERONMETADATA.NCATS_LABS;
drop table BLUEHERONMETADATA.NCATS_VISIT_DETAILS;
whenever sqlerror exit sql.sqlcode
;
-- SQL statements to create table: 
-- select ''''|| 'create table BLUEHERONMETADATA.'||c_table_name ||' as select * from SHRINE_ONT_ACT.'|| c_table_name ||' ;' sql from SHRINE_ONT_ACT.table_access order by sql;
create table BLUEHERONMETADATA.ACT_COVID as select * from SHRINE_ONT_ACT.ACT_COVID ;
create table BLUEHERONMETADATA.ACT_CPT_PX_2018AA as select * from SHRINE_ONT_ACT.ACT_CPT_PX_2018AA ;
create table BLUEHERONMETADATA.ACT_HCPCS_PX_2018AA as select * from SHRINE_ONT_ACT.ACT_HCPCS_PX_2018AA ;
create table BLUEHERONMETADATA.ACT_ICD10CM_DX_2018AA as select * from SHRINE_ONT_ACT.ACT_ICD10CM_DX_2018AA ;
create table BLUEHERONMETADATA.ACT_ICD10PCS_PX_2018AA as select * from SHRINE_ONT_ACT.ACT_ICD10PCS_PX_2018AA ;
create table BLUEHERONMETADATA.ACT_ICD9CM_DX_2018AA as select * from SHRINE_ONT_ACT.ACT_ICD9CM_DX_2018AA ;
create table BLUEHERONMETADATA.ACT_ICD9CM_PX_2018AA as select * from SHRINE_ONT_ACT.ACT_ICD9CM_PX_2018AA ;
create table BLUEHERONMETADATA.ACT_LOINC_LAB_2018AA as select * from SHRINE_ONT_ACT.ACT_LOINC_LAB_2018AA ;
create table BLUEHERONMETADATA.ACT_MED_ALPHA_V2_121318 as select * from SHRINE_ONT_ACT.ACT_MED_ALPHA_V2_121318 ;
create table BLUEHERONMETADATA.ACT_MED_VA_V2_092818 as select * from SHRINE_ONT_ACT.ACT_MED_VA_V2_092818 ;
create table BLUEHERONMETADATA.NCATS_DEMOGRAPHICS as select * from SHRINE_ONT_ACT.NCATS_DEMOGRAPHICS ;
create table BLUEHERONMETADATA.NCATS_ICD10_ICD9_DX_V1 as select * from SHRINE_ONT_ACT.NCATS_ICD10_ICD9_DX_V1 ;
create table BLUEHERONMETADATA.NCATS_LABS as select * from SHRINE_ONT_ACT.NCATS_LABS ;
create table BLUEHERONMETADATA.NCATS_VISIT_DETAILS as select * from SHRINE_ONT_ACT.NCATS_VISIT_DETAILS ;
