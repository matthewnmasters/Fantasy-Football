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
    h2("Historical Data (Long-Form)", align="center"),
    DT::dataTableOutput("tableLong"),
    h2("Trend Graph", align = "center"),
    plotOutput("trendPlot"),
    h2("Aggregate 'Award' Data", align="center"),
    DT::dataTableOutput("tableAward")
  )
)


server<- function(input, output, session) {
  
  #bring in the raw data
  longData<- read.csv("fantasyStats.csv") %>%
    mutate(WinPerc = round(WinPerc, 3))
  
  #create a data set with averages for awards (summarise_each reduces row total, mutate_each doesnt)
  awardData<- longData %>%
    select(-Season) %>%
    group_by(Name) %>%
    summarise_each(funs(mean)) %>%
    group_by(Name) %>%
    mutate_each(funs(format(., nsmall=3)))
    
  
  #create a reactive data set that filters based on selections from checkboxes
  filteredData<- reactive({
    
    newData <- longData %>%
      filter(Name %in% input$playersSelected, Season %in% input$yearsSelected)
    
    return(newData)
    
  })
  
  #the table to show long data
  output$tableLong <- DT::renderDataTable(
    
    filteredData(),
    options= list(pageLength= 12)
    
  )
  
  #the table to show award data
  output$tableAward <- DT::renderDataTable(
    
    awardData,
    options= list(pageLength= 12) 
    
  )
  
  #player checkbox
  output$playersSelected <- renderUI({
    
    checkboxGroupInput(inputId = "playersSelected", label= "Filter Players:", choices= unique(longData$Name), selected =  unique(longData$Name))
    
  })
  
  #Season checkbox
  output$yearsSelected <- renderUI({
    
    checkboxGroupInput(inputId = "yearsSelected", label= "Filter Years:", choices= unique(longData$Season), selected =  unique(longData$Season))
    
  })
  
  #Let them select what variable to visualize
  output$outcomeVariable <- renderUI({
    
    selectInput(inputId = "outcomeVariable", label = "Y Axis for Graph:", choices = c("Wins" = "Win", "Losses" = "Loss", "Points For" = "PF", "Points Against" = "PA", "Yearly Ranking" = "Position", "Number of Moves" = "Moves", "Win Percentage" =  "WinPerc", "Point Differential" =  "PtDiff"))
    
  })
  
  #create the plot
  output$trendPlot <- renderPlot({
    

    ggplot(filteredData(), aes(x=Season, group=Name, color=Name)) + geom_line(aes_string(y= input$outcomeVariable)) + geom_point(aes_string(y= input$outcomeVariable))
    
  })
  
}

shinyApp(ui, server)