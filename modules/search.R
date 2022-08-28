search_ui <- function(id) {
  
  ns <- shiny::NS(id)
  
  shiny::tagList(
    
    shiny::uiOutput(ns("search"))
    
    
  )
  
}
search_server <- function(id, df) {
  
  shiny::moduleServer(
    id,
    
    function(input, output, session) {
      output$search <- renderUI({
          df <- df()
          selectizeInput(
            inputId = "search", 
            label = div(style = "font-size:14px","Search species by Vernacular Name/Scientific Name"),
            multiple = FALSE,
            choices = c("Search Bar" = "", c("None",unique(df$vernacularName),unique(df$scientificName))),
            options = list(
              create = FALSE,
              placeholder = "Search Me",
              maxItems = '1',
              onDropdownOpen = I("function($dropdown) {if (!this.lastQuery.length) {this.close(); this.settings.openOnFocus = false;}}"),
              onType = I("function (str) {if (str === \"\") {this.close();}}")
            )
          )
          
        
      })
      
    }
    
  )
  
}