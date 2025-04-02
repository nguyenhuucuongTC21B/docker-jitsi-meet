# Lấy image chính thức từ Jitsi
FROM jitsi/web:latest

# Mở cổng 80 (Render chỉ hỗ trợ port 80/443)
EXPOSE 80

# Tắt các service không cần thiết để tiết kiệm RAM
RUN rm /etc/cont-init.d/10-config && \
    echo "ENABLE_XMPP_WEBSOCKET=0" >> /defaults/web/config

# Copy file cấu hình từ local (nếu có)
COPY .env /defaults
