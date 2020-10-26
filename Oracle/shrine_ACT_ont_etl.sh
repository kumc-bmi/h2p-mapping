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

# consumes shrine_ont_act.ACT_MANUAL_MAPPING
# creates temp_act_adapter_mapping2 and temp_act_adapter_mapping
sqlplus $USERNAME/$PASSWORD@$SID @shrine_ACT_AdapterMapping_file.sql

# consumes temp_act_adapter_mapping and temp_act_adapter_mapping2
# creates ./AdapterMappings.csv
sqlplus -S $USERNAME/$PASSWORD@$SID @shrine_ACT_export_AdapterMapping.sql | grep -E "^ORA-|^ERROR" || true

# remove empty lines from csv
sed -i '/^\s*$/d' "$mapping_output"

# at this point, the output_csv should contain rows which we have manually addressed, or mappings which
#   were produced above.  now we map everything else 1-to-1
tmp_output_csv="$(mktemp)"
cp "$mapping_output" "$tmp_output_csv"
python3 csv_distinct_merge.py "$tmp_output_csv" "$mapping_input" > "$mapping_output"

if [ "$what_to_do" != "only_AdapterMappings_file" ]; then
  sqlplus $USERNAME/$PASSWORD@$SID @shrine_ACT_onto_index.sql

  # creates shrine_ont_act.ACT_META_MANUAL_MAPPING
  sqlldr $USERNAME/$PASSWORD@$SID data=shrine_ACT_META_MANUAL_MAPPING.csv control=shrine_ACT_META_MANUAL_MAPPING.ctl

  # consumes shrine_ont_act.ACT_META_MANUAL_MAPPING
  sqlplus $USERNAME/$PASSWORD@$SID @shrine_ACT_metadata_and_concept.sql $upload_id $heron_data_schema
fi
