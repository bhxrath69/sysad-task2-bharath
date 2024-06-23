#!/bin/bash

# Check if the current user is core
if [ "$(whoami)" != "core" ]; then
    echo "This script can only be executed by the core user."
    exit 1
fi

core_home=$(eval echo ~core)
mentees_home="$core_home/mentees"
mentors_home="$core_home/mentors"

declare -A mentor_capacity

# Reading mentor details from mentorDetails.txt
while IFS= read -r line; do
    mentor=$(echo $line | cut -d ' ' -f1)
    domain=$(echo $line | cut -d ' ' -f2)
    capacity=$(echo $line | cut -d ' ' -f3)
    mentor_capacity["$mentor"]=$capacity
    echo "Mentor $mentor with capacity $capacity added to domain $domain"
done < mentorDetails.txt

# Reading mentee details from menteeDetails.txt
while IFS= read -r line; do
    rollno=$(echo $line | cut -d ' ' -f1)
    name=$(echo $line | cut -d ' ' -f2)
    domain_pref_file="$mentees_home/$rollno/domain_pref.txt"
    
    if [ -f "$domain_pref_file" ]; then
        while IFS= read -r domain; do
            for mentor in "${!mentor_capacity[@]}"; do
                if [ "${mentor_capacity[$mentor]}" -gt 0 ]; then
                    echo "$rollno $name" >> "$mentors_home/$domain/$mentor/allocatedMentees.txt"
                    echo "$rollno $name assigned to $mentor in $domain"
                    ((mentor_capacity[$mentor]--))
                    break 2
                fi
            done
        done < "$domain_pref_file"
    else
        echo "Domain preference file for $rollno not found."
    fi
done < menteeDetails.txt

# Ensure /home/core/mentees_domain.txt is writable
mentees_domain_file="$core_home/mentees_domain.txt"
if [ ! -w "$mentees_domain_file" ]; then
    sudo chmod 622 "$mentees_domain_file"
fi

# Append domain preferences to mentees_domain.txt
for mentee_dir in "$mentees_home"/*; do
    rollno=$(basename "$mentee_dir")
    domain_pref_file="$mentees_home/$rollno/domain_pref.txt"
    if [ -f "$domain_pref_file" ]; then
        while IFS= read -r domain; do
            echo "$rollno $domain" >> "$mentees_domain_file"
        done < "$domain_pref_file"
    fi
done

MYSQL_ROOT_PASSWORD="password"

service mysql start 

mysql -u root -p"password" -e "USE induction; INSERT INTO mentor_allocation (mentor, mentee_rollno, domain) VALUES('$mentor', '$rollno', '$domain');"

echo "MENTOR ALLOCATION IS COMPLETED"
