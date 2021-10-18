# Dokuwiki

## Getting Started

1. Write A-record on your domain.
2. Copy **.env.dist** to **.env** and make your modifications.
3. Start docker containers:

       $ docker-compose up -d

4. Copy **nginx.wiki.virtualhost.dist** to **/etc/nginx/sites-available/wiki.domain.com** and make your modifications. Create a symbolic link, then reload nginx. Run certbot to create LetsEncrypt certificate if needed and reload nginx again.

       $ sudo ln -s /etc/nginx/sites-available/wiki.domain.com /etc/nginx/sites-enabled/wiki.domain.com
       $ sudo systemctl restart nginx
       $ sudo certbot --nginx -d wiki.domain.com
       $ sudo systemctl restart nginx

5. After that open dokuwiki installer via browser: **https://wiki.domain.com/install.php** and follow instructions.

## Configure

1. LogIn and go to settings, change option "Use nice URLs" to ".htaccess", and check option "Use slash as namespace separator in URLs".
2. If you want hide button in footer go to storage/dokuwiki/lib/tpl/dokuwiki/tpl_footer.php and comment "<div class="buttons">" section.

## TODO

1. Create systemd unit.
2. Add to entrypoint.sh removing footer buttons.
3. Add to entrypoint.sh vendored plugins.
