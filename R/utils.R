clean_raster <- function(r){

  r_crop <- raster::crop(r, raster::extent(r) * 0.76)
  ext <- raster::extent(r_crop)
  ext[3] <- ext[3] * 1.6
  ext[1] <- ext[1] * 2.1
  r_crop <- raster::crop(r_crop, ext)

  # agg_fac <- 40
  # r_agg <- raster::aggregate(r_crop, agg_fac)
  # r_agg <- raster::focal(r_agg, w = matrix(1/9, nrow = 3, ncol = 3))
  # r_agg <- raster::disaggregate(r_agg, agg_fac)
  #
  # r_agg <- as(r_agg, "SpatialGridDataFrame")
  # rgrass7::writeRAST(r_agg, "r_agg", flags = "overwrite")
  # rgrass7::execGRASS("r.grow", input = "r_agg", output = "r_grow",
  #                    radius = 45, flags = "overwrite")
  # r_grow <- raster::raster(rgrass7::readRAST("r_grow"))
  #
  # # > library(raster)
  # # > # example data
  # #   > x <- raster(system.file("external/test.grd", package="raster"))
  # # > e <- extent(x)
  # # > # coerce to a SpatialPolygons object
  # #   > p <- as(e, 'SpatialPolygons')
  # # > r <- x > -Inf
  # # > # or alternatively
  # #   > # r <- reclassify(x, cbind(-Inf, Inf, 1))
  # #   >
  # #   > # convert to polygons (you need to have package 'rgeos' installed for this to work)
  # #   > pp <- rasterToPolygons(r, dissolve=TRUE)
  # # Loading required namespace: rgeos
  # # >
  # #   > # look at the results
  # #   > plot(x)
  # # > plot(p, lwd=5, border='red', add=TRUE)
  # # > plot(pp, lwd=3, border='blue', add=TRUE
  # #        + )
  #
  # r <- r_grow > -Inf
  # r <- raster::aggregate(r_grow, 10)
  # pp <- rasterToPolygons(r, dissolve=TRUE)
  #
  # test <- rasterToPoints(r, fun = function(x){x > -Inf})
  # test2 <- chull(coordinates(test))
  # test2 <- c(test2, test2[1])
  # plot(r_grow)
  # test2 <- test[test2,]
  #
  #
  # c_hull <- SpatialLines(list(Lines(list(Line(test2[,1:2])), ID = "A")))
  #
  # res <- raster::mask(r_crop, c_hull, updatevalue = -Inf)
  #
  #
  # # clump_r <- raster::clump(r_grow)
  # #
  # # browser()
  #
  # # sp::plot(clump_r)
  # # sp::plot(r_crop)
  # # sp::plot(raster(r_agg))
  #
  # # test <- raster::rasterToPolygons(clump_r, fun = function(x){x>0}, dissolve = TRUE)
  #
  # # test <- raster::rasterToPoints(clump_r)
  #
  # # raster::writeRaster(clump_r, "clump_r.tif", "GTiff")
  # # system("gdal_polygonize.py clump_r.tif -f 'ESRI Shapefile' test.shp")
  # # test <- rgdal::readOGR(raster::raster("test.shp"))
  #
  # # res <- clump_r < raster::cellStats(clump_r, "sd") / sqrt(length(clump_r[])) * 2
  # # res <- raster::calc(res, fun = function(x){ x[x==0] <- NA; return(x)})
  res <- raster::trim(r_crop)

  # res <- raster::crop(r, res)



  res

}
