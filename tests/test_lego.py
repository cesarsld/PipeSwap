import pytest
import brownie
from brownie import Wei


def test_loan(lego, me, web3, weth):
    weth.deposit({'from':me, 'value': 2})
    weth.transfer(lego, 2, {"from": me})
    assert weth.balanceOf(lego) == 2
    loan_lego = get_loan_lego(
        web3,
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        Wei("1000 ether"),
        "0x1e0447b19bb6ecfdae1e4ae1694b0c3659614e4e"
    )
    legos = [loan_lego]
    lego.execBatch(
        legos, 0, 0, me, "0x0000000000000000000000000000000000000000", {"from": me}
    )
    assert weth.balanceOf(lego) == 0


def test_uniswap(lego, me, web3, weth):
    uni_lego = get_uni_lego(
        web3,
        [
            "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            "0x6b175474e89094c44da98b954eedeac495271d0f"
        ],
        "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
    )
    sushi_lego = get_uni_lego(
        web3,
        [
            "0x6b175474e89094c44da98b954eedeac495271d0f",
            "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
        ],
        "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F"
    )
    legos = [uni_lego, sushi_lego]
    weth.deposit({"from": me, "value": Wei("2 ether")})
    bal = weth.balanceOf(me)
    weth.approve(lego, Wei("100000000 ether"), {"from": me})
    expected = lego.testSimulateBatch(legos, bal)
    lego.execBatch(
        legos, bal, 0, me, "0x0000000000000000000000000000000000000000", {"from": me}
    )
    assert weth.balanceOf(me) == expected

def test_uni_curve(lego, me, web3, weth):
    uni_lego = get_uni_lego(
        web3,
        [
            "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            "0x6b175474e89094c44da98b954eedeac495271d0f",
        ],
        "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
    )
    curve_lego = get_curve_lego(
        web3, 0, 1, "0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51"
    )
    uni_lego_2 = get_uni_lego(
        web3,
        [
            "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
            "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        ],
        "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
    )
    legos = [uni_lego, curve_lego, uni_lego_2]
    weth.deposit({"from": me, "value": Wei("2 ether")})
    bal = weth.balanceOf(me)
    weth.approve(lego, Wei("100000000 ether"), {"from": me})
    expected = lego.testSimulateBatch(legos, bal)
    lego.execBatch(
        legos, bal, 0, me, "0x0000000000000000000000000000000000000000", {"from": me}
    )
    assert weth.balanceOf(me) >= (expected * 99999) / 100000

def test_moon_token(lego, me, web3, weth):
    moon_lego = get_moon_lego(
        web3,
        "0x0000000000000000000000000000000000000000",
        "0x111111111117dc0aa78b770fa6a738034120c302",
        "0x8B1f66e167653308B3fb15493E7489a4bE58d1e5"
    )
    uni_lego = get_uni_lego(
        web3,
        [
            "0x111111111117dc0aa78b770fa6a738034120c302",
            "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
        ],
        "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
    )
    legos = [moon_lego, uni_lego]
    weth.deposit({"from": me, "value": Wei("2 ether")})
    bal = weth.balanceOf(me)
    weth.approve(lego, Wei("100000000 ether"), {"from": me})
    expected = lego.testSimulateBatch(legos, bal)
    print(expected)
    lego.execBatch(
        legos, bal, 0, me, "0x0000000000000000000000000000000000000000", {"from": me}
    )
    assert weth.balanceOf(me) == expected

def test_moon_token2(lego, me, web3, weth):
    moon_lego = get_moon_lego(
        web3,
        "0x111111111117dc0aa78b770fa6a738034120c302",
        "0x0000000000000000000000000000000000000000",
        "0x8B1f66e167653308B3fb15493E7489a4bE58d1e5"
    )
    uni_lego = get_uni_lego(
        web3,
        [
            "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
            "0x111111111117dc0aa78b770fa6a738034120c302"
        ],
        "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
    )
    legos = [uni_lego, moon_lego]
    weth.deposit({"from": me, "value": Wei("2 ether")})
    bal = weth.balanceOf(me)
    weth.approve(lego, Wei("100000000 ether"), {"from": me})
    expected = lego.testSimulateBatch(legos, bal)
    print(expected)
    lego.execBatch(
        legos, bal, 0, me, "0x0000000000000000000000000000000000000000", {"from": me}
    )
    assert weth.balanceOf(me) == expected
    

def test_moon(lego, me, web3, weth):
    moon_lego = get_moon_lego(
        web3,
        "0x0000000000000000000000000000000000000000",
        "0x6b175474e89094c44da98b954eedeac495271d0f",
        "0x75116BD1AB4B0065B44E1A4ea9B4180A171406ED"
    )
    uni_lego = get_uni_lego(
        web3,
        [
            "0x6b175474e89094c44da98b954eedeac495271d0f",
            "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
        ],
        "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
    )
    legos = [moon_lego, uni_lego]
    weth.deposit({"from": me, "value": Wei("2 ether")})
    bal = weth.balanceOf(me)
    weth.approve(lego, Wei("100000000 ether"), {"from": me})
    expected = lego.testSimulateBatch(legos, bal)
    lego.execBatch(
        legos, bal, 0, me, "0x0000000000000000000000000000000000000000", {"from": me}
    )
    assert weth.balanceOf(me) == expected

def get_uni_lego(web3, path, router):
    byte_data = web3.codec.encode_abi(["address[]"], [path])
    return (0, router, byte_data)


def get_moon_lego(web3, token_a, token_b, pool):
    byte_data = web3.codec.encode_abi(["address", "address"], [token_a, token_b])
    return (1, pool, byte_data)


def get_balancer_lego(web3, token_a, token_b, pool):
    byte_data = web3.codec.encode_abi(["address", "address"], [token_a, token_b])
    return (2, pool, byte_data)


def get_curve_lego(web3, token_id_1, token_id_2, pool):
    byte_data = web3.codec.encode_abi(["int128", "int128"], [token_id_1, token_id_2])
    return (3, pool, byte_data)


def get_loan_lego(web3, token, amount, isolo):
    byte_data = web3.codec.encode_abi(["address", "uint256"], [token, amount])
    return (4, isolo, byte_data)
