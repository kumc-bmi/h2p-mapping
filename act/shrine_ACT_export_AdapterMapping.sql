set linesize 32000
set pagesize 0   -- No header rows
set trimspool on -- remove trailing blanks
set feedback off
-- some row has quatation in theri values, That is why I need to run sql statment.
spool AdapterMappings.csv
spool AdapterMappings.csv
select '"'|| SHRINE_PATH || '","'|| HERON_PATH || '"' from  temp_act_adapter_mapping
where SHRINE_PATH not like '%"%';
select '''' || SHRINE_PATH ||  ''',''' || HERON_PATH || '''' from  temp_act_adapter_mapping
where SHRINE_PATH  like '%"%';
select '"'|| SHRINE_PATH || '","'|| HERON_PATH || '"' from  temp_act_adapter_mapping2
where SHRINE_PATH not like '%"%';
select '''' || SHRINE_PATH ||  ''',''' || HERON_PATH || '''' from  temp_act_adapter_mapping2
where SHRINE_PATH  like '%"%';
spool off
exit;
