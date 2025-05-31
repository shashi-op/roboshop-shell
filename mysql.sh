#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"
R="\e[31m"  # Red color code
G="\e[32m"
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

dnf module disable mysql -y &>> $LOG_FILE
VALIDATE $? "Disable current MySQL version"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOG_FILE
VALIDATE $? "Copied MySQl repo"

dnf install mysql-community-server -y &>> $LOG_FILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOG_FILE 
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "Starting  MySQL Server" 

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG_FILE
VALIDATE $? "Setting  MySQL root password"