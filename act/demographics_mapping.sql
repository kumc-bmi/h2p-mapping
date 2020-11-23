set echo on;
define metadata_schema=&1;
define shrine_ont_schema=&2;

whenever sqlerror continue
;
drop table "&&metadata_schema".NCATS_DEMOGRAPHICS purge;
whenever sqlerror exit sql.sqlcode
;

------------------------------------------------------------------------------
---------------- C_NAME       : ACT Demographics
---------------- C_TABLE_NAME : NCATS_DEMOGRAPHICS
---------------- C_TABLE_CD   : ACT_DEMO
---------------- subtree      : Entire tree
-------------------------------------------------------------------------------
create table "&&metadata_schema".ncats_demographics
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

--- land act_covid concepts in concept_dimension
delete from nightherondata.concept_dimension where concept_path like '\ACT\Demographics\%' ;
insert into nightherondata.concept_dimension (
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
    from
        blueheronmetadata.ncats_demographics ib
    where
        ib.c_basecode is not null;
-- 163 rows inserted

commit;


