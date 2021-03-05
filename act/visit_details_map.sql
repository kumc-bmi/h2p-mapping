set echo on;

define metadata_schema=&1;
define shrine_ont_schema=&2;

whenever sqlerror continue;
drop table "&&metadata_schema".NCATS_VISIT_DETAILS purge;
whenever sqlerror exit sql.sqlcode;

create table "&&metadata_schema".NCATS_VISIT_DETAILS  nologging as select * from "&&shrine_ont_schema".NCATS_VISIT_DETAILS ;


-- remap visit types to use whatever is in heron_terms

-- ambulatory visit
update "&&metadata_schema"."NCATS_VISIT_DETAILS"
set
    ( c_basecode,
      c_facttablecolumn,
      c_tablename,
      c_columnname,
      c_columndatatype,
      c_operator,
      c_dimcode ) = (
        select
            c_basecode,
            c_facttablecolumn,
            c_tablename,
            c_columnname,
            c_columndatatype,
            c_operator,
            c_dimcode
        from
            "&&metadata_schema".heron_terms
        where
            c_fullname = '\i2b2\Visit Details\ENC_TYPE\AV\'
    )
where
    c_fullname = '\ACT\Visit Details\Visit type\Outpatient visit\';

-- emergency department visit
update "&&metadata_schema"."NCATS_VISIT_DETAILS"
set
    ( c_basecode,
      c_facttablecolumn,
      c_tablename,
      c_columnname,
      c_columndatatype,
      c_operator,
      c_dimcode ) = (
        select
            c_basecode,
            c_facttablecolumn,
            c_tablename,
            c_columnname,
            c_columndatatype,
            c_operator,
            c_dimcode
        from
            "&&metadata_schema".heron_terms
        where
            c_fullname = '\i2b2\Visit Details\ENC_TYPE\ED\'
    )
where
    c_fullname = '\ACT\Visit Details\Visit type\ER visit\';

-- emergency department visit admit to inpatient
-- -- missing in heron powell.  equivalent returns 0.  5708

-- inpatient hospital stay
update "&&metadata_schema"."NCATS_VISIT_DETAILS"
set
    ( c_basecode,
      c_facttablecolumn,
      c_tablename,
      c_columnname,
      c_columndatatype,
      c_operator,
      c_dimcode ) = (
        select
            c_basecode,
            c_facttablecolumn,
            c_tablename,
            c_columnname,
            c_columndatatype,
            c_operator,
            c_dimcode
        from
            "&&metadata_schema".heron_terms
        where
            c_fullname = '\i2b2\Visit Details\ENC_TYPE\IP\'
    )
where
    c_fullname = '\ACT\Visit Details\Visit type\Inpatient visit\';

-- no information
update "&&metadata_schema"."NCATS_VISIT_DETAILS"
set
    ( c_basecode,
      c_facttablecolumn,
      c_tablename,
      c_columnname,
      c_columndatatype,
      c_operator,
      c_dimcode ) = (
        select
            c_basecode,
            c_facttablecolumn,
            c_tablename,
            c_columnname,
            c_columndatatype,
            c_operator,
            c_dimcode
        from
            "&&metadata_schema".heron_terms
        where
            c_fullname = '\i2b2\Visit Details\ENC_TYPE\NI\'
    )
where
    c_fullname = '\ACT\Visit Details\Visit type\No Information\';

-- non-acute hospital stay
-- also missing in heron powell. 5708

-- other ambulatory visit
update "&&metadata_schema"."NCATS_VISIT_DETAILS"
set
    ( c_basecode,
      c_facttablecolumn,
      c_tablename,
      c_columnname,
      c_columndatatype,
      c_operator,
      c_dimcode ) = (
        select
            c_basecode,
            c_facttablecolumn,
            c_tablename,
            c_columnname,
            c_columndatatype,
            c_operator,
            c_dimcode
        from
            "&&metadata_schema".heron_terms
        where
            c_fullname = '\i2b2\Visit Details\ENC_TYPE\OA\'
    )
where
    c_fullname = '\ACT\Visit Details\Visit type\Other Outpatient visit\';

commit;
