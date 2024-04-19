#!/bin/bash

# Get the current logged in user.
USER=$(whoami)

# Get the user id of the logged in user.
USERID=$(id -u)

echo "Please enter the DB password.. "          # ExpenseApp@1 is the password. 
read -s mySQLPassword

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

# Disabling the nodejs older version packages.
dnf module disable nodejs -y &>> $LOGFILEPATH
VALIDATION $? "Disabling the nodejs older versions"

# Enabling the latest version of nodejs application.
dng module enable nodejs:20 -y &>> $LOGFILEPATH

# Installing the node js application
dnf install nodejs -y &>> $LOGFILEPATH
VALIDATION $? "Installing the nodejs latest version"

# Creating the expense user only if its not already created to use in this project.
id expense &>> $LOGFILEPATH
if [ $? -eq 0 ]
then
    echo "User expense is already exist in the system... $Y SKIPPING $N"    
else
    useradd expense &>> $LOGFILEPATH
    VALIDATION $? "Creating a user"
fi

# Create a directory only if its not exists to store the application code.
mkdir -p /app &>> $LOGFILEPATH

# Download the application code from the repo.
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOGFILEPATH
VALIDATION $? "Downloading the backend application code"

# Unzipping the code file.
cd /app
rm -rf /app/*
unzip backend.zip &>> $LOGFILEPATH
VALIDATION $? "Unzipping the backend application code"

# Installing the dependencies.
npm install &>> $LOGFILEPATH
VALIDATION $? "Installing dependencies"

# Copying the backend.service file to etc/systemd/system.
cp /home/ec2-user/expense-shell/backend.service etc/systemd/system/backend.service &>> $LOGFILEPATH
VALIDATION $? "Copying the backend.service file to system folder."

# Reload the daemon serice.
systemctl daemon-reload &>> $LOGFILEPATH
VALIDATION $? "Relading the daemon service"

# Starting the backend service.
systemctl start backend &>> $LOGFILEPATH
VALIDATION $? "Staring the Backend service"

# Enabling the backend service.
systemctl enable backend &>> $LOGFILEPATH
VALIDATION $? "Enabling the backend service"

# Installing the mysql client
dnf install mysql -y &>> $LOGFILEPATH
VALIDATION $? "Installing mysql client"

# Loading the schema into the mysql.
mysql -h DBIPADDRESS -uroot -pmySQLPassword < /app/schema/backend.mysql &>> $LOGFILEPATH
VALIDATION $? "Loading the SQL schema"

echo "CHECK THE installation is fine by checking the port number"