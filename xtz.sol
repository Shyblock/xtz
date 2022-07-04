pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./RewardToken.sol";
import "./MyToken.sol";
//import "./2erc20_.sol";

contract xtz {

    mapping(address=> uint256) public user_stakingBalance;

    mapping (address=>uint256) public rewardBalance;

    mapping (address=> bool) public isStaking;

    mapping (address=> uint256) public startTime;

    string public name= "xtz";

    RewardToken public rewardToken;
    IERC20 public myToken;

    event TokenStaking(address indexed from, uint256 amount) ;

    event TokenUnstaking(address indexed from, uint256 amount);
    event GetReward(address to, uint256 amount);

    constructor(IERC20 _myToken, RewardToken _rewardToken){
        myToken= _myToken;
        rewardToken=_rewardToken;
    }

    function tokenStaking(uint256 amount) public{
        //require(token == myToken, "You are only allowed to stake the official erc20 token address which was passed into this contract's constructor");
        require(amount>0 && amount<= myToken.balanceOf(msg.sender), "you cannot stake token");
        //require (myToken.allowance(msg.sender, address(this))>=amount,"insufficient allowance");
        if(isStaking[msg.sender]==true){
            uint toTransfer= calculate_totalReward(msg.sender);
            rewardBalance[msg.sender]+=toTransfer;

        }
        myToken.transferFrom(msg.sender,address(this),amount );
        user_stakingBalance[msg.sender]+=amount;
        startTime[msg.sender]=block.timestamp;
        isStaking[msg.sender]=true;
        emit TokenStaking(msg.sender, amount);
    }

    function tokenUnstaking(uint amount) public{
        require(isStaking[msg.sender]=true && user_stakingBalance[msg.sender]>= amount,"not unstaking" );
        uint _transfer= calculate_totalReward(msg.sender);
        startTime[msg.sender]=block.timestamp;
        uint balanceTransfer=amount;
        amount=0;
        user_stakingBalance[msg.sender] -= balanceTransfer;
        myToken.transfer(msg.sender, balanceTransfer);
        rewardBalance[msg.sender] += _transfer;
        if(user_stakingBalance[msg.sender] == 0){
            isStaking[msg.sender] = false;
        }
        emit TokenUnstaking(msg.sender, amount);
    }

    function getReward() public {
        uint256 toTransfer = calculate_totalReward(msg.sender);
        
        require(toTransfer > 0 || rewardBalance[msg.sender] > 0,"Nothing to withdraw" );
            
        if(rewardBalance[msg.sender] != 0){
            uint256 oldBalance = rewardBalance[msg.sender];
            rewardBalance[msg.sender] = 0;
            toTransfer += oldBalance;
        }

        startTime[msg.sender] = block.timestamp;
        rewardToken.mint(msg.sender, toTransfer);
        emit GetReward(msg.sender, toTransfer);
    }

    function calculate_rewardTime(address user) public view returns(uint256){
        uint256 last_timeUpdate = block.timestamp;
        uint256 totalTime = last_timeUpdate - startTime[user];
        return totalTime;
    }

    function calculate_totalReward(address user) public view returns(uint256) {
        uint256 user_time = calculate_rewardTime(user) * 10**18;
        uint256 rate = 86400;
        uint256 timeRate = user_time / rate;
        uint256 reward = (user_stakingBalance[user] * timeRate) / 10**18;
        return reward;
    } 
}
