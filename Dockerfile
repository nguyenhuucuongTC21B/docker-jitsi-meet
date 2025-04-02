


# Sử dụng image Jitsi Web chính thức MỚI NHẤT
FROM docker.io/jitsi/web:stable-8433

# Thiết lập môi trường
ENV ENABLE_AUTH=0 \
    PUBLIC_URL=https://docker-jitsi-meet-dtwo.onrender.com

# Cài đặt phụ thuộc
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Mở cổng và copy config
EXPOSE 80
COPY .env /defaults
