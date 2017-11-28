#!/bin/bash
RED="31"
GREEN="32"
WOS=""

function makeItColorful {
    echo -e "\e[$2m$1\e[0m"
}

function is_working {
    if [ $? -eq 0 ];then
        makeItColorful "Réussite : $1" $GREEN
    else
        makeItColorful "Echec : $1" $RED
    fi
}

function detectOS {
    if [ -f /etc/lsb-release ]; then
        OS=$(cat /etc/lsb-release | grep DISTRIB_ID | sed 's/^.*=//')
        VERSION=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | sed 's/^.*=//')
        if [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ] ;then
            WOS="$OS"
        fi
    elif [ -f /etc/redhat-release ]; then
        WOS="Fedora"
        sudo dnf install -y --nogpgcheck https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install -y --nogpgcheck https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    elif [ -f /etc/centos-release ]; then
        WOS="CentOS"
    elif [ -f /etc/debian_version ]; then
        WOS="Debian"
    elif [ -f /etc/arch-release ]; then
        WOS="Arch"
    else
        WOS="WTF ?"
    fi
}

# Faire un detectOS avant
function ins {
    all="$@" # pour fonction is_working
    echo "Installation: $all ...."
    if [ "$WOS" = "Ubuntu" ] || [ "$WOS" = "Debian" ] ;then
        sudo apt update -y > /dev/null 2>&1
        sudo apt install $@ -y # > /dev/null 2>&1
        is_working "Installation de $all"
    elif [ "$WOS" = "Fedora" ] ;then
        sudo dnf update -y #> /dev/null 2>&1
        sudo dnf install $@ -y #> /dev/null 2>&1
        is_working "Installation de $all"
    elif [ "$WOS" = "Arch" ] ;then
        yaourt -Sau
        yaourt -Sy $@ --noconfirm #> /dev/null 2>&1
        is_working "Installation de $all"
    else
        makeItColorful "OS Inconnu" $RED
    fi
}


function make {
    detectOS
    # ins python3 python3-pip debian
    ins python python-pip # arch
    pip3 install -r requirements.txt
    ln -s $PWD /usr/local/.
    mkdir -p ~/.local/share/hangupsbot/.
    cp config.json ~/.local/share/hangupsbot/.
    cp examples/hangupsbot.service /etc/systemd/system/
    systemctl enable hangupsbot.service
    # need to start one time
    python3 hangupsbot/hangupsbot.py
}
make $1
exit 0

# Local Variables:
# mode: Shell-script
# coding: mule-utf-8
# End:
