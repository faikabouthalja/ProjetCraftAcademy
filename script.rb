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

