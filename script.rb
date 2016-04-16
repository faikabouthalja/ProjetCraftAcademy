#!/usr/bin/env ruby
#on ajoute les librairies pour json
require 'rubygems'
#update
system 'echo "updating..."'
system 'apt-get update -y  > log.txt && cat log.txt'

#installation module json pour ruby
puts 'installation module json'
system 'gem install json  >> log.txt && cat log.txt'
require 'json'

#lire le fichier json
json = File.read('info.json')
obj = JSON.parse(json)

#on met dans des variables les infos du fichier json
puts 'Parsing du fichier de configuration json'
$hostname= obj['hostname']
$baniere= obj['banniere']
$nameserver= obj['nameserver']

#pour tester, on lit ces variables
puts 'hostname: '.concat( $hostname.to_s)
puts 'banniere: '.concat($baniere.to_s)
puts 'Nameserver: '.concat($nameserver.to_s)

#configurer le hostname
cibleHost=File.open("/etc/hostname", "w+")
cibleHost.write($hostname.to_s)

#configurer la banniere d'accueil
cibleBaniere=File.open("/etc/motd","w+")
cibleBaniere.write($baniere.to_s)

#configurer le serveur DNS
cibleDNS=File.open("/etc/resolv.conf","a+")
cibleDNS.write("nameserver ".concat($nameserver.to_s))

#installation Nginx
puts 'Installation Nginx'
system 'apt-get install -y nginx >> log.txt && cat log.txt'
#enabling and restartiing nginx
system 'update-rc.d nginx defaults '
system 'service nginx restart >> log.txt && cat log.txt'

#installation redis
puts 'installation redis server'
system ' apt-get -y install -y redis-server >> log.txt && cat log.txt'
puts  'Demarrage de Redis....:'
system 'service redis-server restart >> log.txt && cat log.txt'
puts 'Etat:'
system ' service redis-server status'

#ajout du module redis pour ruby
system 'gem install redis >> log.txt && cat log.txt'
system 'apt-get install bundler >> log.txt && cat log.txt'
require 'redis'

#connexion a redis
redis=Redis.new(:host => 'localhost', :port => 6379)
chaine=""
#parsing du fichier log
fichier = File.open("log.txt", "r")
#on place contenu du fichier dans la variable chaine
fichier.each_line { |ligne|
chaine = chaine.concat"#{ligne}\n"
}
fichier.close
#on ajoute contenu dans la base redis
redis.set('logScript', chaine);
value = redis.get('logScript');
#afficher contenu dans la base redis
puts value

# Generation du fichier index.html
puts 'Generation du fichier html'
index=File.open("/usr/share/nginx/html/index.html","w+")
index.write("<!DOCTYPE html>
<html>
<head>
<title>My nginx Welcome Page</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body bgcolor=\"#E6E6FA\">
<h1>Cette page est servie par NGINX : Les logs du Script ruby stockes dans la base Redis </h1>
<p>#{value}</p>
<p><h2>See you soon...</h2></p>
</body>
</html>
")

#on redémarre nginx pour prendre en compte la nvlle page d acceuil nginx
system "service nginx restart"
