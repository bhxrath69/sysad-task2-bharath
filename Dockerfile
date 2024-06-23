# Dockerfile for the server setup

# Use Ubuntu as the base image
FROM ubuntu:latest

# Set the working directory
WORKDIR /root

# Update packages and install necessary software
RUN apt-get update && \
    apt-get install -y \
    apache2 \
    php \
    mysql-client \
    sudo \
    vim

# Copy scripts and files into the container
COPY alias_usergen.sh /root/alias_usergen.sh
COPY display_status.sh /root/display_status.sh
COPY domainpref.sh /root/domainpref.sh
COPY mentoralloc.sh /root/mentoralloc.sh
COPY submit_task.sh /root/submit_task.sh
COPY menteeDetails.txt /root/menteeDetails.txt
COPY mentorDetails.txt /root/mentorDetails.txt

# Ensure scripts have execute permissions
RUN chmod +x /root/*.sh

# Copy mentees_domain.txt to Apache directory
COPY mentees_domain.txt /var/www/html/mentees_domain.txt

# Start Apache service
CMD ["apache2ctl", "-D", "FOREGROUND"]

