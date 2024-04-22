#!/bin/bash

# Get the current logged in user.
USER=$(whoami)

# Get the user id of the logged in user.
USERID=$(id -u)

#echo "Please enter the DB password.. "          # ExpenseApp@1 is the password. 
#read -s mySQLPassword
mySQLPassword=ExpenseApp@1

# Create a log file name format.
TIMESTAMP=$(date +%F-%H-%M-%S)
FILENAME=$(echo $0 | cut -d "." -f1)
LOGFILEPATH=/tmp/$FILENAME-$TIMESTAMP.log

# Set the color codes.
R="\e[31m"
G="\e[32m"
B="\e[33m"
Y="\e[34m"
N="\e[0m"

# Check whether the logged in user is sudo user or not.
if [ $USERID -ne 0 ]
then
    echo -e "The current logged in user '$B $USER $N' is not a sudo user. Get the sudo access and then start installing the packages. "
    exit 1
else
    echo -e "The current logged in user '$B $USER $N' is a sudo user. You can proceed to install the packages."
fi

# Create a function to perform the validation.
VALIDATION(){
    if [ $1 -ne 0 ]
    then
        echo -e "The installation of $2 is $R FAILED $N. Please check the logs created in $LOGFILEPATH"
        exit 1
    else
        echo -e "The installation of $2 is $G SUCCESS $N. Pleaase check that logs created in $LOGFILEPATH"
    fi
}

# Installing nginx application.
dnf install nginx -y &>> $LOGFILEPATH
VALIDATION $? "Installing nginx"

# Enabling nginx service.
systemctl enable nginx &>> $LOGFILEPATH
VALIDATION $? "Enabling nginx service"

# Starting nginx service.
systemctl start nginx &>> $LOGFILEPATH
VALIDATION $? "Starting nginx service"

# Removing all the content inside.
rm -rf /usr/share/nginx/html/* &>> $LOGFILEPATH
VALIDATION $? "Removing the default content in the nginx server"

# Download the application files from the shared repo.
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> $LOGFILEPATH
VALIDATION $? "Downloading the application files"

# Extract the content.
cd /usr/share/nginx/html/
unzip /tmp/frontend.zip &>> $LOGFILEPATH
VALIDATION $? "Extracting the frontend files"

# Copy expense.config file to /etc/nginx/default.d/expense.conf.
cp /home/ec2-user/expenseproject/expense_project/expense.conf /etc/nginx/default.d/expense.conf &>> $LOGFILEPATH
VALIDATION $? "Copying the expense.config file"

# Restart the nginx service
systemctl restart nginx &>> $LOGFILEPATH
VALIDATION $? "Restaring the nginx"