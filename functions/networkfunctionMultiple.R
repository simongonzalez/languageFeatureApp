data <- df
dataOrigin <- c('ConsonantInventories', 'VowelQualityInventories')
dataTarget <- 'Languagename'
dataGroup <- 'Family'
dataValue <- 'Inventorysize'

for(datai in dataOrigin){
  data <- data[data[[datai]] != '',]
}

data <- data %>% 
  distinct(Languagename, .keep_all = T)

tmpOrigins <- NULL

for(i in dataOrigin){
  tmpOrigins <- append(tmpOrigins, data[[i]])
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