#!/bin/bash

#---------------ping mariadb---------------
# check if mariadb container is up and running
ping_mariadb_container() {
    nc -zv mariadb 3306 > /dev/null #ping the mariadb container
    return $? #return the exit status of the ping command
}
start_time=$(date +%s) #get the current time in seconds
end_time=$((start_time + 20)) #set the end time to 20 seconds after the start time
while [ $(date +%s) -lt $end_time ]; do
    ping_mariadb_container
    if [ $? -eq 0 ]; then
        echo "[=======MARIADB IS UP AND RUNNING=======]"
        break
    else
        echo "[=======WATTING FOR MARIADB TO START...=======]"
        sleep 1
    fi
done

if [ $(date +%s) -ge $end_time ]; then
    echo "[=======MARIADB IS NOT RESPONDING=======]"
fi

#---------------wp installation---------------
# wp-cli install
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
# wp-cli permission
chmod +x wp-cli.phar
# wp-cli move to bin
mv wp-cli.phar /usr/local/bin/wp

# go to wordpress directory
cd /var/www/wordpress
# give permission to wordpress directory
chmod -R 755 /var/www/wordpress/
# change owner of wordpress directory to www-data
chown -R www-data:www-data /var/www/wordpress

# download wordpress core files
wp core download --allow-root
# create wp-config.php file with database details
wp core config --dbhost=mariadb:3306 --dbname="$MYSQL_DB" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --allow-root
# install wordpress with the given title, admin username, password and email
wp core install --url="$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_N" --admin_password="$WP_ADMIN_P" --admin_email="$WP_ADMIN_E" --allow-root

# Install Redis Object Cache plugin
wp plugin install redis-cache --activate --allow-root
# Add Redis configuration to wp-config.php
echo "define( 'WP_CACHE_KEY_SALT', '$DOMAIN_NAME' );" >> wp-config.php
echo "define( 'WP_REDIS_HOST', 'redis' );" >> wp-config.php
echo "define( 'WP_REDIS_PORT', 6379 );" >> wp-config.php
echo "define( 'WP_REDIS_TIMEOUT', 1 );" >> wp-config.php
echo "define( 'WP_REDIS_READ_TIMEOUT', 1 );" >> wp-config.php
echo "define( 'WP_REDIS_DATABASE', 0 );" >> wp-config.php

# create a new user with the given username, email, password and role
wp user create "$WP_U_NAME" "$WP_U_EMAIL" --user_pass="$WP_U_PASS" --role="$WP_U_ROLE" --allow-root

#---------------php config---------------
# change listen port from unix socket to 9000
sed -i '36 s@/run/php/php7.4-fpm.sock@9000@' /etc/php/7.4/fpm/pool.d/www.conf
# create a directory for php-fpm
mkdir -p /run/php
# start php-fpm service in the foreground to keep the container running
/usr/sbin/php-fpm7.4 -F