#Bilouvain Phe Map
#----------------------------------------------------------------------------------------
#LIBRARIES  
#----------------------------------------------------------------------------------------
library(tidyverse)
library(shiny)
library(plotly)       #Display interactive plots
library(shinydashboard)
library(readxl)
library(splitstackshape)
library(igraph)
#----------------------------------------------------------------------------------------
#USER INTERFACE FOR THE APPLICATION
#----------------------------------------------------------------------------------------
ui <- dashboardPage(
  dashboardHeader(title = "biPheMap",
                  tags$li(class = "dropdown", 
                          tags$a(href="about.html", 
                                 icon("info"), 
                                 "About", target="_blank"
                          )
                  ),
                  tags$li(class = "dropdown", 
                          tags$a(href="readme.html", 
                                 icon("readme"), 
                                 "Readme", target="_blank"
                          )
                  ),
                  tags$li(class = "dropdown", 
                          tags$a(href="https://labs.icahn.mssm.edu/dolab/", 
                                 icon("question"), 
                                 "Do Lab", target="_blank"
                          )
                  ),
                  tags$li(class = "dropdown", 
                          tags$a(href="https://github.com/rondolab", 
                                 icon("github"), 
                                 "Do Lab", target="_blank"
                          )
                  )
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("biPheMap", tabName = "phemap", icon = icon("dna"))
    )
  ),
  dashboardBody(
    tags$head(tags$style(HTML('.content-wrapper { overflow: auto; }'))),
    tabItems(
      tabItem(tabName = "phemap",
              column(width = 12,
                     
                     DT::dataTableOutput("table1")
                     
              ),
              column(width = 12,
                     fluidRow(
                       
                       column(width = 2,
                              
                              # actionButton("select", "Confirm Selection"),
                              actionButton("generate", " Generate Network"),
                              downloadButton("downloadPlot", "Download Plot"),
                              downloadButton("downloadFile", "Download Data")
                              
                              
                       ),
                       column(
                         width = 8,
                         
                         plotOutput("plot1", width = "100%", height = "600px"))
                     )
              )
      )
      
    )
    
  )
)

#----------------------------------------------------------------------------------------
#SERVER FOR THE APPLICATION
#----------------------------------------------------------------------------------------
server <- function(input, output) {
  
  
  
  file <- read.csv("data/biPheMap_abbreviated_v2.txt", header = TRUE, sep = "\t")
  
  file <- file[,c(1,2,3,8,4,5,6,7)]
  
  file <- file[order(file$Tissue),]
  
  output$table1 <- DT::renderDataTable({
    
    DT::datatable(
      file, 
      # selection = 'multiple',
      filter     = 'top', 
      extensions = c('Buttons', 'Scroller','KeyTable'),
      options    = list(
        columnDefs = list(list(visible=FALSE, targets = c(3))),
        pageLength   = 10,
        keys         = TRUE,
        scrollX      = 500,
        buttons      = list(list(extend = 'colvis', targets = 0, visible = FALSE)),
        lengthMenu   = c(10, 30, 50),
        dom          = 'lBfrtip',
        fixedColumns = TRUE), 
      rownames = FALSE)
  })
  
  selection_table <- reactive({
    
    file[input$table1_rows_all,]
  })
  
  observeEvent(input$generate,{
    
    
    
    relations   <- selection_table()[,c(4,6)]
    
    
    phenos      <- relations %>% distinct(Pheno.description.abbreviated) %>% rename(label = Pheno.description.abbreviated)
    phenos$type <- FALSE
    genes       <- relations %>% distinct(Gene.name) %>% rename(label = Gene.name)
    
    
    nodes <- full_join(phenos, genes, by = "label")
    nodes
    
    nodes <- nodes %>% rowid_to_column("id")
    index <- which(nodes$type == "FALSE")
    
    nodes$type[-index] <- TRUE
    
    per_route <- relations %>%  
      group_by(Pheno.description.abbreviated, Gene.name) %>%
      summarise(weight = n()) %>% 
      ungroup()
    
    edges <- per_route %>% 
      left_join(nodes, by = c("Pheno.description.abbreviated" = "label")) %>% 
      rename(from = id)
    
    edges <- edges %>% 
      left_join(nodes, by = c("Gene.name" = "label")) %>% 
      rename(to = id)
    
    edges <- select(edges, from, to, weight)
    edges
    
    routes_igraph <- graph_from_data_frame(d = edges, vertices = nodes, directed = FALSE)
    
    # deg <- degree(routes_igraph, mode = "all")
    
    plotInput <- function(){
      plot(routes_igraph, 
           vertex.color       = ifelse(V(routes_igraph)$type == TRUE, "salmon", "lightblue"),
           vertex.shape       = ifelse(V(routes_igraph)$type == TRUE, "square", "circle"),
           vertex.size        = 4,
           vertex.label.color = ifelse(V(routes_igraph)$type == TRUE, "salmon", "blue"),
           vertex.label.cex   = 0.8,
           layout             = layout.fruchterman.reingold,
           vertex.label.dist  = 1,
           vertex.label.font  = 2, edge.width = 3)
    }
    
    output$plot1 <- renderPlot({
      
      plotInput()
    }) 
    
    output$downloadPlot <- downloadHandler(
      filename = function() {'biLouvain_Phe-Map.png'},
      content = function(file) {
        
        png(file, width = 900, height = 900)
        print(plotInput())
        
        dev.off()
      })
    
  })
  output$downloadFile <- downloadHandler(
    
    filename = function() {
      ('biPheMap_data')
    }, 
    
    content = function(con) {
      write.table(selection_table(),row.names = FALSE,col.names=T, sep="\t",quote = FALSE,con)
    },
    contentType="csv"
  )
  
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
