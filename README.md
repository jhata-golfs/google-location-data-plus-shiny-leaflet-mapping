This project was meant to explore the data set exported from the Google download location data function and integrate the Leaflet package with Shiny. 

Using the Google Maps location .JSON file, I parse the data to pull mainly Longitude/Latitude/Timestamp. Choosing just a single day where I was riding my motorcycle, I order the data based on timestamp. Using the Shiny App framework on top of the Leaflet package, I display 50 datapoints using an animated sliderInput function in the Shiny UI. This allows the data to be displayed in a "caterpillar" like fashion. 

The final product can be seen here: https://userjhata.shinyapps.io/motorcycle_ride/

The .R script in this repo is meant to be a "plug & play" script where you need only to replace the reference to your own .json file to visualize your own data.