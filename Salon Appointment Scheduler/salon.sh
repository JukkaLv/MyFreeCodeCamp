#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon -t -c "

# echo $($PSQL "SELECT * FROM services") | while read 

SHOW_SERVICE_MENU()
{
  if [[ -z $1 ]]
  then
    echo -e "\nPlease select the service by inputing the number:\n"
  else
    echo -e "\n$1\n"
  fi
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  # echo $SERVICES | sed -E 's/ | /) /g'
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SELECTION
  DEAL_SERVICE_SELECTION $SELECTION
}

DEAL_SERVICE_SELECTION()
{
  if [[ -z $1 ]]
  then
    SHOW_SERVICE_MENU
  else
    SERVICE_ID=$1
    # query by the selected service_id
    QUERY_SERVICE_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID;")
    if [[ -z $QUERY_SERVICE_RESULT ]]
    then
      SHOW_SERVICE_MENU "The number you've inputted is not valid, please input again:"
    else
      BOOK_SERVICE_1 $SERVICE_ID
    fi
  fi
}

BOOK_SERVICE_1()
{
  if [[ -z $1 ]]
  then
    SHOW_SERVICE_MENU
  else
    echo -e "\nPlease leave your phone number(xxx-xxxx):"
    read CUSTOMER_PHONE
    VALIDATE_PHONE_NUMBER $CUSTOMER_PHONE
    if [[ $? == 0 ]]
    then
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      if [[ -z $CUSTOMER_ID ]]
      then
        NEW_CUSTOMER $CUSTOMER_PHONE
        if [[ $? == 0 ]]
        then
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
        else
          echo -e "\nOops! There are something wrong with creating new account, please contact with the support team(123-4567) for help."
          exit
        fi
      fi
      BOOK_SERVICE_2 $1 $CUSTOMER_ID
    else
      echo -e "\nSorry, your phone number is not in correct format, please input again."
      BOOK_SERVICE_1 $1
    fi
  fi
}

BOOK_SERVICE_2()
{
  echo -e "\nPlease leave the time that you wish to come(hh:mm or hh[am|pm]):"
  read SERVICE_TIME
  VALIDATE_SERVICE_TIME $SERVICE_TIME
  if [[ $? == 0 ]]
  then
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($2, $1, '$SERVICE_TIME');")
    if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
    then
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $1;")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $2;")
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      # SHOW_SERVICE_MENU "Is there any more service you want to book?"
      exit
    else
      echo -e "\nSorry, something are going wrong, please contact with our support team(123-4567) for help."
      exit
    fi
  else
    echo -e "\nSorry, the time you left is not in correct format, please input again."
    BOOK_SERVICE_2 $1 $2
  fi
}

VALIDATE_PHONE_NUMBER()
{
  if [[ ! -z $1 ]]
  then
    REGEX='^[0-9]{3}-[0-9]{3}-[0-9]{4}$'
    if [[ $1 =~ $REGEX ]]
    then
      return 0
    fi
  fi
  return 1
}

NEW_CUSTOMER()
{
  if [[ ! -z $1 ]]
  then
    echo -e "\nPlease leave your name:"
    read CUSTOMER_NAME
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nCannot leave empty name, please input again."
      NEW_CUSTOMER $1
    else
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$1');")
      if [[ $INSERT_CUSTOMER_RESULT == 'INSERT 0 1' ]]
      then
        return 0
      fi
    fi
  fi
  return 1
}

VALIDATE_SERVICE_TIME()
{
  if [[ ! -z $1 ]]
  then
    REGEX='^([01][0-9]|2[0-3]):[0-5][0-9]$'
    if [[ $1 =~ $REGEX ]]
    then
      return 0
    else
      REGEX='^(0[1-9]|1[0-2])([aApP][mM])$'
      if [[ $1 =~ $REGEX ]]
      then
        return 0
      fi
    fi
  fi
  return 1
}

SHOW_SERVICE_MENU