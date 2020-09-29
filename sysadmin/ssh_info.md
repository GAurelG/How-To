# SSH:

enplacement personnel des info ssh: /home/aurelien/.ssh/
créer une clé: ssh-keygen -t rsa -C "username@address.server.something"
elle sera sauvegardée sous: /home/aurelien/.ssh/id_rsa	et id_rsa.pub
on peut avoir plusieurs clé ssh, pour cela, les enregistrer sous d'autres nom de fichier.
La clé privée est personnelle et doit être conservée et pas partagée.
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
#hostname will be used to complete the ssh command, can be anything we want (but no user@ in it)
#can put several synonyme if we separate them with space. Can also use wildcards
 HostName github.com
 User git
 IdentityFile ~/.ssh/id_rsa_github

Host nomd'hôte
 HostName bitbucket.org
 User git
 IdentityFile ~/.ssh/id_rsa_bibucket

doing so, allow us to use ssh nomd'hote instead of ssh user@HostName. 

to add a key to the ssh-agent (for example if it was newly created and you have to copy it
from another location because you type the wrong path like a stupid person):

    ```$ssh-add /path/to/ssh/id_rsa...```

In my case it didn't add the key permanently to the user agent, so I had to add the host in the 
.ssh/config file (like explained previously).

Once I created the new key on another computer, i copied the id_rsa.pub file
containing the public ssh key to the computer that ad the ssh access already set up.
I then ran the ssh-copy-id command, but got an error because the key wasn't created on the 
computer so I had to use the -f (for force) option. it worked well.
    ```ssh-copy-id -f -i /path/to/key user@hostname```

On se connecte en faisant: ssh -T git@nomd'hôte
A voir comment ça fonctionne correctement!
A voir comment on détermine le User dans le fichier!

To remove older hosts, one need to know their host name (what was used in the ssh command).
then you can use the command:
    ```ssh-keygen -R hostname [-f filenameOfKnownHosts]```
I also removed the id_rsa.. public and private keys.

### sshfs

For the backups I discovered sshfs. You need to have 
the following line shows an example of an fstab row for an sshfs mount. The x-systemd.automount option can be used on all mount to make the filesystem automount when it is available. It can be useful for external hard drive.

`serverUser@server.address:/ /home/backaurel/mntAlbatros fuse.sshfs defaults,_netdev,allow_other,reconnect,x-systemd.automount,noauto,IdentityFile=/home/backaurel/.ssh/id_rsa 0 0`

To make a simple mount, create the directory to mount in `sudo mkdir /mnt/whatever`
Then mount the sshfs onto it: `sudo sshfs user@server:/ /mnt/whatever/`

we can use an ssh key for login: `sudo sshfs -o IdentityFile=~/.ssh/keyfile /mnt/whatever/`

The Archwiki for the fstab and sshfs are good ressources.

####################


### managing the new user and ssh with keys:

Now that we have a user account, the best practice is to open a new connection using ssh for the 
new user. It is best to stay connected with the root account to make sure that we can connect with the
new user, and if not rectify directly using the root account.

We have no ssh key until now, so we will autenticate using password. Once it is done, the action
we have to do are:

- create an ssh key on our personal machine
    + `$ ssh-keygen` by default the key pair will be saved in ~/.ssh/id_rsa
we can give the output file a new name during the generation
    + we protect it with a passphrase

- We need to copy the public ssh key from the client machine and add it in the ~/.ssh/authorized_key
to simplify that process we can use 'ssh-copy-id':
    + `$ ssh-copy-id -i ~/.ssh/mykey.pub username@host` If the key pair is named using the default
(rsa_id.pub) then we don't need the -i and the key location

- if we changed the name of the key for a specific purpose we will need to
tell ssh to use the different key: `$ ssh -i <key location> login@server.example.com`

- To make it simpler, one can edit the ~/.ssh/config on the client to configure per host
an IdentityFile example:

    ```
    Host ashortname realname.example.com
        HostName realname.example.com
        IdentityFile ~/.ssh/realname_rsa.id #private key for realname
        User remoteUsername
    ```

