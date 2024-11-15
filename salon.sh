#! /bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  psql --username=freecodecamp --dbname=salon -c "SELECT * FROM services;" | while read ID BAR NAME
  do
    if [[ $ID =~ ^[0-9]+$ ]]
    then
      echo "$ID) $NAME"
    fi
  done

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) APPOINTMENT_MENU ;;
    2) APPOINTMENT_MENU ;;
    3) APPOINTMENT_MENU ;;
    4) APPOINTMENT_MENU ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}

APPOINTMENT_MENU(){

  echo -e "\nplease enter your phone number"
  read CUSTOMER_PHONE

  CUSTOMER_RESULT=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE';")

  if [[ -z $CUSTOMER_RESULT ]]
  then

    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    psql --username=freecodecamp --dbname=salon -q -c "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"

  fi

  echo -e "\nfor what time would you like to schedule"
  read SERVICE_TIME

  # get customer ID
  CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

  # add appointment to database
  psql --username=freecodecamp --dbname=salon -q -c "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

  # get service
  SERVICE=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

  # get customer name
  CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;")

  echo -e "\nI have put you down for a$SERVICE at $SERVICE_TIME,$CUSTOMER_NAME."
}

MAIN_MENU