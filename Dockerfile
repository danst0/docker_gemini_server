FROM rust:latest AS build

RUN apt-get update
RUN apt-get -y install openssl

WORKDIR /usr/src/agate
RUN cargo install agate

RUN openssl req -x509 -newkey rsa:4096 -keyout gemini-key.rsa \
  -out gemini-cert.pem -days 4096 -nodes -subj "/CN=g.dumke.me"

FROM ubuntu:latest

WORKDIR /usr/local/gemini
COPY --from=build /usr/local/cargo/bin/agate /usr/local/bin
COPY --from=build /usr/src/agate/gemini-key.rsa   conf/gemini-key.rsa
COPY --from=build /usr/src/agate/gemini-cert.pem  conf/gemini-cert.pem

EXPOSE 1965/tcp
CMD [ "agate", "0.0.0.0:1965", "--content", "geminidocs", "--cert", "conf/gemini-cert.pem", "--key", "conf/gemini-key.rsa" ]
