FROM nginx:1.21.3

# Добавляем пользователю nginx права
RUN     chown -R nginx:nginx /var/cache/nginx && \
        chown -R nginx:nginx /var/log/nginx && \
        chown -R nginx:nginx /etc/nginx/conf.d
RUN     touch /var/run/nginx.pid && \
        chown -R nginx:nginx /var/run/nginx.pid

# Копируем исправленный конфигурационный фаил
COPY ./default.conf /etc/nginx/conf.d/default.conf

# Переключаем пользователя
USER nginx