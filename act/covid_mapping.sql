set echo on;
define metadata_schema=&1;
define shrine_ont_schema=&2;

-- sql generator: select  'drop table "&&metadata_schema".'||c_table_name || 'purge ;' sql from "&&shrine_ont_schema".table_access order by sql;
whenever sqlerror continue
;
drop table "&&metadata_schema".ACT_COVID purge;
whenever sqlerror exit sql.sqlcode
;
create table "&&metadata_schema".ACT_COVID  nologging as select * from "&&shrine_ont_schema".ACT_COVID ;

/** COVID Prodcedures: replace CPT4 with CPT
 1. only 1 cpt in in act covid, and heron has 1 and that' patient count is 0
*/
update "&&metadata_schema".act_covid
set c_basecode = replace(c_basecode, 'CPT4', 'CPT')
where c_basecode like 'CPT4:%'
;
commit
;

update "&&metadata_schema".act_covid
set c_basecode = 'COVID-xyz-test:NEGATIVE'
where c_basecode = 'LOINC:94310-0 NEGATIVE';
commit;

update "&&metadata_schema".act_covid
set c_basecode = 'COVID-xyz-test:POSITIVE'
where c_basecode = 'LOINC:94310-0 POSITIVE';
commit;


/** LABS UMLS
-- Is folder(or leaf) which could have one to many relationsship.

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


Lab Orders	UMLS:C0086143
ANY Positive Lab Test	UMLS:C1444714
ANY Negative Lab Test	UMLS:C1444714
ANY Pending Lab Test	UMLS:C1611271
ANY Equivocal Lab Test	UMLS:C4303880
*/


-- map clarity dx_ids to ACT ICD10
INSERT INTO "&&metadata_schema".act_covid
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
        update_date,
        download_date,
        import_date,
        'ACT' sourcesystem_cd,
        valuetype_cd,
        m_applied_path,
        m_exclusion_cd,
        c_path,
        c_symbol
    FROM
        shrine_ont_act.act_covid   meta
        JOIN icd10_dx_id_map               map10 ON 'ICD10CM:' || map10.icd10 = meta.c_basecode;

insert into "&&metadata_schema".act_covid (
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

insert into "&&metadata_schema".act_covid (
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

insert into "&&metadata_schema".act_covid (
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

insert into "&&metadata_schema".act_covid (
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
