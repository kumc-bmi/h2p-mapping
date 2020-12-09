set echo on;

whenever sqlerror continue;
drop index SHRINE_ONT_ACT.ACT_MED_ALPHA_APPLIED_IDX ;
drop index SHRINE_ONT_ACT.ACT_MED_ALPHA_EXCLUDE_IDX ;
drop index SHRINE_ONT_ACT.ACT_MED_VA_APPLIED_IDX ;
drop index SHRINE_ONT_ACT.ACT_MED_VA_EXCLUDE_IDX ;
drop index SHRINE_ONT_ACT.ACT_MED_VA_fullname_IDX;
drop index SHRINE_ONT_ACT.ACT_MED_VA_hlevel_IDX;
drop index SHRINE_ONT_ACT.ACT_MED_ALPHA_fullname_IDX;
drop index SHRINE_ONT_ACT.ACT_MED_ALPHA_hlevel_IDX;
whenever sqlerror exit sql.sqlcode;


alter session set current_schema=shrine_ont_act;
--------------------------------------------------------------------------------------------------------
---M_EXCLUSION_CD
--------------------------------------------------------------------------------------------------------
CREATE INDEX ACT_MED_VA_EXCLUDE_IDX ON ACT_MED_VA_V2_092818(M_EXCLUSION_CD) PARALLEL 2;
CREATE INDEX ACT_MED_ALPHA_EXCLUDE_IDX ON ACT_MED_ALPHA_V2_121318(M_EXCLUSION_CD) PARALLEL 2;

--------------------------------------------------------------------------------------------------------
---M_APPLIED_PATH
--------------------------------------------------------------------------------------------------------
CREATE INDEX ACT_MED_VA_APPLIED_IDX ON ACT_MED_VA_V2_092818(M_APPLIED_PATH) PARALLEL 2;
CREATE INDEX ACT_MED_ALPHA_APPLIED_IDX ON ACT_MED_ALPHA_V2_121318(M_APPLIED_PATH) PARALLEL 2;

--------------------------------------------------------------------------------------------------------
---c_fullname
--------------------------------------------------------------------------------------------------------
CREATE INDEX ACT_MED_VA_fullname_IDX ON ACT_MED_VA_V2_092818(c_fullname) PARALLEL 2;
CREATE INDEX ACT_MED_ALPHA_fullname_IDX ON ACT_MED_ALPHA_V2_121318(c_fullname) PARALLEL 2;

--------------------------------------------------------------------------------------------------------
---c_hlevel
--------------------------------------------------------------------------------------------------------
CREATE INDEX ACT_MED_VA_hlevel_IDX ON ACT_MED_VA_V2_092818(c_hlevel) PARALLEL 2;
CREATE INDEX ACT_MED_ALPHA_hlevel_IDX ON ACT_MED_ALPHA_V2_121318(c_hlevel) PARALLEL 2;



exit;
