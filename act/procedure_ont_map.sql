/** ACT Procedures

SHRINE / i2b2 queries in general:

1. the incoming query term gets looked up in the adapter mapping file
2. the mapped term gets looked up in a metadata table (chosen using the table_access table) using c_fullname
3. typically, the result is a metadata row with c_tablename = 'concept_dimension' and c_dimcode corresponding pretty closely to c_fullname.
4. the c_dimcode is looked up in the concept_dimension using 'like' to find a bunch of concept_cds
5. the concept_cds are matched against the fact table, and we count(distinct patient_num) to get the results.

-- 1. adapter mapping is trivial

-- 2.
select * from shrinedb.shrine_query order by id desc;

-- <term><value>\\ACT_PX_ICD9_2018\ACT\Procedures\ICD9\V2_2018AA\A18090800\A8352133\A8360905\A8361110\A8340108\</value><name>47.0 Appendectomy</name></term>

select c_table_name from blueheronmetadata.table_access where c_table_cd ='ACT_PX_ICD9_2018';
-- c_table_name = ACT_ICD9CM_PX_2018AA

-- 3.
select * from blueheronmetadata.ACT_ICD9CM_PX_2018AA where c_fullname = '\ACT\Procedures\ICD9\V2_2018AA\A18090800\A8352133\A8360905\A8361110\A8340108\';

select * from nightherondata.concept_dimension where concept_path like '\ACT\Procedures\ICD9\V2_2018AA\A18090800\A8352133\A8360905\A8361110\A8340108\%';

-- ICD9PROC:47.0
select * from nightherondata.concept_dimension
where name_char like 'Append%' and concept_cd like 'ICD9:%'
and concept_cd = 'ICD9:47.0'
;

-- no appendectomies in our cohort
select * from blueheronmetadata.counts_by_concept
where concept_cd = 'ICD9:47.0';

-- what procedures _do_ we have?
create table proc_examples as
select distinct concept_cd, modifier_cd from nightherondata.observation_fact
where concept_cd like 'ICD9:__._'
;
select * from proc_examples ex
join nightherondata.concept_dimension cd on cd.concept_cd = ex.concept_cd
;
-- ICD9:41.5	Total splenectomy


select c_name, c_basecode, replace(c_basecode, 'ICD9PROC:', 'ICD9:') x_basecode, c_visualattributes, c_fullname
from blueheronmetadata.ACT_ICD9CM_PX_2018AA
where c_fullname like '\ACT\Procedures\ICD9\%'
and c_basecode like 'ICD9PROC:%'
;

*/


/** Create procedure tables
 */
whenever sqlerror continue;
drop table "&&metadata_schema".ACT_CPT_PX_2018AA;
drop table "&&metadata_schema".ACT_HCPCS_PX_2018AA;
drop table "&&metadata_schema".ACT_ICD10PCS_PX_2018AA;
drop table "&&metadata_schema".ACT_ICD9CM_PX_2018AA;
whenever sqlerror exit sql.sqlcode;

create table "&&metadata_schema".ACT_CPT_PX_2018AA as select * from SHRINE_ONT_ACT.ACT_CPT_PX_2018AA;
create table "&&metadata_schema".ACT_HCPCS_PX_2018AA as select * from SHRINE_ONT_ACT.ACT_HCPCS_PX_2018AA;
create table "&&metadata_schema".ACT_ICD10PCS_PX_2018AA as select * from SHRINE_ONT_ACT.ACT_ICD10PCS_PX_2018AA;
create table "&&metadata_schema".ACT_ICD9CM_PX_2018AA as select * from SHRINE_ONT_ACT.ACT_ICD9CM_PX_2018AA;


update "&&metadata_schema".ACT_CPT_PX_2018AA
set c_basecode = replace(C_BASECODE,'CPT4:','CPT:')
where c_fullname like '\ACT\Procedures\%'
and c_basecode like 'CPT4:%'
;

update "&&metadata_schema".ACT_ICD9CM_PX_2018AA
set c_basecode = replace(c_basecode, 'ICD9PROC:', 'ICD9:')
where c_fullname like '\ACT\Procedures\ICD9\%'
and c_basecode like 'ICD9PROC:%'
;
-- 4,670 rows updated.

