#!/bin/bash

# OBS! Run from root project level!
berks package cookbooks.tar.gz

aws s3 cp ./cookbooks.tar.gz s3://divelogger-cookbooks/production/

rm cookbooks.tar.gz
