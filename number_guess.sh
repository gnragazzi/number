#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only --no-align -c";

RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ));

#prompt the user for a username
echo -e "\nEnter your username:";
read USERNAME_INPUT;

USERNAME=$($PSQL "SELECT username FROM user_data WHERE username='$USERNAME_INPUT'");
if [[ -z $USERNAME ]]
then
  USERNAME=$USERNAME_INPUT;
  USERNAME_INPUT_RESULT=$($PSQL "INSERT INTO user_data(username) VALUES('$USERNAME')");
  GAMES_PLAYED=0;
  
  echo "Welcome, $USERNAME! It looks like this is your first time here.";
else 
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_data WHERE username='$USERNAME';");
  BEST_GAME=$($PSQL "SELECT best_game FROM user_data WHERE username='$USERNAME';");
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:";

GUESS_COUNT=0;
read GUESS;
(( GUESS_COUNT+= 1 ));

until [[ $GUESS == $RANDOM_NUMBER ]]
do
  if ! [[ $GUESS =~ ^[0-9]*$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:";
    elif [[ $GUESS -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:";
    fi
  fi
  read GUESS
  (( GUESS_COUNT+= 1 ));
done  

if [[ -z $BEST_GAME ]]
then
  BEST_GAME_UPDATE_RESULT=$($PSQL "UPDATE user_data SET best_game=$GUESS_COUNT WHERE username='$USERNAME'");
else
  if [[ $GUESS_COUNT -lt $BEST_GAME ]]
  then
    BEST_GAME_UPDATE_RESULT=$($PSQL "UPDATE user_data SET best_game=$GUESS_COUNT WHERE username='$USERNAME'");
  fi
fi

(( GAMES_PLAYED += 1 ));
GAMES_PLAYED_UPDATE_RESULT=$($PSQL "UPDATE user_data SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'");

echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!";

