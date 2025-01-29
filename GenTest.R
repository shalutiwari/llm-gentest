library(dotenv) # Will read OPENAI_API_KEY from .env file
library(shiny)
library(shinychat) 
library(ellmer) 
library(bslib)

prompt <- paste(collapse = "\n", readLines("prompt.md", warn=FALSE))

ui <- fluidPage(
  h3("Create setup environments for Posit Products "),
  selectInput("product",
              "Posit Product",
              c("Posit Connect", "Posit Workbench", "Posit Package Manager"),
              selected = "Posit Workbench"),
  selectInput("OS",
              "OS",
              c("Ubuntu 20", "Ubuntu 22", "Ubuntu 24","centos"),
              selected = "Ubuntu 20"),
   actionButton("generate", 
               "Generate Setup file", 
               icon("robot"), 
               style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
  chat_ui("chat", placeholder = "Any other questions?")
)


server <- function(input, output, session) {
  chat <- chat_openai(model = "gpt-4o", system_prompt = prompt)
  
  observeEvent(input$generate, {
    user_message <- paste(input$product, input$database, input$auth, input$features)
    chat_append("chat", chat$stream_async(user_message))
  })
  
  observeEvent(input$chat_user_input, {
    chat_append("chat", chat$stream_async(input$chat_user_input))
  })
}

shinyApp(ui, server)