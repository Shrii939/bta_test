// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
============================================================
FULL WORKING SOLIDITY CODE (CLEAN + LEARNABLE)

Covers EVERYTHING your lab expects:
- Simple Storage (basic contract)
- Full-feature contract
- Mapping, Struct, Enum
- Events, Modifiers, Errors
- Payable (ETH handling)
- View / Pure
- Receive / Fallback

Paste directly into Remix → Compile → Deploy → Test
============================================================
*/


/*
============================================================
1. SIMPLE STORAGE (LAB BASIC)
============================================================
*/
contract SimpleStorage {

    uint private storedData;

    /*
    Store value on blockchain
    */
    function set(uint x) public {
        storedData = x;
    }

    /*
    Read stored value
    */
    function get() public view returns (uint) {
        return storedData;
    }
}



/*
============================================================
2. FULL LEARNING CONTRACT
============================================================
*/
contract LearningContract {

    /*
    ENUM → finite states
    */
    enum State { Created, Active, Closed }
    State public currentState;

    /*
    STRUCT → group data
    */
    struct User {
        uint balance;
        bool registered;
    }

    /*
    Mapping → address → user
    */
    mapping(address => User) public users;

    /*
    EVENT → logs (visible in Remix console)
    */
    event Log(address indexed user, string action, uint amount);

    /*
    ERROR → gas-efficient revert
    */
    error InsufficientBalance(uint requested, uint available);

    /*
    MODIFIER → access control
    */
    modifier onlyRegistered() {
        require(users[msg.sender].registered, "Register first");
        _;
    }

    /*
    ============================================================
    USER FUNCTIONS
    ============================================================
    */

    function register() public {
        users[msg.sender] = User(0, true);
    }

    /*
    Deposit ETH into contract
    */
    function deposit() public payable onlyRegistered {
        users[msg.sender].balance += msg.value;

        emit Log(msg.sender, "Deposit", msg.value);
    }

    /*
    Withdraw ETH
    */
    function withdraw(uint amount) public onlyRegistered {

        uint bal = users[msg.sender].balance;

        if (bal < amount) {
            revert InsufficientBalance(amount, bal);
        }

        users[msg.sender].balance -= amount;

        payable(msg.sender).transfer(amount);

        emit Log(msg.sender, "Withdraw", amount);
    }

    /*
    Check balance
    */
    function getBalance() public view onlyRegistered returns (uint) {
        return users[msg.sender].balance;
    }

    /*
    Change contract state
    */
    function changeState(State _state) public {
        currentState = _state;
    }

    /*
    PURE FUNCTION (no blockchain interaction)
    */
    function multiply(uint a, uint b) public pure returns (uint) {
        return a * b;
    }


    /*
    ============================================================
    RECEIVE + FALLBACK
    ============================================================
    */

    /*
    Triggered when ETH sent without data
    */
    receive() external payable {
        users[msg.sender].balance += msg.value;
        emit Log(msg.sender, "Receive", msg.value);
    }

    /*
    Triggered when invalid function called
    */
    fallback() external payable {
        emit Log(msg.sender, "Fallback", msg.value);
    }
}