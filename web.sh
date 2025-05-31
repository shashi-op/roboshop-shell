#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"
R="\e[31m"  # Red color code
G="\e[32m" # Green color code
Y="\e[33m" # Green color code
N="\e[0m" # Normal code

echo "This script has started at $TIMESTAMP" &>> $LOG_FILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "Error:: $2 $R Failed $N"
        exit 1
    else
        echo -e "$2 $G Success $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R You are not a root user $N"
    exit 1 #if exit=0, cmd will continue, if exit>0, cmd will exit
else    
    echo -e "$G You are a root user $N"
fi

dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>> $LOG_FILE
VALIDATE $? "Enable nginx" 

systemctl start nginx &>> $LOG_FILE
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE
VALIDATE $? "removed default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOG_FILE
VALIDATE $? "Downloaded web application"

cd /usr/share/nginx/html &>> $LOG_FILE
VALIDATE $? "moving to nginx html directory"

unzip -o /tmp/web.zip &>> $LOG_FILE
VALIDATE $? "unzipping web"
 
cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOG_FILE 
VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx &>> $LOG_FILE
VALIDATE $? "restarted nginx"