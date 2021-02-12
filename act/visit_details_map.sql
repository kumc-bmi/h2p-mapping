set echo on;

define metadata_schema=&1;
define shrine_ont_schema=&2;

whenever sqlerror continue;
drop table "&&metadata_schema".NCATS_VISIT_DETAILS purge;
whenever sqlerror exit sql.sqlcode;

create table "&&metadata_schema".NCATS_VISIT_DETAILS  nologging as select * from "&&shrine_ont_schema".NCATS_VISIT_DETAILS ;
