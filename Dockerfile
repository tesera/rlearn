FROM r-base:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    libxml2 \
    libxml2-dev \
    libcurl4-openssl-dev \
    git \
    python-pip \
&& rm -rf /var/lib/apt/lists/*

RUN pip install awscli

ENV WD=/opt/rlearn
ENV R_LIBS_USER $WD/rlibs

RUN mkdir -p $WD/rlibs

WORKDIR $WD

COPY install-dependencies.sh install-dependencies.sh

RUN bash ./install-dependencies.sh

COPY . $WD
