set echo on
;
define i2b2_etl_schema=&1;
define SHRINE_ONT_SCHEMA=&2
define MED_TABLE=&3
define nB2=&4
;
/*
TODO:
1. fix @nb2 to id

variables: 
"&&i2b2_etl_schema"
"&&nB2"

*/
/*
1. take act meds
2. add column c_basecode_rxcui
3. convert rxnorm to rxcui (and save in c_basecode_rxcui)
4. convert NUI to rxcui    (and save in c_basecode_rxcui)
5. add column c_basecode_rxcui_heron
6. c_basecode_rxcui_mapped will indicate weather heron has that rxcui or not
7. add column for c_basecode_rxcui_medid
8. map rest of rxcui(which are not mapped to heron using c_basecode_rxcui_mapped ) to med_id  (and save in c_basecode_rxcui_medid)
9. create mapping file first preference c_basecode_rxcui and second preference c_basecode_rxcui_medid
*/
-------------------------------------------------------------------------------
--- create id db link
-------------------------------------------------------------------------------
whenever sqlerror continue;
drop public database link nB2;
whenever sqlerror exit sql.sqlcode;
CREATE public DATABASE LINK nB2 
   USING '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=8521)))(CONNECT_DATA=(SERVICE_NAME=nheronB2)))'
; 
-------------------------------------------------------------------------------
--- tmp_med_mapping
-------------------------------------------------------------------------------
set echo on;
whenever sqlerror continue;
drop table tmp_med_mapping;
whenever sqlerror exit sql.sqlcode
;
CREATE table tmp_med_mapping
parallel 20
NOLOGGING 
as
with clarity_med_id_to_rxcui as (
  --clarity_medication_id, rxcui, dose_pref
  select 'KUH|MEDICATION_ID:' || cmed.medication_id clarity_med_id, rxn.rxnorm_code rxcui, '1) Clarity'  dose_pref
  from clarity.rxnorm_codes@&&nB2 rxn
  join clarity.clarity_medication@id cmed on cmed.medication_id = rxn.medication_id
  union all
  select 'KUH|MEDICATION_ID:' || clarity_med_id, rxcui, '2) GCN'
  from "&&i2b2_etl_schema".clarity_med_id_to_rxcui_gcn@id
  union all
  select 'KUH|MEDICATION_ID:' || clarity_med_id,  rxcui, '3) NDC'
  from "&&i2b2_etl_schema".clarity_med_id_to_rxcui_ndc@id
  union all
  select  'KUH|MEDICATION_ID:' || to_number(clarity_medication_id), rxcui, '4) Manual Curation' --, con.tty, va_name, sdf_name
  from "&&i2b2_etl_schema".med_map_manual_curation mmmc
  join rxnorm.rxnconso@&&nB2 con on con.rxaui = mmmc.sdf_rxaui
)
,nui_to_rxcui  as
  (
  select
    'NUI:' || CODE CODE,
    'RXCUI:' || RXCUI RXCUI
  from rxnorm.rxnconso@&&nb2
    where code like 'N%'
      and code not in ('NOCODE')
  group by rxcui,code
    having count(*) >=1
  )
, NCATS_MEDS_RXCUI as
  (
  select 
  C_HLEVEL ,   C_FULLNAME ,   C_NAME ,  C_SYNONYM_CD ,   C_VISUALATTRIBUTES ,   C_TOTALNUM ,  C_BASECODE ,
  CASE 
    WHEN C_BASECODE like 'RXNORM:%' THEN replace(C_BASECODE,'RXNORM:','RXCUI:')
    WHEN C_BASECODE like 'NUI:%'    THEN nui_to_rxcui.rxcui
    else C_BASECODE
  END as c_basecode_rxcui,
  C_METADATAXML ,  C_FACTTABLECOLUMN ,   C_TABLENAME ,  C_COLUMNNAME ,  C_COLUMNDATATYPE ,  C_OPERATOR ,  C_DIMCODE ,  C_COMMENT ,  C_TOOLTIP ,  UPDATE_DATE ,  DOWNLOAD_DATE ,  IMPORT_DATE ,  SOURCESYSTEM_CD ,
  VALUETYPE_CD ,  M_APPLIED_PATH ,  M_EXCLUSION_CD ,  C_PATH ,  C_SYMBOL 
  from "&&SHRINE_ONT_SCHEMA"."&&MED_TABLE" sh
  left JOIN nui_to_rxcui nui_to_rxcui
    on sh.c_basecode=nui_to_rxcui.code
  )
