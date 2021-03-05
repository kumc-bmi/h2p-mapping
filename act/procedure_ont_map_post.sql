set echo on;
define metadata_schema=&1;
define data_schema=&2;
whenever sqlerror exit sql.sqlcode;

delete from "&&data_schema".concept_dimension
where concept_path like '\ACT\Procedures\%';

insert /*+ APPEND */ into "&&data_schema".concept_dimension(
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
