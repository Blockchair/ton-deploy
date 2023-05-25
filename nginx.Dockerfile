FROM nginx as nginxBuilder
RUN apt-get update && \
    apt install net-tools -y && \
    apt install iputils-ping -y

RUN mkdir -p /etc/nginx/sites-enabled/ 

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/api.conf /etc/nginx/sites-enabled/api.conf  


ENTRYPOINT ["nginx", "-g", "daemon off;"]
