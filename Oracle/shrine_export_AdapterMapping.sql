set linesize 32000
set pagesize 0   -- No header rows
set trimspool on -- remove trailing blanks
set feedback off
-- select '"'|| SCIHLS_PATH || '","'|| HERON_PATH || '"' from  SHRINE_ONT.TEMP_SHRINE_MAPPING order by SCIHLS_PATH;
-- some row has quatation in theri values, That is why I need to run sql statment.
spool myfile.csv
select '"'|| SCIHLS_PATH || '","'|| HERON_PATH || '"' from  SHRINE_ONT.TEMP_SHRINE_MAPPING
where SCIHLS_PATH not like '%"%';
select '''' || SCIHLS_PATH ||  ''',''' || HERON_PATH || '''' from  SHRINE_ONT.TEMP_SHRINE_MAPPING
where SCIHLS_PATH  like '%"%';
spool off
exit;
