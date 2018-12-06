# VMware horizon view sur linux mint/Ubuntu (14.04/16.04)

## pour toutes les architectures:

1. aller chercher le fichier d'installation sur le site de VMware:
   
    https://my.vmware.com/web/vmware/info/slug/desktop_end_user_computing/vmware_horizon_clients/4_0
    
2. lire les notes de version et la doc d'installation pour plus d'informations.

## Pour architecture 32 bits:

1. se rendre dans le dossier où on a copié le fichier d'installation
2. le marquer comme exécutable
3. lancer:
    
    sudo ./nom_de_l'installateur.bundle
    
4. suivre les étapes d'installation de l'installateur et bien utiliser la fonction 
de scan pour trouver les fonctionnalités manquantes.
5. pour la version 4.0 certaines librairies ont une version trop récente il faut donc faire 
croire à VMware que on a les bonnes librairies en utilisant des liens symboliques:
    
    ln -s /lib/i386.../libudev.so.1 /lib/i386/libudev.so.0
    
6. faire de même pour les autres librairies nécéssaires (les installer si elles ne le sont pas):
    - libxml2
    - libssl1.0.0 (doit être libssl.so.1.0.1 dans /lib/i386.../)
    - libxtst6
    - libudev1
    - libpcsclite1
    - libtheora0
    - libv4l-0
    - libpulse0
7. il faut aussi /lib/i386.../libcrypto... /lib/i386.../libcrypto.so.1
8. pour utiliser le client avec le protocole rdp il faut installer: freerdp-x11
9. sur linux mint il est nécéssaire d'installer rdesktop sinon le rdp ne s'ouvre pas.

## Pour architectures 64 bits:

- Les changements précedents peuvent se faire dans /lib/i386.../ où dans /lib/x86.64.../ apparement (à vérifier).
- avant d'installer les librairies nécéssaires il faut faire:
 
    sudo dpkg --add-architecture i386
    sudo apt-get update
    
- Pour installer la liste de dépendances énoncées précédement il est important d'ajouter ":i386" après chaque package.
par exemple:

    sudo apt install libxml2
    
devient:
    
    sudo apt install libxml2:i386
    
