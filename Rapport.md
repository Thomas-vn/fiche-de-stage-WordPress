# Rapport - Stage Wordpress

## Première partie : à propos de WordPress

### Qu'est-ce que Wordpress

Wordpress est un système de gestion de contenu (CMS) open-source et gratuit pour gérer et créer des sites webs ou blogs.

### WordPress est-il beaucoup utilisé ?

Environ 40% des sites web utilisent Wordpress, ce qui en fait le CMS le plus utilisé.

### Combien coûte WordPress ? 

Wordpress est gratuit d'utilisation. Son hébergement par Wordpress.com est en revanche payante.

### Quelle est la différence entre wordpress.com et wordpress.org

Wordpress.com permet de créer son site et de l'héberger sur un serveur distant (cloud). Wordpress.org représente la version open-source qui sera hébergée par nous-même.

### Qu'est-ce qu'un CMS 

CMS (Content Management System) est une application qui permet de créer, modifier et gérer des sites web ou plateforme, sans avoir de compétences techniques.

## Deuxième partie : installation locale

Installation effectuée avec l'aide de la documentation suivante : https://ubuntu.com/tutorials/install-and-configure-wordpress#1-overview

### De quoi WordPress a-t-il besoin pour fonctionner ?

Wordpress a été installé dans un environnement Windows WSL avec une distribution Ubuntu 22.04 Jammy LTS. Les étapes provenant donc de la documentation ont été suivies:

1. Installation des dépendances apache et php: 

```sh
sudo apt update
sudo apt install apache2 \
                ghostscript \
                libapache2-mod-php \
                mysql-server \
                php \
                php-bcmath \
                php-curl \
                php-imagick \
                php-intl \
                php-json \
                php-mbstring \
                php-mysql \
                php-xml \
                php-zip
```

2. Installation de Wordpress.org : 

```sh 
sudo mkdir -p /srv/www
sudo chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/
```

3. Configuration d'Apache pour Wordpress : 

Création d'un site Apache en local port 80 avec la configuration suivante: 

```sh
<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
```

4. Autorisation d'accès au site/url et désactivation par défaut pour éviter les conflits: 

```sh 
sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default
```

5. Création de la DB MySQL et du user : 

```sql
sudo mysql -u root

CREATE DATABASE <nom_db>;

CREATE USER wordpress@localhost IDENTIFIED BY '<your-password>';

GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER
    -> ON wordpress.*
    -> TO wordpress@localhost;

FLUSH PRIVILEGES;

quit
```

6. Configurer Wordpress et les accès à la DB : 

remplacer les champs dans le fichier /srv/www/wordpress/wp-config.php par le user crée :

```sh
sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php

sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/<your-password>/' /srv/www/wordpress/wp-config.php
```

Vérifier si tous les champs ont bel et bien été affectés :

```sh
sudo -u www-data nano /srv/www/wordpress/wp-config.php
```

changer les champs d'authentification suivants avec des accès générés aléatoirement à ce lien https://api.wordpress.org/secret-key/1.1/salt/ : 

```sh
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );
```

7. accéder au Wordpress en local :

Wordpress devrait être accessible au lien suivant : http://localhost.
Ensuite, configuer Wordpress.

### Eléments nécessaires pour que Wordpress puisse fonctionner correctement : 
- Machine avec WSL installé et une distribution Ubuntu plus récente que 20.04 LTS
- les prérequis `php` et `apache2`
- une DB MySQL configurée et accessible 

## Troisième partie : installation distante 

###  Procédure d’installation de WordPress sur une VM 

Comme à l'étape précédente, l'installation de Wordpress sur la VM a été effectuée avec l'aide de la documentation suivante : https://ubuntu.com/tutorials/install-and-configure-wordpress#1-overview

### Etapes nécessaires à l'installation

#### 1. Installation des dépendances 

```sh
sudo apt update
sudo apt install apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip
```

#### 2. Installation de Wordpress 

```sh
sudo mkdir -p /srv/www
sudo chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
```

#### 3.1 Configuration d'Apache pour Wordpress

```sh
<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
```

Activation du site : `sudo a2ensite wordpress`
Activation de le ré-ecriture de l'URL : `sudo a2enmod rewrite`
Désactivation du site par défaut : `sudo a2dissite 000-default`

#### 4. Configuration de la DB

Il existe 2 configurations possibles pour créer un utilisateur MySQL : par interface graphique ou alors par CLI. Dans notre cas, nous allons y procéder par CLI:

1. Accès à la DB avec l'utilisateur root : `sudo mysql -u root`
2. Créer une nouvelle DB : `CREATE DATABASE <nom_db>;`
3. Création d'un utilisateur : `CREATE USER <user_name>@localhost IDENTIFIED BY '<your-password>';`
4. Donner des droits : `GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER` `ON wordpress.*` `TO wordpress@localhost;` `FLUSH PRIVILEGES;` et `quit`

#### 5. Configuration de Wordpress à la DB

Ajouter les champs suivants avec la modification du mot de passe crée au point précédent :

```sh
sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/<your-password>/' /srv/www/wordpress/wp-config.php
```

#### 6. Accéder à l'interface Wordpress

Accéder à l'interface par l'IP depuis un navigateur : `http://<ip_de_la_vm>`. Puis se connecter avec le compt crée

#### Problèmes rencontrés avec l'installation de Wordpress à distance : 
- configuration d'Apache2, notamment avec le fait que l'application soit écoutée sur le port 80 -> solution : changer la configuration des ports d'écoute : 
`sudo nano /etc/apache2/ports.conf`
- accessibilité à l'ip via un navigateur (dans mon cas Google Chrome/Brave) 

### 3.2 Side Quest : installation de phpmyadmin, accessible par un autre port 

#### 1. Mettre à jour les paquets installés & installation de phpMyAdmin

```sh 
sudo apt upgrade && sudo apt install phpmyadmin
```

#### 2. Ajout du port d'écoute dans `/etc/apache2/ports.conf`

```sh 
Listen 8080
```

PhpMyAdmin sera accessible par le port 8080.

#### 3. Ajout de la configuration d'Apache pour l'accès à PhpMyAdmin 

```sh
<VirtualHost *:8080>
    DocumentRoot /srv/share/phpmyadmin
    <Directory /srv/share/phpmyadmin>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/share/phpmyadmin>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
ubuntu@wp-thomas:/etc/a
```

#### 4. Redémarrer Apache2 et vérifier si la configuration tourne correctement

```sh 
sudo systemctl restart apache2
sudo ss -tulnp | grep :8080
```

L'URL est maintenant accessible via le lien suivant : http://<ip_vm>:8080/phpmyadmin. 

