FROM alpine:latest  
RUN apk --no-cache add ca-certificates
# forward request and error logs to docker log collector (nginx as an example)
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log
WORKDIR /root/
CMD ["ash"]  
