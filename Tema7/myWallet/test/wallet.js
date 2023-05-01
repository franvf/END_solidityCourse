const {expect} = require("chai")
const {ethers, network} = require('hardhat')
require("@nomicfoundation/hardhat-chai-matchers")

let owner
let account1
let walletFactoryContract
let tokenContract
let userWallet
let timeLockContract
let governorContract
let myTokenContract
let NFTContract
let snapshotId
let gameContract
let callEncoded
let proposalId
let descriptionHashed
let proposalState


describe("Wallet Factory contract", function() {

    it("Deployment", async function() {
        [owner, account1] = await ethers.getSigners()
        snapshotId = await network.provider.send("evm_snapshot", [])
        const walletFactory = await ethers.getContractFactory("UserWalletFactory")
        walletFactoryContract = await walletFactory.deploy()
    })

    it("Wallet owner creation", async function() {
        expect(await walletFactoryContract.buildWallet())
            .to.emit(walletFactoryContract, "walletCreated")
            .withArgs(await walletFactoryContract.getWalletOf(owner.address), owner.address)
    })

    it("Wallet account1 creation", async function() {
        expect(await walletFactoryContract.connect(account1).buildWallet())
            .to.emit(walletFactoryContract, "walletCreated")
            .withArgs(await walletFactoryContract.getWalletOf(account1.address), account1.address)
    })
})

describe("Token contract", function(){
    it("Deployment", async function(){
        const governanceTkn = await ethers.getContractFactory("GovernanceToken")
        // tokenContract = await governanceTkn.deploy()
        tokenContract = governanceTkn.attach("0x8E9301E82F1eab8242730bB2336dF21a6fEb668D")
    })

    it("Owner transfers 50% of tokens to account1", async function() {
        const tokensToTransfer = ethers.utils.parseUnits("50", "ether") //Ethers to wei
        await tokenContract.transfer(account1.address, tokensToTransfer)

        expect(await tokenContract.balanceOf(owner.address)).to.equal(tokensToTransfer)
        expect(await tokenContract.balanceOf(account1.address)).to.equal(tokensToTransfer)
    })

    it("Owner transfer tokens to the wallet", async function() {
        const ownerWalletAddress = await walletFactoryContract.getWalletOf(owner.address)
        let ownerBalance = await tokenContract.balanceOf(owner.address)
        await tokenContract.transfer(ownerWalletAddress, ownerBalance)

        expect(await tokenContract.balanceOf(ownerWalletAddress)).to.equal(ownerBalance)
        expect(await tokenContract.balanceOf(owner.address)).to.equal(0)
    })

    it("Account1 transfer tokens to the wallet", async function() {

        const account1WalletAddress = await walletFactoryContract.getWalletOf(account1.address)
        let account1Balance = await tokenContract.balanceOf(account1.address)
        await tokenContract.connect(account1).transfer(account1WalletAddress, account1Balance)

        expect(await tokenContract.balanceOf(account1WalletAddress)).to.equal(account1Balance)
        expect(await tokenContract.balanceOf(account1.address)).to.equal(0)
    })

    it("Owner wallet delegates tokens", async function() {
        const ownerWalletAddress = await walletFactoryContract.getWalletOf(owner.address)
        userWallet = await ethers.getContractFactory("UserWallet")
        const ownerWalletContract = userWallet.attach(ownerWalletAddress)

        await ownerWalletContract.delegateMyTokens(tokenContract.address)
        const delegated = await tokenContract.delegates(ownerWalletAddress)

        expect(ownerWalletAddress).to.equal(delegated)
    })

    it("Account1 wallet delegates tokens", async function() {
        const account1WalletAddress = await walletFactoryContract.getWalletOf(account1.address)
        userWallet = await ethers.getContractFactory("UserWallet")
        const account1WalletContract = userWallet.attach(account1WalletAddress)

        await account1WalletContract.connect(account1).delegateMyTokens(tokenContract.address)
        const delegated = await tokenContract.delegates(account1WalletAddress)

        expect(account1WalletAddress).to.equal(delegated)
    })
})

