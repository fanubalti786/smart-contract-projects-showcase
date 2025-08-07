// SPDX-License-Identifier: GPL-3.0

pragma solidity^0.8.0;


contract lotteryContract
{
    // address public owner;
    uint private time;
    address payable[] private players;
    // constructor()
    // {
    //     owner = msg.sender;
    // }

    event lotteryEntered(address indexed player);
    event winnerDeclared(address indexed winner, uint amount);


    receive() external payable
    {
         revert("Please use participate() to join the lottery.");
    }



    function alreadyEntered() private view returns(bool)
    {
        for(uint i=0; i<players.length; i++)
        {
            if(players[i] == msg.sender)
            {
                return true;
            }
        }
        return false;

    }


    function random() private view returns(uint)
    {
        return uint(sha256(abi.encodePacked(block.prevrandao, block.timestamp, block.number, msg.sender)));
    }

    function participate() external payable
    {
        // require(msg.sender != owner, "Owner cannot enter the lottery");
        require(msg.value == 1 ether, "Minimum entry fee is 1 ether"); // Minimum entry fee of 1 ether)
        require(alreadyEntered() == false, "You have already entered the lottery"); // Check if the player has already entered the lottery)
        if(players.length == 0)
        {
            time = block.timestamp;
        }
        players.push(payable(msg.sender));
        emit lotteryEntered(msg.sender);

        checkWinnerCondition();
    }



    function checkWinnerCondition() private
    {
        // require(msg.sender == owner, "you are not owner");
        if(block.timestamp - time >= 2 minutes || players.length >= 5)
        {
        uint index = random() % players.length; 
        players[index].transfer(address(this).balance);
        // address[] memory arr = new address[](0);
        // address payable[] memory arr2 = new address payable[](5);
        players = new address payable[](0);
        }
        
    }


    function getPlayers() public view returns(address payable[] memory)
    {
        return players;
    }




}