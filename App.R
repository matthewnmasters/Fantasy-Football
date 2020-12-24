#############################################################################################
#Fantasy Football Shiny App Demo                                                            #
#Author: Matt Masters                                                                       #
#Date: December 2020                                                                        #
#############################################################################################

library(shiny)
library(dplyr)
library(ggplot2)

#ui<-


server<- function(input, output, session) {
  
  longData<- reactive({
    
    #reactive to:
    input$playersSelected
    input$yearsSelected
    
    rawData <- read.csv("C:/Users/matth/Documents/GitHub/Fantasy-Football/fantasyStats.csv") %>%
      filter(Name %in% input$playersSelected, Season %in% yearsSelected)
    
    return(rawData)
    
  })
  
  
  
}

shinyApp(ui, server)