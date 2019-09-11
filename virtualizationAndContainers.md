# Virtualisation

I will write information about virtual machines, container (maybe snaps, docker...)

## KVM

It is important to check if the hardware is able to support virtualization, and if it is enabled in the BIOS.
Then we install lib-virt qemu and the qemu-kvm package to have the hardware acceleration:

    ```
    sudo apt-get install qemu-kvm libvirt-bin bridge-utils virt-manager
    sudo adduser name libvirtd
    ```

The second step is necessary if the user isn't in the virtd group as it blocks you froom actually running virtualization
software.
You might have to create the group before adding a user to it:
   `sudo addgroup libvirtd`

As we installed the GUI tool 'virt-manager' we can use that to create virtual machine.

### KVM and hardware passthrough

# Containers

## Docker

This first attempt will be using docker to install a postgresql database and communicate with it.

### Installing Docker from official repositories:

    ```
    sudo apt update
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    sudo apt update
    apt-cache policy docker-ce # to ensure I am getting docker from official repositories and not the distribution repository
    sudo apt install docker-ce
    docker --version
    ```
Now we can check if the docker daemon is running:
    ```
    sudo systemctl status docker
    ```
As docker runs as root, you either need to always use sudo or put yourself in the docker group.
    ```
    sudo usermod -aG docker ${USER}
    ```
now you can log out and in to actually have the group assigned to you.

### Running the postgresql

    `docker pull postgres`

First create a folder that will be mounted in the container and serve as data storage. This will allow to destroy and re-install the container without touching the data.

    ```
    mkdir -p $HOME/docker/volumes/postgres
    ```
    
Then we actually run the container:

    ```
    docker run --rm   --name pg-docker -e POSTGRES_PASSWORD=docker -d -p 5432:5432 -v $HOME/docker/volumes/postgres:/var/lib/postgresql/data  postgres
    ```
    
The options mean:
  - rm: Automatically remove the container and it’s associated file system upon exit. In general, if we are running lots of short term containers, it is good practice to to pass rm flag to the docker run command for automatic cleanup and avoid disk space issues. We can always use the v option (described below) to persist data beyond the lifecycle of a container

  - name: An identifying name for the container. We can choose any name we want. Note that two existing (even if they are stopped) containers cannot have the same name. In order to re-use a name, you would either need pass the rm flag to the docker run command or explicitly remove the container by using the command `docker rm [container name]`

  - e: Expose environment variable of name `POSTGRES_PASSWORD` with value docker to the container. This environment variable sets the superuser password for PostgreSQL. We can set `POSTGRES_PASSWORD` to anything we like. I just choose it to be docker for demonstration. There are additional environment variables you can set. These include `POSTGRES_USER` and `POSTGRES_DB`. `POSTGRES_USER` sets the superuser name. If not provided, the superuser name defaults to postgres. `POSTGRES_DB` sets the name of the default database to setup. If not provided, it defaults to the value of `POSTGRES_USER`

  - d: Launches the container in detached mode or in other words, in the background

  - p: Bind port `5432` on *localhost* to port `5432` within the container. This option enables applications running out side of the container to be able to connect to the Postgres server running inside the container

  - v: Mount `$HOME/docker/volumes/postgres` on the host machine to the container side volume path `/var/lib/postgresql/data` created inside the container. This ensures that postgres data persists even after the container is removed 

  [source](https://hackernoon.com/dont-install-postgres-docker-pull-postgres-bee20e200198)
 
To connect to the instance later, just do it as usual. you can use psql or other tools.

### Managing docker containers:

    - `docker ps`: list active containers, -a flag shows all installed containers (running or not)
    - `docker start d9b100f2f636`: the number is the containerID found when doing ps. This command starts stopped containers
    - `docker stop sharp_volhard`: can use contqinerID or nqme to stop containers
    - `docker rm festive_williams`: remove an installed container
