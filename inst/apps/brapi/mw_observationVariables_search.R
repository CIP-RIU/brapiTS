
observationVariables_data = tryCatch({
  res <- read.csv(system.file("apps/brapi/data/observationVariables.csv",
                              package = "brapiTS"),
                  stringsAsFactors = FALSE)
  #res[, -c(1, 2)]
}, error = function(e) {
  NULL
}
)

lst2arr <- function(lst, split = ";"){
  if(lst == "") lst = jsonlite::fromJSON("{}")
  if(length(lst) > 0) {
    lst = safe_split(lst, split)
  }
  lst
}

observationVariables_list = function(
  page = 0, pageSize = 10000,
  observationVariableDbId = "any", ontologyXref = "any", ontologyDbId = "any",
  methodDbId = "any", scaleDbId = "any",
  name = "any", scale.datatype = "any", trait.class = "any"){

  if (observationVariableDbId[1] != "any")
  observationVariables_data <- observationVariables_data[
    observationVariables_data$observationVariableDbId %in% observationVariableDbId, ]
  if(nrow(observationVariables_data) == 0) return(NULL)

  if (ontologyXref[1] != "any")
  observationVariables_data <- observationVariables_data[
    observationVariables_data$ontologyXref %in% ontologyXref, ]
  if(nrow(observationVariables_data) == 0) return(NULL)

  if (ontologyDbId[1] != "any")
  observationVariables_data <- observationVariables_data[
    observationVariables_data$ontologyDbId %in% ontologyDbId, ]
  if(nrow(observationVariables_data) == 0) return(NULL)

  if (methodDbId[1] != "any")
  observationVariables_data <- observationVariables_data[
    observationVariables_data$methodDbId %in% methodDbId, ]
  if(nrow(observationVariables_data) == 0) return(NULL)

  if (scaleDbId[1] != "any")
  observationVariables_data <- observationVariables_data[
    observationVariables_data$scaleDbId %in% scaleDbId, ]
  if(nrow(observationVariables_data) == 0) return(NULL)

  if (name[1] != "any")
  observationVariables_data <- observationVariables_data[
    observationVariables_data$name %in% name, ]
  if(nrow(observationVariables_data) == 0) return(NULL)

  if (scale.datatype[1] != "any")
  observationVariables_data <- observationVariables_data[
    observationVariables_data$scale.datatype %in% scale.datatype, ]
  if(nrow(observationVariables_data) == 0) return(NULL)

  if (trait.class[1] != "any")
  observationVariables_data <- observationVariables_data[
    observationVariables_data$trait.class %in% trait.class, ]
  if(nrow(observationVariables_data) == 0) return(NULL)


  observationVariables_data <- observationVariables_data[
    !duplicated(observationVariables_data$observationVariableDbId), ]

  # paging here after filtering
  pg = paging(observationVariables_data, page, pageSize)
  observationVariables_data <- observationVariables_data[pg$recStart:pg$recEnd, ]

  n = nrow(observationVariables_data)
  out = list(n)
  cn = colnames(observationVariables_data)

  for(i in 1:n){
    #out[[i]] <- as.list(observationVariables_data[i, -c(1, 2) ])
    out[[i]] <- as.list(observationVariables_data[i, ])
    #synonyms
    out[[i]]$synonyms <- lst2arr(out[[i]]$synonyms)

    #context of use
    out[[i]]$contextOfUse <- lst2arr(out[[i]]$contextOfUse)

    #trait
    xt = which(stringr::str_detect(cn, "trait\\."))
    xy = observationVariables_data[i, xt]
    if (all(xy == "" | is.na(xy)) | is.null(xy)) xy = jsonlite::fromJSON("{}")
    if (any(xy != "" | !is.na(xy) | !is.null(xy))) {
      colnames(xy) = stringr::str_replace(colnames(xy), "trait\\.", "")
      xy = as.list(xy)

    }
    names(out[[i]])[15] = "trait"
    out[[i]]$trait = xy
    out[[i]][16:(max(xt) - 2)] = NULL

    out[[i]]$trait$synonyms <- lst2arr(out[[i]]$trait$synonyms)
    out[[i]]$trait$alternativeAbbreviations <- lst2arr(out[[i]]$trait$alternativeAbbreviations)


    #method
    xt = which(stringr::str_detect(cn, "method\\."))
    xy = observationVariables_data[i, xt]
    if (all(xy == "" | is.na(xy)) | is.null(xy)) xy = jsonlite::fromJSON("{}")
    if (any(xy != "" | !is.na(xy) | !is.null(xy))) {
      colnames(xy) = stringr::str_replace(colnames(xy), "method\\.", "")
      xy = as.list(xy)
    }
    names(out[[i]])[16] = "method"
    out[[i]]$method = xy
    out[[i]][17:(max(xt) - 2)] = NULL

    #scale
    xt = which(stringr::str_detect(cn, "scale\\."))
    xy = observationVariables_data[i, xt]
    if (all(xy == "" | is.na(xy)) | is.null(xy)) xy = jsonlite::fromJSON("{}")
    if (any(xy != "" | !is.na(xy) | !is.null(xy))) {
      colnames(xy) = stringr::str_replace(colnames(xy), "scale\\.", "")
      xy = as.list(xy)
    }
    out[[i]]$scale = xy
    out[[i]]$scale[6:8] = NULL

    #scale valid values
    xt = which(stringr::str_detect(cn, "scale\\.validValues\\."))
    xy = observationVariables_data[i, xt]
    if (all(xy == "" | is.na(xy)) | is.null(xy)) xy = jsonlite::fromJSON("{}")
    if (any(xy != "" | !is.na(xy) | !is.null(xy))) {
      colnames(xy) = stringr::str_replace(colnames(xy), "scale\\.validValues\\.", "")
      xy = as.list(xy)
    }
    if(jsonlite::toJSON(out[[i]]$scale) != "{}")  out[[i]]$scale$validValues = xy

    #scale valid values categories
    if(jsonlite::toJSON(out[[i]]$scale) != "{}")  out[[i]]$scale$validValues$categories = lst2arr(xy$categories, "; ")
    out[[i]]$defaultValue = observationVariables_data[i, "defaultValue" ]
  }

  attr(out, "status") = list()
  attr(out, "pagination") = pg$pagination

  out
}


