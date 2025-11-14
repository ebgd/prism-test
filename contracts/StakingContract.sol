// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IWisdomToken.sol"; // <-- L'IMPORT LOCAL CRUCIAL !

contract StakingContract {
    IWisdomToken public immutable token;
    address public owner;

    mapping(address => uint256) public staked;
    uint256 public rewardRate = 100; // Unités de récompense par seconde

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IWisdomToken(_tokenAddress);
    }

    function stake(uint256 _amount) public {
        require(_amount > 0, "Cannot stake 0");
        staked[msg.sender] += _amount;
        // Le StakingContract doit avoir l'approbation de l'utilisateur pour transférer des tokens
        token.transferFrom(msg.sender, address(this), _amount);
    }

    // VULNÉRABILITÉ HAUTE : Ré-entrance
    // L'attaquant peut appeler cette fonction à plusieurs reprises avant que son solde ne soit mis à jour.
    function unstake(uint256 _amount) public {
        require(staked[msg.sender] >= _amount, "Insufficient staked balance");

        // L'appel externe est fait AVANT la mise à jour de l'état
        token.transfer(msg.sender, _amount);

        staked[msg.sender] -= _amount;
    }

    // VULNÉRABILITÉ CRITIQUE : Contrôle d'accès manquant
    // N'importe qui peut changer le taux de récompense, potentiellement à une valeur immense.
    function setRewardRate(uint256 _newRate) public {
        rewardRate = _newRate;
    }

    // OPPORTUNITÉ DE GAZ : `rewardRate` est lu depuis le stockage à chaque itération.
    function calculateBulkRewards(address[] memory users) public view returns (uint256[] memory rewards) {
        rewards = new uint256[](users.length);
        for (uint i = 0; i < users.length; i++) {
            // Mauvaise pratique : `rewardRate` est dans la boucle
            rewards[i] = staked[users[i]] * rewardRate; 
        }
        return rewards;
    }

    // OPPORTUNITÉ DE GAZ : Pourrait être `external`
    function getStake(address _user) public view returns(uint256) {
        return staked[_user];
    }
}
