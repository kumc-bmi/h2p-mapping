set echo on;
define metadata_schema=&1;
define shrine_ont_schema=&2;
define data_schema=&3;

--- land concepts in concept_dimension
delete from "&&data_schema".concept_dimension where concept_path like '\ACT\Demographics\%' ;
insert /*+ APPEND */ into "&&data_schema".concept_dimension (
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
        "&&metadata_schema".ncats_demographics ib
    where
        ib.c_basecode is not null;
-- 163 rows inserted

commit;


/** Build demographic metadata table indexes.

See diagnosis_mapping.sql for act_ix_code_gen

select sql from act_ix_code_gen where c_table_name like '%_DEMO%';
*/
alter session set current_schema=&&metadata_schema;

whenever sqlerror continue;
drop index act_demo_c_fullname;
drop index act_demo_c_hlevel;
drop index act_demo_m_applied_path;
drop index act_demo_m_exclusion_cd;
whenever sqlerror exit sql.sqlcode;

create unique index act_demo_c_fullname on ncats_demographics(c_fullname) parallel 4;
create  index act_demo_c_hlevel on ncats_demographics(c_hlevel) parallel 4;
create  index act_demo_m_applied_path on ncats_demographics(m_applied_path) parallel 4;
create  index act_demo_m_exclusion_cd on ncats_demographics(m_exclusion_cd) parallel 4;
