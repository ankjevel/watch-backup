#!/bin/bash

RSYNC_HOST=$([[ ! -z $RSYNC_HOST ]] && echo "$RSYNC_HOST" || echo "localhost")
RSYNC_LABEL=$([[ ! -z $RSYNC_LABEL ]] && echo "$RSYNC_LABEL" || echo "/tmp/")
RSYNC_USERNAME=$([[ ! -z $RSYNC_USERNAME ]] && echo "$RSYNC_USERNAME" || echo "foo")
RSYNC_PASSWORD=$([[ ! -z $RSYNC_PASSWORD ]] && echo "$RSYNC_PASSWORD" || echo "bar")

inotifywait -m /tmp/backup -e create -e moved_to |
  while read path _action file; do
    if [ ! -f "$path$file" ]; then
      echo "file does not exist"
      break
    fi

    n=0
    echo "sending $path$file to rsync://$RSYNC_USERNAME@$RSYNC_HOST:$RSYNC_LABEL"
    until [ $n -ge 5 ]; do
      n=$[$n+1]
      cd $path && rsync -av ./$file rsync://$RSYNC_USERNAME@$RSYNC_HOST:$RSYNC_LABEL
      if [ $? -eq 0 ]; then
        echo "success ($n attempts)"
        break;
      fi
      echo "retrying: ($n)"
      sleep 10
    done

    if [ $n -ge 5 ]; then
      echo "failed to send $path$file"
    fi
  done
