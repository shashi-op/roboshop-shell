#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"
R="\e[31m"  # Red color code
G="\e[32m"
Y="\e[33m" # Green color code
N="\e[0m" # Normal code
MONGODB_HOST="172.31.26.69"

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

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling old module"

dnf module enable nodejs:18 -y &>> $LOG_FILE
VALIDATE $? "Enabling v-18"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Installing nodejs"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE $? "roboshop user created"
else
    echo -e "User already created $Y ---skipping $N"
fi 

mkdir /app
VALIDATE $? "creating directory app"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOG_FILE
VALIDATE $? "downloading user app"

cd /app
unzip /tmp/user.zip &>> $LOG_FILE
VALIDATE $? "unzipping user app"

npm install &>> $LOG_FILE
VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOG_FILE
VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOG_FILE
VALIDATE $? "Enable user"

systemctl start user &>> $LOG_FILE
VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOG_FILE
VALIDATE $? "Installing MongoDB client"

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOG_FILE
VALIDATE $? "Loading user data into MongoDB"