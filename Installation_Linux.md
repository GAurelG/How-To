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

### HardDrive + SSD set up:

J'ai un SSd et un HDD pour gérer les emplacements des disques et leur mapping, utiliser le /etc/fstab
 pour monter les disques. Utiliser `sudo blkid /dev/...` pour retrouver les infos sur les disques.
J'ai remarqé que mettre tout le /home sur le HDD semble provoquer des ralentissements lorsque les
différentes applications entrent en compétition pour accéder à leurs fichiers de configurations...
Ma solution possible est de toujours avoir le /home sur le SSD mais de mettre les documents, images...
sur le HDD.
Je vais monter le HDD dans un /media/aurelien/... et lier les différents dossier.

I can link directory, /!\ need an output link that doesn't exist before the ln -s command:

   ```$ln -s /original/directory/ /expected/link/place```

The */original/directory/* can also be written */original/directory*

I am also putting the /tmp on a tmpfs of 512M running on the RAM to remove wear on the SSD
I added the following line of code in the /etc/fstab :

tmpfs                                     /tmp            tmpfs   defaults,noatime,nosuid,nodev,noexec,mode=1777,size=512M              0       0

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

### SSH & sshfs

See (ssh docs)[./ssh_info.md]



### Kdump

Kdump is a tool to capture kernel logs when we enter crashes. I tried it for my Ryzen system as it sometimes had some problems.
I wasn't able to get any logs, maybe my problems were different (powersuply cable...) or one of the ryzen C-state (C6) bug.

on Ubuntu based system:

-install: `sudo apt install linux-crashdump`
- during the install process we will be asked if kdump should be enabled by default (we want to answer yes)
- if we missed it, we can run `dpkg-reconfigure kdump-tools` to get asked again.
- check that crashdump is enabled: `cat /proc/cmdline` we should see a "crashkernel=..." option enabled.
- check that the kernel is reserving memory area for kdump : `dmesg | grep -i crash`

[good link](https://www.thegeekstuff.com/2014/05/kdump/)
[link](https://github.com/r4m0n/ZenStates-Linux) to a tool for disabeling C6 states on ryzen.
need to use `sudo modprob cpuid msr` as kernel modules to use.
then run `./zenstates.py --c6-disable`

to run at boot, create a systemd service in /etc/systemd/system:

```
[Unit]
Description=Ryzen Disable C6
DefaultDependencies=no
After=sysinit.target local-fs.target
Before=basic.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/disable_c6

[Install]
WantedBy=basic.target
```

We need to create the executable:

```
#!/bin/sh
zenstates.py --c6-disable
```
[source](https://forum.manjaro.org/t/ryzen-freezes-possible-solution-related-to-c6-state/37870)

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

these apps are installed in a  /snap/... directory.
These apps will put user specific data in ~/snap/...
If anything along the path /hom/user/snap/... is a link, the apparmor profile will prevent the snapped apps to work.
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
to install jupyter notebook, do it in a virtual environment.

```
pip install jupyter
```

To output pdf, you will need to install the `texlive` and `texlive-xetex`.
Also on ubuntu you might need to install `texlive-generic-recommended`
and pandoc might also be necessary (even if it isn't pandoc is good to have installed)

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
I could also use a tmpsfs for other directory. see the askubuntu "how can I use ram
storage for the tmp directory and how to set a maximum to it".
The row in the fstab would be:
`tmpfs /tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=512M 0 0`

The size argument is making the limit for the tmpfs filesystem. I probably would 
need to put several GB, but need a bit more RAM.


### mots de passe:

utiliser keepassXC keepassX or bitwarden

### Virtualisation

see (virtualizationAndContainers.md)[virtualizationAndContainers.md] document.


### Additional fonts

sudo apt install `ttf-mscorefonts-installer`
ou copier les polices depuis linux/windows dans `/usr/share/fonts`
font I liked for my conky: amaze et janda cheerful

### hp printer

install "hplip"

### Telegram:

To make telegram start at boot in tray, add to the ~/.config/autostart/ (for freedesktop compliant
 desktop) the telegramdesktop.desktop file. And the Exec command should be `Telegram -startintray` 

### Steam:

The steam client has a support for 4K but you have to find the option in menu:

steam > option > interface > "enlarge text and icons based on monitor szie"

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
  
### Syncthing:

[Official documentation](https://docs.syncthing.net/intro/gui.html)

When you connect two devices for the first time, you need to restart syncthing 
on both machines for the changes to take effect.

    `sudo ufw allow syncthing`
Rules for allowing syncthing using ufw. for more specific information look at the 
official documentation.
     
Port forwarding to access the web interface on a remote machine pointing the browser to
*http://localhost:9999/#*
     `ssh -L 9999:localhost:8384 machine`
     
Automatically start syncthing for user at system boot:

    `systemctl enable syncthing@myuser.service`
    `systemctl start syncthing@myuser.service`

this is the standard web server address: 
`http://localhost:8384/`

The `.stignore` file is the file where you can specify which files not to synchronise.

To run a web Gui of syncthing, run: `syncthing -browser-only`

The first synchronization will take long ast it will synchronize most of the data as on each machine it will take the first scan as reference, and the first scan on each machine isn't performed at the same time.
Also on one computer I would end-up with a syncthing panic and recurrent shutdown of syncthing during the first synchronization.
My method to avoid that:
- only add one shareed folder at a time and let it synchronize.
- Also keep the reference machine in a "send only" mode during the initial synch to avoid the different machine to rescan their folder in between and mess up with the sync.

# Interresting software:

command line interactive disk usage tool:

 - ncdu

### making a stress test:

install the stress package and use it

### pdf aranger not starting or python not starting

it can happen that some python app don't like locale combination. To remove problem edit the launcher and add the variable: `LC_ALL=C`
