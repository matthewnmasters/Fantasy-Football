#############################################################################################
#Fantasy Football Shiny App Demo                                                            #
#Author: Matt Masters                                                                       #
#Date: December 2020                                                                        #
#############################################################################################

library(shiny)
library(dplyr)
library(ggplot2)
library(DT)

ui<- pageWithSidebar(
  headerPanel('Emory Bonerz Fantasy Football Records and Visualization'),
  sidebarPanel(
    uiOutput("playersSelected"),
    uiOutput("yearsSelected"),
    uiOutput("outcomeVariable")
  ),
  mainPanel(
    DT::dataTableOutput("tableOut"),
    "put graph code here"
  )
)


server<- function(input, output, session) {
  
  longData<- read.csv("fantasyStats.csv")
  
  filteredData<- reactive({
    
    newData <- longData %>%
      filter(Name %in% input$playersSelected, Season %in% input$yearsSelected)
    
    return(newData)
    
  })
  
  output$tableOut <- DT::renderDataTable(
    
    filteredData(),
    options= list(pageLength= 12)
    
  )
  
  output$playersSelected <- renderUI({
    
    checkboxGroupInput(inputId = "playersSelected", label= "Filter Players:", choices= unique(longData$Name), selected =  unique(longData$Name))
    
  })
  
  output$yearsSelected <- renderUI({
    
    checkboxGroupInput(inputId = "yearsSelected", label= "Filter Years:", choices= unique(longData$Season), selected =  unique(longData$Season))
    
  })
  
  output$outcomeVariable <- renderUI({
    
    selectInput(inputId = "outcomeVariable", label = "Y Axis for Graph:", choices = c("Wins" = "Win", "Losses" = "Loss", "Points For" = "PF", "Points Against" = "PA", "Yearly Ranking" = "Position", "Number of Moves" = "Moves", "Win Percentage" =  "WinPerc", "Point Differential" =  "PtDiff"))
    
  })
  
}

shinyApp(ui, server)