
seasons_data = tryCatch({
  read.csv(system.file("apps/brapi/data/seasons.csv", package = "brapiTS"),
           stringsAsFactors = FALSE)
}, error = function(e){
  NULL
}
)


seasons_list = function(year = 0, page = 0, pageSize = 1000){
  if(is.null(seasons_data)) return(NULL)
  if(year != 0) {
    seasons_data = seasons_data[seasons_data$year == year, ]
    if(nrow(seasons_data) == 0) return(NULL)
  }

  # paging here after filtering
  pg = paging(seasons_data, page, pageSize)
  seasons_data <- seasons_data[pg$recStart:pg$recEnd, ]
  n = nrow(seasons_data)

  out = list(n)
  for(i in 1:n){
    out[[i]] <- as.list(seasons_data[i, ])
  }
  attr(out, "pagination") = pg$pagination
  out
}


seasons = list(
  metadata = list(
    pagination = list(
      pageSize = 1000,
      currentPage = 0,
      totalCount = nrow(seasons_data),
      totalPages = 1
    ),
    status = list(),
    datafiles = list()
  ),
  result = list(data = seasons_list())
)


process_seasons <- function(req, res, err){
  prms <- names(req$params)
  page = ifelse('page' %in% prms, as.integer(req$params$page), 0)
  pageSize = ifelse('pageSize' %in% prms, as.integer(req$params$pageSize), 1000)
  year = ifelse(('year' %in% prms), as.integer(req$params$year), 0)

  seasons$result$data = seasons_list(year, page, pageSize)
  seasons$metadata$pagination = attr(seasons$result$data, "pagination")

  if(is.null(seasons$result$data)){
    res$set_status(404)
    seasons$metadata <- brapi_status(100, "No matching results!")
  }
  res$json(seasons)

}


mw_seasons <<-
  collector() %>%
  get("/brapi/v1/seasons[/]?", function(req, res, err){
    process_seasons(req, res, err)
  })  %>%
  put("/brapi/v1/seasons[/]?", function(req, res, err){
    res$set_status(405)
  }) %>%
  post("/brapi/v1/seasons[/]?", function(req, res, err){
    res$set_status(405)
  }) %>%
  delete("/brapi/v1/seasons[/]?", function(req, res, err){
    res$set_status(405)
  })
