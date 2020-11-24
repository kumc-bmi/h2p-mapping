# Supplement ACT SHRINE ontology with terms from KUH / KUMC.

# Database SID, login credentials are provided in the environment.
ACCOUNT=$(USERNAME)/$(PASSWORD)@$(SID)

# Note: exit code of sqlplus is unreliable, so we use sql (i.e. sqlcl)

act_shrine_ontology_mapping: status/table_access

clean:
	rm -rf status

# Make a directory for status, i.e. completion times
# Then as each script finishes, touch a corresponding file.
status/README:
	mkdir -p status
	echo "These files represent completion status of SQL scripts." >$@

status/demographics: status/meta_manual_mapping
	sql $(ACCOUNT) @demographics_mapping.sql $(metadata_schema) $(shrine_ont_schema)
	touch $@

status/meta_manual_mapping: status/README META_MANUAL_MAPPING.dat META_MANUAL_MAPPING.ctl
	sqlldr $(ACCOUNT) control=META_MANUAL_MAPPING.ctl
	touch $@

# link .dat as sqlldlr takes only .dat, and .csv are easier to view on github.
META_MANUAL_MAPPING.dat: META_MANUAL_MAPPING.csv
	ln -s $< $@

status/diagnosis: status/README
	sql $(ACCOUNT) @diagnosis_mapping.sql $(metadata_schema) $(shrine_ont_schema)
	touch $@

status/labs: status/README
	sql $(ACCOUNT) @labs_mapping.sql $(metadata_schema) $(shrine_ont_schema) $(etl_schema)
	touch $@

status/procedures: status/README
	sql $(ACCOUNT) @procedure_ont_map.sql
	touch $@

status/table_access: status/demographics status/diagnosis status/labs status/procedures
	sql $(ACCOUNT) @update_table_access.sql $(metadata_schema)
	touch $@
