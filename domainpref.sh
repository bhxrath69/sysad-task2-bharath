#!/bin/bash

if [ "$(whoami)" = "core" ]; then
    echo "This script cannot be run by the core user."
    exit 1
fi

read -p "Enter your name: " rollno
mentee_home=$(eval echo ~$rollno)

if [ ! -d "$mentee_home" ]; then
    echo "Mentee directory not found."
    exit 1
fi

read -p "Enter your domain preferences (space-separated, e.g., Webdev Appdev Sysad): " prefs
echo "$prefs" > $mentee_home/domain_pref.txt
echo "$rollno $prefs" | sudo tee -a ~/core/mentees_domain.txt

for pref in $prefs; do
    mkdir -p $mentee_home/$pref
done

MYSQL_ROOT_PASSWORD="password"


mysql -u root -p"password" -e "USE induction; INSERT INTO users (name, role) VALUES ('$rollno', '$prefs') ON DUPLICATE KEY UPDATE domains='$prefs';"

echo "all domain prefs are saved in mysql succesfully"
