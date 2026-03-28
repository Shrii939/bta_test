// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
====================================================================
ROBUST BALLOT DAPP (LAB + EDGE CASE HANDLING)

Covers:
- Chairperson control
- Strict state machine
- One person → one vote
- Chairperson vote weight = 2
- Full validation + edge cases
- Safer patterns (no silent bugs)

States:
Init → Regs → Vote → Done
====================================================================
*/

contract Ballot {

    /*
    ================================================================
    ENUM: Voting lifecycle
    ================================================================
    */
    enum State { Init, Regs, Vote, Done }
    State public state;

    /*
    ================================================================
    STRUCT: Voter
    ================================================================
    */
    struct Voter {
        bool registered;
        bool voted;
        uint voteIndex;
    }

    /*
    ================================================================
    STORAGE
    ================================================================
    */
    address public immutable chairperson;
    uint public immutable numProposals;

    mapping(address => Voter) private voters;
    uint[] private voteCounts;

    bool private winnerComputed;
    uint private winnerIndex;

    /*
    ================================================================
    EVENTS (for visibility in Remix logs)
    ================================================================
    */
    event StateChanged(State newState);
    event VoterRegistered(address voter);
    event VoteCast(address voter, uint proposal, uint weight);
    event WinnerComputed(uint winner, uint votes);

    /*
    ================================================================
    ERRORS (gas efficient)
    ================================================================
    */
    error NotChairperson();
    error InvalidState();
    error AlreadyRegistered();
    error NotRegistered();
    error AlreadyVoted();
    error InvalidProposal();
    error InvalidTransition();
    error NoProposals();

    /*
    ================================================================
    MODIFIERS
    ================================================================
    */
    modifier onlyChair() {
        if (msg.sender != chairperson) revert NotChairperson();
        _;
    }

    modifier inState(State _state) {
        if (state != _state) revert InvalidState();
        _;
    }

    /*
    ================================================================
    (a) CONSTRUCTOR
    - Initializes proposals
    - Sets chairperson
    ================================================================
    */
    constructor(uint _numProposals) {
        if (_numProposals == 0) revert NoProposals();

        chairperson = msg.sender;
        numProposals = _numProposals;
        voteCounts = new uint[](_numProposals);

        state = State.Init;
    }

    /*
    ================================================================
    (b) changeState()
    Strict forward-only transitions
    ================================================================
    */
    function changeState(uint next) external onlyChair {

        if (next == 1 && state == State.Init) {
            state = State.Regs;
        }
        else if (next == 2 && state == State.Regs) {
            state = State.Vote;
        }
        else if (next == 3 && state == State.Vote) {
            state = State.Done;
        }
        else {
            revert InvalidTransition();
        }

        emit StateChanged(state);
    }

    /*
    ================================================================
    (c) register()
    - Only chairperson
    - Only in Regs phase
    - Prevent duplicate registration
    - Prevent registering already voted user
    ================================================================
    */
    function register(address voterAddr)
        external
        onlyChair
        inState(State.Regs)
    {
        Voter storage v = voters[voterAddr];

        if (v.registered) revert AlreadyRegistered();
        if (v.voted) revert AlreadyVoted();

        v.registered = true;

        emit VoterRegistered(voterAddr);
    }

    /*
    ================================================================
    (d) vote()
    - Only registered voters
    - Only in Vote phase
    - One vote per user
    - Chairperson weight = 2
    ================================================================
    */
    function vote(uint proposal)
        external
        inState(State.Vote)
    {
        Voter storage v = voters[msg.sender];

        if (!v.registered) revert NotRegistered();
        if (v.voted) revert AlreadyVoted();
        if (proposal >= numProposals) revert InvalidProposal();

        v.voted = true;
        v.voteIndex = proposal;

        uint weight = (msg.sender == chairperson) ? 2 : 1;

        voteCounts[proposal] += weight;

        emit VoteCast(msg.sender, proposal, weight);
    }

    /*
    ================================================================
    (e) reqWinner()
    - Only in Done phase
    - Computes winner every call (as required)
    ================================================================
    */
    function reqWinner()
        external
        inState(State.Done)
        returns (uint winner)
    {
        uint maxVotes = 0;
        uint winningIndex = 0;

        for (uint i = 0; i < numProposals; i++) {
            if (voteCounts[i] > maxVotes) {
                maxVotes = voteCounts[i];
                winningIndex = i;
            }
        }

        winnerIndex = winningIndex;
        winnerComputed = true;

        emit WinnerComputed(winningIndex, maxVotes);

        return winningIndex;
    }

    /*
    ================================================================
    EXTRA VIEW FUNCTIONS (for testing / Remix clarity)
    ================================================================
    */

    function getVotes(uint proposal) external view returns (uint) {
        if (proposal >= numProposals) revert InvalidProposal();
        return voteCounts[proposal];
    }

    function isRegistered(address user) external view returns (bool) {
        return voters[user].registered;
    }

    function hasVoted(address user) external view returns (bool) {
        return voters[user].voted;
    }

    function getCurrentState() external view returns (State) {
        return state;
    }

    function getWinner() external view returns (uint) {
        require(winnerComputed, "Winner not computed yet");
        return winnerIndex;
    }
}