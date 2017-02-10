
phenotypes_search_data = tryCatch({
  res <- read.csv(system.file("apps/brapi/data/studies_observations.csv",
                              package = "brapiTS"),
                  stringsAsFactors = FALSE)
  #res[, 1:12]
}, error = function(e) {
  NULL
}
)

phenotypes_search_list = function(
  germplasmDbId = 'any',
  observationVariableDbId = 'any',
  studyDbId = 'any',
  locationDbId = 'any',
  programDbId = 'any',
  seasonDbId = 'any',
  observationLevel = "plot",
  pageSize = 10000,
  page = 0
  ){

  if (germplasmDbId != "any") {
    phenotypes_search_data <- phenotypes_search_data[phenotypes_search_data$studyDbId %in% studyDbId, ]
    if(nrow(observationVariables_data) == 0) return(NULL)
  }


  # paging here after filtering
  pg = paging(phenotypes_search_data, page, pageSize)
  phenotypes_search_data <- phenotypes_search_data[pg$recStart:pg$recEnd, ]


  n = nrow(phenotypes_search_data)

  out = list(n)

  for(i in 1:n){
    out[[i]] <- as.list(phenotypes_search_data[i, ])
  }

  attr(out, "status") = list()
  attr(out, "pagination") = pg$pagination

  out
}


phenotypes_search = list(
  metadata = list(
    pagination = list(
      pageSize = 1000,
      currentPage = 0,
      totalCount = nrow(phenotypes_search_data),
      totalPages = 0
    ),
    status = list(),
    datafiles = list()
  ),
  result =  list()
)



process_phenotypes_search <- function(req, res, err){
  prms <- names(req$params)

  germplasmDbId = ifelse('germplasmDbIds' %in% prms, req$params$germplasmDbIds, "any")

  observationVariableDbId = ifelse('observationVariableDbIds' %in% prms, req$params$observationVariableDbIds, "any")
  studyDbId = ifelse('studyDbIds' %in% prms, req$params$studyDbIds, "any")
  locationDbId = ifelse('locationDbIds' %in% prms, req$params$locationDbIds, "any")

  programDbId = ifelse('programDbIds' %in% prms, req$params$programDbIds, "any")
  seasonDbId = ifelse('seasonDbIds' %in% prms, req$params$seasonDbIds, "any")
  observationLevel = ifelse('observationLevel' %in% prms, req$params$observationLevel, "any")

  pageSize = ifelse('pageSize' %in% prms, as.integer(req$params$pageSize), 100)
  page = ifelse('page' %in% prms, as.integer(req$params$page), 0)

  phenotypes_search$result$data = phenotypes_search_list(
    germplasmDbId = germplasmDbId,
    observationVariableDbId = observationVariableDbId,
    studyDbId = studyDbId,
    locationDbId = locationDbId,
    programDbId = programDbId,
    seasonDbId = seasonDbId,
    observationLevel = observationLevel,
    pageSize = pageSize,
    page = page
  )
  phenotypes_search$metadata$pagination = attr(phenotypes_search$result$data, "pagination")

  if(is.null(phenotypes_search$result$data)){
    res$set_status(404)
    phenotypes_search$metadata <-
      brapi_status(100,"No matching results.!"
                   , phenotypes_search$metadata$status)
    phenotypes_search$result = list()
  }

  phenotypes_search$metadata = list(pagination = attr(phenotypes_search$result$data, "pagination"),
                            status = attr(phenotypes_search$result$data, "status"),
                            datafiles = list())

  res$set_header("Access-Control-Allow-Methods", "GET")
  res$json(phenotypes_search)

}


mw_phenotypes_search <<-
  collector() %>%
  get("/brapi/v1/phenotypes-search[/]?", function(req, res, err){
    res$set_status(405)
  })  %>%
  put("/brapi/v1/phenotypes-search[/]?", function(req, res, err){
    res$set_status(405)
  }) %>%
  post("/brapi/v1/phenotypes-search[/]?", function(req, res, err){
    process_phenotypes_search(req, res, err)
  }) %>%
  delete("/brapi/v1/phenotypes-search[/]?", function(req, res, err){
    res$set_status(405)
  })