describe("Previous steps to voting process", async function() {

    it("Timelock deployment", async function() {
        const timeLock = await ethers.getContractFactory("MyTimeLock")
        // timeLockContract = await timeLock.deploy(0, [], [])
        timeLockContract = timeLock.attach("0xc2c14a8019076FAEe4531c01F9E4F36F1d5DA5bb")
    })

    it("Governor contract deployment", async function() {
        const governor = await ethers.getContractFactory("MyGovernor")
        // governorContract = await governor.deploy(tokenContract.address, timeLockContract.address, tokenContract.address)
        governorContract = governor.attach("0xd449d155fc7734fF18B33f10eEc1478EA619e18D")
    })

    it("MyToken deployment", async function() {
        const myToken = await ethers.getContractFactory("MyToken")
        myTokenContract = await myToken.deploy()
    })

    it("NFT deployment", async function() {
        const nft = await ethers.getContractFactory("GladiatorNFT")
        NFTContract = await nft.deploy("https://gateway.pinata.cloud/ipfs/QmcRWwPJTqfqLAFC7LX1oNwLipvoTsbtjidYbchDzfCove/")
    })

    it("Game deployment and address setting", async function() {
        const game = await ethers.getContractFactory("GladiatorsGame")
        gameContract = await game.deploy(myTokenContract.address, NFTContract.address)

        await NFTContract.setGladiatorAddress(gameContract.address)
        expect(await NFTContract.getGladiatorAddress()).to.equal(gameContract.address)

        await myTokenContract.setGladiatorAddress(gameContract.address)
        expect(await myTokenContract.getGladiatorAddress()).to.equal(gameContract.address)

    })

    it("Transfer gameContract ownership", async function() {
        await gameContract.transferOwnership(timeLockContract.address)
        const gameOwner = await gameContract.owner()
        expect(gameOwner).to.equal(timeLockContract.address)
    })

    it("Modify roles", async function() {
        const proposerHash = await timeLockContract.PROPOSER_ROLE()
        const executorHash = await timeLockContract.EXECUTOR_ROLE()

        await timeLockContract.grantRole(proposerHash, governorContract.address)
        const isProposer = await timeLockContract.hasRole(proposerHash, governorContract.address)
        expect(isProposer).to.equal(true)

        await timeLockContract.grantRole(executorHash, governorContract.address)
        const isExecutor = await timeLockContract.hasRole(executorHash, governorContract.address)
        expect(isExecutor).to.equal(true)
    })

    it("Start game proposal", async function() {
        const functionCallInterface = new ethers.utils.Interface(["function startGame()"])
        callEncoded = functionCallInterface.encodeFunctionData("startGame", [])
        await governorContract.propose([gameContract.address], [0], [callEncoded], "Proposing initialize the game")

        descriptionHashed = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("Proposing initialize the game"))
        
        proposalId = await governorContract.hashProposal([gameContract.address], [0], [callEncoded], descriptionHashed)
        proposalState = await governorContract.state(proposalId)
        expect(proposalState).to.equal(0)

    })        
})

describe("Vote using our wallet", async function() {
    let ownerWalletAddress
    let ownerWalletContract
    let account1WalletAddress
    let account1WalletContract

    it("Owner vote", async function(){
        ownerWalletAddress = await walletFactoryContract.getWalletOf(owner.address)
        userWallet = await ethers.getContractFactory("UserWallet")
        ownerWalletContract = userWallet.attach(ownerWalletAddress)

        await ownerWalletContract.votePurpose(governorContract.address, proposalId, 1)
        const hastVoted = await governorContract.hasVoted(proposalId, ownerWalletAddress)
        expect(hastVoted).to.equal(true)
    })

    it("Account1 vote", async function(){
        account1WalletAddress = await walletFactoryContract.getWalletOf(account1.address)
        userWallet = await ethers.getContractFactory("UserWallet")
        account1WalletContract = userWallet.attach(account1WalletAddress)

        await account1WalletContract.connect(account1).votePurpose(governorContract.address, proposalId, 1)
        const hastVoted = await governorContract.hasVoted(proposalId, account1WalletAddress)
        expect(hastVoted).to.equal(true)
    })

    it("Pre-queue conditions", async function() {
        await tokenContract.mint(0)
        await tokenContract.mint(0)
        
        const proposalState = await governorContract.state(proposalId)
        expect(proposalState).to.equal(4)

    })

    it("Queue purpose", async function() {
        await governorContract.queue([gameContract.address], [0], [callEncoded], descriptionHashed)
        const proposalState = await governorContract.state(proposalId)
        expect(proposalState).to.equal(5)

        
    })

    it("Add wallets to allowedWallets", async function() {
        await governorContract.addAllowedWallet(ownerWalletAddress)
        await governorContract.addAllowedWallet(account1WalletAddress)

        expect(await governorContract.getIsWalletAllowed(ownerWalletAddress)).to.equal(true)
        expect(await governorContract.getIsWalletAllowed(account1WalletAddress)).to.equal(true)
    })

    it("Execute purpose", async function() {
        let isStarted = await gameContract.gameStarted() //Check value before execution
        expect(isStarted).to.equal(false)

        await ownerWalletContract.executePurpose(governorContract.address, tokenContract.address, proposalId, [gameContract.address], [0], [callEncoded], descriptionHashed)
        proposalState = await governorContract.state(proposalId)
        expect(proposalState).to.equal(7)
       

        isStarted = await gameContract.gameStarted()
        expect(isStarted).to.equal(true)

        await network.provider.send("evm_revert", [snapshotId])
    })
})
