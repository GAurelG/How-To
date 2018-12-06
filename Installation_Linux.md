# Installation de Linux, conseil, march à suivre

## Préparation du SSD/HDD

### formater et partitionner le disque:

Formater avant installation pour avoir un disque propre et éviter les soucis des installateurs.
Séparer la partition Donné (/home) de la racine (/) pour que les données soient séparées du 
système. Pour un ordinateur de Bureau sans Dual boot:
- partition système n°1 ~20-30 Go
- partition système n°2 ~20-30 Go (pour avoir un secon système d'installé, faire des tests...)
- partition swap 1 à 2 Go pour être tranquille en cas de remplissage de la RAM
- partition /home aussi grosse que voulue

2016 --> je formate en ext4, je n'ai pas encore testé d'autre système de fichier
     --> utiliser ntfs pour les partitions données partagées avec windows et HDD externes
     --> utiliser FAT 32 pour clé USB et microSD (en espérant un meilleur standard)

Le disque doit être partitionné avec un MBR si la machine utilise un BIOS. Le nouveau 
standard GPT doit être utilisé pour les machines avec UEFI (post 2011), il peut être utilisé 
sur les machines avec BIOS mais dans de rare cas ce n'est pas compatible.

### Pour les SSD:

Comme pour les HDD les partitions sur SSD doivent être alignée mais pas aux mêmes limites que 
les HDD. Normalement les outils de partitionement doivent le faire d'office et aucune action 
spécifique n'est requise. Pour vérifier que les partitions sont alignée on peut utiliser 
gparted. clique droit sur la partition et regarder le n° du premier bloc, diviser par 2048 
si on obtient un chiffre entier alors on est aligné.
Parfois les SSD ne sont pars reconnus par les BIOS ou UEFI. Dans ce cas il est possible de 
changer l'option SATA de IDE en AHCI. En fonction des Bios ou UEFI cette option peux se 
trouver à différents endroits. Si l'option est introuvable le BIOS/UEFI devrait détecter 
tout seul le SSD et faire la modification automatiquement. Un endroit à regarder peut être:
--> Advanced > Integreted peripherals > SATA configuration changer IDE en AHCI.
L'option peut-être à changer à plusieurs endroits.

Vérifier si le SSD a besoin d'une mise à jour de son firmware.

## Installation du système:

Installer la distribution souhaitée.
2016 --> linux mint 18 

### Si Dual boot avec windows

Mettre le /boot à la racine du disque, l'installateur se chargera de se mettre au bon endroit

#### Si windows boot automatiquement et grub ne s'installe pas:

Dans windows, ouvrir une cmd.exe en mode administrateur (powershell)

1. entrer la commande:
    bcdedit /enum firmware
2. Trouver le chemin du bootloader pour grub 
   (ordi de Fiona: \EFI\ubuntu\grubx64.exe, mais peut être shimx64.exe)
3. entrez la commande:
    bcdedit /set {bootmgr} path \EFI\...\...exe
    bcdedit /set {bootmgr} path \EFI\ubuntu\grubx64.exe (pour sony vaio Fiona)
4. Enjoy!

#### Réglage de l'horloge:

Windows sauvegarde le temps en heure locale sur l'horloge physique de la machine.
Linux sauvegarde le temps en UTC (=GMT). Donc en cas de dual boot si on ne se trouve pas
à l'heure du méridien de greenwich, windows démarre avec un décalage horaire. Le moyen le
plus simple de régler le soucis est de demander à linux de sauvegarder l'heure en heure 
locale. Pour se faire:

éditer: /etc/default/rcS
ajouter: 
    # Set UTC=yes if your hardware clock is set to UTC (GMT)
    UTC=no
 
Ubuntu 15.04 systems and above (e.g. Ubuntu 16.04 LTS):

    open a terminal and execute the following command

    timedatectl set-local-rtc 1

#### Dans windows, désactiver fastboot et utiliser:

    powercfg.exe -h off
    
dans une console administrateur pour enlevé l'hibernation et permettre à ubuntu d'accéder à la 
partition windows.
l'option fastboot se trouve dans panneau de configuration > système > énergie > que fait le bouton 
de mise en marche.


##Après l'installation:

### Swapiness:

Il est important de changer la swapiness de 60 à 10 (ou moins). la swapiness correspond à la proportion du 
système à décharger la RAM sur le HDD/SSD. Elle est notée de 0 à 100, 0=ne jamais transférer 
sur le disque et 100=toujours swaper.
la valeur de swapiness est inscrite dans: /proc/sys/vm/swappiness
exécuter "cat /proc/sys/vm/swappiness" donne la valeur affectée pour la swappiness.
pour changer cette valeur:
mofifier /etc/sysctl.conf et ajouter:
    # Sharply reduce the inclination to swap
    vm.swappiness=1

### Pour SSD:

Ajouter l'option "noatime" sur la ligne de boot de chaque partition (sauf la swap) dans "/etc/fstab". 
Cette option permet d'empêcher d'écrire la date de dernier accès aux fichier si ils ont simplement été 
lu. Si le fichier est modifié, cette date est changée. Ca permet d'économiser des cycles d'écriture.
La nouvelle ligne dans le /etc/fstab doit ressembler à:

UUID=xxxxx   /   ext4 noatime,errors=remount-ro   0   1

Il faut bien faire attention à ne pas ajouter d'espace après la virgule de noatime sinon on risque des 
problèmes au démarage.

Il faut bien vérifier que la distribution va TRIM le SSD. Vérifier pour les SSD antérieurs à 2010 
que l'option est possible:
    # hdparm -I /dev/sda | grep TRIM
        *    Data Set Management TRIM supported (limit 1 block)
Si le disque est compatible avec cet option, vérifier que la distribution l'utilise régulièrement.
Certains conseillent de le faire 1 fois par semaine d'autre 1 fois par jour, regarder les performances 
des SSD et se faire un avis. Les moyen de TRIM le SSD sont:
- manuellement: sudo fstrim -v /
- avec un CRON job (weekly or daily) méthode de linux mint. pour passer de weekly à daily:
 + sudo mv -v /etc/cron.weekly/fstrim /etc/cron.daily
- en utilisant le service systemd. systemctl enable fstrim.timer
- !!!! ne pas utiliser l'option discard dans le fstab (comme noatime avant), ça permet de faire 
  un TRIM continu mais ça peut poser des soucis avec certains SSD alors privilégier un TRIM régulier.

### Crucial MX100 et certain SSD:

L'alimentation peut parfois avoir des soucis si TLP (ou laptop mode tool) est installé.

1. vérifier si TLP est installé et en fonctionnement: tester la commande #tlp-stat
2. Si la commande renvois des informations, retourner en haut de la liste, ou faire #tlp-stat -c pour voir la configuration utilisée.
3. chercher `SATA_LINKPWR_ON_BAT=` si la variable a pour valeur: min_power, il se peut (avec le crucial MX100) que le SSD manque d'énergie dans certains cas de figure.
4. éditer le fichier de configuration de tlp (voir tlp-stat -c pour Fiona c'était: /etc/default/tlp). Changer `SATA_LINKPWR_ON_BAT=min_power` et remplacer min_power par medium_power ou max_performance
5. redémarrer tlp ou l'ordi et tout devrais être bien.

### Scheduler:

Il est recommandé d'utiliser le scheduler "deadline" (pour HDD et SSD). pour vérifier le scheduler:
cat /sys/block/sda/queue/scheduler (avec le /sda/ changé si nécéssaire pour le disque à vérifier)
doit retourner: noop [deadline] cfq
Si deadline n'est pas entre les crochets, on peut l'activer en changeant /etc/default/grub
il faut changer la ligne: GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
en: GRUB_CMDLINE_LINUX_DEFAULT="elevator=deadline quiet splash"
ensuite sauvegarder et lancer la commande: sudo update-grub puis redémarrer

### Hibernation:

désactiver l'hibernation pour les ordi utilisant un SSD. Pour linux mint il faut:
sudo mv -v /etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla /
À voir si c'est vraiment nécéssaire il doit être possible de le désactiver dans les 
paramètres.
pour d'autres système j'ai lus de regarder dans:
 nano /usr/share/polkit-1/actions/org.freedesktop.upower.policy

### KDE:

make sddm use HiDPI settings, edit the config file in /etc/sddm.conf.d and insert:
    
    ```[General]
    Numlock=on
    [wayland]
    EnableHiDPI=true
    [x11]
    EnableHiDPI=true```

### KDENeon:

They use two package managers, apt and pkcon it is better to use the second one as it
will update all their software, and apt can be missing some packages from KDE.

### HiDPI:

The Archwiki has really good information about settings. For KDE I had to change the parameters:

- font size
- icon size: need to be adjusted for each Icon category
- scale the display in display and monitor

To scale the panel I have to set the environment variable:
    `PLASMA_USE_QT_SCALING=1`


### Pour enlever le logo Nvidia:

faire une recherche, il faut soit édter /etc/Xorg/xorg.conf
soit lancer la commande: sudo nvidia-xconfig --no-logo et ça se fait tout seul.

### Firefox:

- Déconnecter l'ancien firefox (de l'ancien disque)
- sauvegarder les groupes d'nglets et les règles µblock (si besoin)
- Se connecter au compte firefox
- Installer les modules: µblock
	not always activated but coul be usefull: OneTab,  noscript, Gnotifier, KDE integration
        deactivated because evil: wot, Ghostery
        not available, used:  better privacy/ tab_group /
- restaurer les config sauvegardées (si besoin)
- Pour les SSD, il est possible de limiter l'utilisation du cache par firefox:
   paramètres > avancé > Network
- Sur linux mint, changer le profil par défault est une bonne idée: firefox -P
  ensuite avec le gestionnaire de profil créer le nouveau profil
 
### Chrome/Chromium:
-Il est possible de limiter l'utilisation du cache, utiliser un lanceur personalisé:
  chromium-browser --disk-cache-size=1 --media-cache-size=1

### Thunderbird:

- Importer le profil Thunderbird:
  + copier le contenu de ~/.thunderbird/XXXXXXX.name dans le nouveau profil.
  le plus sécurisant c'est de démarrer le gestionnaire de profil: thunderbird -P
  et de faire un nouveau profil vide, comme ça on copie des choses vides
- ajouter les extensions: lightning + se connecter au calendrier, avec la copie
  de profil, ça se fait automatiquement!
                          Thunderbird conversations
                          Gnotifier (si besoin)

### Evolution:

Pour transférer Evolution d'un ordinateur à un autre il faut utiliser le plugin "backup and restore".

### SSH:

enplacement personnel des info ssh: /home/aurelien/.ssh/
créer un clée: ssh-keygen -t rsa -C "email@email.com"
elle sera sauvegardée sous: /home/aurelien/.ssh/id_rsa	et id_rsa.pub
on peut avoir plusieurs clé ssh, pour cela, les enregistrer sous d'autres nom de fichier.
La clé privvée est personnelle et doit être conservée et pas partagée.
La clé publique (celle contenue dans le fichier finissant par ".pub") est la clé qui 
doit être transmise au serveur.

Sur le serveur: créer un dossier /home/server_user/.ssh/ et lui mettre les droits: 700 
Créer le fichier "authorized_keys" dans ce dossier et coller la clé publique.
coller la sortie de cat /home/aurelien/id_rsa.pub (ou la clé à utiliser).

Sur le serveur, on doit aussi changer la configuration /etc/ssh/sshd_config
retirer la possibilité d'utiliser un mot de passe et empêcher l'accès root.
mettre la possibilité d'utiliser le XForwarding

Pour utiliser plusieurs clé ssh il faut en générer plusieurs dans différents fichier.
Ensuite mettre la clé publique correspondant à chaque service à utiliser.
Il faut ensuite créer le fichier: /home/aurelien/.ssh/config 
exemple de remplissage pour github et bitbucket:

Host nomd'hôte
 HostName github.com
 User git
 IdentityFile ~/.ssh/id_rsa_github

Host nomd'hôte
 HostName bitbucket.org
 User git
 IdentityFile ~/.ssh/id_rsa_bibucket

On se connecte en faisant: ssh -T git@nomd'hôte
A voir comment ça fonctionne correctement!
A voir comment on détermine le User dans le fichier!

### Pulseaudio

Pour avoir une bonne maitrise du son de pulseaudio, installer pavu-control
Lire archwiki:
https://wiki.archlinux.org/index.php/PulseAudio/Troubleshooting#Static_noise_in_microphone_recording

Pour améliorer le son enregistré par le micro et éliminer une partie des 
bruits ambiant il faut activer le module: module-echo-cancel. Pour cela:
tester si le module est présent: pacmd list-modules | grep echo
si on veux voir plus, on peux exécuter pacmd puis list-modules et chercher dans la liste
Pour l'activer il faut éditer /etc/pulse/default.pa et ajouter les lignes:
	### Enable Echo/Noise-Cancelation
	load-module module-echo-cancel

ensuite il suffit de redémarer pulseaudio: pulseaudio -k
pulseaudio --start
normalement maintenant la commande pacmd list-modules | grep echo doit donner un résultat.

if pulseaudio doesn't start with an error about module-echo-cancel:
try to change the default hardware profile in pavucontrol to "duplex"

### Snaps:

these apps are installed in a  ~/snap/... directory.
To manage there permission, look at the documentation on the snapcraft website.
look into the snap interfaces ... and the snap connect ... commands to manage it.

### Liste de logiciels:

- redshift
- lm-sensor
- transmission
- mpv
- VLC
- vim?
- LOL
- playonlinux
- chromium?
- gthumb
- cheese
- shutter
- brasero
- R/RStudio/Rcommander
- Banshee
- Handbrake
- Sound Juicer
- sound Converter
- Cairo-Doc
- conky
- multisystèmeUSB
- KDEConnect?
- Grsync
- pass?
- tilda?
- samba?
- Jupyter-notebook (ne pas oublier jupyter-nbconvert pour pouvoir exporter)
- BleachBit?

### Conky:

Installer Conky, mettre le fichier .conkyrc dans /home.
activer au démarrage (soit paramètres soit avec ~/.config/autostart/conky)

### Redshift:

activer au démarrage (paramètres ou ~/.config/autostart/redshift)
j'utilise:
redshift -l 51.00:9.0 
Ça fait se comporter l'écran comme si j'était au milieu de l'allemagne.

### Activer le pavé numérique au démarrage:

Soit peut le faire dans le bios, soit on peut le faire en installant numlockx.

### Pare-Feu:

Activer le pare-feu au démarrage. sudo systemctl enable ufw

### Libreoffice:

Mettre le thème d'icones sifr, human semble correct.

### Jupyter-notebook:

aussi appelé Ipython notebook. installer le packet trouvé.
pour linux Mint/Ubuntu:
installer les paquets:
        sudo apt install buil-essential
- pour python2:
        sudo apt install ipython python-pip python-dev python-setuptools

- pour python3
        sudo apt install ipython3 python3-pip python3-dev python3-setuptools

ensuite utiliser
        sudo -H pip install jupyter
        sudo -H pip3 install jupyter
        
J'ai un un soucis avec l'installation, peut-être faire uniquement l'installation en python3 
installer le paquet ipython3-notebook pour être tranquille, ensuite installer le noyaux 
en python2:
        sudo ipython kernel install

J'ai essayé avec le paquet ipython-notebook mais j'ai une erreur, probablement
parceque je n'ai pas installé tous les paquets conseillés. Mais le paquage est 
aussi trop ancien.version 2.... contre version 4....
Le fait d'utiliser sudo -H est à voir, je ne suis pas convaincu de son utilité/nécéssité.
Sous archilunx, utiliser pacman et tout roule!!! :)
Pour exporter il ne faut pas oublier d'installer "pandoc"

