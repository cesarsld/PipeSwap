//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.6;

// deployer is 0x71CD6666064C3A1354a3B4dca5fA1E2D3ee7D303
interface Mooniswap {
	function getReturn(address src, address dst, uint256 amount) external view returns(uint256);

	function swap(
		address src,
		address dst,
		uint256 amount,
		uint256 minReturn,
		address referral) external payable returns(uint256 result);
}
