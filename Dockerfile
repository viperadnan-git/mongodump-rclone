FROM ubuntu

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    unzip \
    tzdata
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor
RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
RUN apt-get update && apt-get install -y \
    mongodb-org-tools
RUN curl https://rclone.org/install.sh | bash

COPY . .

CMD [ "bash", "entrypoint.sh" ]