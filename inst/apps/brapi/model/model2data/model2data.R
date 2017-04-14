# convert model tables to data tables


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
file.copy("../locations_additionalInfo.csv", "../../data/lcoations_additionalInfo.csv",
          overwrite = TRUE)

#maps
file.copy("../maps.csv", "../../data/maps.csv",
          overwrite = TRUE)


# map_positions
## markerName <- markers
mappos <- readr::read_csv("../maps_positions.csv")
mrknms <- readr::read_csv("../markers.csv")
mappos <- merge(mappos, mrknms, "markerDbId")
names(mappos)[5] <- "markerName"
mappos <- mappos[, c("mapDbId",	"markerDbId", "markerName",
                     "location",	"linkageGroupId"
)]
readr::write_csv(mappos, "../../data/maps_positions.csv")

# markerprofiles
## uniqueDisplayName = germplasmDbId <- germplasm-search,
## resultsCount = n markers in profile for germplasm <- markerprofiles_alleles

# markerprofiles_alleles
## marker = markerName = defaultDisplayName <- markers




