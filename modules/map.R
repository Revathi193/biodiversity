map_ui <- function(id) {
  
  ns <- shiny::NS(id)
  
  shiny::tagList(
    
    leaflet::leafletOutput(ns("map"),height = 500)
    
    
  )
  
}
map_server <- function(id, df) {
  
  shiny::moduleServer(
    id,
    
    function(input, output, session) {
      output$map <- leaflet ::renderLeaflet({
        df <- df()
        leaflet(data = df) %>%
          addTiles() %>%
          addMarkers(lng = ~longitudeDecimal, 
                     lat = ~latitudeDecimal,
                     popup = paste("<b>ID:  </b>", df$id, "<br>",
                                   "<b>Locality: </b>", df$locality, "<br>",
                                   "<b>Kingdom: </b>", df$kingdom, "<br>",
                                   "<b>Vernacular Name: </b>", df$vernacularName, "<br>",
                                   "<b>Scientific Name: </b>", df$scientificName, "<br>",
                                   "<b>Family: </b>", df$family, "<br>",
                                   "<b>Classification: </b>", df$higherClassification, "<br>",
                                   "<b>Sex: </b>", df$sex, "<br>",
                                   "<b>Life Stage: </b>", df$lifeStage, "<br>"))
        
      })
      
    }
    
  )
  
}