#' contour_read
#' @description Read a pdf into a lines object
#' @param pdf_path file.path to input pdf
#' @param smallest_length numeric threshold defining the smallest line-length to be returned
#' @param grow_radius numeric value defining how much to "grow" lines prior to thinning
#' @param clean_thresh numeric threshold defining the smallest allowable "dangle"
#' @export
#' @importFrom raster brick raster
#' @importFrom sp SpatialLinesLengths
#' @importFrom magick image_read
#' @importFrom rgrass7 execGRASS readVECT writeRAST
#' @importFrom raster calc brick raster
#' @importFrom methods as
#' @examples \dontrun{
#' pdf <- system.file("extdata/1835300a.pdf", package = "contour2bathy")
#' res <- contour_read(pdf_path = pdf)
#' par(mfrow = c(1,1))
#' sp::plot(res)
#'
#' }
contour_read <- function(pdf_path, smallest_length = 0.00001, grow_radius = 2,
                         clean_thresh = 0.08){
  options(warn = -1)

  pdf_image    <- magick::image_read(pdf_path)
                                                                                 raster_int   <- as.integer(pdf_image[[1]])
  raster_image <- raster::brick(raster_int)
  raster_image <- raster::raster(raster_image, layer = 1)

  raster_image <- raster::calc(raster_image,
                               fun = function(x){ x[x>0] <- NA; return(x)})
  raster_image <- raster::calc(raster_image,
                               fun = function(x){ x[x==0] <- 1; return(x)})
  raster_image <- raster::calc(raster_image,
                               fun = function(x){ x[x!=1] <- 0; return(x)})

  raster_full <- raster_image
  raster_image <- clean_raster(raster_image)

  ####

  loc <- rgrass7::initGRASS("/usr/lib/grass72", home = tempdir(),
                            override = TRUE)
  # rgrass7::gmeta(ignore.stderr = TRUE)
  # set.ignore.stderrOption(TRUE)

  storage.mode(raster_image[]) <- "integer"

  rgrass7::writeRAST(as(raster_image, "SpatialGridDataFrame"), "raster_image",
                     flags = c("overwrite"))
  rgrass7::execGRASS("g.region", raster = "raster_image")
  # rgrass7::execGRASS("r.info", map = "raster_image")

  rgrass7::execGRASS("r.grow", input = "raster_image", output = "r_grow",
                     radius = grow_radius, flags = "overwrite")
  # rgrass7::execGRASS("r.info", map = "r_grow")
  rgrass7::execGRASS("r.mapcalc", expression = "r_grow_int = int(r_grow)")

  rgrass7::execGRASS("r.thin", input = "r_grow_int", output = "r_thin",
                     flags = c("overwrite"))
  rgrass7::execGRASS("r.to.vect", input = "r_thin", output = "r_vect",
                     type = "line", flags = c("s", "overwrite"))


  rgrass7::execGRASS("v.clean", parameters = list(input = "r_vect",
                     output = "r_vect_clean", tool = "rmdangle",
                     threshold = clean_thresh), flags = "overwrite")

  rgrass7::execGRASS("v.build.polylines", input = "r_vect_clean",
                     output = "r_vect_poly", flags = "overwrite")
  # rgrass7::execGRASS("v.info", map =  "r_vect_poly_cat")
  rgrass7::execGRASS("v.category", input = "r_vect_poly",
                     output = "r_vect_poly_cat", type = "line", option = "add")
  rgrass7::execGRASS("v.db.addtable", map  = "r_vect_poly_cat",
                     columns="length_km DOUBLE PRECISION")

  # rgrass7::execGRASS("v.to.db", map = "r_vect_poly_cat", type = "line", option = "length", units = "k", columns = "length_km")
  # rgrass7::execGRASS("v.extract", input = "r_vect_poly_cat", output = "r_vect_long", type = "line", where = "length_km > 0.02", flags = "overwrite")
  #
  res <- rgrass7::readVECT("r_vect_poly_cat")
  # res <- rgrass7::readVECT("r_vect_long")
  # sp::plot(res)

  res <- res[which(sp::SpatialLinesLengths(res) > smallest_length),]

  options(warn = 0)

  list(lines = res, raster = raster_full)
}
