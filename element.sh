#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Function to display element data
DISPLAY_DATA(){
  if [[ -z $1 ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$1" | while IFS="|" read NUMBER SYMBOL NAME WEIGHT MELTING BOILING TYPE
    do
      echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $WEIGHT amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
}

# Check if an argument was provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

# If argument is a number, search by atomic_number
if [[ $1 =~ ^[0-9]+$ ]]
then
  DATA=$($PSQL "SELECT atomic_number, symbol, name, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, types.type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE elements.atomic_number = $1")
  DISPLAY_DATA "$DATA"
  
# If argument is a single letter or two-letter symbol, search by symbol
elif [[ ${#1} -le 2 ]]
then
  DATA=$($PSQL "SELECT atomic_number, symbol, name, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, types.type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol = '$1'")
  DISPLAY_DATA "$DATA"

# Otherwise, search by name
else
  DATA=$($PSQL "SELECT elements.atomic_number, symbol, name, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, types.type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE name = '$1'")
  DISPLAY_DATA "$DATA"
fi
