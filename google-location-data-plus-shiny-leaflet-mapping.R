library(tidyverse)
library(tidytext)
library(jsonlite)
library(ggTimeSeries)
library(lubridate)
library(leaflet)
library(geosphere)
library(animation)
library(magick)
library(htmlwidgets)
library(webshot)
library(stringi)
library(shiny)

location_file <- "[your downloaded google location data].json"

location_data <- fromJSON(location_file)

location_timestamp <- as.tibble(location_data[["locations"]][["timestampMs"]])
latitude <- as.tibble(location_data[["locations"]][["latitudeE7"]])
latitude_clean <- as.tibble(str_replace(latitude$value,paste0('^(.{',nchar(latitude$value)-7,'})(.+)$'),'\\1.\\2'))
longitude <- as.tibble(location_data[["locations"]][["longitudeE7"]])
longitude_clean <- as.tibble(str_replace(longitude$value,paste0('^(.{',nchar(longitude$value)-7,'})(.+)$'),'\\1.\\2'))
accuracy <- as.tibble(location_data[["locations"]][["accuracy"]])
altitude <- as.tibble(location_data[["locations"]][["altitude"]])
velocity <- as.tibble(location_data[["locations"]][["velocity"]])

names(latitude_clean)[names(latitude_clean) == "value"] <- "latitude"
names(longitude_clean)[names(longitude_clean) == "value"] <- "longitude"
names(accuracy)[names(accuracy) == "value"] <- "accuracy"
names(altitude)[names(altitude) == "value"] <- "altitude"
names(velocity)[names(velocity) == "value"] <- "velocity"
names(location_timestamp)[names(location_timestamp) == "value"] <- "timestamp"

location_timestamp$timestamp <- as.POSIXct(as.numeric(location_timestamp$timestamp)/1000, origin = "1970-01-01")

location_df <- cbind(location_timestamp,latitude_clean,longitude_clean,accuracy,altitude,velocity)

location_df$latitude <- as.numeric(location_df$latitude)
location_df$longitude <- as.numeric(location_df$longitude)

write.csv(location_df,"google_location_data.csv",row.names = F)



location_df <- read.csv("google_location_data.csv")


########################################
## MOTORCYCLE WEST LA DATASET

data_sample <- location_df %>%
  filter(as.Date(location_df$timestamp, tz = "America/Los_Angeles") == "YYYY-mm-DD") ##Filters for a specific date

data_sample <- data_sample %>%
  arrange(data_sample$timestamp) %>%
  mutate(
    row_number = row_number()
  )

data_sample$timestamp <- as.POSIXct(data_sample$timestamp)

ui <- fluidPage(
  
  # Sidebar layout with input and output definitions ----
  fluidRow(
    
    # Sidebar panel for inputs ----
    column(4,
           h4("Random Day in West LA on my motorcycle"),
           
           # Input: Slider for the number of bins ----
           sliderInput("range", 
                       "datapoints",
                       min(data_sample$row_number), 
                       max(data_sample$row_number),
                       value = 1, 
                       step = 5,
                       animate =
                         animationOptions(interval = 90, loop = TRUE))
           
    ),
    ##column(4,
    ##       verbatimTextOutput("date")
    ##),
    column(8,
           h4("Map dat shit"),
           # Output: Leaflet Map
           leafletOutput(outputId = "sample_map", width = "100%", height = 500)
    )
  )
)

server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    data_sample %>% 
      filter(data_sample$row_number <= input$range & data_sample$row_number >= input$range-50) 
    ## Filters for only 50 data points at a time allowing for a "trailing" effect to the map
  })
  
  
  output$sample_map<-renderLeaflet({
    leaflet() %>%
      ##Los Angeles
      setView(lng = -118.5817, lat = 34.0497,zoom = 11) %>%
      addTiles()
  })
  
  observe({
    leafletProxy("sample_map", data = filteredData()) %>%
      clearMarkers() %>%
      addCircleMarkers(
        lng = ~longitude, 
        lat = ~latitude,
        radius = 3, 
        fillOpacity = 1,
        stroke = FALSE
      )
  })
}

shinyApp(ui, server)