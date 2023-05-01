const governanceToken = artifacts.require("GovernanceToken")
const timeLock = artifacts.require("MyTimeLock")
const governor = artifacts.require("MyGovernor")
const gladiators = artifacts.require("GladiatorsGame")

contract("GovernanceToken", (accounts) => {

    let gToken
    let amountInWei
    let timeLockContract
    let governorContract
    let gameContract
    let functionCall
    let callEncoded
    let proposalState
    let proposalID
    let descriptionHashed

    it("Token contract transferences", async() => {
        gToken = await governanceToken.deployed()

        amountInWei = web3.utils.toWei("25", "ether")
        await gToken.transfer(accounts[1], amountInWei)
        
        let balance = await gToken.balanceOf.call(accounts[1]) //balanceOf(accounts[1])
        assert.equal(balance.toString(), amountInWei, "Amounts are not equal")

        await gToken.transfer(accounts[2], amountInWei)
        balance = await gToken.balanceOf.call(accounts[2])
        assert.equal(balance.toString(), amountInWei)

        await gToken.transfer(accounts[3], amountInWei)
        balance = await gToken.balanceOf.call(accounts[3])
        assert.equal(balance.toString(), amountInWei)

        balance = await gToken.balanceOf.call(accounts[0])
        assert.equal(balance.toString(), amountInWei)
    })

    it("Token contract delegation", async() => {
        await gToken.delegate(accounts[0])
        let delegated = await gToken.delegates.call(accounts[0])
        assert.equal(delegated.toString(), accounts[0])

        await gToken.delegate(accounts[1], {from: accounts[1]})
        delegated = await gToken.delegates.call(accounts[1])
        assert.equal(delegated.toString(), accounts[1])

        await gToken.delegate(accounts[2], {from: accounts[2]})
        delegated = await gToken.delegates.call(accounts[2])
        assert.equal(delegated.toString(), accounts[2])

        await gToken.delegate(accounts[3], {from: accounts[3]})
        delegated = await gToken.delegates.call(accounts[3])
        assert.equal(delegated.toString(), accounts[3])
    })

    it("Contracts deployed", async() => {
        timeLockContract = await timeLock.deployed()
        governorContract = await governor.deployed()
        gameContract = await gladiators.deployed()
    })

    it("Transfer gameContract ownership", async() => {
        await gameContract.transferOwnership(timeLockContract.address)
        const gameOwner = await gameContract.owner.call()
        assert.equal(gameOwner, timeLockContract.address, "Timelock is not the owner of game")
    })

    it("Modify roles", async() => {
        const proposerHash = await timeLockContract.PROPOSER_ROLE();
        const executorHash = await timeLockContract.EXECUTOR_ROLE();

        await timeLockContract.grantRole(proposerHash, governorContract.address)
        const istProposer = await timeLockContract.hasRole.call(proposerHash, governorContract.address)
        assert.equal(istProposer, true)

        await timeLockContract.grantRole(executorHash, governorContract.address)
        const isExecutor = await timeLockContract.hasRole.call(executorHash, governorContract.address)
        assert.equal(isExecutor, true)
    })

    it("Start game proposal", async() => {
        functionCall = {name: 'startGame',
                            type: 'function',
                            inputs: []}
        
        callEncoded = await web3.eth.abi.encodeFunctionCall(functionCall, []) 

        await governorContract.propose([gameContract.address], [0], [callEncoded], 'Proposing initialize the game')

        descriptionHashed = web3.utils.keccak256('Proposing initialize the game')
        proposalID = await governorContract.hashProposal.call([gameContract.address], [0], [callEncoded], descriptionHashed)
        proposalState = await governorContract.state.call(proposalID)

        assert.equal(proposalState.toString(), 0, "Proposal is not in pending state")

    })

    it("Voting process", async() => {
        await governorContract.castVote(proposalID, 1) //0 -> Against, 1 -> For, 2 -> Abstain 
        let hasVoted = await governorContract.hasVoted.call(proposalID, accounts[0])
        assert.equal(hasVoted, true, "This accounts has not voted yet")

        await governorContract.castVote(proposalID, 1, {from: accounts[1]})
        hasVoted = await governorContract.hasVoted.call(proposalID, accounts[1])
        assert.equal(hasVoted, true, "This accounts has not voted yet")

        await governorContract.castVote(proposalID, 2, {from: accounts[2]})
        hasVoted = await governorContract.hasVoted.call(proposalID, accounts[2])
        assert.equal(hasVoted, true, "This accounts has not voted yet")

        await gToken.mint(0) // Mint to jump a block

        proposalState = await governorContract.state.call(proposalID)
        assert.equal(proposalState.toString(), 4, "Proposal is not in successfull")
    })

    it("Queue proposal", async() => {
        await governorContract.queue([gameContract.address], [0], [callEncoded], descriptionHashed)
        proposalState = await governorContract.state.call(proposalID)
        assert.equal(proposalState.toString(), 5) // 5 means proposal is queued
    })

    it("Execute proposal", async() => {
        let isStarted = await gameContract.gameStarted.call()
        assert.equal(isStarted, false)

        await governorContract.execute([gameContract.address], [0], [callEncoded], descriptionHashed)
        proposalState = await governorContract.state.call(proposalID)
        assert.equal(proposalState.toString(), 7, "Proposal is not executed")

        isStarted = await gameContract.gameStarted.call()
        assert.equal(isStarted, true)
    })
})