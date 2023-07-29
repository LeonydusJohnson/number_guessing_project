#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUM=$($PSQL "SELECT floor((random() * 1000) + 1)")
COUNT=1
WIN=false

echo -e "\nEnter your username:\n"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, guesses) VALUES('$USERNAME', 1, 0)")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  GUESSES=$($PSQL "SELECT guesses FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $GUESSES guesses."
  GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED + 1 WHERE username = '$USERNAME'")
fi

echo "Guess the secret number between 1 and 1000:"

GUESS() {

  read CURRENT_GUESS
  CHECK_NUM $CURRENT_GUESS
  HIGH_LOW $CURRENT_GUESS

}

CHECK_NUM() {

  IS_NUMBER=$($PSQL "SELECT '$1' ~ '^\d+(\.\d+)?$'")
  if [[ $IS_NUMBER = f ]] 
  then
    echo "That is not an integer, guess again:"
    GUESS
  fi

}

HIGH_LOW() {

  while [[ $1 != $NUM ]]
  do
    if [[ $1 > $NUM ]]
    then
      echo "It's lower than that, guess again:"
      # read CURRENT_GUESS
      COUNT=$($PSQL "SELECT $COUNT + 1")
      echo "$1 and $NUM"
      GUESS
    else
      echo "It's higher than that, guess again:"
      #read CURRENT_GUESS
      COUNT=$($PSQL "SELECT $COUNT + 1")
      GUESS
    fi
  done

  if [[ $1 = $NUM ]]
    then
    WIN=true
    RECORD=$($PSQL "SELECT guesses FROM users WHERE username='$USERNAME'")

    RECORD_CHECK=$($PSQL "SELECT $COUNT < $RECORD")

    if [[ $RECORD_CHECK = 't' ]]
    then
      INPUT_RECORD=$($PSQL "UPDATE users SET guesses=$COUNT WHERE username='$USERNAME'")
    fi

    if [[ $RECORD = 0 ]]
    then
      INPUT_RECORD=$($PSQL "UPDATE users SET guesses=$COUNT WHERE username='$USERNAME'")
    fi

    echo "You guessed it in $COUNT tries. The secret number was $NUM. Nice job!" 
    exit 0
  fi

}

if [[ $WIN=false ]]
then
  GUESS
fi
