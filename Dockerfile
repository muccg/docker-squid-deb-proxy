#
FROM muccg/debian8-base
MAINTAINER https://github.com/muccg

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  squid-deb-proxy \
  squid-deb-proxy-client \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN env --unset=DEBIAN_FRONTEND

# Extra locations to cache from
ADD extra-sources.acl /etc/squid-deb-proxy/mirror-dstdomain.acl.d/20-extra-sources.acl
ADD debian-sources.acl /etc/squid-deb-proxy/mirror-dstdomain.acl.d/30-debian-sources.acl
ADD centos-sources.acl /etc/squid-deb-proxy/mirror-dstdomain.acl.d/40-centos-sources.acl
ADD fedora-sources.acl /etc/squid-deb-proxy/mirror-dstdomain.acl.d/50-fedora-sources.acl
ADD ius-sources.acl /etc/squid-deb-proxy/mirror-dstdomain.acl.d/60-ius-sources.acl
ADD postgresql-sources.acl /etc/squid-deb-proxy/mirror-dstdomain.acl.d/61-postgresql-sources.acl
ADD puppetlabs-sources.acl /etc/squid-deb-proxy/mirror-dstdomain.acl.d/62-puppetlabs-sources.acl
ADD ccg-sources.acl /etc/squid-deb-proxy/mirror-dstdomain.acl.d/70-ccg-sources.acl

# Cache RPM
RUN echo 'refresh_pattern rpm$   129600 100% 129600' >> \
  /etc/squid-deb-proxy/squid-deb-proxy.conf

# Don't cache our repos
RUN echo 'acl ccg dstdomain .ccgapps.com.au' >> \
  /etc/squid-deb-proxy/squid-deb-proxy.conf
RUN echo 'acl ccg dstdomain .murdoch.edu.au' >> \
  /etc/squid-deb-proxy/squid-deb-proxy.conf
RUN echo 'cache deny ccg' >> \
  /etc/squid-deb-proxy/squid-deb-proxy.conf

# Point cache directory to /data
RUN ln -sf /data /var/cache/squid-deb-proxy

# Redirect logs to stdout for the container
RUN ln -sf /dev/stdout /var/log/squid-deb-proxy/access.log
RUN ln -sf /dev/stdout /var/log/squid-deb-proxy/store.log
RUN ln -sf /dev/stdout /var/log/squid-deb-proxy/cache.log

ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME ["/data"]

EXPOSE 8000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["squid"]
