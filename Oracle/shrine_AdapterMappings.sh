#!/bin/sh
set -x
set -e
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
# removing each line output instead just looking for "^ORA-|^ERROR"
sqlplus -S $USERNAME/$PASSWORD@$SID @shrine_export_AdapterMapping.sql | grep -E "^ORA-|^ERROR" || true

# removing empty lines from csv
sed '/^\s*$/d' AdapterMappings.csv  > temp.csv
mv temp.csv AdapterMappings.csv

cat shrine_manual_AdapterMappings.csv >> AdapterMappings.csv