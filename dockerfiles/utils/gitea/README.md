# Gitea

## Getting Started

1. Write A-record on your domain.  
2. Copy **.env.dist** to **.env** and make your modifications.  
3. Start docker containers:  

       $ docker-compose up -d
       
4. Copy **nginx.git.virtualhost.dist** to **/etc/nginx/sites-available/git.domain.com** and make your modifications. Create a symbolic link, then reload nginx. Run certbot to create LetsEncrypt certificate if needed and reload nginx again.  

       $ sudo ln -s /etc/nginx/sites-available/git.domain.com /etc/nginx/sites-enabled/git.domain.com
       $ sudo systemctl restart nginx
       $ sudo certbot --nginx -d git.domain.com
       $ sudo systemctl restart nginx

5. After that open gitea installer via browser: **https://git.domain.com** and fill the form according your .env settings. After setup is completed register a new user (use link from the navigation bar). The first registered user has admin privileges.  
6. TODO: Create systemd unit.  
7. TODO: Configure Drone.  
