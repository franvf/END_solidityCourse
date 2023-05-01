
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

import "./myToken.sol";
import "./myNFT.sol";


contract GladiatorsGame is Ownable {

    // address owner;
    address playerOne;
    address playerTwo;
    uint256 tipJar = 0;
    bool public gameStarted;

    MyToken myToken;
    GladiatorNFT myNFT;

    //Mappings
    mapping(address => Player) registeredPlayers;

    //Player
    struct Player{
        address id;
        uint256 tokens;
        bool active;
        Gladiator gladiator;
    }

    //Gladiator
    struct Gladiator {
        Skin skin;
        Weapon weapon;
        uint256 strengthPoints;
        bool isActive;
    }

    enum Skin {
        boots,
        helmet,
        armor
    }

    enum Weapon {
        sword,
        spear,
        trident
    }

    //Error
    error nonValidSkin();
    error nonValidWeapon();

    //Events
    event startedGame();
    event playerRegistered(address indexed);

    //Modifier
    // modifier onlyOwner() {
    //     require(msg.sender == owner, "Unauthorized");
    //     _;
    // }

    constructor(address mtkAddress, address nftAddress){
        // owner = msg.sender;
        myToken = MyToken(mtkAddress);
        myNFT = GladiatorNFT(nftAddress);
    }

    //initialize game
    function startGame() external onlyOwner {
        require(myToken.getGladiatorAddress() == address(this), "Game can't start yet");
        require(myNFT.getGladiatorAddress() == address(this), "Game can't start yet");
        gameStarted = true;

        emit startedGame();
    }

    //register player
    function registerPlayer() external {
        require(gameStarted, "Game not started yet");
        require(!registeredPlayers[msg.sender].active, "Player already registerd");

        registeredPlayers[msg.sender].id = address(msg.sender);
        myToken.mint(msg.sender,  50 ether);
        registeredPlayers[msg.sender].tokens = myToken.balanceOf(msg.sender);
        registeredPlayers[msg.sender].active = true;

        emit playerRegistered(msg.sender);
    }

    //Select items
    function createGladiator(Skin newSkin, Weapon newWeapon) external {
        Player storage currentPlayer = registeredPlayers[msg.sender];
        require(currentPlayer.active, "Player is not registered");
        

        if(newSkin == Skin.boots){
            require(currentPlayer.tokens - 15 ether >= 5 ether, "Player doesn't have enough tokens");
            setNewElement(15 ether, 1);

            if(newWeapon == Weapon.sword){
                require(currentPlayer.tokens - 15 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(15 ether, 1);
                myNFT.mint(msg.sender, 1);

            } else if (newWeapon == Weapon.spear){
                require(currentPlayer.tokens - 25 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(25 ether, 2);
                myNFT.mint(msg.sender, 2);

            } else if (newWeapon == Weapon.trident){
                require(currentPlayer.tokens - 30 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(30 ether, 3);
                myNFT.mint(msg.sender, 3);

            } else {
                revert nonValidWeapon();
            }

        } else if (newSkin == Skin.helmet){

            require(currentPlayer.tokens - 25 ether >= 5 ether, "Player doesn't have enough tokens");
            setNewElement(25 ether, 2);

            if(newWeapon == Weapon.sword){
                require(currentPlayer.tokens - 15 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(15 ether, 1);
                myNFT.mint(msg.sender, 1);

            } else if (newWeapon == Weapon.spear){
                require(currentPlayer.tokens - 25 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(25 ether, 2);
                myNFT.mint(msg.sender, 2);

            } else if (newWeapon == Weapon.trident){
                require(currentPlayer.tokens - 30 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(30 ether, 3);
                myNFT.mint(msg.sender, 3);

            } else {
                revert nonValidWeapon();
            }

        } else if (newSkin == Skin.armor){

            require(currentPlayer.tokens - 30 ether >= 5 ether, "Player doesn't have enough tokens");
            setNewElement(30 ether, 3);

            if(newWeapon == Weapon.sword){
                require(currentPlayer.tokens - 15 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(15 ether, 1);
                myNFT.mint(msg.sender, 1);

            } else if (newWeapon == Weapon.spear){
                require(currentPlayer.tokens - 25 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(25 ether, 2);
                myNFT.mint(msg.sender, 2);

            } else if (newWeapon == Weapon.trident){
                require(currentPlayer.tokens - 30 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(30 ether, 3);
                myNFT.mint(msg.sender, 3);

            } else {
                revert nonValidWeapon();
            }

        } else {
            revert nonValidSkin();
        }

        currentPlayer.gladiator.strengthPoints += (currentPlayer.tokens/2 ether);
        currentPlayer.gladiator.skin = newSkin;
        currentPlayer.gladiator.weapon = newWeapon;
        currentPlayer.gladiator.isActive = true; 
    }

    //Fight
    function fight() external returns(Player memory){
        require(registeredPlayers[msg.sender].active, "Player not registered");
        require(registeredPlayers[msg.sender].gladiator.isActive, "Gladiator is not activated yet");
        require(playerOne == address(0) || playerTwo == address(0), "There are no slots available");

        Player storage currentPlayer = registeredPlayers[msg.sender];
        require(currentPlayer.tokens >= 5 ether, "You don't have enough points to play");


        myToken.sendTokens(msg.sender, address(this), 5 ether);
        currentPlayer.tokens = myToken.balanceOf(msg.sender);

        currentPlayer.tokens -= 5 ether;
        tipJar += 5 ether;

        if(playerOne == address(0)){
            playerOne = msg.sender;
        } else {
            playerTwo = msg.sender;

            //Start fight
            address winnerAddress = startFight(playerOne, playerTwo);

            //Give points
            myToken.sendTokens(address(this), winnerAddress, tipJar);
            registeredPlayers[winnerAddress].tokens = myToken.balanceOf(winnerAddress);
            tipJar = 0;

            //Reset variables
            playerOne = address(0);
            playerTwo = address(0);
            
            return registeredPlayers[winnerAddress];
        }

        return registeredPlayers[address(0)];
    }

    function startFight(address p1, address p2) private view returns(address){
        uint p1Pts = registeredPlayers[p1].gladiator.strengthPoints;
        uint p2Pts = registeredPlayers[p2].gladiator.strengthPoints;

        if(p1Pts >= p2Pts){
            return p1;
        } else {
            return p2;
        }
    }

    function getMyData() external view returns(Player memory){
        return registeredPlayers[msg.sender];
    }

    function setNewElement(uint256 amount, uint256 points) private {
        Player storage currentPlayer = registeredPlayers[msg.sender];
        myToken.sendTokens(msg.sender, address(myToken), amount);
        currentPlayer.tokens = myToken.balanceOf(msg.sender);
        currentPlayer.gladiator.strengthPoints += points;
    }
}