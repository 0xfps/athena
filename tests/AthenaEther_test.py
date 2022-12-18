from brownie import AthenaEther, accounts, reverts

def getAccount():
	return accounts[0]

def deploy():
	acc = getAccount()
	athena = AthenaEther.deploy(accounts[1], {"from": acc})
	return athena

def test_deploy():
	deploy()

def test_balance():
	C = deploy()
	assert C.balanceOf(accounts[1]) == (1000000000) * (10 ** 18) # 1 billion