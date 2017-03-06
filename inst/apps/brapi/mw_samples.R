
read_samples <- function(sampleId) {
  fp = system.file(
    paste0("apps/brapi/data/samples.csv"),
    package = "brapiTS")

  tryCatch({
    dat <- readr::read_csv(fp)
    dat <- dat[dat$sampleId == sampleId, ]
    return(dat)
   }, error = function(e) {
    NULL
  }
  )
}

process_samples <- function(req, res, err) {
  sampleId <- basename(stringr::str_replace(req$path, "v1/samples/", ""))
  message(sampleId)
  dat <- read_samples(sampleId)
  message(nrow(dat))

  if (nrow(dat) == 0) return(res$set_status(400))

  dat <- dat %>% as.data.frame() %>% as.list

  out <- list(
    metadata = list(
      pagination = list(
        pageSize = 0,
        currentPage = 0,
        totalCount = 0,
        totalPages = 0
      ),
      status = list(),
      datafiles = jsonlite::fromJSON("[]")
    ),
    result = dat
  )

  res$json(out)
  res$set_status(200)
  return(res)
}


process_samples_save <- function(req, res, err) {
  prms <- names(req$params)

  set_err_msg <- function(res, msg) {
    res$set_status(400)
    res$json(list(message = msg))
    return(res)
  }

  if (!('plotId' %in% prms)) return(set_err_msg(res, "Missing: plotId"))
  if (!('plantId' %in% prms)) return(set_err_msg(res, "Missing: plantId"))
  if (!('takenBy' %in% prms)) return(set_err_msg(res, "Missing: takenBy"))
  if (!('sampleDate' %in% prms)) return(set_err_msg(res, "Missing: sampleDate"))
  if (!('sampleType' %in% prms)) return(set_err_msg(res, "Missing: sampleType"))
  if (!('tissueType' %in% prms)) return(set_err_msg(res, "Missing: tissueType"))
  if (!('notes' %in% prms)) return(set_err_msg(res, "Missing: notes"))

  status <- list(
    metadata = NULL
    ,
    result = list(sampleId = "Unique-Plant-SampleId-1234567890")
  )
  res$json(status)


  return(res$set_status(200))
}



mw_samples <<-
  collector() %>%
  get("/brapi/v1/samples/[0-9a-zA-Z-_]{1,50}[/]?", function(req, res, err){
    process_samples(req, res, err)
  })  %>%
  put("/brapi/v1/samples[/]?", function(req, res, err){
    process_samples_save(req, res, err)
  }) %>%
  post("/brapi/v1/samples[/]?", function(req, res, err){
    res$set_status(405)
  }) %>%
  delete("/brapi/v1/samples[/]?", function(req, res, err){
    res$set_status(405)
  })
