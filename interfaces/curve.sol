pragma solidity ^0.6.6;

// USDTPool = "0x52EA46506B9CC5Ef470C5bf89f17Dc28bB35D85C";
// YPool = "0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51";
// BUSDPool = "0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27";
// sUSDv2Pool = "0xA5407eAE9Ba41422680e2e00537571bcC53efBfD";

interface ICurvePoolInterface {
	function get_dy_underlying(int128 i, int128 j, uint256 dx) external view returns(uint256);
	function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
	function exchange(int128 i, int128 j, uint256 min_dy) external;
}