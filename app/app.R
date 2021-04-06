#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#look for the required packages
if(!require(shiny)) install.packages("shiny", repos = "http://cran.us.r-project.org")
if(!require(shinydashboard)) install.packages("shinydashboard", repos = "http://cran.us.r-project.org")
if(!require(leaflet)) install.packages("leaflet", repos = "http://cran.us.r-project.org")
if(!require(rgdal)) install.packages("rgdal", repos = "http://cran.us.r-project.org")
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
if(!require(flexdashboard)) install.packages("flexdashboard", repos = "http://cran.us.r-project.org")
if(!require(highcharter)) install.packages("highcharter", repos = "http://cran.us.r-project.org")
if(!require(CoordinateCleaner)) install.packages("CoordinateCleaner", repos = "http://cran.us.r-project.org")
if(!require(plotly)) install.packages("plotly", repos = "http://cran.us.r-project.org")
if(!require(fontawesome)) install.packages("fontawesome", repos = "http://cran.us.r-project.org")
if(!require(rsconnect)) install.packages("rsconnect", repos = "http://cran.us.r-project.org")

#############################################################
#####################Set up the dataframe####################
#############################################################

#Search for files
file_forestLandRatio <- "forestLandRatio.csv"
file_forestArea <- "forestArea.csv"
file_borders <- "TM_WORLD_BORDERS-0.3.shp"

#Read csv files
#forest coverage
forestLandRatio <- read.csv(file_forestLandRatio,skip=4,header=TRUE, fileEncoding="UTF-8-BOM")
#forest area
forestArea <- read.csv(file_forestArea,skip=4,header=TRUE, fileEncoding="UTF-8-BOM")

#reshape the data from wide to long
forestLandRatio_long <- reshape(forestLandRatio,
                                direction = "long",
                                varying = list(names(forestLandRatio)[5:31]),
                                v.names = "Value",
                                idvar = "Country.Code",
                                timevar = "Year",
                                times = 1990:2016)

forestArea_long <- reshape(forestArea,
                           direction = "long",
                           varying = list(names(forestLandRatio)[5:31]),
                           v.names = "Value",
                           idvar = "Country.Code",
                           timevar = "Year",
                           times = 1990:2016)

#Get country centroid data (lat + lng)
data(countryref)
countryref <- countryref %>%
    dplyr::select(centroid.lon, centroid.lat, iso3)

#Prepare data to merge two date frame
#select needed columns
forestLandRatio_long <- forestLandRatio_long %>%
    dplyr::select(Country.Code, Value, Year)

#rename columns
names(forestArea_long)[names(forestArea_long) == "Value"] <- "forestArea"
names(forestLandRatio_long)[names(forestLandRatio_long) == "Value"] <- "forestRatio"

#read shp files for countries' polygons
borders <- readOGR(file_borders)

#############################################################
#####################User Interface##########################
#############################################################

ui <- dashboardPage(
    skin = "green",
    dashboardHeader(title = "Global Forest Changes"), #headers
    dashboardSidebar(),
    dashboardBody(
        fluidRow(box(width = 12, leafletOutput(outputId = "map"))), #leaflet map
        fluidRow(box(width = 12, plotlyOutput(outputId = "timeseries"))) #plotting timeseries
    )
)


#############################################################
#####################Server##################################
#############################################################

