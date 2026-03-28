// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
====================================================================
CRYPTO WALLET DAPP (LAB WEEK 07 & 08)

Features:
- Multiple owners
- Ownership transfer
- Deposit / Withdraw / Transfer ETH
- Account freezing
- Balance tracking
- Full edge case handling
====================================================================
*/

contract CryptoWallet {

    /*
    ================================================================
    STORAGE
    ================================================================
    */

    mapping(address => bool) public owners;      // owner list
    mapping(address => uint) private balances;   // user balances
    mapping(address => bool) public frozen;      // frozen accounts

    /*
    ================================================================
    EVENTS
    ================================================================
    */
    event Deposit(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);
    event Transfer(address indexed from, address indexed to, uint amount);
    event OwnershipChanged(address indexed oldOwner, address indexed newOwner);
    event AccountFrozen(address indexed user, bool status);

    /*
    ================================================================
    ERRORS
    ================================================================
    */
    error NotOwner();
    error ZeroAddress();
    error InsufficientBalance();
    error AccountFrozenError();

    /*
    ================================================================
    MODIFIERS
    ================================================================
    */
    modifier onlyOwner() {
        if (!owners[msg.sender]) revert NotOwner();
        _;
    }

    modifier notFrozen(address user) {
        if (frozen[user]) revert AccountFrozenError();
        _;
    }

    /*
    ================================================================
    (a) CONSTRUCTOR
    - Initialize multiple owners
    ================================================================
    */
    constructor(address[] memory _owners) {
        require(_owners.length > 0, "No owners");

        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid address");
            owners[_owners[i]] = true;
        }
    }

    /*
    ================================================================
    (b) changeOwnership()
    - Only existing owner
    ================================================================
    */
    function changeOwnership(address newOwner)
        external
        onlyOwner
    {
        if (newOwner == address(0)) revert ZeroAddress();

        owners[newOwner] = true;
        owners[msg.sender] = false;

        emit OwnershipChanged(msg.sender, newOwner);
    }

    /*
    ================================================================
    (c) deposit()
    - Anyone can deposit
    - Block if account frozen
    ================================================================
    */
    function deposit()
        external
        payable
        notFrozen(msg.sender)
    {
        require(msg.value > 0, "Zero deposit");

        balances[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    /*
    ================================================================
    (d) withdraw()
    - Ensure sufficient balance
    ================================================================
    */
    function withdraw(uint amount)
        external
        notFrozen(msg.sender)
    {
        if (balances[msg.sender] < amount) revert InsufficientBalance();

        balances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, amount);
    }

    /*
    ================================================================
    (e) transfer()
    - Internal transfer within wallet
    ================================================================
    */
    function transfer(address to, uint amount)
        external
        notFrozen(msg.sender)
        notFrozen(to)
    {
        if (to == address(0)) revert ZeroAddress();
        if (balances[msg.sender] < amount) revert InsufficientBalance();

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }

    /*
    ================================================================
    (f) getBalance()
    ================================================================
    */
    function getBalance()
        external
        view
        returns (uint)
    {
        return balances[msg.sender];
    }

    /*
    ================================================================
    (g) freezeAccount()
    - Only owners can freeze/unfreeze
    ================================================================
    */
    function freezeAccount(address user, bool status)
        external
        onlyOwner
    {
        frozen[user] = status;

        emit AccountFrozen(user, status);
    }

    /*
    ================================================================
    RECEIVE FUNCTION (direct ETH support)
    ================================================================
    */
    receive() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}