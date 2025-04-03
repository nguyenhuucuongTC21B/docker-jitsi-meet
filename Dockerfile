FROM jitsi/web:stable-10133-1

# Cấu hình môi trường
ENV PUBLIC_URL=${RENDER_EXTERNAL_URL:-https://your-service.onrender.com} \
    ENABLE_XMPP_WEBSOCKET=0 \
    JVB_MAX_MEMORY=450m

# Cài đặt phụ thuộc
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Xử lý .env
COPY --chown=jitsi:jitsi .env /defaults/.env
RUN if [ ! -f "/defaults/.env" ]; then touch /defaults/.env; fi

# Xử lý config.js
COPY --chown=jitsi:jitsi config.js /tmp/config_temp.js
RUN if [ -f "/tmp/config_temp.js" ]; then \
      mv /tmp/config_temp.js /usr/share/jitsi-meet/config.js; \
    fi

# Xử lý custom_interface (ĐÃ SỬA)
RUN mkdir -p /usr/share/jitsi-meet && \
    if [ -d "custom_interface" ]; then \
      cp -r --chown=jitsi:jitsi custom_interface/* /usr/share/jitsi-meet/; \
    fi

# Thiết lập cuối cùng
USER jitsi
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost || exit 1
EXPOSE 80
