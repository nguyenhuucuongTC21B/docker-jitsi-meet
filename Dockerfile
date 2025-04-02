# Sử dụng image chính thức mới nhất của Jitsi
FROM jitsi/web:stable-8195

# Mở cổng 80
EXPOSE 80

# Tối ưu cho Render Free
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl && \
    rm -rf /var/lib/apt/lists/*

# Copy file cấu hình
COPY .env /defaults
