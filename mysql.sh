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
    else 
        echo -e "$2  is $G success $N" | tee -a $LOG_FILE 
    fi
}


echo "script started executing at: $(date)"  | tee -a $LOG_FILE

CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabled MySQL server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "started MySQL server"


mysql -h mysql.pooja.icu -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo "MySQL root password is not setup, setting now" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting UP root password"
else
    echo -e "MySQL root password is already setup...$Y SKIPPING $N" | tee -a $LOG_FILE
fi

