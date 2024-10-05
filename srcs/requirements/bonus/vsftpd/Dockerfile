FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y openssl netcat vsftpd

#RUN openssl req -x509 -nodes -out /etc/ssl/certs/vsftpd.crt -keyout /etc/ssl/private/vsftpd.key -subj "/C=KR/ST=/L=Seoul/O=42/OU=42/CN=jeshin.42.fr/UID=jeshin"

COPY ./vsftpd.conf /etc/vsftpd.conf

EXPOSE 21 4559 4560 4561 4562 4563 4564

CMD ["vsftpd", "/etc/vsftpd.conf"]