update "&&metadata_schema".ACT_ICD10PCS_PX_2018AA
set c_basecode = replace(c_basecode, 'ICD10PCS:', 'ICD10:')
where c_fullname like '\ACT\Procedures\%'
and c_basecode like 'ICD10PCS:%'
;
-- 190,176 rows updated.

delete from nightherondata.concept_dimension
where concept_path like '\ACT\Procedures\%';

insert /*+ APPEND */ into nightherondata.concept_dimension(
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
 select * from "&&metadata_schema".ACT_CPT_PX_2018AA union all
 select * from "&&metadata_schema".ACT_HCPCS_PX_2018AA union all
 select * from "&&metadata_schema".ACT_ICD10PCS_PX_2018AA union all
 select * from "&&metadata_schema".ACT_ICD9CM_PX_2018AA
) ib
where ib.c_basecode is not null
;
-- 4,670 rows inserted.

commit;

/** Index procedure metadata
 */
alter session set current_schema="&&metadata_schema";
whenever sqlerror continue;
drop index ACT_PX_CPT_APPLIED_IDX ;
drop index ACT_PX_CPT_EXCLUDE_IDX ;
drop index ACT_PX_HCPCS_APPLIED_IDX ;
drop index ACT_PX_HCPCS_EXCLUDE_IDX ;
drop index ACT_PX_ICD10_APPLIED_IDX ;
drop index ACT_PX_ICD10_EXCLUDE_IDX ;
drop index ACT_PX_ICD9_APPLIED_IDX ;
drop index ACT_PX_ICD9_EXCLUDE_IDX ;
drop INDEX ACT_CPT_PX_fullname_IDX ;
drop INDEX ACT_HCPCS_PX_fullname_IDX ;
drop INDEX ACT_ICD10PCS_PX_fullname_IDX ;
drop INDEX ACT_ICD9CM_PX_fullname_IDX ;
whenever sqlerror exit sql.sqlcode;

CREATE INDEX ACT_PX_CPT_EXCLUDE_IDX ON ACT_CPT_PX_2018AA(M_EXCLUSION_CD) PARALLEL 2;
CREATE INDEX ACT_PX_HCPCS_EXCLUDE_IDX ON ACT_HCPCS_PX_2018AA(M_EXCLUSION_CD) PARALLEL 2;
CREATE INDEX ACT_PX_ICD10_EXCLUDE_IDX ON ACT_ICD10PCS_PX_2018AA(M_EXCLUSION_CD) PARALLEL 2;
CREATE INDEX ACT_PX_ICD9_EXCLUDE_IDX ON ACT_ICD9CM_PX_2018AA(M_EXCLUSION_CD) PARALLEL 2;
CREATE INDEX ACT_PX_CPT_APPLIED_IDX ON ACT_CPT_PX_2018AA(M_APPLIED_PATH) PARALLEL 2;
CREATE INDEX ACT_PX_HCPCS_APPLIED_IDX ON ACT_HCPCS_PX_2018AA(M_APPLIED_PATH) PARALLEL 2;
CREATE INDEX ACT_PX_ICD10_APPLIED_IDX ON ACT_ICD10PCS_PX_2018AA(M_APPLIED_PATH) PARALLEL 2;
CREATE INDEX ACT_PX_ICD9_APPLIED_IDX ON ACT_ICD9CM_PX_2018AA(M_APPLIED_PATH) PARALLEL 2;

CREATE INDEX ACT_CPT_PX_fullname_IDX ON ACT_CPT_PX_2018AA(c_fullname) PARALLEL 2;
CREATE INDEX ACT_HCPCS_PX_fullname_IDX ON ACT_HCPCS_PX_2018AA(c_fullname) PARALLEL 2;
CREATE INDEX ACT_ICD10PCS_PX_fullname_IDX ON ACT_ICD10PCS_PX_2018AA(c_fullname) PARALLEL 2;
CREATE INDEX ACT_ICD9CM_PX_fullname_IDX ON ACT_ICD9CM_PX_2018AA(c_fullname) PARALLEL 2;
