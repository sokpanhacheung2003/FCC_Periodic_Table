#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

DISPLAY_DATA(){
  if [[ -z $1 ]]
  then 
    echo "I could not find that element in the database."
  else
    IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME TYPE MASS MELTING BOILING <<< "$1"
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  fi
}

SYMBOL=$1

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# if number
if [[ $SYMBOL =~ ^[0-9]+$ ]]
then
  # get data by atomic number with joins
  DATA=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e INNER JOIN properties p USING (atomic_number) INNER JOIN types t USING (type_id) WHERE e.atomic_number=$SYMBOL")
  DISPLAY_DATA "$DATA"
else
  LENGTH=${#SYMBOL}
  if [[ $LENGTH -gt 2 ]]
  then
    # get data by full name with joins
    DATA=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e INNER JOIN properties p USING (atomic_number) INNER JOIN types t USING (type_id) WHERE e.name='$SYMBOL'")
    DISPLAY_DATA "$DATA"
  else
    # get data by symbol with joins
    DATA=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e INNER JOIN properties p USING (atomic_number) INNER JOIN types t USING (type_id) WHERE e.symbol='$SYMBOL'")
    DISPLAY_DATA "$DATA"
  fi
fi
