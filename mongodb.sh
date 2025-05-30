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
        echo -e "Error:: $2 $R Failed $NL"
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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
VALIDATE $? "Copying the Mongo repo"

dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>> $LOG_FILE
VALIDATE $? "Enabling mongod" 

systemctl start mongod &>> $LOG_FILE
VALIDATE $? "Starting mongod"

#replacing 127.0.0.1 to 0.0.0.0 for remote access
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG_FILE
VALIDATE $? "Providing remote access"

systemctl restart mongod &>> $LOG_FILE
VALIDATE $? "Restarting mongod"
