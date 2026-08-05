#!/bin/bash
set -euo pipefail

dnf update -y
dnf install -y nginx awscli

cat >/usr/share/nginx/html/index.html <<HTML
<!doctype html>
<html>
  <head><title>${app_name}</title></head>
  <body>
    <h1>${app_name}</h1>
    <p>Environment: ${environment}</p>
    <p>Served from an Auto Scaling Group managed by Terraform.</p>
  </body>
</html>
HTML

systemctl enable nginx
systemctl start nginx
