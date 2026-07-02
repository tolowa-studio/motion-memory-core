# Motion Memory Core — gateway image.
# Standard Caddy plus the caddy-ratelimit plugin (github.com/mholt/caddy-ratelimit),
# which isn't in the stock caddy:2 image and requires an xcaddy build. The
# Caddyfile is baked in at build time (it's git-tracked, no runtime templating
# needed) — Railway services can't bind-mount a host file the way docker-compose
# can, so this is the one approach that works identically in both.
FROM caddy:2-builder AS builder
RUN xcaddy build --with github.com/mholt/caddy-ratelimit

FROM caddy:2
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
