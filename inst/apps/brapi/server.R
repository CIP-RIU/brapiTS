library(jug)

# workaround: the include function's 2nd parameter does not seem to
# work correctly. So here is a one line solution:
# Load all modules in memory to activate mw_ variables for include
# x = list.files(system.file("apps/brapi", package = "brapiTS"), pattern = "mw_", full.names = TRUE) %>%
#   lapply(source)
list.files(system.file("apps/brapi/utils", package = "brapiTS"), full.names = TRUE, recursive = TRUE) %>% lapply(source)

source(system.file("apps/brapi/mw_calls.R", package = "brapiTS"))
source(system.file("apps/brapi/mw_token.R", package = "brapiTS"))
source(system.file("apps/brapi/mw_crops.R", package = "brapiTS"))
source(system.file("apps/brapi/mw_attributes.R", package = "brapiTS"))
source(system.file("apps/brapi/mw_attributes_categories.R", package = "brapiTS"))
source(system.file("apps/brapi/mw_germplasm_attributes.R", package = "brapiTS"))
source(system.file("apps/brapi/mw_germplasm.R", package = "brapiTS"))
source(system.file("apps/brapi/mw_germplasm_pedigree.R", package = "brapiTS"))
source(system.file("apps/brapi/mw_germplasm_markerprofiles.R", package = "brapiTS"))
source(system.file("apps/brapi/mw_germplasm_search.R", package = "brapiTS"))

source(system.file("apps/brapi/mw_locations.R", package = "brapiTS"))

source(system.file("apps/brapi/mw_maps.R", package = "brapiTS"))
source(system.file("apps/brapi/mw_maps_details.R", package = "brapiTS"))
source(system.file("apps/brapi/mw_maps_positions.R", package = "brapiTS"))
source(system.file("apps/brapi/mw_maps_positions_range.R", package = "brapiTS"))





res <- jug() %>%
  cors() %>%
  get("/brapi/v1/", function(req, res, err){
    "\nMock BrAPI server ready!\n\n"
  }) %>%

  # each 'include' corresponds to a first level path and corresponding path

  include(mw_token) %>%
  include(mw_crops) %>%
  include(mw_attributes) %>%
  include(mw_attributes_categories) %>%
  include(mw_calls) %>%
  include(mw_germplasm_attributes) %>%
  include(mw_germplasm_markerprofiles) %>%
  include(mw_germplasm_search) %>%
  include(mw_germplasm) %>%
  include(mw_germplasm_pedigree) %>%
  
  include(mw_locations) %>%
  
  include(mw_maps) %>%
  include(mw_maps_details) %>%
  include(mw_maps_positions) %>%
  include(mw_maps_positions_range) %>%
  
  
  # include(mw_markers) %>%
  # include(mw_markerprofiles) %>%
  # include(mw_markerprofiles_id) %>%
  # include(mw_allelematrix_search) %>%
  # include(mw_phenotypes_search) %>%
  # include(mw_programs) %>%
  
  # include(mw_trials) %>%
  # include(mw_seasons) %>%
  # include(mw_studytypes) %>%
  # include(mw_studies_search) %>%
  # include(mw_studies) %>%
  # include(mw_studies_layout) %>%
  # include(mw_studies_germplasm) %>%
  # include(mw_studies_observations) %>%
  # include(mw_studies_observationunits) %>%
  # include(mw_studies_observationVariables) %>%
  # include(mw_studies_table) %>%
  # include(mw_observationlevels) %>%
  # include(mw_phenotypes_search) %>%
  # include(mw_traits) %>%
  # include(mw_variables_datatypes) %>%
  # include(mw_variables_ontologies) %>%
  # include(mw_variables) %>%
  # include(mw_observationVariables) %>%
    
  # include(mw_samples) %>%

  # catch any remaining unknown pathes
  simple_error_handler() %>%
  serve_it(port = 2021)
