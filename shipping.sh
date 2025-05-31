#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"
R="\e[31m"  # Red color code
G="\e[32m"
Y="\e[33m" # Green color code
N="\e[0m" # Normal code
MYSQL_HOST="172.31.90.150"

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

mkdir -p /app
VALIDATE $? "creating directory app"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOG_FILE
VALIDATE $? "Downloading shipping"

cd /app
VALIDATE $? "moving to app directory"

unzip -o /tmp/shipping.zip &>> $LOG_FILE
VALIDATE $? "unzipping shipping"

mvn clean package &>> $LOG_FILE
VALIDATE $? "Packaging shipping"

mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE
VALIDATE $? "Renaming the artifact"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOG_FILE
VALIDATE $? "Copying service file"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Daemon reload"

systemctl enable shipping  &>> $LOG_FILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>> $LOG_FILE
VALIDATE $? "Starting shipping"

dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "Installing MySQL"

mysql -h mysql.daws76s.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOG_FILE
VALIDATE $? "loading shipping data"

systemctl restart shipping &>> $LOG_FILE
VALIDATE $? "Restarted Shipping