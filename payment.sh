#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi
VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "Installation python3.6"

useradd roboshop &>> $LOGFILE

VALIDATE $? "adding roboshop user"


mkdir /app  &>> $LOGFILE

VALIDATE $? "Creating app directory"


curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "Downloading Payment.zip file"


cd /app &>> $LOGFILE

VALIDATE $? "changing app directory"


unzip /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "unziping payment.zip"



pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "Installting pip3.6"


cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "coping payment.service file"


systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "reload the daemon"


systemctl enable payment &>> $LOGFILE

VALIDATE $? "enabling payment service"


systemctl start payment &>> $LOGFILE

VALIDATE $? "Starting the Payment service"
