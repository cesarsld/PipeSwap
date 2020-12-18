//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.6;


interface Mooniswap {
	function getReturn(address src, address dst, uint256 amount) external view returns(uint256);

	function swap(
		address src,
		address dst,
		uint256 amount,
		uint256 minReturn,
		address referral) external payable returns(uint256 result);
}
