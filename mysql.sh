#!/bin/bash

# Get the current logged in user.
USER=$(whoami)

# Get the user id of the logged in user.
USERID=$(id -u)

# Create a log file name format.
TIMESTAMP=$(date +%F-%H-%M-%S)
FILENAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$TIMESTAMP-$FILENAME.log
#echo "Please enter the DB password.. "          # ExpenseApp@1 is the password. 
#read -s mySQLPassword
mySQLPassword=ExpenseApp@1
DBServerIP=172.31.80.220

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
        echo -e "$2 is $R FAILED $N"
        exit 1
    else
        echo -e "$2 is $G SUCCESS $N"
    fi
}

# Checking that uer is sudo user or not.
if [ $USERID -ne 0 ]
then
    echo -e "This current user $B '$USER' $N is not a sudo user. Please get the sudo access first or login with sudo user before installing packages."
    exit 1
else
    echo -e "This current user $B '$USER' $N has the sudo access. You can proceed to install the packages."
fi

# Installing the mysql-server package.
dnf install mysql-server -y &>> $LOGFILE
VALIDATE $? "Installing MySQL Server"

# Enabling the MySQL Server service.
systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enabling mysql service"

# Starting the mysql service
systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting the mysql service"

# Setting the password to the root user of mysql server. If the password is already set it will set again. So we need to check its first and 
# then we have to set the password if its not set already.
mysql -h DBServerIP -uroot -p$mySQLPassword -e "show databases;" &>> $LOGFILE
if [ $? -eq 0 ]
then
    echo -e "MySQL root password is already set. $Y SKIPPING $N"
else
    mysql_secure_installation --set-root-pass $mySQLPassword &>> $LOGFILE
    VALIDATE $? "Setting the password for root user in MySQL server"
fi