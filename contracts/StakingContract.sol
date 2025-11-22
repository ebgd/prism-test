// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IWisdomToken.sol";

contract StakingContract {
    IWisdomToken public immutable token;
    address public owner;

    mapping(address => uint256) public staked;
    uint256 public rewardRate = 100;
    address[] public stakers;

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IWisdomToken(_tokenAddress);
    }

    function stake(uint256 _amount) public {
        require(_amount > 0, "Cannot stake 0");
        stakers.push(msg.sender);
        staked[msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function unstake(uint256 _amount) public {
        require(staked[msg.sender] >= _amount, "Insufficient staked balance");
        token.transfer(msg.sender, _amount);
        staked[msg.sender] -= _amount;
    }

    function setRewardRate(uint256 _newRate) public {
        rewardRate = _newRate;
    }

    // ✅ PATTERN 1 & 2: uncached-array-length + state-var-in-loop
    function distributeRewards() public {
        for (uint i = 0; i < stakers.length; i++) {
            address staker = stakers[i];
            uint256 reward = staked[staker] * rewardRate;
            staked[staker] += reward;
        }
    }

    // ✅ PATTERN 3: require-with-string
    function calculateBulkRewards(address[] memory users) public view returns (uint256[] memory rewards) {
        require(users.length > 0, "Users array cannot be empty");
        rewards = new uint256[](users.length);
        for (uint i = 0; i < users.length; i++) {
            rewards[i] = staked[users[i]] * rewardRate;
        }
        return rewards;
    }

    // ✅ PATTERN 4: public-to-external
    function getStake(address _user) public view returns(uint256) {
        return staked[_user];
    }
}
