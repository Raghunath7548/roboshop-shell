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

yum install maven -y &>> $LOGFILE

VALIDATE $? "Maven Installation"


useradd roboshop &>> $LOGFILE

VALIDATE $? "Roboshop Use adding"


mkdir /app &>> $LOGFILE

VALIDATE $? "Create app folder"


curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading shipping.zip file"

cd /app &>> $LOGFILE

VALIDATE $? "Changing directory to app folder"

unzip /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "Unzipping shipping folder"


mvn clean package &>> $LOGFILE

VALIDATE $? "mvn clean package"


mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? " Renaming jar file"


cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "Copying the shipping.service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $?  "Relaod the Daemon"

systemctl enable shipping  &>> $LOGFILE

VALIDATE $? "Enable Shipping service"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "Start the shipping folder"

yum install mysql -y &>> $LOGFILE

VALIDATE $? "Install mysql"

mysql -h mysql.devopsjoin.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOGFILE

VALIDATE $? "Load the schema"

systemctl restart shipping &>> $LOGFILE 

VALIDATE $? "Restarting the shipping app"

