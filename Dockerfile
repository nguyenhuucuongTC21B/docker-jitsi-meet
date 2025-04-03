# Sử dụng image đã được kiểm tra hoạt động trên Render (07/2024)
FROM docker.io/jitsi/web:stable-8120

# Thiết lập biến môi trường tối ưu cho Render Free Tier
ENV ENABLE_AUTH=0 \
    PUBLIC_URL=https://your-render-url.onrender.com \
    ENABLE_XMPP_WEBSOCKET=0 \
    JVB_MAX_MEMORY=512m \
    MAX_BITRATE=500000 \
    START_BITRATE=300000 \
    VIDEOQUALITY_HD_THRESHOLD=480

# Cài đặt phụ thuộc tối thiểu (tối ưu dung lượng image)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy config theo thứ tự ưu tiên (giảm số layer)
COPY --chown=jitsi:jitsi \
    .env \
    config.js \
    /defaults/

# Copy giao diện tùy chỉnh (nếu có)
COPY --chown=jitsi:jitsi custom_interface/ /usr/share/jitsi-meet/

# Thiết lập quyền và health check
USER jitsi
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:80 || exit 1

EXPOSE 80
