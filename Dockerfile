# Sử dụng image Jitsi Meet ổn định (kiểm tra 08/2024)
FROM jitsi/web:stable-10133-1

# ========== CẤU HÌNH MÔI TRƯỜNG TỰ ĐỘNG ==========
# Ưu tiên sử dụng biến Render, nếu không có thì dùng URL mặc định
ENV PUBLIC_URL=${RENDER_EXTERNAL_URL:-https://docker-jitsi-meet.onrender.com} \
    # Tối ưu hiệu năng
    ENABLE_XMPP_WEBSOCKET=0 \
    JVB_MAX_MEMORY=450m \
    MAX_BITRATE=500000 \
    START_BITRATE=300000 \
    VIDEOQUALITY_HD_THRESHOLD=480 \
    # Tắt tính năng không cần thiết
    ENABLE_RECORDING=0 \
    ENABLE_FILE_RECORDING_SERVICE=0 \
    DISABLE_HTTPS=1 \
    # Cấu hình timeout
    XMPP_KEEPALIVE_PING_TIMEOUT=30

# ========== CÀI ĐẶT PHỤ THUỘC ==========
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ========== XỬ LÝ CẤU HÌNH LINH HOẠT ==========
# 1. Copy .env với fallback
COPY --chown=jitsi:jitsi .env /defaults/.env
RUN if [ ! -f "/defaults/.env" ]; then \
      echo "Using default .env"; \
      touch /defaults/.env; \
    fi

# 2. Xử lý config.js thông minh
COPY --chown=jitsi:jitsi config.js /tmp/config.js 2>/dev/null || true
RUN if [ -f "/tmp/config.js" ]; then \
      mv /tmp/config.js /usr/share/jitsi-meet/; \
      echo "Custom config.js applied"; \
      # Cập nhật PUBLIC_URL vào config
      sed -i "s|https://.*onrender.com|$PUBLIC_URL|g" /usr/share/jitsi-meet/config.js; \
    else \
      echo "Using default config.js"; \
    fi

# 3. Xử lý custom interface
RUN mkdir -p /usr/share/jitsi-meet && \
    if [ -d "custom_interface" ]; then \
      cp -r --chown=jitsi:jitsi custom_interface/* /usr/share/jitsi-meet/; \
      echo "Custom interface applied"; \
      # Cập nhật URL trong các file tùy chỉnh
      find /usr/share/jitsi-meet -type f -exec sed -i "s|https://.*onrender.com|$PUBLIC_URL|g" {} \; || true; \
    else \
      echo "Using default interface"; \
    fi

# ========== THIẾT LẬP CUỐI CÙNG ==========
# Đảm bảo quyền thư mục
RUN chown -R jitsi:jitsi /usr/share/jitsi-meet

# Ghi log URL đang sử dụng
RUN echo "Jitsi Meet sẽ chạy tại: $PUBLIC_URL" > /url-info.txt

# Health check nâng cao
USER jitsi
HEALTHCHECK --start-period=90s --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:80/ || exit 1

EXPOSE 80

# Lệnh khởi động với logging
CMD echo "Khởi động Jitsi Meet tại $PUBLIC_URL" && \
    cat /url-info.txt && \
    /init