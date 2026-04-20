FROM nginx:alpine
COPY frontend/ /usr/share/nginx/html/
COPY docker/entrypoint.sh /docker-entrypoint.d/40-config.sh
RUN chmod +x /docker-entrypoint.d/40-config.sh
EXPOSE 80
