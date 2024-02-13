// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "./CommitReveal.sol";


contract RPS is CommitReveal{
    struct Player {
        uint choice; // 0 - Rock, 1 - Paper , 2 - Scissors, 3 - undefined
        address addr;
    
    }

    uint256 public constant TIMEOUT = 1 hours;
    
    uint public numPlayer = 0;
    uint public reward = 0;
    mapping (uint => Player) public player;
    uint public numInput = 0;
    uint public numReveal = 0;
    uint public last_act_timestamp = 0;

    function addPlayer() public payable {
        require(numPlayer < 2);
        require(msg.value == 1 ether);
        reward += msg.value;
        player[numPlayer].addr = msg.sender;
        player[numPlayer].choice = 3;
        numPlayer++;
        last_act_timestamp = block.timestamp;
    }

    function getHash(uint choice, uint salt) public view returns (bytes32) {
        return getSaltedHash(bytes32(choice), bytes32(salt));
    }

    function commitInput(bytes32 hashed_choice, uint idx) public  {
        require(numPlayer == 2);
        require(msg.sender == player[idx].addr);
        
        commit(hashed_choice);

        numInput++;
        last_act_timestamp = block.timestamp;
    }

    function revealInput(uint choice, uint salt, uint idx) public {
        require(msg.sender == player[idx].addr);
        require(numInput == 2); 
        revealAnswer(bytes32(choice), bytes32(salt));
        numReveal++;
        if (numReveal == 2){
            _checkWinnerAndPay();
        }
        last_act_timestamp = block.timestamp;
    }



    function _checkWinnerAndPay() private {
        uint p0Choice = player[0].choice;
        uint p1Choice = player[1].choice;
        address payable account0 = payable(player[0].addr);
        address payable account1 = payable(player[1].addr);


        if ((p0Choice + 1) % 7 == p1Choice || (p0Choice + 2) % 7 == p1Choice || (p0Choice + 3) % 7 == p1Choice) {
            // to player 1
            account1.transfer(reward);
        } else if ((p1Choice + 1) % 7 == p0Choice || (p1Choice + 2) % 7 == p0Choice || (p1Choice + 3) % 7 == p0Choice) {
            // to player 0
            account0.transfer(reward);
        } else {
            // to all
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        }

        _reset();
    }
    
    function isTimeout() public {
        require(msg.sender == player[0].addr || msg.sender == player[1].addr);
        require(block.timestamp > last_act_timestamp + TIMEOUT);
        require(numPlayer > 0);


        address payable account0 = payable(player[0].addr);
        address payable account1 = payable(player[1].addr);
        
        // not enough player to play -> return to the player who joined the game 
        if (numPlayer < 2) {
            account0.transfer(reward);
            _reset();
            return;
        }

        
        
        // player not commit in time or all player commit but not reveal -> return 1 ether for each
        if (numInput < 2 || numReveal == 0) {
            account0.transfer(1 ether);
            account1.transfer(1 ether);
            _reset();
            return;
        }

        // player not reveal in time
        if (commits[account0].revealed && !commits[account1].revealed) {
            account0.transfer(reward);
            _reset();
            return;
        }

        if (commits[account1].revealed && !commits[account0].revealed) {
            account1.transfer(reward);
            _reset();
            return;
        }
        
        


    }
    
    function _reset() private {
        numPlayer = 0;
        reward = 0;
        numInput = 0;
        numReveal = 0;
        last_act_timestamp = 0;
        delete commits[player[0].addr];
        delete commits[player[1].addr];
        delete player[0];
        delete player[1];

    }

    
}