, med_mapping as
(
  select 
  sh.*,
  he.c_basecode c_basecode_rxcui_mapped,
  --medid_to_rxcui.concept_cd c_basecode_medid_mapped,
  medid_to_rxcui.clarity_med_id c_basecode_medid_mapped,
  COALESCE(he.c_basecode,medid_to_rxcui.clarity_med_id
  ,sh.c_basecode) --coment this line out to find out which have been not mapped.
  c_basecode_final_mapping
  from NCATS_MEDS_RXCUI sh
  left JOIN BLUEHERONMETADATA.heron_terms he
    on sh.c_basecode_rxcui=he.c_basecode
  left JOIN clarity_med_id_to_rxcui medid_to_rxcui
    on sh.c_basecode_rxcui= 'RXCUI:' ||medid_to_rxcui.rxcui
), med_mapping_heron as
(
  select
  sh.*,
  he.c_fullname heron_path,
  he.c_name heron_c_name
  from med_mapping sh
  left
  join BLUEHERONMETADATA.HERON_TERMS he
    on sh.c_basecode_final_mapping = he.c_basecode
)
select 
C_HLEVEL , C_FULLNAME , C_NAME , c_basecode,
c_basecode_rxcui,c_basecode_rxcui_mapped, c_basecode_medid_mapped,
C_BASECODE_FINAL_MAPPING,heron_path
from med_mapping_heron
GROUP BY 
C_HLEVEL , C_FULLNAME , C_NAME , c_basecode,
c_basecode_rxcui, c_basecode_rxcui_mapped, c_basecode_medid_mapped, 
C_BASECODE_FINAL_MAPPING,heron_path
having count(*)>=1
;
-------------------------------------------------------------------------------
--- TEMP_NCATS_MEDS_HERON
-------------------------------------------------------------------------------
whenever sqlerror continue;
drop table TEMP_NCATS_MEDS_HERON;
whenever sqlerror exit sql.sqlcode;
create table TEMP_NCATS_MEDS_HERON
as
select C_HLEVEL , C_FULLNAME , C_NAME , C_SYNONYM_CD , C_VISUALATTRIBUTES , C_TOTALNUM , C_BASECODE ,  C_FACTTABLECOLUMN , C_TABLENAME , C_COLUMNNAME , C_COLUMNDATATYPE , C_OPERATOR , C_DIMCODE ,  C_TOOLTIP , UPDATE_DATE , DOWNLOAD_DATE , IMPORT_DATE , SOURCESYSTEM_CD , VALUETYPE_CD , M_APPLIED_PATH , M_EXCLUSION_CD , C_PATH , C_SYMBOL
from 
(
select sh.C_HLEVEL C_HLEVEL,
sh.C_FULLNAME C_FULLNAME,
sh.C_NAME C_NAME,
sh.C_SYNONYM_CD C_SYNONYM_CD,
sh.C_VISUALATTRIBUTES C_VISUALATTRIBUTES,
sh.C_TOTALNUM C_TOTALNUM,
COALESCE(he.C_BASECODE_FINAL_MAPPING, sh.C_BASECODE) C_BASECODE,
--sh.C_METADATAXML C_METADATAXML,
sh.C_FACTTABLECOLUMN C_FACTTABLECOLUMN,
sh.C_TABLENAME C_TABLENAME,
sh.C_COLUMNNAME C_COLUMNNAME,
sh.C_COLUMNDATATYPE C_COLUMNDATATYPE,
sh.C_OPERATOR C_OPERATOR,
sh.C_DIMCODE C_DIMCODE,
--sh.C_COMMENT C_COMMENT,
sh.C_TOOLTIP C_TOOLTIP,
sh.UPDATE_DATE UPDATE_DATE,
sh.DOWNLOAD_DATE DOWNLOAD_DATE,
sh.IMPORT_DATE IMPORT_DATE,
sh.SOURCESYSTEM_CD SOURCESYSTEM_CD,
sh.VALUETYPE_CD VALUETYPE_CD,
sh.M_APPLIED_PATH M_APPLIED_PATH,
sh.M_EXCLUSION_CD M_EXCLUSION_CD,
sh.C_PATH C_PATH,
sh.C_SYMBOL C_SYMBOL
from "&&SHRINE_ONT_SCHEMA"."&&MED_TABLE" sh
left join tmp_med_mapping he
on sh.C_FULLNAME = he.c_fullname
) 
group by C_HLEVEL , C_FULLNAME , C_NAME , C_SYNONYM_CD , C_VISUALATTRIBUTES , C_TOTALNUM , C_BASECODE , C_FACTTABLECOLUMN , C_TABLENAME , C_COLUMNNAME , C_COLUMNDATATYPE , C_OPERATOR , C_DIMCODE ,  C_TOOLTIP , UPDATE_DATE , DOWNLOAD_DATE , IMPORT_DATE , SOURCESYSTEM_CD , VALUETYPE_CD , M_APPLIED_PATH , M_EXCLUSION_CD , C_PATH , C_SYMBOL
having count(*) >= 1
;
ALTER TABLE TEMP_NCATS_MEDS_HERON ADD C_METADATAXML clob;
ALTER TABLE TEMP_NCATS_MEDS_HERON ADD C_COMMENT clob;
CREATE INDEX "TEMP_NCATS_MED_IDX" ON "TEMP_NCATS_MEDS_HERON" ("C_FULLNAME") ;
-- no dups
-------------------------------------------------------------------------------
--- TEMP_NCATS_MEDS_HERON_CNT
-------------------------------------------------------------------------------
whenever sqlerror continue;
drop table TEMP_NCATS_MEDS_HERON_CNT;
whenever sqlerror exit sql.sqlcode;
create table TEMP_NCATS_MEDS_HERON_CNT
AS
select c_fullname,count(*) cnt
from TEMP_NCATS_MEDS_HERON
group by c_fullname
;
whenever sqlerror continue;
drop table TEMP_NCATS_MEDS_HERON2;
whenever sqlerror exit sql.sqlcode;
create table TEMP_NCATS_MEDS_HERON2
parallel 20
NOLOGGING
as
  select *
  from TEMP_NCATS_MEDS_HERON
  where c_fullname in
    (
    select c_fullname
    from TEMP_NCATS_MEDS_HERON_CNT
    where cnt=1
    )
