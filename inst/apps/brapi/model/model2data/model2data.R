# convert model tables to data tables

unlink("../../data", recursive = TRUE)
dir.create("../../data")

# attributes
attcat <- readr::read_csv("../attributes_categories.csv")
attdet <- readr::read_csv("../attributes.csv")

att <- merge(attdet, attcat, by = "attributeCategoryDbId")
names(att)[9] <- 'attributeCategoryName'
names(att)[5] <- 'name'

att <- att[, c("attributeDbId", "code", "uri", "name", "description", "attributeCategoryDbId",
               "attributeCategoryName", "datatype", "values")]

att <- dplyr::arrange(att, attributeDbId)
readr::write_csv(att, "../../data/attributes.csv")

# attributes_categories
file.copy("../attributes_categories.csv", "../../data/attributes_categories.csv", overwrite = TRUE)

# calls
file.copy("../calls.csv", "../../data/calls.csv", overwrite = TRUE)

# contacts
file.copy("../contacts.csv", "../../data/contacts.csv", overwrite = TRUE)

# crops
file.copy("../crops.csv", "../../data/crops.csv", overwrite = TRUE)

# germplasm_attributes
gplatt <- readr::read_csv("../germplasm_attributes.csv")
gplatt <- merge(gplatt, att)
gplatt <- gplatt[, c("germplasmDbId", "attributeDbId", "name", "code", "value", "dateDetermined")]
names(gplatt)[3:4] <- c("attributeName", "attributeCode")
gplatt <- dplyr::arrange(gplatt, germplasmDbId, attributeDbId)
readr::write_csv(gplatt, "../../data/germplasm_attributes.csv")

# germplasm_donors
gpldon <- readr::read_csv("../germplasm_donors.csv")
gpldon <- gpldon[, -c(2)]
readr::write_csv(gpldon, "../../data/germplasm_donors.csv")

# germplasm_markerprofiles
file.copy("../germplasm_markerprofiles.csv", "../../data/germplasm_markerprofiles.csv",
          overwrite = TRUE)

# germplasm_search
gplsch <- readr::read_csv("../germplasm-search.csv")
gpldon <- readr::read_csv("../germplasm_donors.csv")

gplsch <- merge(gplsch, gpldon, "germplasmDbId")
gplsch <- gplsch[, c("germplasmDbId",	"defaultDisplayName",	"accessionNumber",	"germplasmName",
                     "germplasmPUI.x",	"pedigree",	"seedSource",	"synonyms",	"commonCropName",
                     "instituteCode",	"instituteName",	"biologicalStatusOfAccessionCode",
                     "countryOfOriginCode",
                     "typeOfGermplasmStorageCode",	"genus",	"species",	"speciesAuthority",
                     "subtaxa",	"subtaxaAuthority",	"donors",	"acquisitionDate"
)]
names(gplsch)[5] <- "germplasmPUI"
readr::write_csv(gplsch, "../../data/germplasm-search.csv")

#location
file.copy("../locations.csv", "../../data/locations.csv",
          overwrite = TRUE)
file.copy("../locations_additionalInfo.csv", "../../data/locations_additionalInfo.csv",
          overwrite = TRUE)

#maps
mappos <- readr::read_csv("../maps_positions.csv")
mapnms <- readr::read_csv("../maps.csv")

n_maps <- max(unique(mappos$mapDbId))
for(i in 1:n_maps) {
  fil <- mappos[mappos$mapDbId == i, ]
  mapnms[i, "markerCount"] <- nrow(fil)
  mapnms[i, "linkageGroupCount"] <- length(unique(fil$linkageGroupId))
}
readr::write_csv(mapnms, "../../data/maps.csv") 

# maps_positions
mrks <- readr::read_csv("../markers.csv")
mpps <- merge(mappos, mrks, "markerDbId")
mpps <- mpps[, c("mapDbId", "markerDbId", "defaultDisplayName", "location", "linkageGroupId")]
names(mpps)[3] <- "markerName"
readr::write_csv(mpps, "../../data/maps_positions.csv") 

# markers
file.copy("../markers.csv", "../../data/markers.csv",
          overwrite = TRUE)

# markerprofiles
# file.copy("../markerprofiles.csv", "../../data/markerprofiles.csv",
#           overwrite = TRUE)
mrkprf <- readr::read_csv("../markerprofiles.csv")
germpl <- readr::read_csv("../germplasm-search.csv")
mrkcnt <- readr::read_csv("../markerprofiles_alleles.csv")
mrkprf <- merge(mrkprf, germpl, "germplasmDbId")
mrkprf <- mrkprf[, c("germplasmDbId", "markerProfilesDbId", "germplasmName",
                     "sampleDbId", "extractDbId", "studyDbId",
                     "analysisMethod", "pedigree")]
names(mrkprf)[2] <- "markerProfileDbId"
names(mrkprf)[3] <- "uniqueDisplayName"
names(mrkprf)[8] <- "resultCount"
mpf <- unique(mrkprf$markerProfileDbId)
n_prf <- length(mpf)
for(i in 1:n_prf) {
  fil <- mrkcnt[mrkcnt$markerprofilesDbId == mpf[i], ]
  mrkprf[i, "resultCount"] <- nrow(fil)
}
readr::write_csv(mrkprf, "../../data/markerprofiles.csv") 

# germplasm_markerprofiles is subset of markerprofiles table
# server has been adjusted: one table less in the model

# markerprofiles table should get results count from detailed data in 
# markerprofiles_alleles (in mw_?)

mrks <- readr::read_csv("../markers.csv")
mrks_data <- readr::read_csv("../markerprofiles_alleles.csv")
mrks_data <- merge(mrks_data, mrks, "markerDbId")
mrks_data <- mrks_data[, c("markerprofilesDbId", "markerDbId", 
                           "defaultDisplayName", "alleleCall")]
names(mrks_data)[3] <- "marker"
readr::write_csv(mrks_data, "../../data/markerprofiles_alleles.csv") 

# programs, trials, studytypes ...



