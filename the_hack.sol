// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract {

    // 1. STATE VARIABLES
    address public owner;

    // 2. MAPPING (users)
    mapping(address => uint) public data;

    // 3. CONSTRUCTOR
    constructor() {
        owner = msg.sender;
    }

    // 4. MODIFIER
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // 5. FUNCTION
    function setData(uint val) public {
        data[msg.sender] = val;
    }

    // 6. VIEW FUNCTION
    function getData() public view returns(uint) {
        return data[msg.sender];
    }
}



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ballot {

    address public chairperson;

    enum State { Init, Regs, Vote, Done }
    State public state;

    mapping(address => bool) public registered;
    mapping(address => bool) public voted;

    uint[] public votes;

    constructor(uint n) {
        chairperson = msg.sender;
        votes = new uint[](n);
        state = State.Init;
    }

    modifier onlyChair() {
        require(msg.sender == chairperson);
        _;
    }

    function changeState(uint s) public onlyChair {
        if(s == 1) state = State.Regs;
        else if(s == 2) state = State.Vote;
        else if(s == 3) state = State.Done;
    }

    function register(address user) public onlyChair {
        require(state == State.Regs);
        registered[user] = true;
    }

    function vote(uint p) public {
        require(state == State.Vote);
        require(registered[msg.sender]);
        require(!voted[msg.sender]);

        voted[msg.sender] = true;

        if(msg.sender == chairperson)
            votes[p] += 2;
        else
            votes[p] += 1;
    }

    function winner() public view returns(uint w) {
        require(state == State.Done);

        uint max;
        for(uint i=0;i<votes.length;i++){
            if(votes[i] > max){
                max = votes[i];
                w = i;
            }
        }
    }
}

// =============

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Wallet {

    mapping(address => uint) public balance;
    mapping(address => bool) public frozen;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier notFrozen() {
        require(!frozen[msg.sender]);
        _;
    }

    function deposit() public payable notFrozen {
        balance[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public notFrozen {
        require(balance[msg.sender] >= amount);

        balance[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function transfer(address to, uint amount) public notFrozen {
        require(balance[msg.sender] >= amount);

        balance[msg.sender] -= amount;
        balance[to] += amount;
    }

    function freeze(address user) public {
        require(msg.sender == owner);
        frozen[user] = true;
    }
}