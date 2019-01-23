
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
options(shiny.maxRequestSize=1000*1024^2) 
shinyServer(function(input, output) {
  
  output$mapInput<-renderPlot({
    req(input$file1)
    library(raster)
    input_dem<-input$file1$datapath
    plot(raster(input_dem),col=gray.colors(256))
  })
  
  output$mapImg <- renderPlot({
    
    #alg ZevenbergenThorne | Horn
    #z: vertical exaggeration
    #file
    #
    # generate bins based on input$bins from ui.R
    #x    <- faithful[, 2]
    #bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    #hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
    #......
    req(input$file1)
    
    input_dem<-input$file1$datapath
    input_mode<-input$mode
    
    if(FALSE){
    #code for hillshade
    tif_file = raster::raster(input_dem)
    
    withProgress(message = 'Making plot', value = 0,{
      #And convert it to a matrix:
      elmat = matrix(raster::extract(tif_file,raster::extent(tif_file),buffer=1000),
                     nrow=ncol(tif_file),ncol=nrow(tif_file))
      
      #We first texture the map with sphere_shade and one of rayshader's built in textures, "desert."
      #By default, the highlight is towards the NW.
      #rgbarray<-
      elmat %>%
        sphere_shade(texture = "desert") %>%
        plot_map()
    })
    }
    
    else{
      library(rgdal)
      library(gdalUtils)
      
      #gdalUtils::gdaldem("hillshade",)
      
      #plot(raster(input_dem),col=gray.colors(256))
      output_hillshade <- gdalUtils::gdaldem(mode=input_mode,
                                             input_dem=input_dem, 
                                             output=paste("output_",input_mode,".tif", sep=""),
                                             output_Raster=TRUE,verbose=TRUE, z=input$z, az=input$az, alt=input$alt
                                             )
      
      plot(output_hillshade,col=gray.colors(256))
    }
  })
  
})
