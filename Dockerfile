FROM ubuntu:xenial
RUN apt-get update \
&& apt-get install -y wget git zip software-properties-common default-jdk awscli
RUN add-apt-repository -y ppa:ubuntugis/ppa \
&& apt update \
&& apt install -y gdal-bin python-gdal
RUN wget https://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz \
&& mkdir osmosis \
&& mv osmosis-latest.tgz osmosis \
&& cd osmosis \
&& tar xvfz osmosis-latest.tgz \
&& rm osmosis-latest.tgz \
&& chmod a+x bin/osmosis
RUN git clone -b docker git@github.com:AntonioLagoD/mapsforge-creator.git

ENV OSMOSIS_HOME="/osmosis"

ENV THREADS=8
ENV SKIP_POI_CREATION="true"
ENV SKIP_MAP_CREATION="false"

ENTRYPOINT ["mapsforge-creator/map-creator.sh"]

