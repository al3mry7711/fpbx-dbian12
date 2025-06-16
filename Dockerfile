FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

COPY install-freepbx.sh /install-freepbx.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /install-freepbx.sh /entrypoint.sh

RUN apt update && apt install -y \
    curl sudo ca-certificates gnupg2 lsb-release \
    && /install-freepbx.sh \
    && apt clean

CMD ["/entrypoint.sh"]
