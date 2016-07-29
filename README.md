docker-squid-deb-proxy
======================

Dockerfile for squid-deb-proxy. Intended for our dev and CI environments.

```
docker run \
    -h 'squid' --net bridge -m 0b -p 3128:8000 \
    -v ${DATA}:/data \
    -v /etc/localtime:/etc/localtime:ro \
    -e USE_ACL=0 \
    --name %n \
    --rm \
    muccg/squid-deb-proxy:latest
```

Environment:

- USE_ACL Enable or diable built in ACL rules (enabled by default)
- USE_AVAHI Enable or disable avahi-daemon (disabled by default)

Derived from::

- https://github.com/pmoust/squid-deb-proxy/
- https://github.com/yasn77/docker-squid-repo-cache/
