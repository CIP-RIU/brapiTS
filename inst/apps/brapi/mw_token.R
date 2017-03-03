

process_token <- function(req, res, err) {
  prms <- names(req$params)

  if(!('grant_type' %in% prms)) return(res$set_status(401))
  if(!('username' %in% prms)) return(res$set_status(401))
  if(!('password' %in% prms)) return(res$set_status(401))

  if(req$params$password == "") return(res$set_status(401))
  if(req$params$username == "") return(res$set_status(403))


  out <- list(
    metadata = list(
      pagination = list(
        pageSize = 0,
        currentPage = 0,
        totalCount = 0,
        totalPages = 0
      ),
      status = jsonlite::fromJSON("[]"),
      datafiles = jsonlite::fromJSON("[]")
    ),
    userDisplayName = "John Smith",
    access_token = "R6gKDBRxM4HLj6eGi4u5HkQjYoIBTPfvtZzUD8TUzg4",
    expires_in = 3600
    )

  res$json(out)
}


process_token_delete <- function(req, res, err) {
  prms <- names(req$params)

  if(!('access_token' %in% prms)) return(res$set_status(401))
  if(req$params$access_token != "") {
    out <- list(
      metadata = list(
        pagination = list(
          pageSize = 0,
          currentPage = 0,
          totalCount = 0,
          totalPages = 0
        ),
        status = list(list(message = "User has been logged out successfully.")),
        datafiles = jsonlite::fromJSON("[]")
      ),
      result = jsonlite::fromJSON("{}")
    )

    res$set_status(201)
    res$json(out)
  }
}

mw_token <<-
  collector() %>%
  get("/brapi/v1/token[/]?", function(req, res, err){
    res$set_status(405)
  }) %>%
  put("/brapi/v1/token[/]?", function(req, res, err){
    res$set_status(405)
  }) %>%
  post("/brapi/v1/token[/]?", function(req, res, err){
    process_token(req, res, err)
  }) %>%
  delete("/brapi/v1/token[/]?", function(req, res, err){
    process_token_delete(req, res, err)
  })
