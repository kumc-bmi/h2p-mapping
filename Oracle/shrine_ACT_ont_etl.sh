set -x;

#creates the AdapterMapping table 
sqlplus $USERNAME/$PASSWORD@$SID @shrine_ACT_AdapterMapping_file.sql

# export AdapterMapping_file as AdapterMappings.csv
sqlplus -S $USERNAME/$PASSWORD@$SID @shrine_ACT_export_AdapterMapping.sql | grep -E "^ORA-|^ERROR" || true


# removing empty lines from csv
sed '/^\s*$/d' AdapterMappings.csv  > temp.csv && mv temp.csv AdapterMappings.csv

# Followings are using metadata mapping approach
grep  ACT_MED_ALPHA_2018  Original_1to1_mapping.csv >> original
grep  ACT_MED_VA_2018     Original_1to1_mapping.csv >> original
grep  ACT_PX_HCPCS_2018   Original_1to1_mapping.csv >> original
grep  ACT_DEMO            Original_1to1_mapping.csv >> original

# Followings are using Adapter Mapping  approach
#grep  ACT_PX_CPT_2018     Original_1to1_mapping.csv >> original
#grep  ACT_DX_ICD10_2018   Original_1to1_mapping.csv >> original
#grep  ACT_PX_ICD10_2018   Original_1to1_mapping.csv >> original
#grep  ACT_LAB_LOINC_2018  Original_1to1_mapping.csv >> original
#grep  ACT_VISIT           Original_1to1_mapping.csv >> original


cat original >> AdapterMappings.csv


if [ "$what_to_do" == "only_AdapterMappings_file" ]
then
    echo "exit 0";
	exit 0;
fi


sqlplus $USERNAME/$PASSWORD@$SID @shrine_ACT_onto_index.sql

#sqlplus $USERNAME/$PASSWORD@$SID @shrine_ACT_metadata_and_concept.sql $upload_id
