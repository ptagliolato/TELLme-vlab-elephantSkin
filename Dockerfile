FROM ptagliolato/r-spatial-base:1.0.2
RUN mkdir /root/TELLme-vlab-elephantSkin
COPY ui.R root/TELLme-vlab-elephantSkin/ui.R
COPY server.R root/TELLme-vlab-elephantSkin/server.R
COPY global.R root/TELLme-vlab-elephantSkin/global.R
COPY modules/bbxSelector.R root/TELLme-vlab-elephantSkin/modules/bbxSelector.R
COPY Rprofile.site /usr/lib/R/etc/

# set shiny listen on port 3838 with Rprofile.site provided
COPY Rprofile.site /usr/lib/R/etc/
EXPOSE 3838

LABEL maintainer="ptagliolato <tagliolato.p@irea.cnr.it>" \
   org.opencontainers.image.authors="Tagliolato (tagliolato.p@irea.cnr.it) and Oggioni" \
   org.opencontainers.image.version="1.1.0" \
   org.opencontainers.image.licences="GPL3" \
   edu.science.data.group.project="Erasmus Plus TELLme Project" \
   edu.science.data.group.name="CNR-IREA-milano-LabSDI-GETIT" \
   author.orcid="0000-0002-0261-313X"

##### USAGE:
# build the image:
#   docker build -t tellme-vlab-elephantskin:<version> .
# run the container:
#   docker run -it --rm --env-file=env -p 3838:3838 tellme-vlab-elephantskin:<version>
# open your browser (if you are running the container in your machine) at the url:
#   http://127.0.0.1:3838/
#####

CMD ["R", "-e", "shiny::runApp('/root/TELLme-vlab-elephantSkin')"]

