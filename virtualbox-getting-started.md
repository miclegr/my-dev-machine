*** VirtualBox steps

1. download image iso (e.g. [focal](https://releases.ubuntu.com/focal))
2. create a new VM in VirtualBox
    - max memory and cpu
    - bridged networking
    - during installation check on OpenSSH server
3. setup guest addons:
    1. Devices -> Insert Guest CD
    2. ```
    sudo apt-get install -y make gcc linux-headers-$(uname -r)
    sudo mkdir /mnt/cdrom
    sudo mount /dev/cdrom /mnt/cdrom
    sudo /mnt/cdrom/VBoxLinuxAdditions.sh
    sudo usermod -a -G vboxsf $USER
    ```
4. setup shared directories as needed
5. set up ansible ```
sudo apt-get install -y python3-pip
pip install ansible
```
6. reboot
