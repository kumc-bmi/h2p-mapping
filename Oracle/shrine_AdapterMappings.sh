#!/bin/sh
SHRINE_ONT_SCHEMA=$1
SID=$2
USERNAME=$3
PASSWORD=$4
########################################################################
# Coppying NACCR onotologoies and Generating SHRRINE ONT Mapping 
########################################################################


sqlplus $USERNAME/$PASSWORD@$SID << EOF

-- Drop old shrine NAACCR_ONTOLOGY and built fresh shrine NAACCR_ONTOLOGY
-- But Not going to build new shrine (shrin_ont.shrine) ontolgies everytime, 
-- it will be used as it is from Harvard.
drop table $SHRINE_ONT_SCHEMA.NAACCR_ONTOLOGY;
create table $SHRINE_ONT_SCHEMA.NAACCR_ONTOLOGY
  as (
    select * from BLUEHERONMETADATA.NAACCR_ONTOLOGY
  );


-- Create Shrine mapping as temp table
-- It will be mergezed with manual mapping in jenkins job
drop table $SHRINE_ONT_SCHEMA.temp_shrine_mapping;
CREATE TABLE $SHRINE_ONT_SCHEMA.temp_shrine_mapping
   AS (
       -- diagnosis icd9
        select '\\SHRINE'|| so.c_fullname scihls_path,
               '\\i2b2_Diagnoses' || ht.c_fullname heron_path 
        from $SHRINE_ONT_SCHEMA.shrine so
        join blueheronmetadata.heron_terms ht
          on so.c_basecode=ht.c_basecode
          and so.c_basecode like 'ICD9:%' 
          and ht.C_FULLNAME like '\i2b2\Diagnoses\%'
          
        union ALL
        
         -- diagnosis icd10
        select '\\SHRINE'|| so.c_fullname scihls_path,
               '\\i2b2_Diagnoses' || ht.c_fullname heron_path 
        from $SHRINE_ONT_SCHEMA.shrine so
        join blueheronmetadata.heron_terms ht
          on so.c_basecode=ht.c_basecode
          and so.c_basecode like 'ICD10:%' 
          and ht.C_FULLNAME like '\i2b2\Diagnoses\%'
        
        union ALL
        
        -- demographics 
        select '\\SHRINE'|| so.c_fullname scihls_path,
               '\\i2b2_Demographics' || ht.c_fullname heron_path 
        from $SHRINE_ONT_SCHEMA.shrine so
        join blueheronmetadata.heron_terms ht
          on so.c_basecode=ht.c_basecode
          and so.c_basecode like 'DEM%' 
          and ht.C_FULLNAME like '\i2b2\Demographics\%'

        union ALL

        -- NAACCR (tumor registry)
        select '\\SHRINE_NAACCR' || c_fullname as scihls_path,
               '\\i2b2_naaccr' ||  c_fullname as heron_path
        from $SHRINE_ONT_SCHEMA.NAACCR_ONTOLOGY
    );


/*
-- making terms visible(ACTIVE) if they have been mapped.
-- This does not need to run everytime as we are not building SHRINE ontolgies everytime.

update $SHRINE_ONT_SCHEMA.shrine
  set C_VISUALATTRIBUTES = regexp_replace( C_VISUALATTRIBUTES,'(^.{1})(.{1})(.*)$','\1A\3')
  where c_fullname in 
              (select substr(scihls_path,9,length(scihls_path))
                from temp_shrine_mapping
              );
*/

exit;
EOF


##########################################################################
# exporting shrine ont mapping as CSV and then comnine with manual mapping
##########################################################################

sqlplus -S $USERNAME/$PASSWORD@$SID << EOF
select systimestamp from dual;

set termout off
set arraysize 1000
-- set rowprefetch 2
set pages 0
SET echo off
SET feedback off
SET pagesize 0
SET linesize 32000
SET sqlprompt ''
SET trimspool on
set term off
set feed off
SPOOL AdapterMappings.csv
select '"'|| SCIHLS_PATH || '", "'|| HERON_PATH || '"' from  $SHRINE_ONT_SCHEMA.TEMP_SHRINE_MAPPING;
SPOOL off

set termout on
select systimestamp from dual;

exit
EOF

tail -n+2 AdapterMappings.csv  > temp.csv
head -n-1 temp.csv  > AdapterMappings.csv
rm temp.csv

cat shrine_manual_AdapterMappings.csv >> AdapterMappings.csv