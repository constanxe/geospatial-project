function(input, output, session) {
    
    zoomlevel = reactive({
        input$map_zoom
    })
    
    # look at current school selected
    curr_sch_id = reactive({
        which(jc@data$SCHOOL == input$jc, arr.ind=TRUE)
    })

    # read the rds file of the isochrone of the school selected
    iso = reactive({
        schName = jc@data$SCHOOL[[curr_sch_id()]]
        iso = readRDS(file=paste0(dp_j_prefix, schName,'.rds'))
        return(iso)
    })
    
    # read the rds file of the hansen of the school selected
    hansen = reactive({
      schName = jc@data$SCHOOL[[curr_sch_id()]]
      hansen = readRDS(file=paste0(dp_h_prefix, schName,'.rds'))
      return(hansen)
    })
    
    # read the rds file of the sam of the school selected
    sam = reactive({
      schName = jc@data$SCHOOL[[curr_sch_id()]]
      sam = readRDS(file=paste0(dp_s_prefix, schName,'.rds'))
      return(sam)
    })

    
    yessch = reactive({
      !is.null(input$display) && 'Show school points' %in% input$display
    })
    nosch = reactive({
      !('Show school points' %in% input$display)
    })
    
    yeshdb = reactive({
      !is.null(input$display) && 'Show HDB points' %in% input$display
    })
    nohdb = reactive({
      !('Show HDB points' %in% input$display)
    })
    
    
    output$jcTable <- renderDT(
      if(length(input$region)==0){
        jc@data %>% dplyr::select(-X, -Y)
      }else{
        jc@data %>% 
          dplyr::filter(REGION %in% toupper(input$region)) %>% 
          dplyr::select(-X, -Y)
      },
      options = list(lengthChange = FALSE)
    )
    
    output$row <- renderPrint({

    })

    
    # look at the input analysis and add the layer for the selected analysis
    observeEvent(input$analysis, {
        proxy <- leafletProxy("mapPlot")
        if (input$analysis=='Duration (Isochrone)'){
            schName = jc@data$SCHOOL[[curr_sch_id()]]
            proxy %>% addMapPane("isolayer", zIndex = 410) %>% setView(lng = 103.8198, lat = 1.3521, zoom = 11) %>%
                addPolygons(data =iso(), stroke = TRUE, weight=0.5,
                smoothFactor = 1, color="black", options = pathOptions(pane = "isolayer"),
                fillOpacity = 0.8, fillColor =c('cyan','gold','tomato','red'), group = 'isolayer' )
        }else{
            proxy %>% clearGroup('isolayer') 
        }
        
        if(input$analysis=='Distance (Hansen Accessibility)'){
          pal <- colorFactor(
            palette = 'Blues',
            domain = hansen()@data$distanceHansen
          )
          proxy %>% clearGroup('hansendistlayer') %>% addMapPane('hansendistlayer', zIndex = 412) %>%
            addCircles(lng = hansen()@coords[,1], lat = hansen()@coords[,2], radius = sqrt(hansen()@data$distanceHansen)*10, weight= 5, color = pal(hansen()@data$distanceHansen), 
                       stroke = TRUE, fillOpacity = 0.4, opacity = 0.8,
                       group = 'hansendistlayer', options = pathOptions(pane = "hansendistlayer")) 
        }else{
          proxy %>% clearGroup('hansendistlayer')
        }
        
        if(input$analysis=='Duration (Hansen Accessibility)'){
          pal <- colorFactor(
            palette = 'Purples',
            domain = hansen()@data$durationHansen
          )
          proxy %>% clearGroup('hansenduralayer') %>% addMapPane('hansenduralayer', zIndex = 412) %>%
            addCircles(lng = hansen()@coords[,1], lat = hansen()@coords[,2], radius = sqrt(hansen()@data$durationHansen)*10, weight= 5, color = pal(hansen()@data$durationHansen), 
                       stroke = TRUE, fillOpacity = 0.4, opacity = 0.8,
                       group = 'hansenduralayer', options = pathOptions(pane = "hansenduralayer")) 
        }else{
          proxy %>% clearGroup('hansenduralayer')
        }
        
        if(input$analysis=='Distance (Spatial Accessibility Measure)'){
          pal <- colorFactor(
            palette = 'Blues',
            domain = sam()@data$distanceSam
          )
          proxy %>% clearGroup('samdistlayer') %>% addMapPane('samdistlayer', zIndex = 412) %>%
            addCircles(lng = sam()@coords[,1], lat = sam()@coords[,2], radius = sqrt(sam()@data$distanceSam)*10, weight= 5, color = pal(sam()@data$distanceSam), 
                       stroke = TRUE, fillOpacity = 0.4, opacity = 0.8,
                       group = 'samdistlayer', options = pathOptions(pane = "samdistlayer")) 
        }else{
          proxy %>% clearGroup('samdistlayer')
        }
        
        if(input$analysis=='Duration (Spatial Accessibility Measure)'){
          pal <- colorFactor(
            palette = 'Purples',
            domain = sam()@data$durationHansen
          )
          proxy %>% clearGroup('samduralayer') %>% addMapPane('samduralayer', zIndex = 412) %>%
            addCircles(lng = sam()@coords[,1], lat = sam()@coords[,2], radius = sqrt(sam()@data$durationSam)*10, weight= 5, color = pal(sam()@data$durationSam), 
                       stroke = TRUE, fillOpacity = 0.4, opacity = 0.8,
                       group = 'samduralayer', options = pathOptions(pane = "samduralayer")) 
        }else{
          proxy %>% clearGroup('samduralayer')
        }
        
        
    })
    
    
    observeEvent(input$region,
      updateSelectInput(session, "jc",
                        label = "Junior College",
                        choices =  jc@data$SCHOOL[jc@data$REGION %in% toupper(input$region)]
      )
    )
    
   
    
    # look at the selected display and add the layer in if checked
    observeEvent(input$display, {
        proxy <- leafletProxy("mapPlot")
        schName = jc@data$SCHOOL[[curr_sch_id()]]

        if (yeshdb()){
            proxy %>%  addMapPane("hdblayer", zIndex = 420) %>% 
                addCircleMarkers( lng = hdb@coords[,1], lat = hdb@coords[,2], 
                                  opacity = 1, fillOpacity = 1, fillColor = '#E4CD05',color = '#000', 
                                  stroke=TRUE, weight = 0.5, radius= 2, options = pathOptions(pane = "hdblayer"),
                                  popup = hdb@data$ADDRESS, label = hdb@data$ADDRESS, 
                                  data = hdb@data$ADDRESS, group = 'hdblayer')
        } else if (nohdb()) {
            proxy %>% clearGroup('hdblayer')  
        }
        
        if (yessch()){
            proxy %>%  addMapPane("schlayer", zIndex = 420) %>% 
                addMarkers(lng = jc@coords[,1], lat = jc@coords[,2], 
                           popup = jc@data$ADDRESS, options = markerOptions(interactive = TRUE), clusterOptions = markerClusterOptions(),
                           data = jc@data$ADDRESS,
                           group = 'schlayer', icon = schIcon)
        } else if (nosch()) {
            proxy %>% clearGroup('schlayer')
        }

    })

    
    
  
    
    # look at the selected jc and the various selected items and add the layers in
    observeEvent(input$jc, {
        
        if( is.null(zoomlevel())){
            zlevel = 12
        }else{
            zlevel = zoomlevel()
        }
        
        proxy <- leafletProxy("mapPlot")
        schName = jc@data$SCHOOL[[curr_sch_id()]]
        
        if (input$analysis=='Duration (Isochrone)'){
            proxy %>% clearGroup('isolayer') %>% addMapPane("isolayer", zIndex = 410) %>% setView(lng = 103.8198, lat = 1.3521, zoom = 11) %>%
                addPolygons(data =iso(), stroke = TRUE, weight=0.5,
                            smoothFactor = 1, color="black", options = pathOptions(pane = "isolayer"),
                            fillOpacity = 0.6, fillColor =c('cyan','gold','tomato','red'), group = 'isolayer' )
                
        }
        
        if(input$analysis=='Distance (Hansen Accessibility)'){
          pal <- colorFactor(
            palette = 'Blues',
            domain = hansen()@data$distanceHansen
          )
          proxy %>% clearGroup('hansendistlayer') %>% addMapPane('hansendistlayer', zIndex = 412) %>%
            addCircles(lng = hansen()@coords[,1], lat = hansen()@coords[,2], radius = sqrt(hansen()@data$distanceHansen)*10, color = pal(hansen()@data$distanceHansen), 
                       stroke = TRUE, fillOpacity = 0.8, 
                       group = 'hansendistlayer', options = pathOptions(pane = "hansendistlayer")) 
        }
        
        if(input$analysis=='Duration (Hansen Accessibility)'){
          pal <- colorFactor(
            palette = 'Purples',
            domain = hansen()@data$durationHansen
          )
          proxy %>% clearGroup('hansenduralayer') %>% addMapPane('hansenduralayer', zIndex = 412) %>%
            addCircles(lng = hansen()@coords[,1], lat = hansen()@coords[,2], radius = sqrt(hansen()@data$durationHansen)*10, weight= 5, color = pal(hansen()@data$durationHansen), 
                       stroke = TRUE, fillOpacity = 0.4, opacity = 0.8,
                       group = 'hansenduralayer', options = pathOptions(pane = "hansenduralayer")) 
        }
        
        if(input$analysis=='Distance (Spatial Accessibility Measure)'){
          pal <- colorFactor(
            palette = 'Blues',
            domain = sam()@data$distanceSam
          )
          proxy %>% clearGroup('samdistlayer') %>% addMapPane('samdistlayer', zIndex = 412) %>%
            addCircles(lng = sam()@coords[,1], lat = sam()@coords[,2], radius = sqrt(sam()@data$distanceSam)*10, weight= 5, color = pal(sam()@data$distanceSam), 
                       stroke = TRUE, fillOpacity = 0.4, opacity = 0.8,
                       group = 'samdistlayer', options = pathOptions(pane = "samdistlayer")) 
        }
        
        if(input$analysis=='Duration (Spatial Accessibility Measure)'){
          pal <- colorFactor(
            palette = 'Purples',
            domain = sam()@data$durationSam
          )
          proxy %>% clearGroup('samduralayer') %>% addMapPane('samduralayer', zIndex = 412) %>%
            addCircles(lng = sam()@coords[,1], lat = sam()@coords[,2], radius = sqrt(sam()@data$durationSam)*10, weight= 5, color = pal(sam()@data$durationSam), 
                       stroke = TRUE, fillOpacity = 0.4, opacity = 0.8,
                       group = 'samduralayer', options = pathOptions(pane = "samduralayer")) 
        }
        
        
        proxy %>% clearGroup('targetlayer') %>% addMapPane("targetlayer", zIndex = 430) %>%
            addMarkers(lng = jc@coords[curr_sch_id(),1], lat = jc@coords[curr_sch_id(),2], 
                       popup = schName, options = markerOptions(interactive = TRUE), clusterOptions = markerClusterOptions(), 
                       group = 'targetlayer', icon = schIcon) %>% 
            flyTo(lng = jc@coords[curr_sch_id(),1], lat = jc@coords[curr_sch_id(),2], zlevel)
    })
    

    schIcon <- makeIcon(
        iconUrl = "schIcon.png",
        iconWidth = 20, iconHeight = 30,
        iconAnchorX = 10, iconAnchorY = 30,
    )
    
    
    #for the legend
    observe({
        schName = jc@data$SCHOOL[[curr_sch_id()]]
        proxy <- leafletProxy("mapPlot")
        proxy %>% clearControls()
        if (input$analysis=='Duration (Isochrone)'){
            count = iso()@data$blocks
            proxy %>% addLegend(position="topright",colors=rev(c("lightskyblue","greenyellow","gold","orange","tomato")),
                                labels=rev(c('< 90 min', '< 60 min', '< 45 min', '< 30 min', '< 15 min')),
                                opacity = 0.8,
                                title=paste0("Travel time from public transport to ", schName, ' :'))
        }
        
        if(input$analysis == 'Distance (Hansen Accessibility)'){
          vals = hansen()@data$distanceHansen
          colorpal <- colorBin("Blues", vals,  reverse = TRUE)
          proxy %>%  addLegend(position="topright", pal = colorpal, values = vals,
                               opacity = 0.8, labFormat = labelFormat(transform = function(vals) sort(vals, decreasing = TRUE)),
                               title=paste0("Hansen Accessibility on DISTANCE from HDBs to ", schName, ' (high to low)'))
        }
        
        if(input$analysis == 'Duration (Hansen Accessibility)'){
          vals = hansen()@data$durationHansen
          colorpal <- colorBin("Purples", vals,  reverse = TRUE)
          proxy %>%  addLegend(position="topright", pal = colorpal, values = vals,
                               opacity = 0.8, labFormat = labelFormat(transform = function(vals) sort(vals, decreasing = TRUE)),
                               title=paste0("Hansen Accessibility on DURATION from HDBs to ", schName, ' (high to low)'))
        }
        
        if(input$analysis == 'Distance (Spatial Accessibility Measure)'){
          vals = sam()@data$distanceSam
          colorpal <- colorBin("Blues", vals,  reverse = TRUE)
          proxy %>%  addLegend(position="topright", pal = colorpal, values = vals,
                               opacity = 0.8, labFormat = labelFormat(transform = function(vals) sort(vals, decreasing = TRUE)),
                               title=paste0("SAM Accessibility on DISTANCE from HDBs to ", schName, ' (high to low)'))
        }
        
        if(input$analysis == 'Duration (Spatial Accessibility Measure)'){
          vals = sam()@data$durationSam
          colorpal <- colorBin("Purples", vals,  reverse = TRUE)
          proxy %>%  addLegend(position="topright", pal = colorpal, values = vals,
                               opacity = 0.8, labFormat = labelFormat(transform = function(vals) sort(vals, decreasing = TRUE)),
                               title=paste0("SAM Accessibility on DURATION from HDBs to ", schName, ' (high to low)'))
        }
        
        if (yeshdb()){
          proxy %>%  addLegend(position="topright",colors=rev(c('#E4CD05')),
                                 labels=rev(c("HDB")),
                                 opacity = 0.8)
        } else if (nohdb()) {
            proxy %>% clearGroup('hdblayer')
        }
        
        if (yessch()){
          proxy %>%  addLegend(position="topright",colors=rev(c('red')),
                               labels=rev(c("school")),
                               opacity = 0.8)
        } else if (nosch()) {
          proxy %>% clearGroup('schlayer')
        }

    })
    
    
    
    # save the display into mapPlot to be call from UI.R
    output$mapPlot <- renderLeaflet({
        leaflet() %>%
            setView( lng = 103.8198, lat = 1.3521, zoom = 12) %>%
            setMaxBounds( lng1 = 103.4057919091
                          , lat1 = 1.1648902351
                          , lng2 = 104.2321161335
                          , lat2 = 1.601881499) %>%
        addProviderTiles(providers$CartoDB.DarkMatter,
                         options = providerTileOptions(opacity = 0.8))%>%
            htmlwidgets::onRender("
          function(el,x) {
            document.title = 'Merge'R'Us'
          }
      ")
    })
    
    
}
