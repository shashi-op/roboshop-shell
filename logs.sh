#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"
RED="\e[31m"  # Red color code
GREEN="\e[32m" # Green color code
NORMAL="\e[0m" # Normal code

echo "This script has started at $TIMESTAMP" &>> $LOG_FILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "Error:: $2 $RED Failed $NORMAL"
        exit 1
    else
        echo -e "$2 $GREEN Success $NORMAL"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$RED You are not a root user $NORMAL"
    exit 1 #if exit=0, cmd will continue, if exit>0, cmd will exit
else    
    echo -e "$GREEN You are a root user $NORMAL"
fi

dnf install nginx -y &>> $LOG_FILE  # '&' means either true or false, redirect the o/p to the logfile
VALIDATE $? "Installing nginx"

dnf install git -y &>> $LOG_FILE
VALIDATE $? "Installling git"