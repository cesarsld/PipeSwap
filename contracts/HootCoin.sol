//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.6;

interface WETH {
	function deposit() external payable;
	function withdraw(uint wad) external;
	function transferFrom(address src, address dst, uint wad) external returns (bool);
}

interface Owl {
	function hootIn() external payable;
	function hootIn(uint wad) external;
	function hootInTo(uint _wad, address _to) external;
	function hootOutEth(uint wad) external;
	function hootOut(uint wad) external;
	function hootOutFrom(uint _wad, address _from) external;

	function totalSupply() external view returns (uint);
	function approve(address guy, uint wad) external returns (bool);
	function transfer(address dst, uint wad) external returns (bool);
	function transferFrom(address src, address dst, uint wad) external returns (bool);
}

contract HootCoin is Owl {
	string public name     = "Hoot Coin";
	string public symbol   = "HOOT";
	uint8  public decimals = 18;

	WETH weth = WETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

	event  Approval(address indexed src, address indexed guy, uint wad);
	event  Transfer(address indexed src, address indexed dst, uint wad);
	event  Deposit(address indexed dst, uint wad);
	event  Withdrawal(address indexed src, uint wad);

	mapping (address => uint)                       public  balanceOf;
	mapping (address => mapping (address => uint))  public  allowance;

	receive() external payable {
		hootIn();
	}
	function hootIn() public override payable {
		_hootIn(msg.value);
		weth.deposit{value: msg.value}();
	}

	function hootIn(uint wad) external override {
		_hootIn(wad);
		weth.transferFrom(msg.sender, address(this), wad);		
	}

	function hootInTo(uint _wad, address _to) public override {
		balanceOf[_to] += _wad;
		weth.transferFrom(msg.sender, address(this), _wad);
		emit Deposit(_to, _wad);
		emit Transfer(address(0), _to, _wad);
	}

	function _hootIn(uint wad) internal {
		balanceOf[msg.sender] += wad;
		emit Deposit(msg.sender, wad);
		emit Transfer(address(0), msg.sender, wad);
	}

	function hootOutEth(uint wad) public override {
		_hootOut(wad);
		weth.withdraw(wad);
		msg.sender.transfer(wad);
	}

	function hootOut(uint wad) public override {
		_hootOut(wad);
		weth.transferFrom(address(this), msg.sender, wad);
	}

	function hootOutFrom(uint _wad, address _from) external override {
		require(balanceOf[_from] >= _wad, "Owl: not enough balance");
		if (_from != msg.sender && allowance[_from][msg.sender] != uint(-1)) {
			require(allowance[_from][msg.sender] >= _wad, "Owl: not enough allowance");
			allowance[_from][msg.sender] -= _wad;
		}
		balanceOf[_from] -= _wad;
		weth.transferFrom(address(this), msg.sender, _wad);
	}

	function _hootOut(uint wad) internal {
		require(balanceOf[msg.sender] >= wad);
		balanceOf[msg.sender] -= wad;
		emit Withdrawal(msg.sender, wad);
	}

	function totalSupply() public override view returns (uint) {
		return address(this).balance;
	}

	function approve(address guy, uint wad) public override returns (bool) {
		allowance[msg.sender][guy] = wad;
		emit Approval(msg.sender, guy, wad);
		return true;
	}

	function transfer(address dst, uint wad) public override returns (bool) {
		return transferFrom(msg.sender, dst, wad);
	}

	function transferFrom(address src, address dst, uint wad) public override returns (bool)
	{
		require(balanceOf[src] >= wad, "Owl: not enough balance");
		if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
			require(allowance[src][msg.sender] >= wad, "Owl: not enough allowance");
			allowance[src][msg.sender] -= wad;
		}
		balanceOf[src] -= wad;
		balanceOf[dst] += wad;
		emit Transfer(src, dst, wad);
		return true;
	}
}