# Dead code checklist

Found on `master` at 41176f7 (2026-11-01). Nothing here has been deleted yet.

## Safe to delete

Nothing in the repo reaches these.

### Minitest suite (not run)
- [ ] `test/controllers/`
- [ ] `test/models/`
- [ ] `test/selenium/`
- [ ] `test/fixtures/` (2.1 MB)
- [ ] `test/test_helper.rb`
- [ ] `test/data/test.dat`, `test/data/SingingSongtestfile.txt`, `test/data/citation.pdf` (unused)
- Keep `test/factories/` and the rest of `test/data/`: the RSpec specs use them.

### One-off scripts in `lib/` (not required anywhere; `lib/` isn't autoloaded)
- [ ] `lib/load_variates.rb`: connects to a hard-coded `meta_development` as user `bohms`
- [ ] `lib/table_copy.rb`: uses the long-gone DBI gem
- [ ] `lib/parse_eml.rb`: reads a local `weather.eml`
- [ ] `lib/parser_test.rb`: loads `db/schema.rb` into SQLite
- [ ] `lib/element_handler.rb`
- [ ] `lib/eml_datatable_builder.rb`: stale copy; the live class is `app/models/eml_datatable_builder.rb`

### Models
- [ ] `app/models/unit_dictionary_job.rb`: whole body commented out

### Controller actions with no route
- [ ] `CitationsController#index_by_doi`
- [ ] `CitationsController#bibliography`
- [ ] `DatasetsController#upload`
- [ ] `DatasetsController#set_affiliation_for` and its route: uses `render :update` (removed in Rails 3), nothing links to it

### Templates and partials nothing renders
- [ ] `app/views/datatables/lter_index_not_used.html.erb`
- [ ] `app/views/datum/weather_datas/show.erb`
- [ ] `app/views/datasets/_dataset.html.erb`
- [ ] `app/views/datasets/_dataset_file_fields.html.erb`
- [ ] `app/views/datasets/_variate.eml.erb`
- [ ] `app/views/datatables/_temporal_coverage.html.erb`
- [ ] `app/subdomain_views/people/_show.html.erb`

### `.js.erb` templates no request asks for (pages link to the HTML versions)
- [ ] `app/views/variates/new.js.erb`
- [ ] `app/views/affiliations/new.js.erb`
- [ ] `app/views/authors/new.js.erb`

### Unused helper methods
- [ ] `DatatablesHelper#ok_to_qc?`
- [ ] `DatatablesHelper#options_for_measurement_scale`
- [ ] `DatatablesHelper#options_for_data_type`

### Routes that point at nothing (they raise instead of returning 404)
- [ ] `resources :data_contributions` (no controller)
- [ ] `resources :climdb` (no controller)
- [ ] `resources :authors`: only `index` exists
- [ ] `resources :collections`: only `index` and `show` exist
- [ ] `resources :sponsors`: only `index` and `show` exist
- [ ] `resources :studies`: new, create, show, destroy have no actions
- [ ] `resources :units`: new, create, destroy have no actions
- [ ] `resources :ownerships`: edit, update, destroy have no actions
- [ ] `protocols#destroy`
- [ ] `abstracts#download`
- [ ] `citations#index_by_type` (the `get :index_by_type` route)
- [ ] `datatables#auto_complete_for_datatable_keyword_list`

## Probably dead: check nobody runs them from the console

Nothing in the app, rake tasks or specs calls these model methods.

- [ ] `Datatable#clone_into`
- [ ] `Datatable#related_keywords`
- [ ] `Datatable#convert_to_csv`
- [ ] `Datatable#generate_variates`
- [ ] `Datatable#supercession_candidates`
- [ ] `Datatable#release_all_current_records`
- [ ] `Person#to_lter_personneldb`
- [ ] `Person#lno_affiliations`
- [ ] `Person#no_current_lno_role?`
- [ ] `ScoreCard#scores_to_csv`
- [ ] `Study.find_all_with_datatables`
- [ ] `Treatment.select_options_by_use_in_citations`
- [ ] `Treatment.select_options_by_study`
- [ ] `Abstract.by_authors`
- [ ] `Citation#doi_citation_part`
- [ ] `Protocol#dataset_description`
- [ ] `EmlDatasetBuilder#project_party`
- [ ] `EmlDatasetBuilder#eml_kbs_address`

## Check the WordPress site first

- [ ] `app/views/users/show.js.erb`, `UsersController#show` and `resource :users, only: :show`: the old jQuery sign-in status script. The `signed-in` body class replaced it and nothing in this repo loads `/users.js`, but the WordPress theme might.

## Already pending elsewhere

- [ ] `app/assets/javascripts/protovis-d3.2.js`, `proto-graphs.js`, `scores.js`: removed by the unmerged `feature/d3-graphs` branch
- [ ] `invites` table (needs a migration)
- [ ] `permissions_legacy` table (needs a migration)
- [ ] `permissions.decision` column (needs a migration)
