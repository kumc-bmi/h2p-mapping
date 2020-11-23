set echo on;
define heron_data_schema=&2;

------------------------------------------------------------------------------------------------------------------------------
-- COVID LABS LOINC
-- TODO: Find out derived facts for LOINC
------------------------------------------------------------------------------------------------------------------------------
/*
from:Morris, Michele <mim18@pitt.edu>
Yes map the labs to the derived facts. I think that is what most sites are doing at this point. Your version of the files may 
have an error where Positive and Negative have the same code but that is fixed in the updated version of the files which I am 
getting ready to repost. 
ANY Negative Lab Test  UMLS:C1334932
ANY Positive Lab Test  UMLS:C1335447
ANY Pending Lab Test  UMLS:C1611271
ANY Equivocal Lab Test  UMLS:C4303880
If you cannot map the lab to one of the 4 values you should map to Laboratory Testing
Laboratory Testing  UMLS:C0022885
*/
insert into blueheronmetadata.act_covid
select 
C_HLEVEL ,
C_FULLNAME ,
C_NAME ,
C_SYNONYM_CD ,
C_VISUALATTRIBUTES ,
C_TOTALNUM ,
'COVID-xyz-test:NEGATIVE' C_BASECODE ,
C_METADATAXML ,
C_FACTTABLECOLUMN ,
C_TABLENAME ,
C_COLUMNNAME ,
C_COLUMNDATATYPE ,
C_OPERATOR ,
C_DIMCODE ,
C_COMMENT ,
C_TOOLTIP ,
M_APPLIED_PATH ,
UPDATE_DATE ,
DOWNLOAD_DATE ,
IMPORT_DATE ,
SOURCESYSTEM_CD ,
VALUETYPE_CD ,
M_EXCLUSION_CD ,
C_PATH ,
C_SYMBOL 
from blueheronmetadata.act_covid
where c_basecode = 'LOINC:94310-0 NEGATIVE'
;

DELETE
from blueheronmetadata.act_covid
where c_basecode = 'LOINC:94310-0 NEGATIVE'
;

commit;
insert into blueheronmetadata.act_covid
select
C_HLEVEL ,
C_FULLNAME ,
C_NAME ,
C_SYNONYM_CD ,
C_VISUALATTRIBUTES ,
C_TOTALNUM ,
'COVID-xyz-test:POSITIVE' C_BASECODE ,
C_METADATAXML ,
C_FACTTABLECOLUMN ,
C_TABLENAME ,
C_COLUMNNAME ,
C_COLUMNDATATYPE ,
C_OPERATOR ,
C_DIMCODE ,
C_COMMENT ,
C_TOOLTIP ,
M_APPLIED_PATH ,
UPDATE_DATE ,
DOWNLOAD_DATE ,
IMPORT_DATE ,
SOURCESYSTEM_CD ,
VALUETYPE_CD ,
M_EXCLUSION_CD ,
C_PATH ,
C_SYMBOL 
from blueheronmetadata.act_covid
where c_basecode = 'LOINC:94310-0 POSITIVE'
;
DELETE
from blueheronmetadata.act_covid
where c_basecode = 'LOINC:94310-0 POSITIVE'
;
commit;
-------------------------------------------------------------------------------------------------------------------------------
--- LABS UMLS
-- Is folder(or leaf) which could have one to many relationsship.
------------------------------------------------------------------------------------------------------------------------------
/*
Lab Orders	UMLS:C0086143
ANY Positive Lab Test	UMLS:C1444714
ANY Negative Lab Test	UMLS:C1444714
ANY Pending Lab Test	UMLS:C1611271
ANY Equivocal Lab Test	UMLS:C4303880
*/




-------------------------------------------------------------------------------
-- visit LOS
-------------------------------------------------------------------------------
MERGE
INTO    "&&heron_data_schema".visit_dimension trg
USING   (
        SELECT  t1.rowid AS rid, t2.nval_num
        FROM    "&&heron_data_schema".visit_dimension t1
        JOIN    "&&heron_data_schema".observation_fact t2
        ON      t1.encounter_num = t2.encounter_num
        WHERE   t2.concept_cd='UHC|LOS:1'
        ) src
ON      (trg.rowid = src.rid)
WHEN MATCHED THEN UPDATE
    SET trg.length_of_stay = src.nval_num;  
commit;
--342,973 rows merged.

-- map clarity dx_ids to ACT ICD10
INSERT INTO blueheronmetadata.act_covid
    WITH icd10_dx_id_map AS (
        SELECT
            map10.code icd10,
            map10.dx_id,
            edg.dx_name
        FROM
            clarity.edg_current_icd10   map10
            JOIN clarity.clarity_edg         edg ON map10.dx_id = edg.dx_id
    )
    SELECT
--map10.*,
        c_hlevel + 1 c_hlevel,
        c_fullname
        || 'kuh_dx_id_'
        || map10.dx_id
        || '\' c_fullname,
        map10.dx_name c_name,
        c_synonym_cd,
        c_visualattributes,
        c_totalnum,
        'KUH|DX_ID:' || map10.dx_id c_basecode,
        c_metadataxml,
        c_facttablecolumn,
        c_tablename,
        c_columnname,
        c_columndatatype,
        c_operator,
        c_fullname
        || 'kuh_dx_id_'
        || map10.dx_id
        || '\' c_dimcode,
        c_comment,
        c_tooltip
        || 'kuh_dx_id_'
        || map10.dx_id
        || '\' c_tooltip,
        m_applied_path,
        update_date,
        download_date,
        import_date,
        'ACT' sourcesystem_cd,
        valuetype_cd,
        m_exclusion_cd,
        c_path,
        c_symbol
    FROM
        shrine_ont_act.act_covid   meta
        JOIN icd10_dx_id_map               map10 ON 'ICD10CM:' || map10.icd10 = meta.c_basecode;

