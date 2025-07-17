#!/bin/bash

# Path to nginx config
NGINX_CONF="/etc/nginx/conf.d/default.conf"

# Check if APP_URL is set
if [ -z "$APP_URL" ]; then
    echo "APP_URL environment variable is not set."
    exit 1
fi

# Strip protocol (http:// or https://) from APP_URL
APP_URL="${APP_URL#*://}"

echo "Replacing server_name in Nginx configuration with APP_URL: $APP_URL"
# Replace server_name value with APP_URL
sed -i "s|^\s*server_name\s\+\S\+;|    server_name $APP_URL;|g" "$NGINX_CONF"


echo "Nginx configuration updated with APP_URL."

exec "$@"