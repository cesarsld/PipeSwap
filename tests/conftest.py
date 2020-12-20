import pytest


@pytest.fixture(scope="function", autouse=True)
def shared_setup(fn_isolation):
    pass


@pytest.fixture()
def minter(accounts):
    return accounts.at("0x2F0b23f53734252Bda2277357e97e1517d6B042A", force=True)

@pytest.fixture()
def me(accounts):
    return accounts.at("0xf521Bb7437bEc77b0B15286dC3f49A87b9946773", force=True)

@pytest.fixture()
def big(accounts):
    return accounts.at("0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e", force=True)

@pytest.fixture()
def receiver(accounts):
    return accounts[2]

@pytest.fixture()
def weth(interface, minter):
    return interface.Weth("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", owner=minter)

@pytest.fixture()
def usdc(interface, minter):
    return interface.IERC20("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", owner=minter)


@pytest.fixture()
def hoot(HootCoin, minter):
    return HootCoin.deploy({"from": minter})

@pytest.fixture()
def lego(Lego,  minter):
    return Lego.deploy({'from': minter})