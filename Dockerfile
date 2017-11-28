## 28/11/2017
##
## based on 
## https://www.rstudio.com/products/shiny/download-server/
## http://rstudio.github.io/shiny-server/latest/#redhatcentos-5.4
## partially based on Dockerfile by Winston Chang "winston@rstudio.com"

FROM centos:centos7

MAINTAINER Igor Kozin "igor.kozin@icr.ac.uk"

## Update yum and get wget
RUN yum -y update; yum clean all
RUN yum -y install wget pandoc pandoc-citeproc libxml2-devel libcurl-devel \
    cairo-devel libXt-devel v8-devel openssl-devel mesa-libGLU-devel mariadb-devel

## Install R-3.4.2-2.el7
## all required packages are download beforehand using download script
COPY epel/* /tmp/

## Enable EPEL
RUN rpm -ivh /tmp/epel-release-7-11.noarch.rpm

RUN yum -y install \
    /tmp/R-3.4.2-2.el7.x86_64.rpm \
    /tmp/R-core-3.4.2-2.el7.x86_64.rpm \
    /tmp/R-core-devel-3.4.2-2.el7.x86_64.rpm \
    /tmp/R-devel-3.4.2-2.el7.x86_64.rpm \
    /tmp/R-java-3.4.2-2.el7.x86_64.rpm \
    /tmp/R-java-devel-3.4.2-2.el7.x86_64.rpm \
    /tmp/libRmath-3.4.2-2.el7.x86_64.rpm \
    /tmp/libRmath-devel-3.4.2-2.el7.x86_64.rpm \
    /tmp/libRmath-static-3.4.2-2.el7.x86_64.rpm

# A workaround to fix missing /usr/share/doc/R-3.2.2/html folder
# it is not created by yum but is created by rpm.
# Not tested if it is needed for 3.4.2
RUN rpm -e R R-devel R-core R-core-devel && \
    rpm -iv \
    /tmp/R-3.4.2-2.el7.x86_64.rpm \
    /tmp/R-core-3.4.2-2.el7.x86_64.rpm \
    /tmp/R-core-devel-3.4.2-2.el7.x86_64.rpm \
    /tmp/R-devel-3.4.2-2.el7.x86_64.rpm 

## Update method of installing packages
RUN echo 'options(download.file.method = "libcurl")' >> /usr/lib64/R/library/base/R/Rprofile

## Install R deps
RUN R -e "install.packages(c('shiny', 'rmarkdown', 'shinyjs', 'data.table', 'dplyr', 'tidyr', 'ggplot2', 'knitr', 'markdown', 'stringr','DT','seqminer'), repos='https://cran.rstudio.com/')"

RUN R -e "source('https://bioconductor.org/biocLite.R'); biocLite('ggbio')"
RUN R -e "source('https://bioconductor.org/biocLite.R'); biocLite('GenomicRanges')"
RUN R -e "source('https://bioconductor.org/biocLite.R'); biocLite('TxDb.Hsapiens.UCSC.hg19.knownGene')"
RUN R -e "source('https://bioconductor.org/biocLite.R'); biocLite('org.Hs.eg.db')"

## Install Shiny server
## This needs to be done after 'shiny' is installed
RUN yum -y install --nogpgcheck /tmp/shiny-server-1.5.5.872-rh5-x86_64.rpm && \
    rm -f /tmp/*rpm 

EXPOSE 3838

COPY shiny-server.sh   /usr/bin/shiny-server.sh
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
RUN chmod +x /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]
