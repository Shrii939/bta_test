// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
============================================================
BALLOT DAPP (WITH COMMENTS FOR LEARNING)
============================================================
*/

contract Ballot {

    // Different phases of voting
    enum State { Init, Regs, Vote, Done }
    State public state;

    // Chairperson (deployer)
    address public chairperson;

    // Number of proposals
    uint public numProposals;

    // Track if user is registered
    mapping(address => bool) public registered;

    // Track if user already voted
    mapping(address => bool) public voted;

    // Vote count for each proposal
    uint[] public votes;

    /*
    CONSTRUCTOR
    - Runs once when contract is deployed
    - Initializes proposals and chairperson
    */
    constructor(uint _numProposals) {
        chairperson = msg.sender; // deployer is chairperson
        numProposals = _numProposals;
        votes = new uint[](_numProposals);
        state = State.Init;
    }

    /*
    MODIFIER
    - Restricts access to chairperson
    */
    modifier onlyChair() {
        require(msg.sender == chairperson, "Not chairperson");
        _;
    }

    /*
    CHANGE STATE FUNCTION
    - Moves contract through phases
    */
    function changeState(uint s) public onlyChair {
        if (s == 1 && state == State.Init)
            state = State.Regs;
        else if (s == 2 && state == State.Regs)
            state = State.Vote;
        else if (s == 3 && state == State.Vote)
            state = State.Done;
        else
            revert("Invalid transition");
    }

    /*
    REGISTER VOTER
    - Only chairperson can register
    - Only in Regs phase
    */
    function register(address user) public onlyChair {
        require(state == State.Regs, "Not in registration phase");
        require(!registered[user], "Already registered");

        registered[user] = true;
    }

    /*
    VOTE FUNCTION
    - Only registered users
    - Only once
    - Chairperson gets weight = 2
    */
    function vote(uint proposal) public {
        require(state == State.Vote, "Not in voting phase");
        require(registered[msg.sender], "Not registered");
        require(!voted[msg.sender], "Already voted");
        require(proposal < numProposals, "Invalid proposal");

        voted[msg.sender] = true;

        if (msg.sender == chairperson)
            votes[proposal] += 2; // chairperson vote weight
        else
            votes[proposal] += 1;
    }

    /*
    GET WINNER
    - Only after voting is done
    - Returns proposal with highest votes
    */
    function reqWinner() public view returns (uint winner) {
        require(state == State.Done, "Voting not finished");

        uint maxVotes = 0;

        for (uint i = 0; i < numProposals; i++) {
            if (votes[i] > maxVotes) {
                maxVotes = votes[i];
                winner = i;
            }
        }
    }
}



/*
============================================================
CRYPTO WALLET DAPP (WITH COMMENTS)
============================================================
*/

contract CryptoWallet {

    // Store balances of users
    mapping(address => uint) private balances;

    // Store frozen accounts
    mapping(address => bool) public frozen;

    // Store owners
    mapping(address => bool) public owners;

    /*
    EVENTS (for logging)
    */
    event Deposit(address user, uint amount);
    event Withdraw(address user, uint amount);
    event Transfer(address from, address to, uint amount);
    event Freeze(address user, bool status);
    event OwnershipChanged(address oldOwner, address newOwner);

    /*
    MODIFIER: Only owner access
    */
    modifier onlyOwner() {
        require(owners[msg.sender], "Not owner");
        _;
    }

    /*
    MODIFIER: Check if account is not frozen
    */
    modifier notFrozen(address user) {
        require(!frozen[user], "Account frozen");
        _;
    }

    /*
    CONSTRUCTOR
    - Initialize multiple owners
    */
    constructor(address[] memory _owners) {
        for (uint i = 0; i < _owners.length; i++) {
            owners[_owners[i]] = true;
        }
    }

    /*
    CHANGE OWNERSHIP
    - Owner transfers ownership to new address
    */
    function changeOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");

        owners[newOwner] = true;
        owners[msg.sender] = false;

        emit OwnershipChanged(msg.sender, newOwner);
    }

    /*
    DEPOSIT FUNCTION
    - Accept ETH and store balance
    */
    function deposit() public payable notFrozen(msg.sender) {
        require(msg.value > 0, "Zero deposit");

        balances[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    /*
    WITHDRAW FUNCTION
    - Withdraw ETH from wallet
    */
    function withdraw(uint amount) public notFrozen(msg.sender) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, amount);
    }

    /*
    TRANSFER FUNCTION
    - Transfer ETH internally
    */
    function transfer(address to, uint amount)
        public
        notFrozen(msg.sender)
        notFrozen(to)
    {
        require(to != address(0), "Invalid address");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }

    /*
    GET BALANCE
    */
    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    /*
    FREEZE ACCOUNT
    - Only owners can freeze/unfreeze
    */
    function freezeAccount(address user, bool status)
        public
        onlyOwner
    {
        frozen[user] = status;

        emit Freeze(user, status);
    }

    /*
    RECEIVE FUNCTION
    - Direct ETH transfer support
    */
    receive() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}