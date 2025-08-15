FROM ubuntu:20.04
RUN apt update  && apt install -y procps coreutils
COPY mon.sh /mon.sh
RUN chmod +x /mon.sh
CMD ["/mon.sh"]
