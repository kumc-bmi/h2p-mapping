-- create_1to1_metadata_tables.sql
set echo on;
define metadata_schema=&2;
define shrine_ont_schema=&3;
-- define metadata_schema=BLUEHERONMETADATA;
-- define shrine_ont_schema=SHRINE_ONT_ACT;
-------------------------------------------------------------------------------
-- DROP and Create metadata.ont tables
-------------------------------------------------------------------------------
-- SQL statements to drop table:
-- select  'drop table "&&metadata_schema".'||c_table_name || ';' sql from "&&shrine_ont_schema".table_access order by sql;
whenever sqlerror continue
;
drop table "&&metadata_schema".ACT_COVID;
drop table "&&metadata_schema".ACT_CPT_PX_2018AA;
drop table "&&metadata_schema".ACT_HCPCS_PX_2018AA;
drop table "&&metadata_schema".ACT_ICD10CM_DX_2018AA;
drop table "&&metadata_schema".ACT_ICD10PCS_PX_2018AA;
drop table "&&metadata_schema".ACT_ICD9CM_DX_2018AA;
drop table "&&metadata_schema".ACT_ICD9CM_PX_2018AA;
drop table "&&metadata_schema".ACT_LOINC_LAB_2018AA;
-- TODO: see following comment is still relvant : Following tables are using metadata approach,but require changes.
drop table "&&metadata_schema".ACT_MED_ALPHA_V2_121318;
drop table "&&metadata_schema".ACT_MED_VA_V2_092818;
drop table "&&metadata_schema".NCATS_DEMOGRAPHICS;
drop table "&&metadata_schema".NCATS_ICD10_ICD9_DX_V1;
drop table "&&metadata_schema".NCATS_LABS;
drop table "&&metadata_schema".NCATS_VISIT_DETAILS;
whenever sqlerror exit sql.sqlcode
;
-- SQL statements to create table: 
-- select ''''|| 'create table "&&metadata_schema".'||c_table_name ||' as select * from "&&shrine_ont_schema".'|| c_table_name ||' ;' sql from "&&shrine_ont_schema".table_access order by sql;
create table "&&metadata_schema".ACT_COVID as select * from "&&shrine_ont_schema".ACT_COVID ;
create table "&&metadata_schema".ACT_CPT_PX_2018AA as select * from "&&shrine_ont_schema".ACT_CPT_PX_2018AA ;
create table "&&metadata_schema".ACT_HCPCS_PX_2018AA as select * from "&&shrine_ont_schema".ACT_HCPCS_PX_2018AA ;
create table "&&metadata_schema".ACT_ICD10CM_DX_2018AA as select * from "&&shrine_ont_schema".ACT_ICD10CM_DX_2018AA ;
create table "&&metadata_schema".ACT_ICD10PCS_PX_2018AA as select * from "&&shrine_ont_schema".ACT_ICD10PCS_PX_2018AA ;
create table "&&metadata_schema".ACT_ICD9CM_DX_2018AA as select * from "&&shrine_ont_schema".ACT_ICD9CM_DX_2018AA ;
create table "&&metadata_schema".ACT_ICD9CM_PX_2018AA as select * from "&&shrine_ont_schema".ACT_ICD9CM_PX_2018AA ;
create table "&&metadata_schema".ACT_LOINC_LAB_2018AA as select * from "&&shrine_ont_schema".ACT_LOINC_LAB_2018AA ;
create table "&&metadata_schema".ACT_MED_ALPHA_V2_121318 as select * from "&&shrine_ont_schema".ACT_MED_ALPHA_V2_121318 ;
create table "&&metadata_schema".ACT_MED_VA_V2_092818 as select * from "&&shrine_ont_schema".ACT_MED_VA_V2_092818 ;
create table "&&metadata_schema".NCATS_DEMOGRAPHICS as select * from "&&shrine_ont_schema".NCATS_DEMOGRAPHICS ;
create table "&&metadata_schema".NCATS_ICD10_ICD9_DX_V1 as select * from "&&shrine_ont_schema".NCATS_ICD10_ICD9_DX_V1 ;
create table "&&metadata_schema".NCATS_LABS as select * from "&&shrine_ont_schema".NCATS_LABS ;
create table "&&metadata_schema".NCATS_VISIT_DETAILS as select * from "&&shrine_ont_schema".NCATS_VISIT_DETAILS ;
exit
;
