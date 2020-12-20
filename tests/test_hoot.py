import pytest
import brownie
from brownie import Wei

def test_hoot(hoot, weth, minter, me):
	weth.approve(hoot, 2 ** 256 - 1, {'from':me})
	weth.approve(hoot, 2 ** 256 - 1, {'from':minter})
	hoot.hootIn({'from':me, 'value': Wei("1 ether")})
	assert hoot.balanceOf(me) == Wei("1 ether")
	assert weth.balanceOf(hoot) == Wei("1 ether")
	hoot.hootIn(Wei("10 ether"), {'from':minter})
	assert hoot.balanceOf(minter) == Wei("10 ether")

	pre = weth.balanceOf(me)
	preM = weth.balanceOf(minter)
	hoot.hootOut(Wei("1 ether"), {'from': me})
	assert weth.balanceOf(me) == pre + Wei("1 ether")
	hoot.hootOut(Wei("10 ether"), {'from': minter})
	assert weth.balanceOf(minter) == preM + Wei("10 ether")

def f():
	minter = accounts.at("0x2F0b23f53734252Bda2277357e97e1517d6B042A", force=True)
	me = accounts.at("0xf521Bb7437bEc77b0B15286dC3f49A87b9946773", force=True)
	hoot = HootCoin.deploy({"from": minter})
	weth = interface.ERC20("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", owner=minter)
	weth.approve(hoot, 2 ** 256 - 1, {'from':me})
	weth.approve(hoot, 2 ** 256 - 1, {'from':minter})
	hoot.hootIn({'from':me, 'value': Wei("1 ether")})
	assert hoot.balanceOf(me) == Wei("1 ether")
	assert weth.balanceOf(hoot) == Wei("1 ether")