# Supplement ACT SHRINE ontology with terms from KUH / KUMC.

# Database SID, login credentials are provided in the environment.
ACCOUNT=$(USERNAME)/$(PASSWORD)@$(SID)

# Note: exit code of sqlplus is unreliable, so we use sql (i.e. sqlcl)

status/mapping: status/demographics status/visit_details \
		status/diagnosis status/labs status/procedures \
		status/covid status/medications
	touch $@

# targets ending in `_post` deal with concept/visit/patient dimensions,
#   indexes, table_access - had to be able to run on different computer.

status/table_access: status/demographics_post status/visit_details_post \
		status/diagnosis_post status/labs_post status/procedures_post \
		status/covid_post status/medications_post
	sql $(ACCOUNT) @update_table_access.sql $(metadata_schema)
	touch $@

status/visit_details:
	sql $(ACCOUNT) @visit_details_map.sql \
		$(metadata_schema) $(shrine_ont_schema) $(heron_data_schema)
	mkdir -p status
	touch $@

status/visit_details_post:
	sql $(ACCOUNT) @visit_details_map_post.sql \
		$(metadata_schema) $(shrine_ont_schema) $(heron_data_schema)
	mkdir -p status
	touch $@

status/demographics: status/meta_manual_mapping
	sql $(ACCOUNT) @demographics_mapping.sql $(metadata_schema) $(shrine_ont_schema)
	mkdir -p status
	touch $@

status/demographics_post:
	sql $(ACCOUNT) @demographics_mapping_post.sql $(metadata_schema) $(shrine_ont_schema)
	mkdir -p status
	touch $@

status/meta_manual_mapping: META_MANUAL_MAPPING.dat META_MANUAL_MAPPING.ctl
	sqlldr $(ACCOUNT) control=META_MANUAL_MAPPING.ctl
	mkdir -p status
	touch $@

# link .dat as sqlldlr takes only .dat, and .csv are easier to view on github.
META_MANUAL_MAPPING.dat: META_MANUAL_MAPPING.csv
	ln -s $< $@

status/diagnosis:
	sql $(ACCOUNT) @diagnosis_mapping.sql $(metadata_schema) $(shrine_ont_schema)
	mkdir -p status
	touch $@

status/diagnosis_post:
	sql $(ACCOUNT) @diagnosis_mapping_post.sql $(metadata_schema) $(shrine_ont_schema)
	mkdir -p status
	touch $@

status/labs:
	sql $(ACCOUNT) @labs_mapping.sql $(metadata_schema) $(shrine_ont_schema) $(etl_schema)
	mkdir -p status
	touch $@

status/labs_post:
	sql $(ACCOUNT) @labs_mapping_post.sql $(metadata_schema) $(shrine_ont_schema) $(etl_schema)
	mkdir -p status
	touch $@

status/medications_post:
	sql $(ACCOUNT) @medication_post.sql $(metadata_schema)
	mkdir -p status
	touch $@

status/medications_tables:
	sql $(ACCOUNT) @medication_mapping.sql \
		$(metadata_schema) $(shrine_ont_schema) $(etl_schema) ACT_MED_ALPHA_V2_121318
	sql $(ACCOUNT) @medication_mapping.sql \
		$(metadata_schema) $(shrine_ont_schema) $(etl_schema) ACT_MED_VA_V2_092818
	mkdir -p status
	touch $@

status/procedures:
	sql $(ACCOUNT) @procedure_ont_map.sql $(metadata_schema)
	mkdir -p status
	touch $@

status/procedures_post:
	sql $(ACCOUNT) @procedure_ont_map_post.sql $(metadata_schema)
	mkdir -p status
	touch $@

status/covid:
	sql $(ACCOUNT) @covid_mapping.sql $(metadata_schema) $(shrine_ont_schema)
	mkdir -p status
	touch $@

status/covid_post:
	sql $(ACCOUNT) @covid_mapping_post.sql $(metadata_schema) $(shrine_ont_schema)
	mkdir -p status
	touch $@

clean:
	rm -rf status
