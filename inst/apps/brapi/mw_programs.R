
programs_data = tryCatch({
  read.csv(system.file("apps/brapi/data/programs.csv", package = "brapiTS"), stringsAsFactors = FALSE)
}, error = function(e){
  NULL
}
)

programs_list = function(abbr = "any", prg = "any", page=0, pageSize = 100,
                         programDbId = "any",
                         objective = "any",
                         leadPerson = "any"){
  if (is.null(programs_data)) return(NULL)
  if (abbr != "any") {
    programs_data = programs_data[programs_data$abbreviation == abbr, ]
    if(nrow(programs_data) == 0) return(NULL)
  }

  if (programDbId != "any") {
    programs_data = programs_data[programs_data$programDbId == programDbId, ]
    if(nrow(programs_data) == 0) return(NULL)
  }

  if (leadPerson != "any") {
    programs_data = programs_data[programs_data$leadPerson == leadPerson, ]
    if(nrow(programs_data) == 0) return(NULL)
  }

  if (objective != "any") {
    programs_data = programs_data[programs_data$objective == objective, ]
    if(nrow(programs_data) == 0) return(NULL)
  }

  if (prg != "any") {
    programs_data = programs_data[programs_data$name == prg, ]
    if(nrow(programs_data) == 0) return(NULL)
  }
  # paging here after filtering
  pg = paging(programs_data, page, pageSize)
  programs_data <- programs_data[pg$recStart:pg$recEnd, ]

  n = nrow(programs_data)
  out = list(n)
  for(i in 1:n){
    out[[i]] <- as.list(programs_data[i, ])
  }
  attr(out, "pagination") = pg$pagination
  out
}


programs = list(
  metadata = list(
    pagination = list(
      pageSize = 100,
      currentPage = 0,
      totalCount = nrow(programs_data),
      totalPages = 1
    ),
    status = list(),
    datafiles = list()
  ),
  result = list(data = programs_list())
)


process_programs <- function(req, res, err){
  prms <- names(req$params)
  page = ifelse('page' %in% prms, as.integer(req$params$page), 0)
  pageSize = ifelse('pageSize' %in% prms, as.integer(req$params$pageSize), 100)
  abbreviation = ifelse('abbreviation' %in% prms, req$params$abbreviation, "any")
  programName = ifelse('programName' %in% prms, req$params$programName, "any")
  pname = ifelse('name' %in% prms, req$params$name, "any")
  programName = ifelse(programName == "any", pname, programName)

  programDbId = ifelse('programDbId' %in% prms, req$params$programDbId, "any")
  objective = ifelse('objective' %in% prms, req$params$objective, "any")
  leadPerson = ifelse('leadPerson' %in% prms, req$params$leadPerson, "any")

  programs$result$data = programs_list(abbreviation, programName, page, pageSize,
                                       programDbId = programDbId,
                                       objective = objective,
                                       leadPerson = leadPerson)
  programs$metadata$pagination = attr(programs$result$data, "pagination")

  if(is.null(programs$result$data)){
    res$set_status(404)
    programs$metadata <- brapi_status(100, "No matching results!")
  }
  res$set_header("Access-Control-Allow-Methods", "GET")
  res$json(programs)

}

mw_programs <<-
  collector() %>%
  get("/brapi/v1/programs[/]?", function(req, res, err){
    process_programs(req, res, err)
  }) %>%
  put("/brapi/v1/programs[/]?", function(req, res, err){
    res$set_status(405)
  }) %>%
  post("/brapi/v1/programs-search[/]?", function(req, res, err){
    process_programs(req, res, err)
  }) %>%
  delete("/brapi/v1/programs[/]?", function(req, res, err){
    res$set_status(405)
  })
