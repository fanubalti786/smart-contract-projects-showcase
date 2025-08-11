// SPDX-Lincese-Identifier: GPL-3.0

pragma solidity^0.8.0;


contract auctionContract
{
    address payable public auctioneer;
    uint public stblock;
    uint public etblock;

    enum aucState{Started,Runnig,Ended,Cancelled}
    aucState public state;

    uint public highestBid;
    uint public highestPayableBid;
    uint public bidInc;

    address payable public highestBidder;

    mapping (address => uint) public bids;

    constructor()
    {
        auctioneer = payable(msg.sender);
        state = aucState.Runnig;
        stblock = block.number;
        etblock = block.number + 240;
        bidInc = 1 ether;
    }
    
    


    modifier notOwner() 
    {
        require(msg.sender != auctioneer,"Owner cannot bid");
        _;
    }

    modifier owner()
    {
        require(msg.sender == auctioneer, "should be owner");
        _;
    }

    modifier running()
    {
        require(state == aucState.Runnig, "Auction is not running");
        _;
    }



    modifier beforeEnd()
    {
        require(block.number < etblock, "should be owner");
        _;
    }

    function cancelAuc() public owner
    {
        state = aucState.Cancelled;
    }

    function endAuc() public owner
    {
        state = aucState.Ended;
    }



    function min(uint a, uint b) private pure returns(uint)
    {
        if(a<=b)
            return a;
        else
            return b;
        
    }


    function bid() public payable notOwner running beforeEnd
    {
        require(msg.value >= 1 ether,"Bid should be greater than highest bid");
        uint currentBid = bids[msg.sender] + msg.value;

        require(currentBid > highestPayableBid, "Bid already increased");

        bids[msg.sender] = currentBid;

        if(currentBid <= bids[highestBidder])
        {
            highestPayableBid = min(currentBid + bidInc, bids[highestBidder]);
        }
        else
        {
            highestPayableBid = min(currentBid, bids[highestBidder] + bidInc);
            highestBidder = payable(msg.sender);
            highestBid = currentBid;
        }
    }


    function finalize() public 
    {
        require(state == aucState.Cancelled || state == aucState.Ended || block.number >= etblock, "The bid is currently active.");
        require(msg.sender == auctioneer || bids[msg.sender] > 0, "You have not placed a bid");

        address payable person;
        uint value;

        if(state == aucState.Cancelled)
        {
            person = payable(msg.sender);
            value = bids[msg.sender];
        }
        else
        {
            if(msg.sender == auctioneer)
            {
                person = auctioneer;
                value = highestPayableBid;
            }
            else
            {
                if(msg.sender == highestBidder)
                {
                    person = highestBidder;
                    value = bids[highestBidder] - highestPayableBid;
                }
                else
                {
                    person = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }

        bids[msg.sender] = 0;
        person.transfer(value);



    }

}
