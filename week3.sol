// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
============================================================
FULL WORKING SMART CONTRACT (FOR LEARNING)
Covers:
- State variables
- Mapping
- Struct
- Enum
- Events
- Modifiers
- Errors
- Payable functions
- View & Pure
- Receive & Fallback
============================================================
*/

contract LearningContract {

    /*
    ============================================================
    ENUM: Represents contract state
    ============================================================
    */
    enum State { Created, Active, Closed }
    State public currentState;

    /*
    ============================================================
    STRUCT: Custom user structure
    ============================================================
    */
    struct User {
        uint balance;
        bool registered;
    }

    /*
    ============================================================
    MAPPING: Store users by address
    ============================================================
    */
    mapping(address => User) public users;

    /*
    ============================================================
    EVENT: Logs actions on blockchain
    ============================================================
    */
    event Log(address indexed user, string action, uint amount);

    /*
    ============================================================
    ERROR: Efficient error handling
    ============================================================
    */
    error NotEnoughBalance(uint requested, uint available);

    /*
    ============================================================
    MODIFIER: Restrict access to registered users
    ============================================================
    */
    modifier onlyRegistered() {
        require(users[msg.sender].registered, "User not registered");
        _;
    }

    /*
    ============================================================
    FUNCTION: Register user
    ============================================================
    */
    function register() public {
        users[msg.sender] = User(0, true);
    }

    /*
    ============================================================
    FUNCTION: Deposit ETH
    - payable allows receiving Ether
    ============================================================
    */
    function deposit() public payable onlyRegistered {
        users[msg.sender].balance += msg.value;

        emit Log(msg.sender, "Deposit", msg.value);
    }

    /*
    ============================================================
    FUNCTION: Withdraw ETH
    ============================================================
    */
    function withdraw(uint amount) public onlyRegistered {
        uint bal = users[msg.sender].balance;

        if (bal < amount) {
            revert NotEnoughBalance(amount, bal);
        }

        users[msg.sender].balance -= amount;

        payable(msg.sender).transfer(amount);

        emit Log(msg.sender, "Withdraw", amount);
    }

    /*
    ============================================================
    FUNCTION: Get balance (READ ONLY)
    ============================================================
    */
    function getBalance() public view onlyRegistered returns (uint) {
        return users[msg.sender].balance;
    }

    /*
    ============================================================
    FUNCTION: Change state
    ============================================================
    */
    function changeState(State _state) public {
        currentState = _state;
    }

    /*
    ============================================================
    PURE FUNCTION: No blockchain interaction
    ============================================================
    */
    function multiply(uint a, uint b) public pure returns (uint) {
        return a * b;
    }

    /*
    ============================================================
    RECEIVE FUNCTION:
    Triggered when ETH sent without data
    ============================================================
    */
    receive() external payable {
        users[msg.sender].balance += msg.value;

        emit Log(msg.sender, "Receive", msg.value);
    }

    /*
    ============================================================
    FALLBACK FUNCTION:
    Triggered when function not found
    ============================================================
    */
    fallback() external payable {
        emit Log(msg.sender, "Fallback", msg.value);
    }
}


/*
============================================================
SEPARATE SIMPLE CONTRACT (LAB REQUIRED)
============================================================
*/

contract SimpleStorage {

    /*
    Stores a single value permanently
    */
    uint storedData;

    /*
    Set value
    */
    function set(uint x) public {
        storedData = x;
    }

    /*
    Get value
    */
    function get() public view returns (uint) {
        return storedData;
    }
}