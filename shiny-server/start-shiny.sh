docker run --name "shiny" -p 80:3838 -d \
    -v /home/shiny-server/shinyapps/:/srv/shiny-server/ \
    -v /home/shiny-server/log/:/var/log/ \
    -v /home/shiny-server/templates/:/etc/shiny-server/templates/ \
    oncogenetics-shiny:latest 
