// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
    CryptoWallet Smart Contract

    Features:
    - Multiple owners
    - Deposit, Withdraw, Transfer Ether
    - Freeze accounts
    - Ownership transfer
    - Balance tracking per user
*/

contract CryptoWallet {

    /* ========== STATE VARIABLES ========== */

    // Mapping to store balances of users
    mapping(address => uint256) private balances;

    // Mapping to check if an address is an owner
    mapping(address => bool) public isOwner;

    // Mapping to check if an account is frozen
    mapping(address => bool) public frozenAccounts;

    // Store list of owners (optional but useful)
    address[] public owners;


    /* ========== EVENTS ========== */

    // Emitted when Ether is deposited
    event Deposit(address indexed user, uint256 amount);

    // Emitted when Ether is withdrawn
    event Withdraw(address indexed user, uint256 amount);

    // Emitted when transfer happens
    event Transfer(address indexed from, address indexed to, uint256 amount);

    // Emitted when ownership changes
    event OwnershipChanged(address indexed oldOwner, address indexed newOwner);

    // Emitted when account is frozen/unfrozen
    event AccountFrozen(address indexed user, bool status);


    /* ========== MODIFIERS ========== */

    // Restrict function to only owners
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    // Prevent frozen accounts from performing actions
    modifier notFrozen() {
        require(!frozenAccounts[msg.sender], "Account is frozen");
        _;
    }


    /* ========== CONSTRUCTOR ========== */

    /*
        Initializes contract with multiple owners
        Accepts an array of addresses and marks them as owners
    */
    constructor(address[] memory _owners) {
        require(_owners.length > 0, "At least one owner required");

        for (uint i = 0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
    }


    /* ========== CORE FUNCTIONS ========== */

    /*
        Change ownership:
        - Only existing owner can call
        - Replaces old owner with new owner
    */
    function changeOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");

        isOwner[msg.sender] = false;
        isOwner[newOwner] = true;

        emit OwnershipChanged(msg.sender, newOwner);
    }


    /*
        Deposit Ether into wallet:
        - Anyone can deposit
        - msg.value contains Ether sent
    */
    function deposit() public payable notFrozen {
        require(msg.value > 0, "Send some Ether");

        balances[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }


    /*
        Withdraw Ether:
        - User can withdraw only their balance
        - Uses transfer for simplicity
    */
    function withdraw(uint256 amount) public notFrozen {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, amount);
    }


    /*
        Transfer Ether internally:
        - Moves balance between users (no actual ETH leaves contract)
    */
    function transfer(address to, uint256 amount) public notFrozen {
        require(!frozenAccounts[to], "Recipient is frozen");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(to != address(0), "Invalid address");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }


    /*
        Get balance of caller
        - Simple view function
    */
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }


    /*
        Freeze or unfreeze an account:
        - Only owners can call
        - Prevents deposit, withdraw, transfer
    */
    function freezeAccount(address user, bool freeze) public onlyOwner {
        frozenAccounts[user] = freeze;

        emit AccountFrozen(user, freeze);
    }
}