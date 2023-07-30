#Output message for guess as well as set variables for guesses and guess count
echo -e "\nGuess the secret number between 1 and 1000:"
USER_GUESS=0
COUNT=0

#loop for user guesses and checks for if correct, if digit, if higher, or if lower until correct guess made
while [[ $USER_GUESS != $NUM ]]
do  
  read USER_GUESS
  COUNT=$(( $COUNT + 1 ))

  if [[ $USER_GUESS = $NUM ]]
  then
    #check best game and replace if higher
    echo "You guessed it in $COUNT tries! The secret number was $NUM. Nice job!"
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USER_INPUT'")
    if [[ $BEST_GAME = 0 || $COUNT < $BEST_GAME ]]
    then
      INSERT_BEST_GAME=$($PSQL "UPDATE users SET best_game=$COUNT WHERE username='$USER_INPUT'")
    fi
  else
    IS_NUMBER=$($PSQL "SELECT '$USER_GUESS' ~ '^\d+(\.\d+)?$'")

    if [[ $IS_NUMBER = f ]]
    then 
      echo "That is not an integer, guess again:"
    else
      if [[ $USER_GUESS > $NUM ]]
      then
        echo "It's lower than that, guess again:"
      else
        echo "It's higher than that, guess again:"
      fi
    fi
  fi
done
