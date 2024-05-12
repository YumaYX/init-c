#!/bin/bash

cd /tmp && curl -O https://ftp.riken.jp/Linux/almalinux/9.4/isos/x86_64/AlmaLinux-9-latest-x86_64-dvd.iso

mount -o loop /tmp/AlmaLinux*.iso /media

