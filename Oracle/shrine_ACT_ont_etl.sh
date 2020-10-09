#!/bin/bash

# given an upstream `mapping_input` csv, this script prepares the ACT ontology mapping in two ways:
#
# - through the `mapping_output` csv (typically called AdapterMappings.csv; provided to the shrine app)
# - through `shrine_ACT_metadata_and_concept.sql`

set -euxo pipefail

: "$USERNAME"
: "$PASSWORD"
: "$SID"
: "$upload_id"
: "$heron_data_schema"
mapping_input="Original_1to1_mapping.csv"
mapping_output="AdapterMappings.csv"

# creates shrine_ont_act.ACT_MANUAL_MAPPING
sqlldr $USERNAME/$PASSWORD@$SID data=shrine_ACT_MANUAL_MAPPING_table.csv control=shrine_ACT_MANUAL_MAPPING_table.ctl

# create the AdapterMapping table
# consumes shrine_ont_act.ACT_MANUAL_MAPPING
sqlplus $USERNAME/$PASSWORD@$SID @shrine_ACT_AdapterMapping_file.sql

# creates shrine_ont_act.ACT_META_MANUAL_MAPPING
sqlldr $USERNAME/$PASSWORD@$SID data=shrine_ACT_META_MANUAL_MAPPING.csv control=shrine_ACT_META_MANUAL_MAPPING.ctl

# export AdapterMapping_file.  `AdapterMappings.csv` is created here!
# consumes shrine_ont_act.ACT_META_MANUAL_MAPPING
sqlplus -S $USERNAME/$PASSWORD@$SID @shrine_ACT_export_AdapterMapping.sql | grep -E "^ORA-|^ERROR" || true

# remove empty lines from csv
sed -i '/^\s*$/d' "$mapping_output"

# Followings are using metadata mapping approach
# Original_1to1_mapping.csv will be added trough jenkins
# TODO: Ask ACT commounity, is it ok to pulish Original_1to1_mapping.csv on github?
grep -E '(ACT_DEMO|ACT_MED_ALPHA_2018|ACT_MED_VA_2018|ACT_PX_HCPCS_2018)' "$mapping_input" >> "$mapping_output"

# remove covid diag (ICD10CM is being done by adapter mapping)
grep -Fv '\\ACT_COVID_V1\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0037088' "$mapping_input" >> "$mapping_output"

# the following are left out of the mapping_output csv
#   ACT_PX_CPT_2018
#   ACT_DX_ICD10_2018
#   ACT_PX_ICD10_2018
#   ACT_LAB_LOINC_2018
#   ACT_VISIT

if [ "$what_to_do" != "only_AdapterMappings_file" ]; then
  sqlplus $USERNAME/$PASSWORD@$SID @shrine_ACT_onto_index.sql
  sqlplus $USERNAME/$PASSWORD@$SID @shrine_ACT_metadata_and_concept.sql $upload_id $heron_data_schema
fi
