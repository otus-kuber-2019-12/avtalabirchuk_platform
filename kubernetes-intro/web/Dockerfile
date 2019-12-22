FROM nginx:stable
RUN groupadd --gid 1001 otus \
  && useradd --uid 1001 -g root -G sudo --shell /bin/bash -m otus

ADD /kubernetes-intro/web/conf.d /etc/nginx/conf.d
RUN sed -i 's/user  nginx/user otus/' /etc/nginx/nginx.conf
RUN chmod -R 777 /var/cache/* && chmod -R 777 /var/run/
COPY /kubernetes-intro/web/app /app

WORKDIR /app
USER otus
CMD /usr/sbin/nginx -g 'daemon off;'