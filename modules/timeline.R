timeline_ui <- function(id) {
  
  ns <- shiny::NS(id)
  
  shiny::tagList(
    
    timevis::timevisOutput(ns("timeline"),height = 500)
    
    
  )
  
}
timeline_server <- function(id, df) {
  
  shiny::moduleServer(
    id,
    
    function(input, output, session) {
      output$timeline <- renderTimevis({
        df <- df()
        timevis(df)
      })
      
    }
    
  )
  
}