server <- function(input, output) {

    #prepare input data for the initial map
    data_input <- left_join(forestArea_long, countryref, by = c("Country.Code"="iso3")) %>%
        left_join(.,forestLandRatio_long, by = c("Country.Code"="Country.Code","Year"="Year")) %>%
        dplyr::filter(complete.cases(.)) %>%
        mutate(hotspot = ifelse(forestArea > median(forestArea)*1.5,1,0))

    #get rid of duplicated data
    data_input <- data_input[!duplicated(data_input[c("Country.Code","Year")]),]

    #get data frame for the latest forest data
    data_latest <- data_input %>%
        dplyr::filter(Year == 2015) %>%
        arrange(Country.Code)

    data_deforest <- data_input %>%
        dplyr::filter(Year == 2000) %>%
        arrange(Country.Code) %>%
        mutate(hugeLoss = ifelse(forestArea*0.8 > data_latest$forestArea |
                                (forestArea - data_latest$forestArea) > 50000,1,0)) %>%
        dplyr::filter(hugeLoss == 1) %>%
        dplyr::filter(hotspot == 1)

    forestArea2016 <- data_latest

    # Create a palette that maps factor levels to colors
    pal <- colorFactor(c("yellow","green"), domain = c(0,1))

    bins <- c(5,10,15,20,30,40,50,60,80)
    pal_fill <- colorBin("YlGn", domain = forestArea2016$forestRatio, bins = bins)

    forestArea2016$label <- paste("<p>",forestArea2016$Country.Name,"</p>",
                                  "<p>","Forest Area: ",round(forestArea2016$forestArea,0)," km²","</p>",
                                  "<p>","Coverage: ",round(forestArea2016$forestRatio,0),"%","</p>")

    icons_warning <- iconList(makeIcon("http://pngimg.com/uploads/exclamation_mark/exclamation_mark_PNG57.png",
                                       iconWidth = 18, iconHeight = 18))


    #the initial map
    output$map <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$Esri.WorldImagery) %>% #add basemap
            setView(lng = -57.272078, lat = -7.173734, zoom = 4) %>% #set centre
            addPolygons(data = borders, #add countries' polygons
                        color = "#580000",
                        weight = 1,
                        smoothFactor = 1,
                        fillOpacity = 0.75,
                        fillColor = pal_fill(forestArea2016$forestRatio),
                        layerId = ~ISO3,
                        highlight = highlightOptions( #set highlight when browsing the country polygons
                            weight = 5,
                            color = "red",
                            fillOpacity = 0.7
                        )) %>%
            addCircleMarkers(lng = forestArea2016$centroid.lon,
                             lat = forestArea2016$centroid.lat,
                             radius = ifelse(forestArea2016$hotspot == 1, 6, 4),
                             color = pal(forestArea2016$hotspot),
                             stroke = FALSE,
                             #clusterOptions = markerClusterOptions(showCoverageOnHover = FALSE),
                             fillOpacity = 0.5,
                             label = lapply(forestArea2016$label, HTML),
                             labelOptions = labelOptions(direction = "bottom",
                                                         style = list(
                                                             "color" = "#020048",
                                                             "font-family" = "mono",
                                                             "box-shadow" = "3px 3px rgba(0,0,0,0.25)",
                                                             "font-size" = "15px",
                                                             "border-color" = "#DAF7A6"))) %>%
            addLegend(pal = pal_fill,
                      values = forestArea2016$forestRatio,
                      opacity = 0.7,
                      position = "topright",
                      title = "Forest Coverage (%)") %>%
            addMarkers(data = data_deforest,
                       lng = jitter(data_deforest$centroid.lon, factor = 0.1),
                       lat = jitter(data_deforest$centroid.lat, factor = 0.1),
                       icon = icons_warning)
    })

    data_for_chart <- reactive({
        dplyr::filter(data_input, Country.Code == input$map_shape_click$id)
    })

    observe({
        event <- input$map_shape_click
        print(event$id)
        print(icons_warning)
        print(paste0(data_deforest$centroid.lon,",",data_deforest$centroid.lat))
    })

    output$timeseries <- renderPlotly({
        if (is.null(input$map_shape_click) == 0) {
        data_for_chart() %>%
        plot_ly(x = ~Year, y = ~forestArea, type = 'scatter', mode='lines+markers') %>%
        layout(title=paste0(input$map_shape_click$id,": Forest Changes in the last 3 decades"),xaxis = list(title = "Year"), yaxis = list(title = "Forest Area (km²)"))
        }
            })
}

# Run the application
shinyApp(ui = ui, server = server)
