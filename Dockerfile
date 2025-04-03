# Sử dụng image Jitsi Meet ổn định
FROM jitsi/web:stable-10133-1

# Cấu hình môi trường
ENV PUBLIC_URL=${RENDER_EXTERNAL_URL:-https://docker-jitsi-meet.onrender.com} \
    ENABLE_XMPP_WEBSOCKET=0 \
    JVB_MAX_MEMORY=450m

# Cập nhật và cài đặt các phụ thuộc cần thiết
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Xử lý file .env
COPY --chown=jitsi:jitsi .env /defaults/.env
RUN if [ ! -f "/defaults/.env" ]; then \
      touch /defaults/.env; \
      echo "Created default .env file"; \
    fi

# Xử lý config.js (ĐÃ SỬA)
COPY --chown=jitsi:jitsi config.js /tmp/config_temp.js
RUN if [ -f "/tmp/config_temp.js" ]; then \
      mv /tmp/config_temp.js /usr/share/jitsi-meet/config.js && \
      echo "Applied custom config.js"; \
    else \
      echo "No custom config.js found, skipping..."; \
    fi

# Xử lý custom_interface
RUN mkdir -p /usr/share/jitsi-meet
COPY --chown=jitsi:jitsi custom_interface/ /usr/share/jitsi-meet/ || true
RUN if [ -d "/usr/share/jitsi-meet/custom_interface" ]; then \
      echo "Custom interface applied"; \
    else \
      echo "No custom interface found, skipping..."; \
    fi

# Thiết lập cuối cùng
USER jitsi
EXPOSE 80
