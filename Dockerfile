FROM golang:1.25.1
RUN apt update && apt install tzdata && cp /usr/share/zoneinfo/Europe/Helsinki /etc/localtime
RUN mkdir -p /app
COPY . /app
WORKDIR /app
RUN go build -C server .
EXPOSE 8080
CMD ["server/server", "-p", "8080"]
