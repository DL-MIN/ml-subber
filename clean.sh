#!/bin/sh
##------------------------------------------------------------------------------
## Clean and harden docker images
## 
## Helpful sources:
## - https://gist.github.com/christiansteier/dd8c5544c69504d29bd938726691255b
## - https://gist.github.com/michaeldimoudis/93d49c5d4e92f9cfd5dd3924fa8e13a5
##
## @author     Lars Thoms <lars@thoms.io>
## @date       2023-05-08
##------------------------------------------------------------------------------

##------------------------------------------------------------------------------
## Configuration
##------------------------------------------------------------------------------

# Paths to system files
SYSDIR="/bin /etc /lib /sbin /usr"

# Users to keep
USERS="root nobody container cool postgres"

# Groups to keep
GROUPS="root nobody docker container cool postgres"


##------------------------------------------------------------------------------
## Users and groups
## 
## Remove unlisted users and groups from system. Furthermore, disable login and
## remove interactive shell for the rest.
##------------------------------------------------------------------------------

# Remove unlisted users
awk -F':' '{print $1}' < /etc/passwd | grep -vE "$(echo "${USERS}" | sed -E 's@\s+@|@g')" | while IFS= read -r item _
do
    deluser "${item}"
done

# Remove unlisted groups
awk -F':' '{print $1}' < /etc/group | grep -vE "$(echo "${GROUPS}" | sed -E 's@\s+@|@g')" | while IFS= read -r item _
do
    delgroup "${item}"
done

# Disable password login for everybody
while IFS=: read -r item _
do
    passwd -l "${item}"
done < /etc/passwd

# Remove interactive login shell for everybody
sed -i -r 's@^(.*):[^:]*$@\1:/sbin/nologin@' /etc/passwd


##------------------------------------------------------------------------------
## Filesystem
## 
## Remove unnecessary files and restrict permissions as far as possible.
##------------------------------------------------------------------------------

# Ensure system dirs are owned by root and not writable by anybody else
find ${SYSDIR} -xdev -type d -exec chown root:root {} + -exec chmod 0755 {} +

# Set right permissions for /tmp and /var/tmp
chmod a=rwx,o+t /tmp
chmod a=rwx,o+t /var/tmp

# Remove all suid files
find ${SYSDIR} -xdev -type f -a -perm +4000 -delete

# Remove other programs that could be dangerous
find ${SYSDIR} -xdev \( \
    -name hexdump -o \
    -name chgrp -o \
    -name ln -o \
    -name od -o \
    -name strings -o \
    -name su \
\) -delete

# Remove unused files, inter alia, and alternative/old files
find ${SYSDIR} -xdev -type f -regex '.*-$' -delete

# Remove cache, documentation and homes
find \
    /home/ \
    /media/ \
    /mnt/ \
    /opt/ \
    /root/ \
    /srv/ \
    /tmp/ \
    /var/cache/apk/ \
    /var/cache/man/ \
    /usr/share/doc/ \
    /usr/share/man/ \
    /usr/share/info/ \
    /var/spool/ \
    /var/tmp/ \
    -xdev -mindepth 1 -maxdepth 1 -exec rm -rf {} +

# Remove init scripts
rm -rf \
    /etc/init.d \
    /etc/fstab \
    /lib/rc \
    /etc/conf.d \
    /etc/inittab \
    /etc/runlevels \
    /etc/rc.conf

# Remove cron scripts
rm -rf \
    /var/spool/cron \
    /etc/crontabs \
    /etc/periodic

# Remove kernel tunables
rm -rf \
    /etc/sysctl* \
    /etc/modprobe.d/ \
    /etc/modules \
    /etc/mdev.conf \
    /etc/acpi/

# Remove git repositories
find ${SYSDIR} -xdev -type d -name '.git' -delete

# Remove python cache
find ${SYSDIR} -xdev -type f -name '*.py[co]' -delete

# Remove apk configs
find ${SYSDIR} -xdev -type f -regex '.*apk.*' ! -name apk -delete

# Remove broken symlinks
find ${SYSDIR} -xdev -type l -exec test ! -e {} \; -delete

# Delete itself
rm -- "${0:-}"
