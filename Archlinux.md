# TLP:

J'ai masqué systemd-rfkill.service (sudo systemd-rfkill.service) pour éviter tout conflit entre rfkill et tlp. voir archwiki TLP. Lors désinstallation de TLP démasquer le service.

# erreur Alsaclt restore at boot:

erreur: process /usr/bin/alsactl restore 0 failed exit code 99

apparement ça viendrais du fait que la commande /usr/bin/alsactl est démarée avant que /usr ne soit monté. lors du prochain upgrade de alsa, su diff dans /lib/udev/rules/90-alsa-restaure.rules accepter
changement de la première ligne avec ajout de TEST==...

