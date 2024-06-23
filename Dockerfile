


FROM ubuntu:latest

WORKDIR /root

# data packages download 
RUN apt-get update && \
    apt-get install -y \
    apache2 \
    php \
    mysql-client \
    sudo \
    vim

COPY alias_usergen.sh /root/alias_usergen.sh
COPY display_status.sh /root/display_status.sh
COPY domainpref.sh /root/domainpref.sh
COPY mentoralloc.sh /root/mentoralloc.sh
COPY submit_task.sh /root/submit_task.sh
COPY menteeDetails.txt /root/menteeDetails.txt
COPY mentorDetails.txt /root/mentorDetails.txt


RUN chmod +x /root/*.sh


COPY mentees_domain.txt /var/www/html/mentees_domain.txt


CMD ["apache2ctl", "-D", "FOREGROUND"]