observationVariables = list(
  metadata = list(
    pagination = list(
      pageSize = 0,
      currentPage = 0,
      totalCount = 0,
      totalPages = 0
    ),
    status = list(),
    datafiles = list()
  ),
  result =  list()
)



process_observationVariables <- function(req, res, err){
  #message("Hi")
  prms <- names(req$params)
  #message(str(req$params$observationVariableDbIds))


  page <- ifelse('page' %in% prms, as.integer(req$params$page), 0)
  pageSize <- ifelse('pageSize' %in% prms, as.integer(req$params$pageSize), 10000)
  observationVariableDbId <- ifelse('observationVariableDbIds' %in% prms,
                                    req$params$observationVariableDbIds %>% paste(collapse = ";"), "any")
  ontologyXref <- ifelse('ontologyXrefs' %in% prms,
                         req$params$ontologyXrefs %>% paste(collapse = ";"), "any")
  ontologyDbId <- ifelse('ontologyDbIds' %in% prms,
                         req$params$ontologyDbIds %>% paste(collapse = ";"), "any")
  methodDbId <- ifelse('methodDbIds' %in% prms,
                       req$params$methodDbIds %>% paste(collapse = ";"), "any")
  scaleDbId <- ifelse('scaleDbIds' %in% prms,
                      req$params$scaleDbIds %>% paste(collapse = ";"), "any")
  name <- ifelse('names' %in% prms,
                 req$params$names %>% paste(collapse = ";"), "any")
  scale.datatype <- ifelse('datatypes' %in% prms,
                           req$params$datatypes %>% paste(collapse = ";"), "any")
  trait.class <- ifelse('traitClasses' %in% prms,
                        req$params$traitClasses %>% paste(collapse = ";"), "any")

  observationVariableDbId <- safe_split(observationVariableDbId)
  ontologyXref <- safe_split(ontologyXref)
  ontologyDbId <- safe_split(ontologyDbId)
  methodDbId <- safe_split(methodDbId)
  scaleDbId <- safe_split(scaleDbId)
  name <- safe_split(name)
  scale.datatype <- safe_split(scale.datatype)
  trait.class <- safe_split(trait.class)


  observationVariables$result$data = observationVariables_list(
    page, pageSize, observationVariableDbId, ontologyXref, ontologyDbId, methodDbId, scaleDbId,
    name, scale.datatype, trait.class)

  observationVariables$metadata$pagination = attr(observationVariables$result$data, "pagination")

  if (is.null(observationVariables$result$data)) {
    res$set_status(404)
    observationVariables$metadata <-
      brapi_status(100, "No matching results!"
                   , observationVariables$metadata$status)
    observationVariables$result = list()
  }

  res$set_header("Access-Control-Allow-Methods", "POST")
  res$json(observationVariables)
}


mw_observationVariables <<-
  collector() %>%
  get("/brapi/v1/variables-search[/]?", function(req, res, err){
    res$set_status(405)
  })  %>%
  put("/brapi/v1/variables-search[/]?", function(req, res, err){
    res$set_status(405)
  }) %>%
  post("/brapi/v1/variables-search[/]?", function(req, res, err){
    process_observationVariables(req, res, err)
  }) %>%
  delete("/brapi/v1/variables-search[/]?", function(req, res, err){
    res$set_status(405)
  })

