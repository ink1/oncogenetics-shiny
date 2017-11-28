CentOS 7 based Docker container for running Shiny service.

	https://www.rstudio.com/products/shiny/download-server/
	http://rstudio.github.io/shiny-server/latest/#redhatcentos-5.4

The problem with using existing Shiny Dockerfiles was that they rely on debian:testing
and therefore too fluid to keep track of.
	https://github.com/rocker-org/rocker/issues/124

Hence the decision to create our own Dockerfile based on a reliable distro such as CentOS.

====================================================================================================

To build container
~~~~~~~~~~~~~~~~~~

./download.sh
docker build --tag=oncogenetics-shiny . 2>&1 | tee log.build


To run container
~~~~~~~~~~~~~~~~

cp -r shiny-server /home/
cd /home/shiny-server
tar zxvf shinyapps.tgz
# or 
# cd shinyapps
# git clone https://github.com/oncogenetics/LocusExplorer
# cd -
chown -R root.root shinyapps
chcon -Rt svirt_sandbox_file_t /home/shiny-server

docker run --name "shiny" -p 80:3838 -d \
    -v /home/shiny-server/shinyapps/:/srv/shiny-server/ \
    -v /home/shiny-server/log/:/var/log/ \
    -v /home/shiny-server/templates/:/etc/shiny-server/templates/ \
    oncogenetics-shiny:latest

The last command is contained in the script shiny-server/start-shiny.sh

Make sure the name "shiny" is used because this ensures the service is restarted on reboot.
List running containers:
	docker ps
List all containers including stopped ones
	docker ps -a
Stop container
	docker stop <container_name>
Remove stopped container
	docker rm <container_name>


The setup assumes the host has the following directory structure:

log files (files written by shiny server)
	/home/shiny-server/log

shiny apps source (files read by shiny server)
	/home/shiny-server/shinyapps
	/home/shiny-server/shinyapps/LocusExplorer

web page templates (files read by shiny server)
	/home/shiny-server/templates
	/home/shiny-server/templates/directoryIndex.html
	/home/shiny-server/templates/error.html


Then check the service by pointing to http://oncogenetics.icr.ac.uk/

====================================================================================================

Starting Shiny Docker Container as a Service
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

See
	https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/sect-managing_services_with_systemd-unit_files
	https://stackoverflow.com/questions/30449313/how-do-i-make-a-docker-container-start-automatically-on-system-boot

Make sure the conainer is running and it is named "shiny".
	(/home/shiny-server/start-shiny.sh was run)

cd /etc/systemd/system
vi docker-shiny.service

[Unit]
Description=Oncogenetics Shiny Service
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a shiny
ExecStop=/usr/bin/docker stop -t 5 shiny

[Install]
WantedBy=default.target

systemctl enable docker-shiny.service

After that start, status, and stop should do the right things and docker-shiny.service will 
be started on reboot:
	systemctl start docker-shiny.service
	systemctl status docker-shiny.service
	systemctl stop docker-shiny.service
