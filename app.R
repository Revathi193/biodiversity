## load all the required packages
if(!require(shiny)) install.packages("shiny", repos = "http://cran.us.r-project.org")
if(!require(shinydashboard)) install.packages("shinydashboard", repos = "http://cran.us.r-project.org")
if(!require(leaflet)) install.packages("leaflet", repos = "http://cran.us.r-project.org")
if(!require(timevis)) install.packages("timevis", repos = "http://cran.us.r-project.org")
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
if(!require(DT)) install.packages("DT", repos = "http://cran.us.r-project.org")
if(!require(ggplot2)) install.packages("ggplot2", repos = "http://cran.us.r-project.org")


## max file size
options(shiny.maxRequestSize=60*1024^2)

# source all files in modules folder
list.files("modules") %>%
  purrr::map(~ source(paste0("modules/", .)))



## UI page
header <- dashboardHeader(title = "Biodiversity Dashboard") 

sidebar <- dashboardSidebar(
  sidebarMenu(
    uiOutput("country"),
    br(),
    br(),
    search_ui("search")
  )
)

body <- dashboardBody(
  tags$head(        
    #in line styling
    tags$style(HTML(
      
      #siderbar background
      '.skin-blue .main-sidebar {
          background-color: #2B4B5E;}',
      
      #siderbar text color
      '.skin-blue .main-sidebar .sidebar{
          color: white;}'
    ))),
    
  tabsetPanel(
  tabPanel("Input Data",
           br(),
           div(dataTableOutput("inputdata"), style = "font-size:80%")),
  tabPanel(title = "Visualization",
           br(),
           uiOutput("map"),
           br(),
           br(),
           uiOutput("timeline")),
  tabPanel(title = "Stats",
           br(),
           valueBoxOutput("tot_species"),
           valueBoxOutput("count_sel_species"),
           uiOutput("kingdom_bar")
  )))


ui <- dashboardPage(header, sidebar, body, skin='blue')


server <- function(input, output) {
  
  ## read csv file
  data <- reactive({
    data <- read.csv("dataset.csv")
  })
  
  ## view the data in the Input Data tab as datatable
  output$inputdata <- DT::renderDataTable({
    return(datatable(data(),rownames = FALSE,options = list(pageLength = 20)))
  })
  
  ## after reading file, select the required country from the dataset
  output$country <- renderUI({
    selectInput('country',div(style = "font-size:14px","Select a Country"), choices = c("None",unique(data()$country)), multiple = F)})
  
  
  
  ## filter the dataset with the user selected country
  filtercountry <- reactive({
    df <- data()
    df <- df[df$country==input$country,]
  })
  
  ## total number of species in selected country
  total_species <- reactive({
    sum(filtercountry()$individualCount)})
  
  ## display as box output
  output$tot_species <- renderValueBox({
    valueBox(
      formatC(total_species(), format="d", big.mark=',')
      ,paste('Total Species:')
      ,icon = icon("stats",lib='glyphicon')
      ,color = "aqua")
  })
  
  ## count of species in each kingdom
  kingdom_count <- reactive({
    filtercountry() %>% group_by(kingdom) %>% summarise(value = sum(individualCount)) %>% filter(kingdom != "")
  })
  
  ## display count of species in each kingdom as bar chart 
  output$kingdom_bar <- renderUI({
    if(input$country != "None")
      renderPlot({
        ggplot(data = kingdom_count(), 
               aes(x=kingdom, y=value)) + 
          geom_bar(position = "dodge", fill = "#088F8F",stat = "identity") + ylab("Count") + 
          xlab("Kingdom") + theme(legend.position="bottom" 
                                  , axis.text.x = element_text(size = 8, angle = 90),
                                  plot.title = element_text(size=15, face="bold")) + 
          ggtitle("Count by Kingdom")
      },height = 300, width = 600)
    else
      renderText(paste("Please select a country to view the kingdom count"))
  }
  )
  
  
  ## search the species by Vernacular/Scientific Name
  search_server(id = "search", df = filtercountry)
  
  ## filter the data with the user selected Vernacular/Scientific Name
  filtered_data <- reactive({
    ## if the search input blank
    if(input$search == "")
    {
      df <- filtercountry()
      return(df)
    }
    ## search for vernacular name
    else if(isTRUE(input$search %in% filtercountry()$vernacularName == TRUE))
    {
      df <- filtercountry()
      df <- df[df$vernacularName==input$search,]
      names(df)[names(df) == 'eventDate'] <- 'start'
      df$start <- as.Date(df$start)
      df$id<- df$id
      df$content<- df$vernacularName
      return(df)
    }
    ## search for scientific name
    else if(isTRUE(input$search %in% filtercountry()$scientificName == TRUE))
    {
      df <- filtercountry()
      df <- df[df$scientificName==input$search,]
      names(df)[names(df) == 'eventDate'] <- 'start'
      df$start <- as.Date(df$start)
      df$id<- df$id
      df$content<- df$scientificName
      return(df)
    }
    
  })
  
  ## count of the selected species
  count_sel_species <- reactive({
    sum(filtered_data()$individualCount)})
  
  ## represent the count of selected species in box
  output$count_sel_species <- renderValueBox({
    valueBox(
      formatC(count_sel_species(), format="d", big.mark=',')
      ,paste('Total Count of selected species:')
      ,icon = icon("stats",lib='glyphicon')
      ,color = "aqua")
  })
  
  ## visualize the observation of selected species  in map
  output$map <- renderUI({
    ## if there is no country is selected, the default text
    if(input$country != "None")
    {
      if(input$search != "")
      map_server(id = "map", df = filtered_data)
      else
        renderText(paste("Please search Vernacular Name/Scientific Name to view the species in map"))
    }
    else
      renderText(paste("Please select a country to view the species in map"))
  }
  )
  
  ## visualize the observation of selected species in timeline plot
  output$timeline <- renderUI({
    ## if there is no country is selected, the default text
    if(input$country != "None")
    {
      if(input$search != "")
      ## visualize the timeline of selected species
      timeline_server(id = "timeline", df = filtered_data)
      else
        renderText(paste("Please search Vernacular Name/Scientific Name to view the timeline of species"))
    }
    else
    {
      renderText(paste("Please select a country to view the timeline of species"))
    }
  }
  )
  
}

# Run the application 
shinyApp(ui = ui, server = server)