#!/bin/bash

DATE=`date +%Y-%m-%d:%H:%M:%S`

sudo mongodump --db divelogger --out /opt/backups/$DATE

sudo tar -zcvf /opt/backups/versioned-backup.tar.gz -C /opt/backups/$DATE .

aws s3 cp /opt/backups/versioned-backup.tar.gz s3://divelogger-backup/production/mongo/ --region eu-west-1

# remove redundant folder
#sudo rm -r /opt/backups/$DATE

#sudo rm -r /opt/backups/$DATE.tar.gz