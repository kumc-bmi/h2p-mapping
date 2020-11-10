/*
Authors: Lav Patel
Contact: http://informatics.kumc.edu/
Copyright: Copyright (c) 2017 Univeristy of Kansas Medical Center
License: MIT
*/

-- Drop old shrine NAACCR_ONTOLOGY and built fresh shrine NAACCR_ONTOLOGY
-- But Not going to build new shrine (shrin_ont.shrine) ontolgies everytime, 
-- it will be used as it is from Harvard.
drop table SHRINE_ONT.NAACCR_ONTOLOGY;
create table SHRINE_ONT.NAACCR_ONTOLOGY
  as (
    select * from BLUEHERONMETADATA.NAACCR_ONTOLOGY
  );


-- Create Shrine mapping as temp table
-- It will be mergezed with manual mapping in jenkins job
drop table SHRINE_ONT.temp_shrine_mapping;
CREATE TABLE SHRINE_ONT.temp_shrine_mapping
   AS (
       -- diagnosis icd9
        select '\\SHRINE'|| so.c_fullname scihls_path,
               '\\i2b2_Diagnoses' || ht.c_fullname heron_path 
        from SHRINE_ONT.shrine so
        join blueheronmetadata.heron_terms ht
          on so.c_basecode=ht.c_basecode
          and so.c_basecode like 'ICD9:%' 
          and ht.C_FULLNAME like '\i2b2\Diagnoses\%' 
        union ALL
        -- diagnosis icd10
        select '\\SHRINE'|| so.c_fullname scihls_path,
               '\\i2b2_Diagnoses' || ht.c_fullname heron_path 
        from SHRINE_ONT.shrine so
        join blueheronmetadata.heron_terms ht
          on so.c_basecode=ht.c_basecode
          and so.c_basecode like 'ICD10:%' 
          and ht.C_FULLNAME like '\i2b2\Diagnoses\%'
        union ALL
        -- demographics 
        select '\\SHRINE'|| so.c_fullname scihls_path,
               '\\i2b2_Demographics' || ht.c_fullname heron_path 
        from SHRINE_ONT.shrine so
        join blueheronmetadata.heron_terms ht
          on so.c_basecode=ht.c_basecode
          and so.c_basecode like 'DEM%' 
          and ht.C_FULLNAME like '\i2b2\Demographics\%'
        union ALL
        -- NAACCR (tumor registry)
        select '\\SHRINE_NAACCR' || c_fullname as scihls_path,
               '\\i2b2_naaccr' ||  c_fullname as heron_path
        from SHRINE_ONT.NAACCR_ONTOLOGY
        union ALL
        -- Procedure (CPT, ICD9, ICD10)
        select '\\SHRINE'|| so.c_fullname scihls_path
              ,'\\PCORI_PROCEDURE' || ht.c_fullname heron_path
        from SHRINE_ONT.shrine so
        join blueheronmetadata.heron_terms ht
          on replace(so.c_basecode,'ICD10PCS','ICD10') = ht.c_basecode
        where
          (
          so.c_basecode like 'CPT:%'
          or so.c_basecode like 'ICD9:%'
          or so.c_basecode like 'ICD10PCS:%'
          )
          and ht.C_FULLNAME like '\PCORI\PROCEDURE\%'
      );


/*
-- making terms visible(ACTIVE) if they have been mapped.
-- This does not need to run everytime as we are not building SHRINE ontolgies everytime.

update SHRINE_ONT.shrine
  set C_VISUALATTRIBUTES = regexp_replace( C_VISUALATTRIBUTES,'(^.{1})(.{1})(.*)$','\1A\3')
  where c_fullname in 
              (select substr(scihls_path,9,length(scihls_path))
                from temp_shrine_mapping
              );
*/


/*
Test Cases
*/


-- Test Case-1 : Check distinct counts of proedure's c_basecode in heron_terms
select basecodes_string,
      case
        when basecodes_string = ':0; CPT:13549; ICD10:178189; ICD9:4664; PROCEDURE:2'
           THEN 1
        else 1/0
      END as pass_fail
from (
  select listagg(basecode, '; ') within group (order by basecode) basecodes_string
  from (
    select
       REGEXP_SUBSTR(ht.c_basecode,'[^:]+',1,1) || ':' ||count(distinct(ht.c_basecode)) basecode
    from blueheronmetadata.heron_terms ht
    where ht.C_FULLNAME like '\PCORI\PROCEDURE\%'
    group by REGEXP_SUBSTR(ht.c_basecode,'[^:]+',1,1)
    order by basecode
        ) basecode_count
     )heron_terems_basecode;


--Test Case-2: Check distinct count of proedure's c_basecode in shrine_terms
select basecodes_string,
      case
        when basecodes_string = ':0; CPT:13549; HCPCS:6778; ICD10PCS:178189; ICD9:4664; PROCEDURE:2'
           THEN 1
        else 1/0
      END as pass_fail
from (
  select listagg(basecode, '; ') within group (order by basecode) basecodes_string
    from (
      select 
        REGEXP_SUBSTR(so.c_basecode,'[^:]+',1,1) || ':' || count(distinct(so.C_BASECODE)) basecode
      from SHRINE_ONT.shrine so
      where so.C_FULLNAME like '\SHRINE\PROCEDURE\%'
      group by REGEXP_SUBSTR(so.c_basecode,'[^:]+',1,1)
      order by basecode
          ) basecode_count
      ) shrine_terms_basecode;