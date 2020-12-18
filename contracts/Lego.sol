pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "../interfaces/curve.sol";
import "../interfaces/uniswap.sol";
import "../interfaces/mooniswap.sol";
import "../interfaces/balancer.sol";
import "../interfaces/weth.sol";
import "./dydx/ICallee.sol";
import "./dydx/DydxFlashloanBase.sol";

contract Lego is ICallee, DydxFlashloanBase {
	enum Service {
		uniswap_sushi,
		mooniswap,
		balancer,
		curve,
		dydx_loan
	}

	// lego blocks will contain data of tokens to exchange or token ID (for curve) and address on which to execute those calls
	struct LegoBlock {
		Service service;
		address target;
		bytes	data;
	}

	Weth constant weth = Weth(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

	// flash loan should happen as first block and only once, IO token should be WETH
	// todo: exit in my weth fork
	function execBatch(LegoBlock[] memory _legos, uint _amount, uint _maxGasFee, address _to) public {
		require(_simulateBatch(_legos, _amount, _maxGasFee), "No arb");
		_executeBatch(_legos, _amount, 0);
		weth.transfer(_to, weth.balanceOf(address(this)));
	}

	// checks if the pipe execution is profitable
	function _simulateBatch(LegoBlock[] memory _legos, uint _amount, uint _maxGasFee) internal view returns (bool) {
		uint io = _amount;
		uint sub;
		for (uint i = 0; i < _legos.length; i++) {
			if (_legos[i].service == Service.dydx_loan) {
				(, uint amount) = _decodeLoan(_legos[i].data);
				io = amount;
				sub = amount;
			}
			else
				io = _simulateBlockOutcome(_legos[i], io);
		}
		return io > sub + 2 + _maxGasFee;
	}

	// executes the pipe execution
	function _executeBatch(LegoBlock[] memory _legos, uint amount, uint offset) internal {
		uint io = amount;
		for (uint i = offset; i < _legos.length; i++) {
			if (_legos[i].service == Service.dydx_loan){
				(address token, uint loan) = _decodeLoan(_legos[i].data);
				_initiateFlashLoan(_legos[i].target, token, loan, _legos, i + 1);
				break;
			}git remote add origin https://github.com/cesarsld/PipeSwap.git
			else
				io = _executeBlock(_legos[i], io);
		}
	}

	function _executeBlock(LegoBlock memory _lego, uint _in) internal returns(uint out) {
		if (_lego.service == Service.uniswap_sushi) {
			address[] memory path = _decodeUniswap(_lego.data);
			uint[] memory outputs = Uniswap(_lego.target).swapExactTokensForTokens(_in, 0, path, address(this), block.timestamp + 10);
			out = outputs[outputs.length - 1]; 
		}
		else if (_lego.service == Service.mooniswap) {
			(address src, address dst) = _decodeMooniswap(_lego.data);
			if (src == address(0)) {
				weth.withdraw(_in);
				out = Mooniswap(_lego.target).swap{value: _in}(src, dst, _in, 0, address(0));
			}
			else{
				out = Mooniswap(_lego.target).swap(src, dst, _in, 0, address(0));
				if (dst == address(0))
					weth.deposit{value: out}();
			}
		}
		else if (_lego.service == Service.balancer) {
			(address tokenIn, address tokenOut) = _decodeBalancer(_lego.data);
			(out,) = BPool(_lego.target).swapExactAmountIn(tokenIn, _in, tokenOut, 0, uint(-1));
		}
		else if (_lego.service == Service.curve) {
			(int128 a, int128 b) = _decodeCurve(_lego.data);
			out = ICurvePoolInterface(_lego.target).get_dy_underlying(a, b, _in);
			ICurvePoolInterface(_lego.target).exchange_underlying(a, b, _in, 0);
		}
	}

	function _simulateBlockOutcome(LegoBlock memory _lego, uint _in) internal view returns (uint out){
		if (_lego.service == Service.uniswap_sushi) {
			address[] memory path = _decodeUniswap(_lego.data);
			uint[] memory outputs = Uniswap(_lego.target).getAmountsOut(_in, path);
			out = outputs[outputs.length - 1];
		}
		else if (_lego.service == Service.mooniswap) {
			(address src, address dst) = _decodeMooniswap(_lego.data);
			out = Mooniswap(_lego.target).getReturn(src, dst, _in);
		}
		else if (_lego.service == Service.balancer) {
			(address tokenIn, address tokenOut) = _decodeBalancer(_lego.data);
			BPool pool = BPool(_lego.target);
			out = BPool(_lego.target).calcOutGivenIn(
				pool.getBalance(tokenIn),
				pool.getDenormalizedWeight(tokenIn),
				pool.getBalance(tokenOut),
				pool.getDenormalizedWeight(tokenOut),
				_in,
				pool.getSwapFee());
		}
		else if (_lego.service == Service.curve) {
			(int128 a, int128 b) = _decodeCurve(_lego.data);
			out = ICurvePoolInterface(_lego.target).get_dy_underlying(a, b, _in);
		}
		else if (_lego.service == Service.dydx_loan)
			out = _in;
	}

	// function called by dydx to engage flashloan execution, we need to carry on batch execution from here and offset the blocks
	function callFunction(
        address sender,
        Account.Info memory account,
        bytes memory data
    ) public override {
        (uint offset, uint amount, LegoBlock[] memory legos) = abi.decode(data, (uint, uint, LegoBlock[]));
		_executeBatch(legos, offset, amount);
    }

	//flash loan entry
	function _initiateFlashLoan(address _solo, address _token, uint _amount, LegoBlock[] memory _legos, uint _offset)
        internal {
        ISoloMargin solo = ISoloMargin(_solo);

        // Get marketId from token address
        uint marketId = _getMarketIdFromTokenAddress(_solo, _token);

        // Calculate repay amount (_amount + (2 wei))
        // Approve transfer from
        uint repayAmount = _getRepaymentAmountInternal(_amount);
        IERC20(_token).approve(_solo, repayAmount);

        // 1. Withdraw $
        // 2. Call callFunction(...)
        // 3. Deposit back $
        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

        operations[0] = _getWithdrawAction(marketId, _amount);
        operations[1] = _getCallAction(
            // Encode MyCustomData for callFunction
            //abi.encode(MyCustomData({token: _token, repayAmount: repayAmount, data: _data}))
            abi.encode(_offset, _amount, _legos)
        );
        operations[2] = _getDepositAction(marketId, repayAmount);

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        solo.operate(accountInfos, operations);
    }

	function _decodeUniswap(bytes memory data) internal pure returns(address[] memory) {
		return abi.decode(data, (address[]));
	}

	function _decodeMooniswap(bytes memory data) internal pure returns(address, address) {
		return abi.decode(data, (address, address));
	}

	function _decodeCurve(bytes memory data) internal pure returns(int128, int128) {
		return abi.decode(data, (int128, int128));
	}

	function _decodeBalancer(bytes memory data) internal pure returns(address, address) {
		return abi.decode(data, (address, address));
	}

	function _decodeLoan(bytes memory data) internal pure returns(address, uint) {
		return abi.decode(data, (address, uint));
	}

	receive() external payable {}
}