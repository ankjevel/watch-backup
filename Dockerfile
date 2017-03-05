FROM alpine:3.5

# https://pkgs.alpinelinux.org/packages
RUN \
  apk add --no-cache 'inotify-tools=3.14-r2' 'rsync<3.2' 'bash<4.4'

#
# example config on rsync-host:
#
# [tmp]
#   comment = Backup location
#   path = /tmp/backup
#   read only = false
#   auth users = foo
#   secrets file = /etc/rsyncd.secret
#
# ... where ENV is used as following:
#
# RSYNC_LABEL = [tmp]
#   [tmp] is the identifier, it still needs to be named: /tmp/
# RSYNC_USERNAME = "auth users"
#   This is the user allowed in rsync
# RSYNC_PASSWORD = "secrets file"
#   "secrets file" points to a file that contains a username and password,
#   you need to specify the password used
#

ENV RSYNC_HOST localhost
ENV RSYNC_LABEL /tmp/
ENV RSYNC_USERNAME foo
ENV RSYNC_PASSWORD bar

VOLUME [ "/tmp/backup" ]

COPY ./run.sh /app/run.sh

WORKDIR /app

CMD ./run.sh
