// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract UnsafeBank is ReentrancyGuard {
    mapping(address => uint256) public balances;
    address public owner;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // VULNÉRABILITÉ CRITIQUE : N'importe qui peut devenir propriétaire !
    function setOwner(address _newOwner) public {
        owner = _newOwner;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // VULNÉRABILITÉ HAUTE : Ré-entrance. Le modifier nonReentrant n'est pas utilisé.
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        // L'appel externe est fait AVANT la mise à jour du solde
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] -= _amount;
        emit Withdrawal(msg.sender, _amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
