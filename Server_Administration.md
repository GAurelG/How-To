# Some indications on how to administer personal servers:

## APACHE config:

## OpenSSL:

1. To create a self signed OpenSSL certificate see Digital Ocean how to.
I enabeled the a2enmod mode for Apache:

  `sudo a2enmod ssl`

  then restart Apache

2. Create a new key and self signed certificate:

  `sudo openssl req -X509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt`

    - **openssl**: commande for openssl
    - **req**: This specifies a subcommand for X.509 certificate signing request (CSR) management. X.509 is a public key infrastructure standard that SSL adheres to for its key and certificate managment. Since we are wanting to create a new X.509 certificate, this is what we want.req: 
    - **x509**:  This option specifies that we want to make a self-signed certificate file instead of generating a certificate request.
    - **nodes**: This option tells OpenSSL that we do not wish to secure our key file with a passphrase. Having a password protected key file would get in the way of Apache starting automatically as we would have to enter the password every time the service restarts.
    - **days 365**: specify validity lenght of the certificate
    - **newkey rsa:2048**: This option will create the certificate request and a new private key at the same time. This is necessary since we didn't create a private key in advance. The rsa:2048 tells OpenSSL to generate an RSA key that is 2048 bits long.
    - **keyout**: This parameter names the output file for the private key file that is being created.
    - **out**: This option names the output file for the certificate that we are generating.

  We placed the certificate in ***`/etc/apche2/ssl/apache.crt`***
  We placed the private key in ***`/etc/apache2/ssl/apache.key`***

3. Then configure apache2 (change stuffs in the file `/etc/apache2/sites-available/default-ssl.conf`)

### Renew Self Signed Certificate:

1. We will use the old key (for now located in /etc/apache2/ssl/apache.key)
  and replace the apache.crt file with our new key, then restart apache

2. Create new certificate with existing key:

  `openssl req -key *domain.key* -new -x509 -days 365 -out *domain.crt*`
  
  change domaine.key and domain.crt to the key and certificate i want.

3. restart apache (`sudo service apache2 restart` on ubuntu 14.04)  

Next is the link to a really good openSSL cheatsheet:
[openSSL cheatsheet](https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs)

