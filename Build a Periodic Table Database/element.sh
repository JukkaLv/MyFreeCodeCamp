#!/bin/bash

## MY ASSIGNMENT ##
PSQL='psql --username=freecodecamp --dbname=periodic_table -t --no-align -c'

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  NUMBER=$1
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
    RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1' OR name = '$1';")
    if [[ ! -z $RESULT ]]
    then
      NUMBER=$RESULT
    else
      NUMBER=-1
    fi
  fi
  RESULT=$($PSQL "SELECT symbol,name,type_id,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements INNER JOIN properties ON elements.atomic_number = properties.atomic_number WHERE elements.atomic_number = $NUMBER;")
  if [[ ! -z $RESULT ]]
  then
    IFS='|' read SYMBOL NAME TYPE_ID MASS MELT BOIL <<< $RESULT
    TYPE=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID";)
    echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
  else
    echo "I could not find that element in the database."
  fi
fi
