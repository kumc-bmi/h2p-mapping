# Supplement ACT SHRINE ontology with terms from KUH / KUMC.

# Database SID, login credentials are provided in the environment.
ACCOUNT=$(USERNAME)/$(PASSWORD)@$(SID)

act_shrine_ontology_mapping: status/table_access

# Make a directory for status, i.e. completion times
# Then as each script finishes, touch a corresponding file.
status/README:
	mkdir -p status
	echo "These files represent completion status of SQL scripts." >$@

status/demographics: status/README
	sqlplus $(ACCOUNT) @demographics_mapping.sql $(metadata_schema) $(shrine_ont_schema)
	touch $@

status/diagnosis: status/README
	sqlplus $(ACCOUNT) @diagnosis_mapping.sql $(metadata_schema) $(shrine_ont_schema)
	touch $@

status/procedures: status/README
	sqlplus $(ACCOUNT) @procedure_ont_map.sql

status/table_access: status/demographics status/diagnosis status/procedures
	sqlplus $(ACCOUNT) @update_table_access.sql $metadata_schema
	touch $@
