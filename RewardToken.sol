pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable {
    constructor() ERC20("Reward Token","RDT") {
        //_mint(msg.sender, 100 * 10**18);
    }
    function mint(address to, uint256 amount) public onlyOwner{
        _mint(to, amount);
    }
}
