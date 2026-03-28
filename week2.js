/*
============================================================
1. CRYPTOGRAPHIC PRIMITIVES
- SHA-256 & Keccak-256 hashing
- RSA Digital Signature (sign + verify)
============================================================
*/

const crypto = require('crypto');
const { keccak256 } = require('js-sha3');

/*
Compute SHA-256 and Keccak-256 hashes
Input  : message (string)
Output : object containing both hashes
*/
function computeHashes(message) {
    const sha256Hash = crypto.createHash('sha256')
        .update(message)
        .digest('hex');

    const keccakHash = keccak256(message);

    return { sha256Hash, keccakHash };
}

/*
Generate RSA public-private key pair
*/
function generateKeys() {
    return crypto.generateKeyPairSync('rsa', {
        modulusLength: 2048
    });
}

/*
Sign a message using private key
*/
function signMessage(privateKey, message) {
    const signer = crypto.createSign('SHA256');
    signer.update(message);
    signer.end();
    return signer.sign(privateKey, 'hex');
}

/*
Verify signature using public key
*/
function verifySignature(publicKey, message, signature) {
    const verifier = crypto.createVerify('SHA256');
    verifier.update(message);
    verifier.end();
    return verifier.verify(publicKey, signature, 'hex');
}


/*
============================================================
2. SIMPLE BLOCK CREATION & CHAIN LINKING
- Each block stores previous hash
- Ensures immutability via hash chaining
============================================================
*/

class SimpleBlock {
    constructor(index, previousHash, timestamp, data) {
        this.index = index;
        this.previousHash = previousHash;
        this.timestamp = timestamp;
        this.data = data;

        // Hash is computed at creation
        this.hash = this.calculateHash();
    }

    /*
    Calculate SHA-256 hash of block contents
    */
    calculateHash() {
        return crypto.createHash('sha256')
            .update(
                this.index +
                this.previousHash +
                this.timestamp +
                JSON.stringify(this.data)
            )
            .digest('hex');
    }
}

/*
Creating a small blockchain manually
*/
const genesisBlock = new SimpleBlock(0, "0", Date.now(), "Genesis Block");
const block1 = new SimpleBlock(1, genesisBlock.hash, Date.now(), { amount: 100 });
const block2 = new SimpleBlock(2, block1.hash, Date.now(), { amount: 50 });

console.log(genesisBlock, block1, block2);


/*
============================================================
3. PROOF OF WORK BLOCKCHAIN
- Mining uses nonce
- Hash must satisfy difficulty (leading zeros)
============================================================
*/

class Transaction {
    constructor(fromAddress, toAddress, amount) {
        this.fromAddress = fromAddress;
        this.toAddress = toAddress;
        this.amount = amount;
    }
}

class Block {
    constructor(timestamp, transactions, previousHash = '') {
        this.timestamp = timestamp;
        this.transactions = transactions;
        this.previousHash = previousHash;

        /*
        Nonce:
        - Incremented until valid hash found
        */
        this.nonce = 0;

        this.hash = this.calculateHash();
    }

    /*
    Hash includes nonce -> enables mining
    */
    calculateHash() {
        return crypto.createHash('sha256')
            .update(
                this.previousHash +
                this.timestamp +
                JSON.stringify(this.transactions) +
                this.nonce
            )
            .digest('hex');
    }

    /*
    Proof-of-Work mining:
    Keep changing nonce until hash satisfies difficulty
    Example: difficulty = 2 -> hash starts with "00"
    */
    mineBlock(difficulty) {
        while (!this.hash.startsWith("0".repeat(difficulty))) {
            this.nonce++;
            this.hash = this.calculateHash();
        }
        console.log("Block mined:", this.hash);
    }
}

class Blockchain {
    constructor() {
        this.chain = [this.createGenesisBlock()];

        /*
        Difficulty controls mining hardness
        Higher value = more computation
        */
        this.difficulty = 2;

        this.pendingTransactions = [];

        /*
        Reward given to miner after mining
        */
        this.miningReward = 100;
    }

    createGenesisBlock() {
        return new Block(Date.now(), [], "0");
    }

    getLatestBlock() {
        return this.chain[this.chain.length - 1];
    }

    /*
    Add transaction to pending list
    */
    createTransaction(transaction) {
        this.pendingTransactions.push(transaction);
    }

    /*
    Mine all pending transactions
    - Creates a new block
    - Rewards miner
    */
    minePendingTransactions(minerAddress) {
        const block = new Block(
            Date.now(),
            this.pendingTransactions,
            this.getLatestBlock().hash
        );

        block.mineBlock(this.difficulty);

        this.chain.push(block);

        /*
        Reward transaction added for next block
        */
        this.pendingTransactions = [
            new Transaction(null, minerAddress, this.miningReward)
        ];
    }

    /*
    Calculate balance of an address
    */
    getBalance(address) {
        let balance = 0;

        for (const block of this.chain) {
            for (const tx of block.transactions) {
                if (tx.fromAddress === address) balance -= tx.amount;
                if (tx.toAddress === address) balance += tx.amount;
            }
        }

        return balance;
    }
}


/*
============================================================
4. APPLICATION (USAGE)
============================================================
*/

const myCoin = new Blockchain();

myCoin.createTransaction(new Transaction("A", "B", 50));
myCoin.createTransaction(new Transaction("B", "A", 20));

console.log("Mining...");
myCoin.minePendingTransactions("miner1");

console.log("Miner balance:", myCoin.getBalance("miner1"));


/*
============================================================
5. MERKLE TREE
- Efficient verification of transactions
- Root hash represents entire dataset
============================================================
*/

/*
SHA-256 helper
*/
function hash(data) {
    return crypto.createHash('sha256')
        .update(data)
        .digest('hex');
}

/*
Build Merkle Tree
- Pair hashes and hash again
- Repeat until one root remains
*/
function buildMerkleTree(transactions) {
    let layer = transactions.map(tx => hash(tx));

    while (layer.length > 1) {
        let nextLayer = [];

        for (let i = 0; i < layer.length; i += 2) {
            if (i + 1 < layer.length) {
                nextLayer.push(hash(layer[i] + layer[i + 1]));
            } else {
                /*
                If odd number of nodes,
                duplicate last hash
                */
                nextLayer.push(hash(layer[i] + layer[i]));
            }
        }

        layer = nextLayer;
    }

    return layer[0]; // Merkle Root
}

/*
Wrapper to compute root
*/
function computeMerkleRoot(transactions) {
    return buildMerkleTree(transactions);
}

/*
Verify if transaction exists in list
(Simple inclusion check + root consistency)
*/
function verifyTransactionInMerkleTree(transaction, transactions) {
    const root = buildMerkleTree(transactions);

    if (!transactions.includes(transaction)) return false;

    return root === buildMerkleTree(transactions);
}