One can add multiple Host with different parameters, or add multiple IdentityFile.
the option `IdentitiesOnly yes` will prevent any other identity of being used for 
connection with the server from that client.

- now, we can try to loggin using ssh and the user account to check
 if we get prompted for the key.

- if there are problem, check if the key has been added to the authorized_key file
on the server, or if the client is trying to use the right key.

- Now that we can use the key, we need to deactivate ssh password login,
to do so:
    + connect to the server (host).
    + `$ sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.origin`
    + `$ sudo vim /etc/ssh/sshd_config`
    + change the line with "PasswordAuthentication" uncomment and set to
      "PassworAuthentication no"
    + save and quit the file
    + restart the ssh daemon `$ sudo systemctl restart ssh`
    + open a new terminal and check if we can connect using ssh before closing this session

- We can also remove root login possibility:
    + connect to the server (host).
    + `$ sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.origin`
    + `$ sudo vim /etc/ssh/sshd_config`
    + change the line with "PermitRootLogin" uncomment and set to
      "PermitRootLogin no"
    + save and quit the file
    + restart the ssh daemon `$ sudo systemctl restart ssh`
    + open a new terminal and check if we can connect using ssh before closing this session
    + also check if it is now impossible to connect as root

I could look at X forwarding, but for the base config I don't need it.

#### SSH reverse tunneling

- I can use reverse tunneling to send information back from the remote server to my PC. This will be useful to avoid having to configure the home router, and also to avoid problems in case my home IP adfdress changes.

- To use the reverse tunneling, I need ssh-server installed on both machine.
- It is recommanded to ssh back to a restrained user.
- I found a good explaination:  [https://unix.stackexchange.com/questions/46235/how-does-reverse-ssh-tunneling-work](https://unix.stackexchange.com/questions/46235/how-does-reverse-ssh-tunneling-work)
    Basically with the reverse tunneling, we ask ssh to create a pipe in the bigger ssh connection pipe.
    the inside pipe needs to have a start and an end, we specify the direction of the data transfert in the 
insider pipe by using the -L (for data transfert starting on the client and going to the server = like general
ssh connection). the -R makes a reverse connection (from the "server" to the "client").

to do the reverse tunneling, one need to set-up the option on the remote host(in in /etc/ssh/sshd_config):
- AllowTcpForwarding yes  
- GatewayPort no # this allows only connection from server machine on itself

the command on the client to start the ssh connection is:
```userC@client$ ssh -R 22345:localhost:22 userS@server```

One danger of that if I don't specify the GatewayPort on the sshd config of the server (?) is that basically
anyone connecting to the server on the specified port could be binded to local port 22. this can be a security risk.
more info about ssh tunneling:
[https://www.ssh.com/ssh/tunneling/exampl](https://www.ssh.com/ssh/tunneling/example)
[https://chamibuddhika.wordpress.com/2012/03/21/ssh-tunnelling-explained/](https://chamibuddhika.wordpress.com/2012/03/21/ssh-tunnelling-explained/)
# the chamibuddhika.wordpress is a really good document, I need to get it as a PDF for offline reference.
# see the [reference_pdf](SSH_tunneling_nice_reference.pdf)

this tells SSH to link the port 22345 (can be any port between 1024 and 65535 not used) on the remote to
the port on localhost (the client) 22, so the ssh port of the local machine.
After the successful connection, we can initiate the connection from the server (even witin the first
ssh session) to itself on the specified port and ssh will forward it to the port 22 on the local machine.
```userS@server$ ssh -p 22345 userC@localhost```

Other SSH options:
- -f tells ssh to background itself to avoid having to run stuffs through it to keep the connection alive
- -N tells that we don't want to run any remote commands, save ressources
- -T disable pseudo tty allocation = do not create interactive shell

Digital Ocean as a really nice guide on ssh lok for "digital ocean, ssh essential guide"

#### Two factor autentication with ssh:

a method to use google authenticator (TOTP) with ssh connection can be found at the [following link](https://sysconfig.org.uk/two-factor-authentication-with-ssh.html)
It seems quite easy to implement.
