#!/bin/sh
SID=$1
USERNAME=$2
PASSWORD=$3
########################################################################
# Coppying NACCR onotologoies and Generating SHRRINE ONT Mapping 
########################################################################

sqlplus -S $USERNAME/$PASSWORD@$SID @shrine_AdapterMappings.sql

##########################################################################
# exporting shrine ont mapping as CSV and then comnine with manual mapping
##########################################################################

sqlplus -S $USERNAME/$PASSWORD@$SID << EOF | grep -E "^ORA-|^ERROR"
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
select '"'|| SCIHLS_PATH || '","'|| HERON_PATH || '"' from  SHRINE_ONT.TEMP_SHRINE_MAPPING;
SPOOL off

set termout on
select systimestamp from dual;

exit
EOF

tail -n+2 AdapterMappings.csv  > temp.csv
head -n-1 temp.csv  > AdapterMappings.csv
rm temp.csv

cat shrine_manual_AdapterMappings.csv >> AdapterMappings.csv