#!/bin/sh -e

start() {
    docker run --name="shiny" -p 80:3838 -d \
        -v /home/shiny-server/shinyapps/:/srv/shiny-server/ \
        -v /home/shiny-server/log/:/var/log/ \
        -v /home/shiny-server/templates/:/etc/shiny-server/templates/ \
        oncogenetics-shiny:latest 
}

stop() {
    docker stop shiny
    docker rm shiny
}

case "$1" in
    start)
        start
        ;;
    restart)
        stop
        start
        ;;
    stop)
        stop
        ;;
    *)
        echo "usage: $0 start|restart|stop"
        exit 1
esac

