#!/bin/sh

if [ -r /etc/default/locale ]; then

  . /etc/default/locale

  export LANG LANGUAGE

fi

# startxfce4
lxsession -s LXDE -e LXDE
