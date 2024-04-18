#!/bin/bash

# Get the current logged in user.
USER=$(whoami)

# Get the user id of the logged in user.
USERID=$(id -u)

# Create a log file name format.
TIMESTAMP=$(date +%F-%H-%M-%S)
FILENAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$TIMESTAMP-$FILENAME.log

# Creating a color codes.
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

# Function created to perform a validation on the result of the command execution.
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo "$2.. installation of $2 is $R FAILED $N"
    else
        echo "$2.. installation of $2 is $G SUCCESS $N"
    fi
}

# Checking that uer is sudo user or not.
if [ $USERID -ne 0 ]
then
    echo "This current user $USER is not a sudo user. Please get the sudo access first or login with sudo user before installing packages."
else
    echo "this current user $USER is has the sudo access. You can proceed to install the packages."
fi

# Installing the mysql-server package.
dnf install mysql-server -y &>> $LOGFILE
VALIDATE $? "Installing MySQL Server"

# Enabling the MySQL Server service.
systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enabling the mysql service"

# Starting the mysql service
systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting the mysql service"

# Setting the password to the root user of mysql server.
mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting the password for root user in MySQL server"

