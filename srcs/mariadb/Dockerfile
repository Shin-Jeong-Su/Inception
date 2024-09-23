# pull base image
FROM debian:bullseye

# update and upgrade
RUN apt update && apt upgrade -y

# install the required packages
RUN apt install -y mariadb-server

# copy file from host to container
COPY ./mdb_conf.sh /mdb_conf.sh

# set permissions to the filee
RUN chmod +x /mdb_conf.sh

# define entrypoint command to run when the container starts
ENTRYPOINT ["./mdb_conf.sh"]