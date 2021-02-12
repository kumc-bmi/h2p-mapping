define metadata_schema=&1
define data_schema=&2
define MED_TABLE=&3

-- activate concepts
delete from "&&data_schema".concept_dimension
where
    sourcesystem_cd = 'ACT.&&MED_TABLE';

insert into "&&data_schema".concept_dimension (
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
        "&&metadata_schema"."&&MED_TABLE"
    where
        c_basecode is not null
;

commit;

alter session set current_schema=&&metadata_schema;

whenever sqlerror continue;
drop index act_med_alpha_2018_c_fullname;
drop index act_med_alpha_2018_c_hlevel;
drop index act_med_alpha_2018_m_applied_p;
drop index act_med_alpha_2018_m_exclusion;
drop index act_med_va_2018_c_fullname;
drop index act_med_va_2018_c_hlevel;
drop index act_med_va_2018_m_applied_path;
drop index act_med_va_2018_m_exclusion_cd;
whenever sqlerror exit sql.sqlcode;

create unique index act_med_alpha_2018_c_fullname on act_med_alpha_v2_121318(c_fullname) parallel 4;
create  index act_med_alpha_2018_c_hlevel on act_med_alpha_v2_121318(c_hlevel) parallel 4;
create  index act_med_alpha_2018_m_applied_p on act_med_alpha_v2_121318(m_applied_path) parallel 4;
create  index act_med_alpha_2018_m_exclusion on act_med_alpha_v2_121318(m_exclusion_cd) parallel 4;
create unique index act_med_va_2018_c_fullname on act_med_va_v2_092818(c_fullname) parallel 4;
create  index act_med_va_2018_c_hlevel on act_med_va_v2_092818(c_hlevel) parallel 4;
create  index act_med_va_2018_m_applied_path on act_med_va_v2_092818(m_applied_path) parallel 4;
create  index act_med_va_2018_m_exclusion_cd on act_med_va_v2_092818(m_exclusion_cd) parallel 4;
