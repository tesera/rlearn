FROM r-base:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    libxml2 \
    libxml2-dev \
    libcurl4-openssl-dev \
    git \
    python-pip \
    python-setuptools \
    && rm -rf /var/lib/apt/lists/*

RUN pip install awscli

ENV WD=/opt/rlearn
ENV R_LIBS_USER $WD/rlibs

RUN mkdir -p $WD/rlibs

WORKDIR $WD

COPY install-dependencies.sh install-dependencies.sh

RUN bash ./install-dependencies.sh

COPY . $WD

RUN R CMD build .
RUN R CMD INSTALL --library=$R_LIBS_USER rlearn_1.0.0.tar.gz
