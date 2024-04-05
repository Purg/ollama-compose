# Resources
1. `https://gist.github.com/dahlsailrunner/679e6dec5fd769f30bce90447ae80081`
2. `https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04`
3. `https://www.tecmint.com/find-my-dns-server-ip-address-in-linux/`
4. `https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html`

# 1
`openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout ./nginx-selfsigned.key -out ./nginx-selfsigned.crt`

Question Answers Used:
- Country Name (2 letter code) [AU]:US
- State or Province Name (full name) [Some-State]:New York
- Locality Name (eg, city) []:Clifton Park
- Organization Name (eg, company) [Internet Widgits Pty Ltd]:Kitware, Inc.
- Organizational Unit Name (eg, section) []:Computer Vision
- Common Name (e.g. server FQDN or YOUR name) []:rivellon.kitware.com
- Email Address []:paul.tunison@kitware.com

# 2
`openssl dhparam -out ./dhparam.pem 4096`
This takes a while when using 4096...

# 3
Can determine local DNS servers via `systemd-resolve --status` and looking for
the `DNS Servers` section. This should list the IP addresses of our DNS
servers.
* 10.83.83.25
* 10.83.83.26

Instead of creating file `ssl-params.conf`, just incorporated into nginx config
Content from Resource #2 seems to be out of date relative to info on #4.
Written file here an attempt to update the example.

