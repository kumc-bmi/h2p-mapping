# Supplement ACT SHRINE ontology with terms from KUH / KUMC.

# Database SID, login credentials are provided in the environment.
ACCOUNT=$(USERNAME)/$(PASSWORD)@$(SID)

act_shrine_ontology_mapping: status/table_access

# Make a directory for status, i.e. completion times
# Then as each script finishes, touch a corresponding file.
status/README:
	mkdir -p status
	echo "These files represent completion status of SQL scripts." >$@

status/demographics: status/meta_manual_mapping
	sqlplus $(ACCOUNT) @demographics_mapping.sql $(metadata_schema) $(shrine_ont_schema)
	touch $@

status/meta_manual_mapping: status/README META_MANUAL_MAPPING.dat META_MANUAL_MAPPING.ctl
	sqlldr $(ACCOUNT) control=META_MANUAL_MAPPING.ctl
	touch $@

# link .dat as sqlldlr takes only .dat, and .csv are easier to view on github.
META_MANUAL_MAPPING.dat: META_MANUAL_MAPPING.csv
	ln -s $< $@

status/diagnosis: status/README
	sqlplus $(ACCOUNT) @diagnosis_mapping.sql $(metadata_schema) $(shrine_ont_schema)
	touch $@

status/medications: status/README
	sql $(ACCOUNT) @medication_mapping.sql $(etl_schema) $(shrine_ont_schema) ACT_MED_ALPHA_V2_121318
	sql $(ACCOUNT) @medication_mapping.sql $(etl_schema) $(shrine_ont_schema) ACT_MED_VA_V2_092818
	touch $@

status/procedures: status/README
	sqlplus $(ACCOUNT) @procedure_ont_map.sql
	touch $@

status/table_access: status/demographics status/diagnosis status/procedures
	sqlplus $(ACCOUNT) @update_table_access.sql $(metadata_schema)
	touch $@
