#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams;")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ ${YEAR} != 'year' ]]
  then
    #FIND WINNER_ID FIRST
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='${WINNER}';")
    #IF WINNER_ID NOT EXIST, THEN INSERT IT TO TEAM TABLE
    if [[ -z $WINNER_ID ]]
    then
      INSERT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('${WINNER}');")
      if [[ $INSERT_RESULT == "INSERT 0 1" ]]
      then
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='${WINNER}';")
      fi
    fi

    #FIND OPPONENT_ID FIRST
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='${OPPONENT}';")
    #IF OPPONENT_ID NOT EXIST, THEN INSERT IT TO TEAM TABLE
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('${OPPONENT}');")
      if [[ $INSERT_RESULT == "INSERT 0 1" ]]
      then
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='${OPPONENT}';")
      fi
    fi

    #INSERT GAME DATA TO GAME TABLE
    INSERT_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES(${YEAR},'${ROUND}',${WINNER_ID},${OPPONENT_ID},${WINNER_GOALS},${OPPONENT_GOALS});")
    if [[ $INSERT_RESULT != "INSERT 0 1" ]]
    then
      echo $INSERT_RESULT
    fi
  fi
done