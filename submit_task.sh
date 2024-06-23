#!/bin/bash


is_mentee() {
    current_user=$(whoami)
    grep -q "^$current_user " /path/to/menteesDetails.txt
}


is_mentor() {
    current_user=$(whoami)
    grep -q "^$current_user " /path/to/mentorsDetails.txt
}


if ! is_mentee && ! is_mentor; then
    echo "This script can only be executed by mentees or mentors."
    exit 1
fi

if is_mentee; then
    current_user=$(whoami)
    mentee_home=$(eval echo ~$current_user)
    core_home=$(eval echo ~core)
    
    read -p "Enter task number (e.g., task1, task2, task3): " task
    read -p "Enter domain (Webdev, Appdev, Sysad): " domain
    
    task_dir="$mentee_home/$domain/$task"
    mkdir -p "$task_dir"
    
    read -p "Enter task details: " task_details
    echo "$task_details" > "$task_dir/task.txt"
    
    echo "$task - $domain" >> "$mentee_home/task_submitted.txt"
    
    echo "$current_user - $task - $domain" >> "$core_home/mentees_domain.txt"
    
    echo "Task $task submitted in domain $domain."

elif is_mentor; then
    current_user=$(whoami)
    core_home=$(eval echo ~core)
    
    mentor_domain=$(grep "^$current_user " /path/to/mentorsDetails.txt | cut -d ' ' -f2)
    mentor_home=$(eval echo ~$current_user)
    
    while IFS= read -r line; do
        mentee=$(echo $line | cut -d ' ' -f1)
        mentee_rollno=$(echo $line | cut -d ' ' -f2)
        
        mentee_home=$(eval echo ~$mentee_rollno)
        
        for task in task1 task2 task3; do
            task_dir="$mentee_home/$mentor_domain/$task"
            if [ -d "$task_dir" ]; then
                ln -s "$task_dir" "$mentor_home/submittedTasks/$task"
                if [ "$(ls -A $task_dir)" ]; then
                    echo "$task - completed" >> "$mentee_home/task_completed.txt"
                else
                    echo "$task - not completed" >> "$mentee_home/task_completed.txt"
                fi
            fi
        done
    done < "$mentor_home/allocatedMentees.txt"
    
    echo "Mentor tasks checked and symlinked."
fi

MYSQL_ROOT_PASSWORD="password"


   mysql -u root -p"password" -e "USE induction; INSERT INTO mentor_tasks (mentor, mentee, task_number, status) SELECT '$current_user', mentee, task_number, CASE WHEN EXISTS (SELECT 1 FROM $mentee_home/task_completed.txt) THEN 'completed' ELSE 'not completed' END FROM mentor_allocation WHERE mentor = '$current_user';"
    
    echo "Mentor tasks checked and symlinked."
fi
