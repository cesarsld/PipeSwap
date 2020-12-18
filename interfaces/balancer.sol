pragma solidity ^0.6.6;

interface BPool {
	function swapExactAmountIn(
		address tokenIn,
		uint tokenAmountIn,
		address tokenOut,
		uint minAmountOut,
		uint maxPrice
	) external returns (uint tokenAmountOut, uint spotPriceAfter);

	function calcOutGivenIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint tokenAmountIn,
        uint swapFee
    ) external pure returns (uint tokenAmountOut);

	function getDenormalizedWeight(address token) external view returns (uint);
	
	function totalSupply() external view returns (uint);

	// gives _totalWeight
	function getTotalDenormalizedWeight() external view returns (uint);

	function getSwapFee() external view returns (uint);

	function getBalance(address token) external view returns (uint);

}