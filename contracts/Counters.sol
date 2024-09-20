// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        uint256 _value; 
    }

    // Returns the current value of the counter
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    // Increments the counter by 1
    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    // Decrements the counter by 1
    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    // Resets the counter to 0
    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
