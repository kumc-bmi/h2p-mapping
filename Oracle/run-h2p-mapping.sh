#!/bin/bash
set -e

# Expected environment variables (put there by Jenkins, etc.)

# All i2b2 terms - used for local path mapping
#export terms_table=

. ./load_pcornet_mapping.sh

# Insert local terms as leaves of the PCORNet terms and run the transform
sqlplus /nolog <<EOF
connect ${pcornet_cdm_user}/${pcornet_cdm}

set echo on;
set timing on;
set linesize 3000;
set pagesize 5000;

define i2b2_meta_schema=${i2b2_meta_schema}
define terms_table=${terms_table}

-- Local terminology mapping
start pcornet_mapping.sql

-- Prepare for transform
start gather_table_stats.sql

quit;
EOF
