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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

VALIDATE $? "Setting up NPM source"

yum install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing NodeJS"
#Once the user is created, if you run this script 2nd time.
#This command will defnitely fail
#Improvement: first check the user alredy exist or not , if not exist then create.
useradd roboshop &>>$LOGFILE

#write a condition to check directory alredy exist or not.
mkdir /app &>>$LOGFILE

# give full path of user.service becuase we are inside /app
curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE
VALIDATE $? "downloading user artifact"

cd /app  &>>$LOGFILE
VALIDATE $? "Moving into app directory"

unzip /tmp/user.zip &>>$LOGFILE
VALIDATE $? "unzipping user"

npm install   &>>$LOGFILE

VALIDATE $? "Installing dependencies"

# give full path of user.service becuse we are inside /app
cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>>$LOGFILE

VALIDATE $? "copying user.service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon-reload"


systemctl enable user &>>$LOGFILE

VALIDATE $? "Enabling user"


systemctl start user &>>$LOGFILE

VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copying Mongo Repo"

yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing Mongo client"

mongo --host mongodb.devopsjoin.online </app/schema/user.js &>>$LOGFILE

VALIDATE $? "Loading user data into mongo db"




