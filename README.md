FRONT-RUNNING PROBLEM
    use commit-reveal to solve by adding function commitInput() that get hashed_choice and idx
to commit, adding function revealInput() that get choice and salt and idx to reveal.

ETH LOCKING PROBLEM
    timestamp comes to play by stamp time when calling addPlayer(), commitInput(), revealInput()
and call function isTimeout() to check whether it's timeout or not, detail in code.

ADDING ROCK WATER AIR PAPER SPONGE SCISSORS FIRE
    using modulo method, detail in code.
