FROM alpine:3.19

LABEL version="0.0.1" 
RUN apk update \
  && apk upgrade \
  && apk --no-cache add curl jq

COPY entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
