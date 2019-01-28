
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

#TODO: check for eventual issues with raster saved by gdaldem and then copied to fileoutput.
#     Could it affect a multi-user environment?

library(shiny)
library(raster)
library(rgdal)
library(gdalUtils)

colors4slope<-c("black","#ffb701","white")
palette4slope<-colorRampPalette(colors4slope,bias=1,interpolate="spline")

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
        
        temptiff <- tempfile(fileext = ".tif")
        #browser()
        # check params depending on input_mode. Cf. https://www.gdal.org/gdaldem.html
        if(input_mode=="hillshade"){
          out <- gdalUtils::gdaldem(mode=input_mode,
                                    input_dem=input_dem, 
                                    output=temptiff,
                                    output_Raster=TRUE,verbose=TRUE, z=input$z, az=input$az, alt=input$alt
          )
        }
        else if(input_mode=="slope"){
          out <- gdalUtils::gdaldem(mode=input_mode,
                                    input_dem=input_dem, 
                                    output=temptiff,
                                    output_Raster=TRUE,verbose=TRUE, b=1, s=111120,compute_edges = TRUE
          )
          
        }
        else{
          out <- gdalUtils::gdaldem(mode=input_mode,
                                  input_dem=input_dem, 
                                    output=temptiff,
                                    output_Raster=TRUE,verbose=TRUE
          )
          
        }
        })#end progress
        
        #browser()
        return(out)
        
      })#end isolate
    }
  })
  
  
  currentInputRaster<-reactive({
    req(input$file1)
    
    input_dem<-input$file1$datapath
    return(raster(input_dem))
  })
  
  observeEvent(currentInputRaster(),{enable("doPlotMap")})
  
  observeEvent(currentProcessedRaster(),{enable("downloadData")})
  
  #observe({output$path<-renderUI(textInput("MYPATH", "path", value = req(input$file1$datapath)))})
  
  # plot input raster
  output$mapInput<-renderPlot({
    withProgress(message = 'Making plot...', value = 0.5,{
        plot(currentInputRaster(),col=gray.colors(256))
    })
  })
  
  #on button click process input raster and plot it
  observeEvent(input$doPlotMap, ignoreInit = TRUE, {
    
    r <- currentProcessedRaster()
    output$mapImg<-renderPlot(
      withProgress(message = 'Making plot...', value = 0.5,{
        if(isolate(input$mode=="hillshade"))
          plot(r,col=gray.colors(256))
        else if(isolate(input$mode=="slope"))
          plot(r,col=palette4slope(256))
        else
          plot(r,col=gray.colors(256))
      })
    )
  })

  output$downloadData<-downloadHandler(
    filename=paste("output_",input$mode,".tif", sep=""), 
    content=function(file){
      writeRaster(currentProcessedRaster(),file, datatype = "INT1U", options=c("COMPRESSION=DEFLATE"))
    }
  )
})
