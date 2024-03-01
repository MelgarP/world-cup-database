#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WGOALS OPGOALS
do
  # skip the first line "year"
  if [[ $YEAR != "year" ]]
  then
    #check if the team is already in the table
    if [[ $WINNER != "winner" ]]
    then
      # get winner_id
      WINNER_ID=$($PSQL "SELECT winner_id FROM games WHERE winner_id = (SELECT team_id FROM teams WHERE name = '$WINNER') ")
      # if team not found
      if [[ -z $WINNER_ID ]]
      then
        # insert into teams
        INSERT_TO_TEAMS=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER') ")
      fi
    fi
    #get looser team_id
    #skip first line for "opponent"
    if [[ $OPPONENT != "opponent" ]]
    then
      #get opponent id 
      O_ID=$($PSQL "SELECT opponent_id FROM games WHERE opponent_id = (SELECT team_id FROM teams WHERE name = '$OPPONENT') ")
      #if team not found
      if [[ -z $O_ID ]]
      then
        #insert looser team
        INSERT_TO_TEAMS=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT') ")
      fi
    fi
    # check if game already in games table using all the information iteriating with year
    if [[ $YEAR != "year" ]]
    then
    GET_GAME_ID=$($PSQL "SELECT game_id FROM games FULL JOIN teams on games.winner_id = teams.team_id WHERE year = $YEAR AND (round = '$ROUND' AND winner_id = (SELECT team_id FROM teams WHERE name = '$WINNER') AND opponent_id = (SELECT team_id FROM teams WHERE name ='$OPPONENT')) ")
    # if game not in table
      if [[ -z $GET_GAME_ID ]]
      then
        #insert into games table
        INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', (SELECT team_id FROM teams WHERE name = '$WINNER'), (SELECT team_id FROM teams WHERE name ='$OPPONENT'), $WGOALS, $OPGOALS)") 
      fi
    fi  
  fi

done