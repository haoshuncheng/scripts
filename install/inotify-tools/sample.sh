#!/bin/sh

#-- nohup sh sample.sh& -- 
host=204.45.0.66

src=/usr/deploy/andplus/androidplus/
dst=andplus


sync() {
        rsync -avz  --delete  --force --exclude=".svn/***" --password-file=/etc/rsyncd/rsync.password  $src www@$1::$dst
}

/usr/local/cellar/inotify/bin/inotifywait --exclude=".svn/***" -mrq  --timefmt '%d/%m/%y %H:%M' --format '%T %w%f%e' -e modify,delete,create,attrib $src | while read files;
do
 sync $host
done
