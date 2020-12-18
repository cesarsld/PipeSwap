pragma solidity ^0.6.0;

import "./IERC20.sol";

interface Weth is IERC20 {
	function deposit() external payable;
    function withdraw(uint wad) external;
}