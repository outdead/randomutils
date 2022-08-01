# Focalboard

## Getting Started
1. Write A-record on your domain.
2. Copy **.env.dist** to **.env** and make your modifications.
3. Start docker containers:

       $ mkdir -p storage/focalboard/data
       $ sudo chown -R nobody storage/focalboard/data
       $ docker-compose up -d

4. Copy **nginx.focalboard.virtualhost.dist** to **/etc/nginx/sites-available/focalboard.domain.com** and make your modifications. Create a symbolic link, then reload nginx. Run certbot to create LetsEncrypt certificate if needed and reload nginx again.

       $ sudo ln -s /etc/nginx/sites-available/focalboard.domain.com /etc/nginx/sites-enabled/focalboard.domain.com
       $ sudo systemctl restart nginx
       $ sudo certbot --nginx -d focalboard.domain.com
       $ sudo systemctl restart nginx

## Configure
No Way.  

## TODO
1. Create systemd unit.
2. Add Dockerfile and customize css.
