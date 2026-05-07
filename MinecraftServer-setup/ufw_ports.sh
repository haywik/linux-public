#!/bin/bash 

if [ "$EUID" -ne 0 ]; then 
  echo "Must be root"
  exit 1
fi

ufw insert 1 allow 19132
ufw insert 1 allow 25565
ufw insert 1 allow 24454
