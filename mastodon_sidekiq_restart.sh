#!/bin/bash

echo "$(date)" >> /home/user/sidekiq_reboot_log.txt

tail -n 1 /home/user/sidekiq_reboot_log.txt

systemctl restart mastodon-sidekiq.service

exit_code=$?

echo "Exit Code for 'systemctl restart':${exit_code} " >> /home/user/sidekiq_reb>

tail -n 1 /home/user/sidekiq_reboot_log.txt

