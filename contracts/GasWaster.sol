// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract GasWaster {
    uint256[] public numbers;
    address public admin;

    constructor() {
        admin = msg.sender;
        for (uint i = 0; i < 10; i++) {
            numbers.push(i);
        }
    }

    // OPPORTUNITÉ DE GAZ : `numbers.length` est lu à chaque itération de la boucle.
    function sumArray() public view returns (uint256) {
        uint256 total = 0;
        for (uint i = 0; i < numbers.length; i++) {
            total += numbers[i];
        }
        return total;
    }

    // OPPORTUNITÉ DE GAZ : Cette fonction pourrait être `external` au lieu de `public`.
    function getAdmin() public view returns (address) {
        return admin;
    }
}
