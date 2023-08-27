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

yum install golang -y &>> $LOGFILE

VALIDATE $? "Installing golang"

useradd roboshop &>> $LOGFILE

VALIDATE $? "Adding roboshop as user"

mkdir /app &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch.zip &>> $LOGFILE

VALIDATE $? "Downloading dispatch.zip file"


cd /app &>> $LOGFILE

VALIDATE $? "Chaning directory to app"

unzip /tmp/dispatch.zip &>> $LOGFILE

VALIDATE $? "Unziping dispatch.zip file"

go mod init dispatch &>> $LOGFILE

VALIDATE $? "Downloading dependencies"

go get &>> $LOGFILE

VALIDATE $? "Get go language"


go build &>> $LOGFILE

VALIDATE $? "Build go lanaguage"

cp   /home/centos/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE

VALIDATE $? "Copy the dispatch service "

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "reload the daemon"

systemctl enable dispatch &>> $LOGFILE

VALIDATE $? "Enable Dispatch"

systemctl start dispatch &>> $LOGFILE

VALIDATE $? "Starting the dispatch"

