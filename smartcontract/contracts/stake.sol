// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@klaytn/contracts/token/ERC20/IERC20.sol";
import "@klaytn/contracts/access/Ownable.sol";

contract Staker is Ownable {
    IERC20 public rewardToken;
    IERC20 public stakeToken;

    uint256 constant SECONDS_PER_YEAR = 31536000;

    struct User {
        uint256 stakedAmount;
        uint256 startTime;
        uint256 rewardAccrued;
        address feeDelegate; // Address delegated to pay fees
    }

    mapping(address => User) user;

    uint256 public feePercentage;

    constructor(address _rewardToken) Ownable() {
        rewardToken = IERC20(_rewardToken);
        feePercentage = 1; // 1% fee
    }

    function setStakeToken(address _token) external onlyOwner returns (address _newToken) {
        require(IERC20(_token) != stakeToken, "Token already set");
        require(IERC20(_token) != rewardToken, "Cannot stake reward");
        require(_token != address(0), "Cannot set address zero");

        stakeToken = IERC20(_token);
        _newToken = address(stakeToken);
    }

    function setFeePercentage(uint256 _percentage) external onlyOwner {
        require(_percentage <= 100, "Invalid percentage");
        feePercentage = _percentage;
    }

    function stake(uint256 amount) external {
        User storage _user = user[msg.sender];
        uint256 _amount = _user.stakedAmount;

        stakeToken.transferFrom(msg.sender, address(this), amount);

        if (_amount == 0) {
            _user.stakedAmount = amount;
            _user.startTime = block.timestamp;
        } else {
            updateReward();
            _user.stakedAmount += amount;
        }
    }

    function calcReward() public view returns (uint256 _reward) {
        User storage _user = user[msg.sender];

        uint256 _amount = _user.stakedAmount;
        uint256 _startTime = _user.startTime;
        uint256 duration = block.timestamp - _startTime;

        _reward = (duration * 20 * _amount) / (SECONDS_PER_YEAR * 100);
    }

    function claimReward(uint256 amount) external {
        User storage _user = user[msg.sender];
        updateReward();
        uint256 _claimableReward = _user.rewardAccrued;
        require(_claimableReward >= amount, "Insufficient funds");

        uint256 fee = amount * feePercentage / 100;
        uint256 amountAfterFee = amount - fee;

        _user.rewardAccrued -= amount;

        // Transfer the fee directly if no delegate is set
        if (_user.feeDelegate == address(0)) {
            rewardToken.transfer(owner(), fee);
        } else {
            rewardToken.transferFrom(msg.sender, owner(), fee);
        }

        rewardToken.transfer(msg.sender, amountAfterFee);
    }

    function updateReward() public {
        User storage _user = user[msg.sender];
        uint256 _reward = calcReward();
        _user.rewardAccrued += _reward;
        _user.startTime = block.timestamp;
    }

    function withdraw(uint256 amount) external {
        User storage _user = user[msg.sender];
        uint256 staked = _user.stakedAmount;
        require(staked >= amount, "Insufficient fund");
        updateReward();
        _user.stakedAmount -= amount;
        stakeToken.transfer(msg.sender, amount);
    }

   

    function userInfo(address _user) external view returns (User memory) {
        return user[_user];
    }

    function delegateFee(address _delegate) external {
        user[msg.sender].feeDelegate = _delegate;
    }
}
