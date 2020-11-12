#!/bin/sh
set -e

# Create the log file to be able to run tail
touch /var/log/cron.log
touch /var/log/covid.log

# Taken from https://stackoverflow.com/questions/37458287/how-to-run-a-cron-job-inside-a-docker-container
printenv | grep -v "no_proxy" >> /etc/environment
crond
# mege both log files into one stream
tail -f /var/log/cron.log -f /var/log/covid.log