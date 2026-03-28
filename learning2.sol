// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
=====================================================================
SOLIDITY BASICS — READ THIS LIKE CODE NOTES (NOT THEORY)
=====================================================================

You don’t “understand Solidity” today.
You learn patterns. This file is those patterns.

=====================================================================
1. CONTRACT = CLASS (ENTRY POINT)
=====================================================================

Everything lives inside a contract.
Think of it like a Java class.
*/

contract Basics {

    /*
    ================================================================
    2. DATA TYPES (YOU WILL USE THESE ONLY)
    ================================================================

    uint        → positive integers (0,1,2…)
    int         → signed integers (-1, +1)
    bool        → true / false
    address     → Ethereum account (like user ID)
    string      → text
    bytes       → raw data

    DEFAULT VALUES:
    uint = 0
    bool = false
    address = 0x000...
    */

    uint public number = 10;
    bool public flag = true;
    address public owner;
    string public name = "Solidity";

    /*
    ================================================================
    3. VISIBILITY (IMPORTANT FOR EXAM)
    ================================================================

    public   → anyone can read
    private  → only inside contract
    internal → inside + inherited contracts
    external → only outside calls

    RULE:
    - Use public for reading values
    - Use private for internal logic
    */

    uint private secret = 999;

    /*
    ================================================================
    4. CONSTRUCTOR (INITIALIZATION)
    ================================================================

    Runs ONLY ONCE when contract is deployed
    Used to set owner / initial values
    */

    constructor() {
        owner = msg.sender; // person who deployed contract
    }

    /*
    ================================================================
    5. GLOBAL VARIABLES (VERY IMPORTANT)
    ================================================================

    msg.sender → who called function
    msg.value  → ETH sent
    block.timestamp → current time

    These are used everywhere
    */

    /*
    ================================================================
    6. FUNCTIONS (HOW TO WRITE)
    ================================================================

    function name(parameters) visibility returns(type)

    TYPES:
    - normal
    - view (read only)
    - pure (no blockchain interaction)
    - payable (accept ETH)
    */

    // NORMAL FUNCTION (modifies state)
    function setNumber(uint _num) public {
        number = _num;
    }

    // VIEW FUNCTION (only read, no change)
    function getNumber() public view returns(uint) {
        return number;
    }

    // PURE FUNCTION (no state read/write)
    function add(uint a, uint b) public pure returns(uint) {
        return a + b;
    }

    // PAYABLE FUNCTION (accept ETH)
    function deposit() public payable {
        // msg.value contains ETH sent
    }

    /*
    ================================================================
    7. REQUIRE (VALIDATION)
    ================================================================

    Stops execution if condition fails
    */

    function checkOwner() public view {
        require(msg.sender == owner, "Not owner");
    }

    /*
    ================================================================
    8. MAPPING (KEY → VALUE STORAGE)
    ================================================================

    Used everywhere for users
    */

    mapping(address => uint) public balances;

    function addBalance(uint amount) public {
        balances[msg.sender] += amount;
    }

    /*
    ================================================================
    9. STRUCT (CUSTOM DATA TYPE)
    ================================================================
    */

    struct User {
        uint balance;
        bool active;
    }

    mapping(address => User) public users;

    function createUser() public {
        users[msg.sender] = User(100, true);
    }

    /*
    ================================================================
    10. MODIFIER (REUSABLE CONDITIONS)
    ================================================================
    */

    modifier onlyOwner() {
        require(msg.sender == owner, "Not allowed");
        _;
    }

    function restricted() public onlyOwner {
        // only owner can execute
    }

    /*
    ================================================================
    11. EVENTS (LOGGING)
    ================================================================
    */

    event Action(address user, uint value);

    function logSomething(uint val) public {
        emit Action(msg.sender, val);
    }

    /*
    ================================================================
    12. ENUM (STATES)
    ================================================================
    */

    enum State { Start, Running, End }
    State public currentState;

    function changeState(State _state) public {
        currentState = _state;
    }

    /*
    ================================================================
    13. IF / LOOP (BASIC LOGIC)
    ================================================================
    */

    function loopExample() public pure returns(uint) {
        uint sum = 0;

        for(uint i = 0; i < 5; i++) {
            sum += i;
        }

        return sum;
    }

    /*
    ================================================================
    14. TRANSFER ETH
    ================================================================
    */

    function withdraw(uint amount) public {
        require(address(this).balance >= amount);

        payable(msg.sender).transfer(amount);
    }

    /*
    ================================================================
    15. RECEIVE FUNCTION
    ================================================================
    */

    receive() external payable {
        // triggered when ETH sent directly
    }
}


/*
=====================================================================
FINAL MENTAL MODEL (MEMORIZE THIS)

contract {
    state variables
    constructor
    modifiers
    mappings / structs
    functions
}

FUNCTION FLOW:
input → require checks → logic → update state → return

THAT'S SOLIDITY.
=====================================================================
*/