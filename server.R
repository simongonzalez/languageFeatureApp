shinyServer(function(input, output, session) {
  
  df <- read.csv('segments.csv', stringsAsFactors = F)
  prs <- read.csv('Parameters.csv', stringsAsFactors = F)
  
  #source(file.path("server", "visualInspection_server.R"),  local = TRUE)$value
  #
  output$selAr <- renderUI({
    tmpOptions <- sort(unique(prs$area))
    selectInput('selectArea', 'Select Area', choices = tmpOptions)
  })
  
  output$selParam <- renderUI({
    if(is.null(input$selectArea))
      return()
    
    tmpOptions <- sort(unique(prs[prs$area == input$selectArea, 'name']))
    selectInput('selectParameter', 'Select Parameter', choices = tmpOptions)
  })
  
  output$selPlot <- renderEcharts4r({
    if(is.null(input$selectArea))
      return()
    
    if(is.null(input$selectParameter))
      return()
    
    tmpOptionsCorrelation <- prs[prs$name == input$selectParameter, 'correlation']
    
    timesel <- as.character(tmpOptionsCorrelation)
    
    dfc <- df
    
    if(input$includeUnclassified){
      dfc[dfc[[timesel]] == '',timesel] <- '0 unclassified'
    }else{
      dfc <- dfc[dfc[[timesel]] != '',]
    }
    
    dfc <- dfc %>% distinct(Languagename, .keep_all = T)
    
    dfc$plotValue <- dfc[[timesel]]
    
    dfc$label <- paste0(dfc$Languagename, ' (', dfc$Family, ')')
    
    if(input$sizeby == 'Same Size'){
      dfc$size = 10
    }else if(input$sizeby == 'Inventory Size'){
      dfc$size = dfc$Inventorysize
    }else if(input$sizeby == 'Consonants Size'){
      dfc$size = dfc$Consonantn
    }else if(input$sizeby == 'Vowels Size'){
      dfc$size = dfc$Voweln
    }
    
    dfcplot <- dfc %>%
      group_by_(.dots= timesel)
    
    if(input$inDifferentPlot){
      dfcplot <- dfcplot %>%
        e_charts(Longitude, timeline = T)
    }else{
      dfcplot <- dfcplot %>%
        e_charts(Longitude)
    }
    
    dfcplot <- dfcplot %>%
      e_geo() %>%
      e_scatter(
        Latitude, label, size = size,
        coord_system = "geo"
      ) %>% 
      e_tooltip(formatter = htmlwidgets::JS("
      function(params){
                                        return(params.name)
                                        }
                                        ")
      ) %>% 
      e_theme(input$themes) %>%
      e_toolbox_feature(feature = "saveAsImage")
    
    dfcplot
  })
  
  
  output$selBarPlot <- renderHighchart({
    if(is.null(input$selectArea))
      return()
    
    if(is.null(input$selectParameter))
      return()
    
    tmpOptionsCorrelation <- prs[prs$name == input$selectParameter, 'correlation']
    
    timesel <- as.character(tmpOptionsCorrelation)
    
    dfc <- df
    
    if(input$includeUnclassified){
      dfc[dfc[[timesel]] == '',timesel] <- '0 unclassified'
    }else{
      dfc <- dfc[dfc[[timesel]] != '',]
    }
    
    dfc <- dfc %>% distinct(Languagename, .keep_all = T)
    
    dfc$plotValue <- dfc[[timesel]]
    
    dfc$label <- paste0(dfc$Languagename, ' (', dfc$Family, ')')
    
    if(input$sizeby == 'Same Size'){
      dfc$size = 10
    }else if(input$sizeby == 'Inventory Size'){
      dfc$size = dfc$Inventorysize
    }else if(input$sizeby == 'Consonants Size'){
      dfc$size = dfc$Consonantn
    }else if(input$sizeby == 'Vowels Size'){
      dfc$size = dfc$Voweln
    }
    
    dfcPlot <- dfc %>% group_by(plotValue) %>% count()
    
    hchart(dfcPlot, "column", hcaes(x = plotValue, y = n, group = plotValue))
  })
  
  
  output$selNet <- renderUI({
    
    selList <- list()
    
    for(i in unique(prs$area)){
      selList[[i]] <- sort(unique(prs[prs$area == i,'name']))
    }
    
    selectInput("selNetwork", "Select Networks", selList, 
                #selected = 
                multiple = T)
  })
  
  output$selplotnetwork <- renderSigmaNet({
    if(is.null(input$selNetwork))
      return()
    
    if(input$selNetwork == '')
      return()
    
    data <- df
    dataOrigin <- input$selNetwork
    
    tmpOptionsCorrelation <- prs[prs$name %in% input$selNetwork, 'correlation']
    
    timesel <- as.character(tmpOptionsCorrelation)
    dataOrigin <- timesel

    dataTarget <- 'Languagename'
    dataGroup <- 'Family'
    dataValue <- 'Inventorysize'
    
    for(datai in dataOrigin){
      data <- data[data[[datai]] != '',]
    }
    
    data <- data %>% distinct(Languagename, .keep_all = T)
    
    tmpOrigins <- NULL
    
    for(datai in dataOrigin){
      tmpOrigins <- append(tmpOrigins, data[[datai]])
    }
    
    tmpOriginsAll <- append(tmpOrigins, data[[dataTarget]])
    
    allnames <- data.frame(id = tmpOriginsAll)
    allnames <- distinct(allnames %>% group_by(id) %>% mutate(value = n()))
    allnames <- allnames[order(allnames$value, decreasing = T),]
    allnames$number <- 0:(nrow(allnames)-1)
    
    groupMapUnique <- data %>% distinct_(dataTarget, dataGroup)
    groupMap <- setNames(groupMapUnique[[dataGroup]],
                         groupMapUnique[[dataTarget]])
    
    allnames$group <- as.character(groupMap[as.character(allnames$id)])
    allnames$group[is.na(allnames$group)] <- 'source'
    
    nodes <- data.frame(id = allnames$number,
                        name = allnames$id,
                        group = allnames$group, 
                        size = allnames$value,
                        value = allnames$value)
    
    sourceMap <- setNames(allnames$number, allnames$id)
    
    tmpTargets <- rep(data[[dataTarget]], length(dataOrigin))
    tmpValues <- rep(data[[dataValue]], length(dataOrigin))
    
    edges <- data.frame(source = tmpOrigins, 
                        target = tmpTargets, 
                        value = tmpValues)
    
    edges$source <- as.numeric(sourceMap[as.character(edges$source)])
    edges$target <- as.numeric(sourceMap[as.character(edges$target)])
    
    edges$source <- as.integer(edges$source)
    edges$target <- as.integer(edges$target)
    
    net <- graph_from_data_frame(d=edges, vertices=nodes, directed=T) 
    
    layout <- layout_with_fr(net)
    sig <- sigmaFromIgraph(net, layout = layout)
    sig %>%
      addNodeSize(sizeMetric = 'degree', minSize = 2, maxSize = 8) %>%
      addEdgeSize(sizeAttr = 'value', minSize = .1, maxSize = 2) %>%
      addNodeColors(colorAttr = 'group', colorPal = 'Set1')
  })
  
}
)