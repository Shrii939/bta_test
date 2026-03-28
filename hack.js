/*
=====================================================================
JAVASCRIPT BASICS — ONE FILE CRASH COURSE (EXAM SURVIVAL MODE)
=====================================================================

Read top → bottom once.
Then re-type once.
That’s enough to function.

=====================================================================
1. VARIABLES (STORE DATA)
=====================================================================
*/

let number = 10;          // can change
const pi = 3.14;         // cannot change
var oldWay = "avoid";    // outdated, ignore

/*
DATA TYPES
*/
let a = 5;               // number
let b = "hello";         // string
let c = true;            // boolean
let d = null;            // empty
let e = undefined;       // not assigned

/*
=====================================================================
2. ARRAYS (LIST)
=====================================================================
*/

let arr = [1, 2, 3];

arr.push(4);             // add
arr.pop();               // remove last

// loop through array
for (let i = 0; i < arr.length; i++) {
    console.log(arr[i]);
}

/*
=====================================================================
3. OBJECTS (KEY-VALUE, LIKE MAPPING)
=====================================================================
*/

let user = {
    name: "Shridhar",
    age: 22
};

console.log(user.name);  // access

/*
=====================================================================
4. FUNCTIONS (REUSABLE LOGIC)
=====================================================================
*/

// normal function
function add(x, y) {
    return x + y;
}

// arrow function (modern)
const multiply = (x, y) => {
    return x * y;
};

// short arrow
const square = x => x * x;

/*
=====================================================================
5. CONDITIONS (IF / ELSE)
=====================================================================
*/

let val = 10;

if (val > 5) {
    console.log("greater");
} else {
    console.log("smaller");
}

/*
=====================================================================
6. LOOPS
=====================================================================
*/

// for loop
for (let i = 0; i < 3; i++) {
    console.log(i);
}

// for-of (clean)
for (let x of arr) {
    console.log(x);
}

/*
=====================================================================
7. IMPORTANT: THIS (LIKE msg.sender IDEA)
=====================================================================

"this" refers to current object
*/

let obj = {
    name: "JS",
    show: function() {
        console.log(this.name);
    }
};

obj.show();

/*
=====================================================================
8. PROMISES (ASYNC BASIC)
=====================================================================
*/

let promise = new Promise((resolve, reject) => {
    let success = true;

    if (success) resolve("done");
    else reject("error");
});

promise.then(res => console.log(res))
       .catch(err => console.log(err));

/*
=====================================================================
9. ASYNC / AWAIT (SIMPLER PROMISE)
=====================================================================
*/

async function test() {
    let result = await promise;
    console.log(result);
}

/*
=====================================================================
10. SIMPLE CLASS (LIKE CONTRACT STRUCTURE)
=====================================================================
*/

class Wallet {

    constructor() {
        this.balance = 0;
    }

    deposit(amount) {
        this.balance += amount;
    }

    withdraw(amount) {
        if (this.balance >= amount) {
            this.balance -= amount;
        }
    }

    getBalance() {
        return this.balance;
    }
}

let w = new Wallet();
w.deposit(100);
w.withdraw(50);
console.log(w.getBalance());

/*
=====================================================================
FINAL PATTERN (MEMORIZE)

JS FLOW:

variable → function → condition → loop → object/class

=====================================================================

RELATION TO SOLIDITY:

JS object  ~ Solidity mapping
JS class   ~ Solidity contract
this       ~ msg.sender (kind of reference)
function   ~ function
if         ~ require (logic check)

=====================================================================

You don’t need full JS.
You need:
- variables
- functions
- objects
- loops

That’s enough to survive.
=====================================================================
*/