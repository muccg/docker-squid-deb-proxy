#
FROM debian:stretch-slim
MAINTAINER https://github.com/muccg/

ENV USE_ACL=1
ENV USE_AVAHI=0
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  avahi-utils \
  avahi-daemon \
  squid-deb-proxy \
  squid-deb-proxy-client \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN env --unset=DEBIAN_FRONTEND

# Add ACLs
ADD etc /etc

# Additional config, mount over this at runtime to override 
RUN echo \
'refresh_pattern rpm$   129600 100% 129600\n\
shutdown_lifetime 1 second\n\
pipeline_prefetch on\n\
icp_port 0\n\
htcp_port 0\n\
icp_access deny all\n\
htcp_access deny all\n\
snmp_port 0\n\
snmp_access deny all\n'\
    >> /etc/squid-deb-proxy/squid-deb-proxy.conf


# Point cache directory to /data
RUN ln -sf /data /var/cache/squid-deb-proxy

# Redirect logs to stdout for the container
RUN ln -sf /dev/stdout /var/log/squid-deb-proxy/access.log
RUN ln -sf /dev/stdout /var/log/squid-deb-proxy/store.log
RUN ln -sf /dev/stdout /var/log/squid-deb-proxy/cache.log

ADD docker-entrypoint.sh /docker-entrypoint.sh

VOLUME ["/data"]

EXPOSE 8000 5353/udp

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["squid"]
