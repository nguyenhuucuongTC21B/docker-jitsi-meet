# Sử dụng image Jitsi Meet ổn định nhất (kiểm tra 07/2024)
FROM jitsi/web:stable-10133-1

# Thiết lập biến môi trường tối ưu cho Render Free Tier
ENV ENABLE_AUTH=0 \
    PUBLIC_URL=https://docker-jitsi-meet-2h2b.onrender.com \
    ENABLE_XMPP_WEBSOCKET=0 \
    JVB_MAX_MEMORY=450m \
    MAX_BITRATE=500000 \
    START_BITRATE=300000 \
    VIDEOQUALITY_HD_THRESHOLD=480 \
    ENABLE_RECORDING=0 \
    ENABLE_FILE_RECORDING_SERVICE=0

# Cài đặt phụ thuộc tối thiểu (tối ưu dung lượng image)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy config với cơ chế fallback an toàn
COPY --chown=jitsi:jitsi .env /defaults/.env
RUN if [ ! -f "/defaults/.env" ]; then \
      echo "No .env file, using defaults"; \
      touch /defaults/.env; \
    fi

# Xử lý config.js an toàn
RUN if [ -f "config.js" ]; then \
      cp --chown=jitsi:jitsi config.js /usr/share/jitsi-meet/; \
      echo "Custom config.js applied"; \
    else \
      echo "No config.js, using defaults"; \
    fi

# Xử lý custom_interface an toàn
RUN mkdir -p /usr/share/jitsi-meet && \
    if [ -d "custom_interface" ]; then \
      cp -r --chown=jitsi:jitsi custom_interface/* /usr/share/jitsi-meet/; \
      echo "Custom interface applied"; \
    else \
      echo "No custom interface"; \
    fi

# Thiết lập quyền và health check
USER jitsi
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:80 || exit 1

EXPOSE 80
