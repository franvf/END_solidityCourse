
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./myToken.sol";

contract GladiatorsGame {

    address owner;
    address playerOne;
    address playerTwo;
    uint256 tipJar = 0;
    bool gameStarted;

    MyToken myToken;

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
        helmet,
        armor,
        boots
    }

    enum Weapon {
        sword,
        trident,
        spear
    }

    //Error
    error nonValidSkin();
    error nonValidWeapon();

    //Modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    constructor(address mtkAddress){
        owner = msg.sender;
        myToken = MyToken(mtkAddress);
    }

    //initialize game
    function startGame() external onlyOwner {
        require(myToken.getGladiatorAddress() == address(this), "Game can't start yet");
        gameStarted = true;
    }

    //register player
    function registerPlayer() external {
        require(gameStarted, "Game not started yet");
        require(!registeredPlayers[msg.sender].active, "Player already registerd");

        registeredPlayers[msg.sender].id = address(msg.sender);
        myToken.mint(msg.sender, 50);
        registeredPlayers[msg.sender].tokens = myToken.balanceOf(msg.sender);
        registeredPlayers[msg.sender].active = true;
    }

    //Select items
    function createGladiator(Skin newSkin, Weapon newWeapon) external {
        Player storage currentPlayer = registeredPlayers[msg.sender];
        require(currentPlayer.active, "Player is not registered");
 
        if(newSkin == Skin.helmet) {
            require(currentPlayer.tokens - 15 >= 5, "Player doesn't have enough tokens");
            setNewElement(15, 1);
        } else if(newSkin == Skin.armor){
            require(currentPlayer.tokens - 25 >= 5, "Player doesn't have enough tokens");
            setNewElement(25, 2);
        } else if (newSkin == Skin.boots){
            require(currentPlayer.tokens - 30 >= 5, "Player doesn't have enough tokens");
            setNewElement(30, 3);
        } else {
            revert nonValidSkin();
        }

        if(newWeapon == Weapon.sword) {
            require(currentPlayer.tokens - 15 >= 5, "Player doesn't have enough tokens");
            setNewElement(15, 1);
        } else if(newWeapon == Weapon.trident){
            require(currentPlayer.tokens - 25 >= 5, "Player doesn't have enough tokens");
            setNewElement(25, 2);
        } else if (newWeapon == Weapon.spear){
            require(currentPlayer.tokens - 30 >= 5, "Player doesn't have enough tokens");
            setNewElement(30, 3);
        } else {
            revert nonValidWeapon();
        }

        currentPlayer.gladiator.strengthPoints += (currentPlayer.tokens/2);
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
        require(currentPlayer.tokens >= 5, "You don't have enough points to play");


        myToken.senTokens(msg.sender, address(this), 5);
        currentPlayer.tokens = myToken.balanceOf(msg.sender);

        currentPlayer.tokens -= 5;
        tipJar += 5;

        if(playerOne == address(0)){
            playerOne = msg.sender;
        } else {
            playerTwo = msg.sender;

            //Start fight
            address winnerAddress = startFight(playerOne, playerTwo);

            //Give points
            myToken.senTokens(address(this), winnerAddress, tipJar);
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
        myToken.senTokens(msg.sender, address(myToken), amount);
        currentPlayer.tokens = myToken.balanceOf(msg.sender);
        currentPlayer.gladiator.strengthPoints += points;
    }
}