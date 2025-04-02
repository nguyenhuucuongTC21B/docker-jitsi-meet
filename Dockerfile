# Sử dụng image Jitsi chính thức MỚI NHẤT
FROM jitsi/web:latest

# Cài đặt các phụ thuộc cần thiết
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl && \
    rm -rf /var/lib/apt/lists/*

# Copy cấu hình
COPY .env /defaults
EXPOSE 80
