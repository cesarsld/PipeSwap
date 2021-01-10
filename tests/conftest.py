import pytest


@pytest.fixture(scope="function", autouse=True)
def shared_setup(fn_isolation):
    pass


@pytest.fixture()
def minter(accounts):
    return accounts.at("0x2F0b23f53734252Bda2277357e97e1517d6B042A", force=True)

@pytest.fixture()
def me(accounts):
    return accounts.at("0x742d35cc6634c0532925a3b844bc454e4438f44e", force=True)

@pytest.fixture()
def big(accounts):
    return accounts.at("0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e", force=True)

@pytest.fixture()
def axie(interface):
    return interface.IAxie("0xf5b0a3efb8e8e4c201e2a935f110eaaf3ffecb8d")

@pytest.fixture()
def axiearb(OriginArb, me):
    return OriginArb.deploy({'from': me})

@pytest.fixture()
def woa(interface, minter):
    return interface.IERC20("0xEC0A0915A7c3443862B678B0d4721C7aB133FDCf", owner=minter)

@pytest.fixture()
def receiver(accounts):
    return accounts[2]

@pytest.fixture()
def weth(interface, minter):
    return interface.Weth("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", owner=minter)

@pytest.fixture()
def dai(interface, minter):
    return interface.Weth("0x6b175474e89094c44da98b954eedeac495271d0f", owner=minter)

@pytest.fixture()
def tusd(interface, minter):
    return interface.Weth("0x0000000000085d4780B73119b644AE5ecd22b376", owner=minter)

@pytest.fixture()
def usdc(interface, minter):
    return interface.IERC20("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", owner=minter)

@pytest.fixture()
def hoot(HootCoin, minter):
    return HootCoin.deploy({"from": minter})

@pytest.fixture()
def lego(Lego,  minter):
    return Lego.deploy({'from': minter})