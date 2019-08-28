
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
library(elevatr)

#colors4slope<-c("black","#ffb701","white")
colors4slope<-c("#836e05", "#b79c17","#f1e9bc", "white")
palette4slope<-colorRampPalette(colors4slope,bias=1,interpolate="spline")
plotInBbxSelector<-function(raster2plot,proxy){
  #proxy<-bbxSelector1$proxymap()
  #raster2plot<- raster::resample(currentInputRaster(),fact=4,expand=FALSE)
  #rasterResampled<-
  proxy%>%
    clearShapes()%>%
    clearImages()%>%
    addRasterImage(raster2plot, opacity=0.7, group="inputDEM")  %>%
    addLayersControl(baseGroups=c("OpenStreeMap","CartoDB"),
                     overlayGroups="inputDEM")
}
options(shiny.maxRequestSize=1000*1024^2) 

shinyServer(function(input, output, session) {
  #hack
  
  #browser()
  lf<-leaflet()%>%addTiles() 
  
  
  # TODO: gdal needs to read from file! Must adjust for API raster
  currentProcessedRaster<-reactive({
    if(input$doPlotMap!=0){
      isolate({
        disable("downloadData")
        withProgress(message = 'Computing map', value = 0.2,{
        
        #req(input$file1)
        #req(currentInputRaster())
        req(dem$dem)
        datapath<-tempfile(fileext=".tif")
        
        if(dem$source=='user'){
          cat("from user")
          input_dem<-input$file1$datapath
        }
        else{
          cat("write raster file (source is not from user)")
          raster::writeRaster(dem$dem,filename = datapath, format="GTiff")
          input_dem<-datapath
        }
        # TODO: gdal needs to read from file!
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
  
  dem<-reactiveValues()
  
  
  bbxSelector1<-callModule(bbxSelector, "bbxSelectorId", reactive({input$file1}))
  
  zoomlevel<-reactive({
    input$zlevel
  })
  
  # enable when bbx actually selected
  observeEvent(bbxSelector1$bbx(),{enable("getRasterFromAPI")})
  
  observeEvent(input$getRasterFromAPI, ignoreInit = TRUE, {
    progress <- shiny::Progress$new()
    # Make sure it closes when we exit this reactive, even if there's an error
    on.exit(progress$close())
    progress$set(message = "Downloading data from remote server...", value = 0)
    #cat(input$bbxSelectorId)
    tryCatch(
      {
        dem$dem <-elevatr::get_elev_raster(bbxSelector1$bbx_df(), prj=bbxSelector1$crs_string(),z=zoomlevel(), clip = "bbox")
        dem$source <- "http://s3.amazonas.com/"
        plotInBbxSelector(dem$dem,bbxSelector1$proxymap())
        # proxy<-bbxSelector1$proxymap()
        # proxy%>%
        #   clearShapes()%>%
        #   clearImages()%>%
        #   addRasterImage(dem$dem, opacity=0.7, group="inputDEM")  %>%
        #   addLayersControl(baseGroups=c("OpenStreeMap","CartoDB"),
        #                    overlayGroups="inputDEM")
      },
      error=function(e){
        cat(paste(e))
      },
      finally={}
    )
    
    
    
    # observe({
    #   proxy<-bbxSelector1$proxymap()
    #   raster2plot<- raster::resample(currentInputRaster(),fact=4,expand=FALSE)
    #   #rasterResampled<-
    #   proxy%>%
    #     clearShapes()%>%
    #     clearImages()%>%
    #     addRasterImage(raster2plot, opacity=0.7, group="inputDEM")  %>%
    #     addLayersControl(baseGroups=c("OpenStreeMap","CartoDB"),
    #                      overlayGroups="inputDEM")
    # })
    
    
    #getRasterFromAPI()
    # bbox <- c(xmin = 8.49941, 
    #           ymin = 44.68090,
    #           xmax = 11.42868,
    #           ymax = 46.63806)
    # sf_bbox <- st_bbox(bbox, crs = 4326) %>% 
    #   sf::st_as_sfc() %>% 
    #   sf::st_sf()
    
    # path<-tempdir()
    # dem$dem <- raster::getData('alt', country=input$country, path=path, mask=TRUE)
    # dem$source <- "http://srtm.csi.cgiar.org/"
  })
  
  observeEvent(input$file1, ignoreInit = TRUE, {
    input_dem<-input$file1$datapath
    cat(input$file1$datapath)
    dem$dem <- raster::raster(input_dem)
    dem$source <- "user"
  })
  
  currentInputIsFileFromUser<-reactive({
    req(dem$source=="user")
    cat(dem$source)
    return(dem$source=="user")
  })
  
  currentInputRaster<-reactive({
    req(dem$dem)
    return(dem$dem)
  })
  
  # currentInputRaster<-reactive({
  #   req(input$file1)
  # 
  #   input_dem<-input$file1$datapath
  #   return(raster(input_dem))
  # })
  
  observeEvent(currentInputRaster(),{
    enable("doPlotMap")
    #output$mapleaflet<-renderLeaflet(mapview::addExtent(lf,currentInputRaster()))
  })
  
  observeEvent(currentProcessedRaster(),{enable("downloadData")})
  
  #observe({output$path<-renderUI(textInput("MYPATH", "path", value = req(input$file1$datapath)))})
  
  # plot input raster
  output$mapInput<-renderPlot({
    
    
    withProgress(message = 'Making plot...', value = 0.5,{
        plot(currentInputRaster(),col=gray.colors(256))
    })
    
  })
  
  #output$mapleaflet<-renderLeaflet(lf)
  #+mapview::mapview()@map)
  
  # # hack to only draw leaflet once
  # output$mapleaflet <- renderLeaflet({
  #   #browser()
  #   if(req(not_rendered,cancelOutput=TRUE)) {
  #     not_rendered <- FALSE
  #     lf
  #   }
  # })
  
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
    
    #browser()  
    output$mapleaflet<-renderLeaflet({
      if(isolate(input$mode=="slope")) paletta=palette4slope
      else paletta=gray.colors(256)#mapviewGetOption("raster.palette")(256)
      #l <- mapview::mapview(r[[1]])@map
      l <- mapview(r[[1]],
                   col.regions        = paletta
           )@map
      l
    #  newprog<-CRS("+init=epsg:3857")
    #  rr<-projectRaster(r,crs=newprog)
      #leaflet() %>% addTiles() %>% setView(0, 0, 2) %>% leaflet::addRasterImage(projectRasterForLeaflet(raster(r),method = "bilinear"))
      
      
      # %>% leaflet::addRasterImage(projectRasterForLeaflet(rr,method = "bilinear"))
      # l <- l  %>%  pippo
    })
    
  })

  output$downloadData<-downloadHandler(
    filename=paste("output_",input$mode,".tif", sep=""), 
    content=function(file){
      writeRaster(currentProcessedRaster(),file, datatype = "INT1U", options=c("COMPRESSION=DEFLATE"))
    }
  )
})
