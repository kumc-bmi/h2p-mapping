# Supplement ACT SHRINE ontology with terms from KUH / KUMC.

# Database SID, login credentials are provided in the environment.
ACCOUNT=$(USERNAME)/$(PASSWORD)@$(SID)

act_shrine_ontology_mapping: status/concept_dimension status/table_access

# Make a directory for status, i.e. completion times
# Then as each script finishes, touch a corresponding file.
status:
	mkdir -p $@

# TODO: migrate this code to per-domain scripts
status/tables: status
	sqlplus $(ACCOUNT) @create_metadata_tables_from_shrine_ont.sql \
		$(metadata_schema) $(shrine_ont_schema)
	touch $@

status/demographics: status/tables
	sqlplus $(ACCOUNT) @demographics_mapping.sql $(metadata_schema)
	touch $@

status/diagnosis: status/tables
	sqlplus $(ACCOUNT) @diagnosis_mapping.sql $(metadata_schema)
	touch $@

status/procedures: status/tables
	sqlplus $(ACCOUNT) @procedure_ont_map.sql

# TODO: clarify what's going on here or move contents of this script elsewhere.
status/misc:
	sqlplus $(ACCOUNT) @metadata_and_concept.sql $(upload_id) \
		$(heron_data_schema) $(shrine_ont_schema)

# Ensure concepts from all dimensions are in the concept dimension.
# TODO: migrate this code to per-domain scripts?
status/concept_dimension: status/diagnosis status/demographics status/procedures status/misc
	sqlplus $(ACCOUNT) @update_concept_dimension.sql $(upload_id) \
		$(heron_data_schema) $(metadata_schema)

# TODO: migrate this code to per-domain scripts
status/table_access:
	sqlplus $(ACCOUNT) @update_table_access.sql $metadata_schema
	touch $@


# procedures_done_idea:
#	touch $@ --date (sql "select max(modified) from procedures")
