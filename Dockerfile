FROM azul/zulu-openjdk-debian:8

RUN apt-get update -qq && apt-get install --no-install-recommends -y wget ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN wget https://dl.embulk.org/embulk-0.9.24.jar -O /usr/local/bin/embulk \
  && chmod +x /usr/local/bin/embulk

COPY . /embulk
WORKDIR /embulk
