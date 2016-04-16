#!/usr/bin/env ruby
#on ajoute les librairies pour json
require 'rubygems'
require 'json'

system 'echo "updating..."'
#system 'apt-get update'
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

#update et upgrade
puts 'updating..'
#system 'apt-get update -y '

puts 'Installation Nginx'
system 'apt-get install -y nginx > /dev/null 2>&1'
#enabling and restartiing nginx
system 'update-rc.d nginx defaults > /dev/null 2>&1'
system 'service nginx restart'

puts 'installation redis server'
system ' apt-get -y install -y redis-server > /dev/null 2>&1'
puts  'Demarrage de Redis....:'
system 'service redis-server restart'
puts 'Etat:'
system ' service redis-server status'


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
<body>
<h1>Ceci est ma page d accueil pour nginx</h1>
<p>cette page est generee a partir de mon script ruby.</p>
</body>
</html>
")
system "service nginx restart"
