#!/bin/bash
datetime=`date "+%Y%m%d+%H%M"`
backupdir="/home/ralph/log/backup/${datetime}"
mkdir $backupdir
/home/ralph/shell/taxonomy_stop.sh
mv /home/ralph/log/taxonomy_mongrel.log $backupdir
mv /home/ralph/sites/Taxonomy/log/production.log $backupdir
/home/ralph/shell/taxonomy_start.sh
