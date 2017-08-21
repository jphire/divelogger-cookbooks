#!/bin/bash

berks package cookbooks.tar.gz

aws s3 cp ./cookbooks.tar.gz s3://divelogger-cookbooks/

rm cookbooks.tar.gz