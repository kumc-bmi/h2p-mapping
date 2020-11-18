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
: "$metadata_schema"
: "$shrine_ont_schema"

sqlplus $USERNAME/$PASSWORD@$SID @create_metadata_tables_from_shrine_ont.sql $metadata_schema
sqlplus $USERNAME/$PASSWORD@$SID @update_table_access.sql $metadata_schema
sqlplus $USERNAME/$PASSWORD@$SID @diagnosis_mapping.sql $metadata_schema
sqlplus $USERNAME/$PASSWORD@$SID @metadata_and_concept.sql $upload_id $heron_data_schema $shrine_ont_schema
sqlplus $USERNAME/$PASSWORD@$SID @procedure_ont_map.sql

sqlplus $USERNAME/$PASSWORD@$SID @update_concept_dimension.sql $upload_id $heron_data_schema $metadata_schema
