---
title: "Installing Android Studio with Distrobox"
date: 2024-04-03T09:01:46-04:00
draft: false
---
Installing Android Studio with Distrobox has a few missing dependencies. These were the following instructions that I needed to complete in order to install on an Ubuntu 22.04 container.
1. (Host Machine) Create a Distrobox container
```bash
# Note replace <container-name> with a unique name
distrobox create --name <container-name> --image ubuntu:22.04 --home $HOME/distrobox/home/<container-name>
distrobox enter <container-name> 
```
2. (Container) Install dependencies
```bash
# Installing dependencies
sudo dpkg --add-architecture i386
sudo apt update
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
sudo apt install libncurses5 libpulse0 libxtst6 git libglib2.0-bin build-essential libxft2 qemu qemu-kvm libnotify4 libglu1 xvfb
```
3. (Host Machine) Download Android Studio from the official website [here](https://developer.android.com/studio)
4. (Host Machine) Move the downloaded tar.zx file to home of container e.g.
```bash
mv ~/Downloads/android-studio-2023.2.1.24-linux.tar.gz ~/distrobox/home/<container-name>
```
5. (Container) Extract the tar.xz `tar -xzf <name-of-file>` e.g.
```bash
cd ~/
tar -xzf android-studio-2023.2.1.24-linux.tar.gz
```
6. (Container) Android studio can now be started from the home directory with `./android-studio/bin/studio.sh`.
7. (Container) Add it to your path by appending `export PATH="$HOME/android-studio/bin:$PATH"` to your `~/.bashrc`. Now it can be launches with `studio.sh`