### Python:

installer:
- matplotlib
- numpy
- pandas (et pandas-doc)
- scipy (et scipy-doc)
- seaborn
- statsmodel (apparement n'est pas installable avec apt?)

### Tmpfs:

On peut utiliser un tmpfs grâce au fstab(apparement sur archlinux c'est par défaut. Je ne le fait pas 
sur le gros ordi au début, ça va utiliser de la RAM et j'ai la flemme. On verra comment ça évolue.

### mots de passe:

utiliser keepassX

### Gestion clé GPG

### Chiffrement du disque

### Virtualisation

### Accès à distance

### Additional fonts

sudo apt install `ttf-mscorefonts-installer`

### hp printer

install "hplip"

### Polices:

Installer ttf-microsoft
copier les polices intéressantes de /usr/share/fonts (surtou les amaze et janda cheerful)
il y en a aussi dans ~/.fonts/
Ajouter les polices microsoft et autres polices

### Telegram:

To make telegram start at boot in tray, add to the ~/.config/autostart/ (for freedesktop compliant
 desktop) the telegramdesktop.desktop file. And the Exec command should be `Telegram -startintray` 

### Gestion des sauvegardes:

Les choses à Sauvegarder:
- Firefox:
  + une session de groupTab pour firefox
  + bookmark de firefox
  + la liste blanche de µBlock

- Thunderbird:
  + fichier de configuration
  
- linux:
  + /home (on peut jeter un certain nombre de choses mais en première approche)
  + faire une liste 
