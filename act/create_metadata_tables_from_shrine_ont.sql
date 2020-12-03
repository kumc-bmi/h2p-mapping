-- create_1to1_metadata_tables.sql
set echo on;
define metadata_schema=&1;
define shrine_ont_schema=&2;
-------------------------------------------------------------------------------
-- DROP and Create metadata.ont tables
-------------------------------------------------------------------------------
-- SQL statements to drop table:

whenever sqlerror continue
;
drop table "&&metadata_schema".ACT_LOINC_LAB_2018AA purge;
-- TODO: see following comment is still relvant : Following tables are using metadata approach,but require changes.
drop table "&&metadata_schema".ACT_MED_ALPHA_V2_121318 purge;
drop table "&&metadata_schema".ACT_MED_VA_V2_092818 purge;
drop table "&&metadata_schema".NCATS_LABS purge;

whenever sqlerror exit sql.sqlcode
;
-- SQL statements to create table: 
-- sql generator: select ''''|| 'create table "&&metadata_schema".'||c_table_name ||' nologging as select * from "&&shrine_ont_schema".'|| c_table_name ||' ;' sql from "&&shrine_ont_schema".table_access order by sql;

create table "&&metadata_schema".ACT_LOINC_LAB_2018AA  nologging as select * from "&&shrine_ont_schema".ACT_LOINC_LAB_2018AA ;
create table "&&metadata_schema".ACT_MED_ALPHA_V2_121318  nologging as select * from "&&shrine_ont_schema".ACT_MED_ALPHA_V2_121318 ;
create table "&&metadata_schema".ACT_MED_VA_V2_092818  nologging as select * from "&&shrine_ont_schema".ACT_MED_VA_V2_092818 ;
create table "&&metadata_schema".NCATS_LABS  nologging as select * from "&&shrine_ont_schema".NCATS_LABS ;

exit
;
