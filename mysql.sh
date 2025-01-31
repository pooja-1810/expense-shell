#!/bin/bash

LOGS_FOLDER="/var/log/expense"

SCRIPT_NAME=$(echo $0 | cut -d "." -f1)

TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)

LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

mkdir -p $LOGS_FOLDER     # -p (if directory exits nothing happens, if no it creates)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

USERID=$(id -u)

CHECK_ROOT()
{
    if [ $USERID -ne 0 ]
    then 
        echo -e  "$R Please run the script with root privileges $N" | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE() {
if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R not successful $N" | tee -a $LOG_FILE
        exit 1
    else g
        echo -e "$2  is $G success $N" | tee -a $LOG_FILE 
    fi
}


echo "script started executing at: $(date)"  | tee -a $LOG_FILE

CHECK_ROOT

dnf install mysql-server -y
VALIDATE $? "Installing MySQL server"

systemctl enable mysqld
VALIDATE $? "Enabled MySQL server"

systemctl start mysqld
VALIDATE $? "started MySQL server"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting the root password"

