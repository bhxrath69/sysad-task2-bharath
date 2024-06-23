#!/bin/bash

# Check if the script is being run by the core user
if [ "$(whoami)" != "core" ]; then
    echo "This script can only be executed by the core user."
    exit 1
fi

# Variables
MYSQL_ROOT_PASSWORD="password"

# Create core user and necessary directories
sudo useradd -m core
core_home=$(eval echo ~core)
sudo mkdir -p $core_home/mentors
sudo mkdir -p $core_home/mentees

# Start MySQL service
sudo service mysql start

# Create database and users table if they don't exist
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS induction;"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "USE induction; CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT, name VARCHAR(255), role VARCHAR(255), PRIMARY KEY (id));"

# To read mentors and create users
while IFS= read -r line; do
    mentor=$(echo $line | cut -d ' ' -f1)
    domain=$(echo $line | cut -d ' ' -f2)
    sudo useradd -m -d $core_home/mentors/$domain/$mentor $mentor
    sudo mkdir -p $core_home/mentors/$domain/$mentor/submittedTasks/{task1,task2,task3}
    sudo touch $core_home/mentors/$domain/$mentor/allocatedMentees.txt
    echo "Mentor $mentor added to domain $domain"
    # Insert mentor details into MySQL database
    mysql -u root -p$MYSQL_ROOT_PASSWORD -e "USE induction; INSERT INTO users (name, role) VALUES ('$mentor', 'Mentor');"
done < mentorDetails.txt

# To read mentee details from menteeDetails.txt
while IFS= read -r line; do
    rollno=$(echo $line | cut -d ' ' -f1)
    name=$(echo $line | cut -d ' ' -f2)
    sudo useradd -m -d $core_home/mentees/$rollno $rollno
    sudo touch $core_home/mentees/$rollno/domain_pref.txt
    sudo touch $core_home/mentees/$rollno/task_completed.txt
    sudo touch $core_home/mentees/$rollno/task_submitted.txt
    echo "Mentee $name (Roll No: $rollno) added"
    # Insert mentee details into MySQL database
    mysql -u root -p$MYSQL_ROOT_PASSWORD -e "USE induction; INSERT INTO users (name, role) VALUES ('$rollno', 'Mentee');"
done < menteeDetails.txt

# Permissions
sudo chmod 700 $core_home/mentees/*
sudo chmod 700 $core_home/mentors/*/*

# Core permissions
sudo chmod 755 $core_home/mentees
sudo chmod 755 $core_home/mentors
sudo chmod 755 $core_home

# Core file that mentees can write to
sudo touch $core_home/mentees_domain.txt
sudo chmod 622 $core_home/mentees_domain.txt

echo "Alias user generation completed."

