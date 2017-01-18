#' contour_read
#' @description Read a pdf into a lines object
#' @param pdf_path file.path to input pdf
#' @export
#' @importFrom raster brick raster
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
contour_read <- function(pdf_path){
  options(warn = -1)

  pdf_image     <- magick::image_read(pdf_path)
                                                                                                   raster_int <- as.integer(pdf_image[[1]])
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

  loc <- rgrass7::initGRASS("/usr/lib/grass70", home = tempdir(), override = TRUE)
  # rgrass7::gmeta(ignore.stderr = TRUE)
  # set.ignore.stderrOption(TRUE)

  storage.mode(raster_image[]) <- "integer"

  rgrass7::writeRAST(as(raster_image, "SpatialGridDataFrame"), "raster_image", flags = c("overwrite"))
  rgrass7::execGRASS("g.region", raster = "raster_image")
  # rgrass7::execGRASS("r.info", map = "raster_image")

  rgrass7::execGRASS("r.grow", input = "raster_image", output = "r_grow", radius = 2, flags = "overwrite")
  # rgrass7::execGRASS("r.info", map = "r_grow")
  rgrass7::execGRASS("r.mapcalc", expression = "r_grow_int = int(r_grow)")

  rgrass7::execGRASS("r.thin", input = "r_grow_int", output = "r_thin", flags = c("overwrite"))
  rgrass7::execGRASS("r.to.vect", input = "r_thin", output = "r_vect", type = "line", flags = c("s", "overwrite"))


  rgrass7::execGRASS("v.clean", parameters = list(input = "r_vect", output = "r_vect_clean", tool = "rmdangle", threshold = 0.08), flags = "overwrite")

  res <- rgrass7::readVECT("r_vect_clean")
  # sp::plot(res)

  options(warn = 0)

  list(lines = res, raster = raster_full)
}
