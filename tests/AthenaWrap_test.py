from brownie import AthenaWrap, accounts, reverts

def getAccount():
	return accounts[0]

def deploy():
	acc = getAccount()
	athena = AthenaWrap.deploy({"from": acc})
	return athena

def test_deploy():
	deploy()

def test_balance():
	C = deploy()
	c = C.address
	assert C.balanceOf(c) == (1000000000) * (10 ** 18) # 1 billion

def test_totalWrapped():
	C = deploy()
	assert C.totalWrapped() == 0

def test_totalUnwrapped():
	C = deploy()
	assert C.totalUnwrapped() == 0

def test_totalWrappedByAddress():
	C = deploy()
	j = 0
	zero = "0x0000000000000000000000000000000000000000"

	with reverts():
		j = C.totalWrappedByAddress(zero)

	assert C.totalWrappedByAddress(accounts[3]) == 0
	assert j == 0

def test_totalUnwrappedByAddress():
	C = deploy()
	j = 0
	zero = "0x0000000000000000000000000000000000000000"

	with reverts():
		j = C.totalUnwrappedByAddress(zero)

	assert C.totalUnwrappedByAddress(accounts[3]) == 0
	assert j == 0

def test_precalculateTaxForWrap():
	C = deploy()
	j = 0

	with reverts():
		j = C.precalculateTaxForWrap(0)

	m = C.precalculateTaxForWrap(1000)

	assert m == (1000 / 1000) # 1 Token
	assert j == 0

def test_withdraw():
	C = deploy()

	with reverts():
		C.withdraw({"from": accounts[3]})

	with reverts():
		C.withdraw({"from": accounts[0]})

	assert accounts[0].balance() == "1000 ether"

def test_wrap():
	C = deploy()

	with reverts():
		# C.wrap({"value": "0", "from": accounts[1]})
		accounts[1].transfer(C.address, "0 ether")

	accounts[2].transfer(C.address, "5 ether")

	tax = (1 * 5) * (10 ** 15)
	amt = (5 * 10 ** 18) - tax

	assert accounts[2].balance() == "995 ether"
	assert C.balanceOf(accounts[2]) == amt
	assert C.totalWrapped() == "5 ether"
	assert C.totalUnwrapped() == 0


def test_unwrap():
	C = deploy()

	with reverts():
		# C.wrap({"value": "0", "from": accounts[1]})
		accounts[1].transfer(C.address, "0 ether")

	accounts[2].transfer(C.address, "5 ether")

	tax = (1 * 5) * (10 ** 15)
	amt = (5 * 10 ** 18) - tax

	assert accounts[2].balance() == "990 ether"
	assert C.balanceOf(accounts[2]) == amt
	assert C.totalWrapped() == "5 ether"
	assert C.totalUnwrapped() == 0

	# with reverts():
	# 	# C.wrap({"value": "0", "from": accounts[1]})
	# 	accounts[1].transfer(C.address, "0 ether")

	# accounts[2].transfer(C.address, "5 ether")

	C.unwrap(amt, {"from": accounts[2]})

	unwrap_tax = (1 * amt) / 1000
	unwrap_amt = amt - unwrap_tax

	maybe_total = (990 * 10 ** 18) + unwrap_amt

	assert accounts[2].balance() > "990 ether"
	assert accounts[2].balance() == maybe_total
	assert C.balanceOf(accounts[2]) == 0
	assert C.totalWrapped() == "5 ether"
	assert C.totalUnwrapped() == amt

def test_withdraw2():
	C = deploy()

	with reverts():
		C.withdraw({"from": accounts[3]})

	with reverts():
		C.withdraw({"from": accounts[0]})

	with reverts():
		# C.wrap({"value": "0", "from": accounts[1]})
		accounts[1].transfer(C.address, "0 ether")

	accounts[2].transfer(C.address, "5 ether")

	C.withdraw({"from": accounts[0]})

	tax_should_be = 5 * 10 ** 15
	total = (100 * 10 ** 18) + (5 * 10 ** 15)

	assert accounts[0].balance() >= "1000 ether"