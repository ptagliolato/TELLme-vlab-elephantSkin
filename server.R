
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

#TODO: check for eventual issues with raster saved by gdaldem and then copied to fileoutput.
#     Could it affect a multi-user environment?

library(shiny)
options(shiny.maxRequestSize=1000*1024^2) 
shinyServer(function(input, output, session) {
  
  currentProcessedRaster<-reactive({
    if(input$doPlotMap!=0){
      isolate({
        disable("downloadData")
        withProgress(message = 'Computing map', value = 0.2,{
        
        req(input$file1)
        req(currentInputRaster())
        
        
        input_dem<-input$file1$datapath
        input_mode<-input$mode
        
        library(rgdal)
        library(gdalUtils)
        
        # check params depending on input_mode. Cf. https://www.gdal.org/gdaldem.html
        if(input_mode=="hillshade"){
          out <- gdalUtils::gdaldem(mode=input_mode,
                                    input_dem=input_dem, 
                                    output=paste("out_",input_mode,".tif", sep=""),
                                    output_Raster=TRUE,verbose=TRUE, z=input$z, az=input$az, alt=input$alt
          )
          #browser()
        }
        else{
          out <- gdalUtils::gdaldem(mode=input_mode,
                                    input_dem=input_dem, 
                                    output=paste("out_",input_mode,".tif", sep=""),
                                    output_Raster=TRUE,verbose=TRUE
          )
        }
        })#end progress
        return(out)
        
      })#end isolate
    }
  })
  
  
  currentInputRaster<-reactive({
    req(input$file1)
    library(raster)
    input_dem<-input$file1$datapath
    return(raster(input_dem))
  })
  
  observeEvent(currentInputRaster(),{enable("doPlotMap")})
  
  observeEvent(currentProcessedRaster(),{enable("downloadData")})
  
  
  output$mapInput<-renderPlot({
    # req(input$file1)
    # library(raster)
    # input_dem<-input$file1$datapath
    # plot(raster(input_dem),col=gray.colors(256))
    withProgress(message = 'Making plot...', value = 0.5,{
      plot(currentInputRaster(),col=gray.colors(256))
    })
  })
  
  output$mapImg<-renderPlot({
    if(input$doPlotMap!=0){
      isolate(
        withProgress(message = 'Making plot...', value = 0.5,{
          plot(currentProcessedRaster(),col=gray.colors(256))
        })
      )
    }
  })
  # TODO: anticipate rendering input map before processed output.
  # Consider reactive value/action button to process the image on user request.
  # output$mapImg <- renderPlot({
  #   
  #   #alg ZevenbergenThorne | Horn
  #   #z: vertical exaggeration
  #   #file
  #   #
  #   # generate bins based on input$bins from ui.R
  #   #x    <- faithful[, 2]
  #   #bins <- seq(min(x), max(x), length.out = input$bins + 1)
  #   
  #   # draw the histogram with the specified number of bins
  #   #hist(x, breaks = bins, col = 'darkgray', border = 'white')
  #   
  #   #......
  #   req(input$file1)
  #   
  #   input_dem<-input$file1$datapath
  #   input_mode<-input$mode
  #   
  #   if(FALSE){
  #     #code for hillshade
  #     tif_file = raster::raster(input_dem)
  #     
  #     withProgress(message = 'Making plot', value = 0,{
  #       #And convert it to a matrix:
  #       elmat = matrix(raster::extract(tif_file,raster::extent(tif_file),buffer=1000),
  #                      nrow=ncol(tif_file),ncol=nrow(tif_file))
  #       
  #       #We first texture the map with sphere_shade and one of rayshader's built in textures, "desert."
  #       #By default, the highlight is towards the NW.
  #       #rgbarray<-
  #       elmat %>%
  #         sphere_shade(texture = "desert") %>%
  #         plot_map()
  #     })
  #   }
  #   
  #   else{
  #     
  #     library(rgdal)
  #     library(gdalUtils)
  #     
  #     #gdalUtils::gdaldem("hillshade",)
  #     
  #     #plot(raster(input_dem),col=gray.colors(256))
  #     
  #     withProgress(message = 'Making plot', value = 0.5,{
  #       
  #       # check params depending on input_mode. Cf. https://www.gdal.org/gdaldem.html
  #       if(input_mode=="hillshade"){
  #         output_hillshade <- gdalUtils::gdaldem(mode=input_mode,
  #                                                input_dem=input_dem, 
  #                                                output=paste("output_",input_mode,".tif", sep=""),
  #                                                output_Raster=TRUE,verbose=TRUE, z=input$z, az=input$az, alt=input$alt
  #         )
  #       }
  #       else{
  #         output_hillshade <- gdalUtils::gdaldem(mode=input_mode,
  #                                                input_dem=input_dem, 
  #                                                output=paste("out_",input_mode,".tif", sep=""),
  #                                                output_Raster=TRUE,verbose=TRUE
  #         )
  #       }
  #       
  #       plot(output_hillshade,col=gray.colors(256))
  #     })#end progress
  #   }
  # })
  
  output$downloadData<-downloadHandler(filename=paste("output_",input$mode,".tif", sep=""), 
                                       content=function(file){
                                         #writeRaster(currentProcessedRaster(),file)
                                         browser()
                                         file.copy(paste("out_",input$mode,".tif", sep=""), file)
                                       }
  )
})
