
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
    phenotypes_search_data <- phenotypes_search_data[phenotypes_search_data$germplasmDbId %in%
                                                       germplasmDbId, ]
    if(nrow(phenotypes_search_data) == 0) return(NULL)
  }

  if (observationVariableDbId != "any") {
    phenotypes_search_data <- phenotypes_search_data[phenotypes_search_data$observationVariableDbId %in%
                                                       observationVariableDbId, ]
    if(nrow(phenotypes_search_data) == 0) return(NULL)
  }

  if (studyDbId != "any") {
    phenotypes_search_data <- phenotypes_search_data[phenotypes_search_data$studyDbId %in%
                                                       studyDbId, ]
    if (nrow(phenotypes_search_data) == 0) return(NULL)
  }

  if (locationDbId != "any") {
    phenotypes_search_data <- phenotypes_search_data[phenotypes_search_data$locationDbId %in%
                                                       locationDbId, ]
    if (nrow(phenotypes_search_data) == 0) return(NULL)
  }

  if (programDbId != "any") {
    phenotypes_search_data <- phenotypes_search_data[phenotypes_search_data$programDbId %in%
                                                       programDbId, ]
    if (nrow(phenotypes_search_data) == 0) return(NULL)
  }

  if (seasonDbId != "any") {
    phenotypes_search_data <- phenotypes_search_data[phenotypes_search_data$seasonDbId %in%
                                                       seasonDbId, ]
    if (nrow(phenotypes_search_data) == 0) return(NULL)
  }

  if (observationLevel != "any") {
    phenotypes_search_data <- phenotypes_search_data[phenotypes_search_data$observationLevel %in%
                                                       observationLevel, ]
    if (nrow(phenotypes_search_data) == 0) return(NULL)
  }


  # paging here after filtering
  pg = paging(phenotypes_search_data, page, pageSize)
  phenotypes_search_data <- phenotypes_search_data[pg$recStart:pg$recEnd, ]


  ouid = unique(phenotypes_search_data$observationUnitDbId)

  n = length(ouid)
  #message(n)
  out = list(n)

  pg$pagination$totalCount = n

  for(i in 1:n){
    odat = phenotypes_search_data[phenotypes_search_data$observationUnitDbId == ouid[i], ]
    #odat = phenotypes_search_data
    #odat1 = odat[1, ]

    out[[i]] <- as.list(odat[1,
                              c("observationUnitDbId", "observationLevel", "observationLevels",
                                "plotNumber", "plantNumber", "blockNumber", "replicate",

                                "observationUnitName", "germplasmDbId", "germplasmName",
                                "studyDbId", "studyName", "studyLocationDbId", "studyLocation",
                                "programName", "X", "Y",
                                "entryNumber", "entryType"
                                ) ])

    trts <- list()
    if (odat$factor != "") {
      trts <- as.list(odat[1, c("factor", "modality")])
    }
    out[[i]]$treatments <- trts



    obid = unique(odat$observationVariableDbId)
    m = nrow(odat)
    obs = list(m)
    for (j in 1:m) {
      obs[[j]] <- as.list(odat[odat$observationVariableDbId == obid[j],
                               c("observationDbId", "observationVariableDbId", "observationVariableName",
                                 "observationTimestamp", "season", "operator", "value")])
      names(obs[[j]])[6] = c("observationTimeStamp")
      names(obs[[j]])[4] = c("collector")
    }
    out[[i]]$observations = obs


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

  germplasmDbId = "any"
  if ('germplasmDbIds' %in% prms) {
    germplasmDbId <- req$params$germplasmDbIds %>%  paste(collapse = ";") %>% safe_split()
  }
  observationVariableDbId = "any"
  if ('observationVariableDbIds' %in% prms) {
    observationVariableDbId <- req$params$observationVariableDbIds %>%  paste(collapse = ";") %>% safe_split()
  }
  studyDbId = "any"
  if ('studyDbIds' %in% prms) {
    studyDbId <- req$params$studyDbIds %>%  paste(collapse = ";") %>% safe_split()
  }
  locationDbId = "any"
  if ('locationDbIds' %in% prms) {
    locationDbId <- req$params$locationDbIds %>%  paste(collapse = ";") %>% safe_split()
  }
  programDbId = "any"
  if ('programDbIds' %in% prms) {
    programDbId <- req$params$programDbIds %>%  paste(collapse = ";") %>% safe_split()
  }
  seasonDbId = "any"
  if ('seasonDbIds' %in% prms) {
    seasonDbId <- req$params$seasonDbIds %>%  paste(collapse = ";") %>% safe_split()
  }

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

