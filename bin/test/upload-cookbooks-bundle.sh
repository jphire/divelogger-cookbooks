#!/bin/bash

# OBS! Run from root project level!
berks package cookbooks.tar.gz

aws s3 cp ./cookbooks.tar.gz s3://divelogger-cookbooks/test/

rm cookbooks.tar.gz
