set -x

# copying as .dat as sqlldlr takes only .dat, and .csv are easier to view on github.
cp shrine_ACT_MANUAL_MAPPING_table.csv shrine_ACT_MANUAL_MAPPING_table.dat
sqlldr $USERNAME/$PASSWORD@$SID control=shrine_ACT_MANUAL_MAPPING_table.ctl

# copying as .dat as sqlldlr takes only .dat, and .csv are easier to view on github.
cp shrine_ACT_META_MANUAL_MAPPING.csv shrine_ACT_META_MANUAL_MAPPING.dat
sqlldr $USERNAME/$PASSWORD@$SID control=shrine_ACT_META_MANUAL_MAPPING.ctl

#creates the AdapterMapping table
sqlplus $USERNAME/$PASSWORD@$SID @shrine_ACT_AdapterMapping_file.sql

# export AdapterMapping_file as AdapterMappings.csv
sqlplus -S $USERNAME/$PASSWORD@$SID @shrine_ACT_export_AdapterMapping.sql | grep -E "^ORA-|^ERROR" || true

# removing empty lines from csv
sed '/^\s*$/d' AdapterMappings.csv >temp.csv && mv temp.csv AdapterMappings.csv

# Followings are using metadata mapping approach
# Original_1to1_mapping.csv will be added trough jenkins
# TODO: Ask ACT commounity, is it ok to pulish Original_1to1_mapping.csv on github?
grep ACT_MED_ALPHA_2018 Original_1to1_mapping.csv >>original
grep ACT_MED_VA_2018 Original_1to1_mapping.csv >>original
grep ACT_PX_HCPCS_2018 Original_1to1_mapping.csv >>original
grep ACT_DEMO Original_1to1_mapping.csv >>original
grep ACT_COVID_V1 Original_1to1_mapping.csv >>original

# Followings are using Adapter Mapping  approach
#grep  ACT_PX_CPT_2018     Original_1to1_mapping.csv >> original
#grep  ACT_DX_ICD10_2018   Original_1to1_mapping.csv >> original
#grep  ACT_PX_ICD10_2018   Original_1to1_mapping.csv >> original
#grep  ACT_LAB_LOINC_2018  Original_1to1_mapping.csv >> original
#grep  ACT_VISIT           Original_1to1_mapping.csv >> original

cat original >>AdapterMappings.csv

if [ "$what_to_do" == "only_AdapterMappings_file" ]; then
    echo "exit 0"
    exit 0
fi

sqlplus $USERNAME/$PASSWORD@$SID @shrine_ACT_onto_index.sql

sqlplus $USERNAME/$PASSWORD@$SID @shrine_ACT_metadata_and_concept.sql $upload_id