union all 
--dups
--for all dups, concat __ || c_basecode
  select 
  C_HLEVEL ,
  C_FULLNAME || '__' || C_BASECODE C_FULLNAME,
  C_NAME ,C_SYNONYM_CD ,C_VISUALATTRIBUTES ,C_TOTALNUM ,C_BASECODE ,C_FACTTABLECOLUMN ,C_TABLENAME ,C_COLUMNNAME ,C_COLUMNDATATYPE ,C_OPERATOR ,C_DIMCODE ,C_TOOLTIP ,UPDATE_DATE ,DOWNLOAD_DATE ,
  IMPORT_DATE ,SOURCESYSTEM_CD ,VALUETYPE_CD ,M_APPLIED_PATH ,M_EXCLUSION_CD ,C_PATH ,C_SYMBOL ,C_METADATAXML ,C_COMMENT 
  from TEMP_NCATS_MEDS_HERON
  where c_fullname in 
    (
    select c_fullname
    from TEMP_NCATS_MEDS_HERON_CNT
    where cnt>1
    )
union all
  select 
  C_HLEVEL ,
  C_FULLNAME,
  C_NAME ,C_SYNONYM_CD ,C_VISUALATTRIBUTES ,C_TOTALNUM ,C_BASECODE ,C_FACTTABLECOLUMN ,C_TABLENAME ,C_COLUMNNAME ,C_COLUMNDATATYPE ,C_OPERATOR ,C_DIMCODE ,C_TOOLTIP ,UPDATE_DATE ,DOWNLOAD_DATE ,
  IMPORT_DATE ,SOURCESYSTEM_CD ,VALUETYPE_CD ,M_APPLIED_PATH ,M_EXCLUSION_CD ,C_PATH ,C_SYMBOL ,C_METADATAXML ,C_COMMENT 
  from "&&SHRINE_ONT_SCHEMA"."&&MED_TABLE"
  where c_fullname in 
    (
    select c_fullname
    from TEMP_NCATS_MEDS_HERON_CNT
    where cnt>1
    )
;
-------------------------------------------------------------------------------
--- blueheronmetadata."MED_TABLE"
-------------------------------------------------------------------------------
whenever sqlerror continue;
drop table blueheronmetadata."&&MED_TABLE";
whenever sqlerror exit sql.sqlcode;
create table blueheronmetadata."&&MED_TABLE"
as
select * from TEMP_NCATS_MEDS_HERON2;


-- activate concepts
delete from nightherondata.concept_dimension
where
    sourcesystem_cd = 'ACT.&&MED_TABLE';

insert into nightherondata.concept_dimension (
    concept_cd,
    concept_path,
    name_char,
    update_date,
    download_date,
    import_date,
    sourcesystem_cd
)
    select
        c_basecode,
        c_fullname,
        c_name,
        update_date,
        download_date,
        sysdate,
        'ACT.&&MED_TABLE'
    from
        blueheronmetadata."&&MED_TABLE"
    where
        c_basecode is not null

commit;