insert into blueheronmetadata.act_covid (
    c_hlevel,
    c_fullname,
    c_basecode,
    c_name,
    c_synonym_cd,
    c_visualattributes,
    c_facttablecolumn,
    c_tablename,
    c_columnname,
    c_columndatatype,
    c_operator,
    c_dimcode,
    c_tooltip,
    m_applied_path,
    update_date,
    download_date,
    import_date,
    sourcesystem_cd
) values (
    '7',
    '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0242656\UMLS_C1444343\MECHANICAL_VENT\UMLS_C0199470\KUH|FLO_MEAS_ID:6687_SEL\',
    'KUH|FLO_MEAS_ID:6687_SEL',
    '002- #6687 $$ Vent Initial >',
    'N',
    'LA',
    'concept_cd',
    'concept_dimension',
    'concept_path',
    'T',
    'LIKE',
    '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0242656\UMLS_C1444343\MECHANICAL_VENT\UMLS_C0199470\KUH|FLO_MEAS_ID:6687_SEL\',
    'ACT Phenotype\COVID-19 Related Terms\Course Of Illness\Respiratory Therapy Management\Mechanical Ventilation',
    '@',
    SYSDATE,
    SYSDATE,
    SYSDATE,
    'ACT'
);

insert into blueheronmetadata.act_covid (
    c_hlevel,
    c_fullname,
    c_basecode,
    c_name,
    c_synonym_cd,
    c_visualattributes,
    c_facttablecolumn,
    c_tablename,
    c_columnname,
    c_columndatatype,
    c_operator,
    c_dimcode,
    c_tooltip,
    m_applied_path,
    update_date,
    download_date,
    import_date,
    sourcesystem_cd
) values (
    '7',
    '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0242656\UMLS_C1444343\MECHANICAL_VENT\UMLS_C0199470\KUH|FLO_MEAS_ID:6688_SEL\',
    'KUH|FLO_MEAS_ID:6688_SEL',
    '003- #6688 $$ Vent Subsequent Day >',
    'N',
    'LA',
    'concept_cd',
    'concept_dimension',
    'concept_path',
    'T',
    'LIKE',
    '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0242656\UMLS_C1444343\MECHANICAL_VENT\UMLS_C0199470\KUH|FLO_MEAS_ID:6688_SEL\',
    'ACT Phenotype\COVID-19 Related Terms\Course Of Illness\Respiratory Therapy Management\Mechanical Ventilation',
    '@',
    SYSDATE,
    SYSDATE,
    SYSDATE,
    'ACT'
);

insert into blueheronmetadata.act_covid (
    c_hlevel,
    c_fullname,
    c_basecode,
    c_name,
    c_synonym_cd,
    c_visualattributes,
    c_facttablecolumn,
    c_tablename,
    c_columnname,
    c_columndatatype,
    c_operator,
    c_dimcode,
    c_tooltip,
    m_applied_path,
    update_date,
    download_date,
    import_date,
    sourcesystem_cd
) values (
    '7',
    '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0242656\UMLS_C1444343\MECHANICAL_VENT\UMLS_C0199470\KUH|FLO_MEAS_ID:4256\',
    'KUH|FLO_MEAS_ID:4256',
    '004- #4256 $$ Vent Supply (#)',
    'N',
    'LA',
    'concept_cd',
    'concept_dimension',
    'concept_path',
    'T',
    'LIKE',
    '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0242656\UMLS_C1444343\MECHANICAL_VENT\UMLS_C0199470\KUH|FLO_MEAS_ID:4256\',
    'ACT Phenotype\COVID-19 Related Terms\Course Of Illness\Respiratory Therapy Management\Mechanical Ventilation',
    '@',
    SYSDATE,
    SYSDATE,
    SYSDATE,
    'ACT'
);

insert into blueheronmetadata.act_covid (
    c_hlevel,
    c_fullname,
    c_basecode,
    c_name,
    c_synonym_cd,
    c_visualattributes,
    c_facttablecolumn,
    c_tablename,
    c_columnname,
    c_columndatatype,
    c_operator,
    c_dimcode,
    c_tooltip,
    m_applied_path,
    update_date,
    download_date,
    import_date,
    sourcesystem_cd
) values (
    '7',
    '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0242656\UMLS_C1444343\MECHANICAL_VENT\UMLS_C0199470\KUH|FLO_MEAS_ID:10469_SEL\',
    'KUH|FLO_MEAS_ID:10469_SEL',
    'KUH|FLO_MEAS_ID:10469_SEL","001- #10469 VDR Device ID >',
    'N',
    'LA',
    'concept_cd',
    'concept_dimension',
    'concept_path',
    'T',
    'LIKE',
    '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0242656\UMLS_C1444343\MECHANICAL_VENT\UMLS_C0199470\KUH|FLO_MEAS_ID:10469_SEL\',
    'ACT Phenotype\COVID-19 Related Terms\Course Of Illness\Respiratory Therapy Management\Mechanical Ventilation',
    '@',
    SYSDATE,
    SYSDATE,
    SYSDATE,
    'ACT'
);

-- land act_covid concepts in concept_dimension
delete from nightherondata.concept_dimension where sourcesystem_cd like 'ACT' ;
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
        blueheronmetadata.act_covid ib
    where
        ib.c_basecode is not null;
-- 81,219 rows inserted

commit;
