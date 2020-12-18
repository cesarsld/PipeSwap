//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.6;



// sushi router: 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F
// uni router: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

interface Uniswap {
	function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

	function addLiquidity(
		address tokenA,
		address tokenB,
		uint amountADesired,
		uint amountBDesired,
		uint amountAMin,
		uint amountBMin,
		address to,
		uint deadline
	) external returns (uint amountA, uint amountB, uint liquidity);

	function swapExactTokensForTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external returns (uint[] memory amounts);
}