# Start with a base image
FROM alpine:3.20.3

# Who was the nice guy that shared it with us
LABEL Maintainer="omartinex"

# Set a non-root user to avoid running as root for better security
RUN set -eux; \
    addgroup -S myappgroup \
    && adduser -h /home/myappuser -D \
    -s /sbin/nologin -g "" -G myappgroup myappuser

# Ensure files have proper ownership and permissions
RUN chmod 755 /home/myappuser

# Set necessary environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Update Alpine packages and install Redis
RUN set -eux; \
    apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache redis && \
    rm -rf /var/cache/apk/*

# Ensure Redis directories are accessible by the non-root user
RUN mkdir -p /data && \
    chown -R myappuser:myappgroup /data /var/lib/redis /var/log/redis /etc/redis.conf

# Set Redis to listen on a non-privileged port
EXPOSE 6379

# Switch to the non-root user
USER myappuser

# Define a volume for persistent storage
VOLUME [ "/data" ]

# Command to run Redis
CMD ["redis-server", "--protected-mode", "no", "--port", "6379", "--dir", "/data"]
