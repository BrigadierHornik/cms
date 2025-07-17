#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

# Define working directory
WORKDIR=/app/backend

# Change to the Laravel project directory
cd $WORKDIR



# 1. Install/Update Composer Dependencies (Optional but recommended)
composer install --no-interaction --prefer-dist --optimize-autoloader
echo "Composer dependencies installed."

# 2. Check if .env file exists after making sure vendor directory is present
if [ ! -f ".env" ]; then
  # If .env file does not exist, create it
  # Check if .env file exists
    echo "Creating .env file..."
    # Copy .env.example to .env
    cp .env.example .env
    echo ".env file created."

    # Generate Laravel application key
    echo "Generating Laravel application key..."
    php artisan key:generate
    echo "Application key generated."
else
  echo ".env file already exists. Skipping creation and key generation."
fi

# 3. Modify .env file with variables from Docker Compose environment
echo "Updating .env variables from Docker environment..."

# Use sed to replace values. Check if the Docker env var is set first.
# Example for DB_HOST:
# - The `|` is used as a delimiter for sed to avoid issues if values contain `/`.
# - `^DB_HOST=` matches lines starting with DB_HOST=.
# - `.*` matches the rest of the line.
# - `${DB_HOST:-laravel_db}` uses the Docker env var `DB_HOST` or defaults to `laravel_db` if unset/empty. Choose appropriate defaults.
# Define the variables you want to update
ENV_VARS="DB_CONNECTION DB_HOST DB_PORT DB_DATABASE DB_USERNAME DB_PASSWORD"

# Loop through each variable and update it in the .env file
for VAR in $ENV_VARS; do
    # 1) If it’s already defined (uncommented), update it in place.
    if grep -q "^$VAR=" /app/backend/.env; then
        sed -i "s|^$VAR=.*|$VAR=${!VAR//\\/\\\\}|" /app/backend/.env

    # 2) Else if it’s present but commented out (e.g. "#FOO=…" or "# FOO=…"), remove the “#” and overwrite.
    elif grep -q "^[[:space:]]*#[[:space:]]*$VAR=" /app/backend/.env; then
        sed -i "s|^[[:space:]]*#[[:space:]]*$VAR=.*|$VAR=${!VAR//\\/\\\\}|" /app/backend/.env

    # 3) Otherwise, append a fresh line "VAR=value" at the end.
    else
        echo "$VAR=${!VAR}" >> /app/backend/.env
    fi
done


APP_KEY_VALUE=$(grep -q "^APP_KEY=" .env | cut -d '=' -f2-)

if [ ! -z $APP_KEY_VALUE]; then
    echo "APP_KEY already set in .env file. Skipping key generation."
else
    echo "Generating Laravel application key..."
    php artisan key:generate
    echo "Application key generated."
fi

JWT_SECRET_VALUE=$(grep -q "^JWT_SECRET=" .env | cut -d '=' -f2-)

if [ ! -z $JWT_SECRET_VALUE ]; then
    echo "JWT_SECRET already set in .env file. Skipping JWT secret generation."
else
    echo "Generating JWT secret..."
    php artisan jwt:secret --force
    echo "JWT secret generated."
fi


# Add more sed commands for other variables you need to override (e.g., REDIS_HOST, MAIL_HOST)

echo ".env variables updated."

# 4. Run Database Migrations (Optional but common)
# Using --force to run in non-interactive mode
echo "Running database migrations..."
php artisan migrate --force
echo "Database migrations complete."

# 5. Optimize Laravel (Optional - Be cautious with caching config/routes)
# Caching config means .env changes and Docker env vars won't be read until cache is cleared
# Uncomment if you understand the implications and need the performance boost
# echo "Caching configuration..."
# php artisan config:cache
# php artisan route:cache
# php artisan view:cache

# 6. Fix Permissions (If needed, depends on your base image user)
# If your web server/php-fpm runs as www-data, ensure it owns storage and bootstrap/cache
#echo "Setting permissions..."
#chown -R www-data:1000 /app/backend
#chmod g+rw -R /app/backend

# 7. Execute the main container command (passed from CMD in Dockerfile)
# "$@" allows arguments passed to the entrypoint script (like the CMD) to be executed
echo "Starting the main application process..."

# Execute the original command
exec "$@"