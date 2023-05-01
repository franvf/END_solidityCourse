//SPDX-License-Identifier: MIT

import "./myToken.sol";
import "./myNFT.sol";

pragma solidity ^0.8.17;

contract GladiatorsGame {

    address private owner;
    address private playerOne;
    address private playerTwo;
    bool private gameStarted;
    uint256 tipJar = 0;

    MyToken myToken;
    GladiatorNFT myNFT; //MODIFIED

    //Mappings
    mapping(address => Player) registeredPlayers;

    //Gladiator -> MODIFIED
    enum Skin { 
        boots,  
        helmet,
        armor
    } 

    //MODIFIED
    enum Weapon {
        sword,
        spear,
        trident
    }

    struct Gladiator {
        Skin skin;
        Weapon weapon;
        uint256 strengthPoints;
        bool isActive;
    }

    //Player
    struct Player {
        address id;
        uint256 tokens;
        Gladiator gladiator;
        bool active; 
    }

    //Events
    event startedGame();
    event playerRegistered(address indexed);

    //Errors
    error nonValidSkin();
    error nonValidWeapon();

    //Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    //Constructor 
    constructor(address mtkAddress, address nftAddress){
        owner = msg.sender;
        myToken = MyToken(mtkAddress);
        myNFT = GladiatorNFT(nftAddress); //MODIFIED
    }
    
    //initialize game
    function startGame() external onlyOwner {
        require(myToken.getGladiatorAddress() == address(this), "Game can't start yet"); 
        require(myNFT.getGladiatorAddress() == address(this), "Game can't start yet"); //MODIFIED
        gameStarted = true;

        emit startedGame(); //MODIFIED
    }

    //register players
    function registerPlayer() external {
        require(gameStarted, "Game not started yet");
        require(!registeredPlayers[msg.sender].active, "Player already registered");

        registeredPlayers[msg.sender].id = address(msg.sender);
        myToken.mint(msg.sender, 50 ether);  //MODIFIED
        registeredPlayers[msg.sender].tokens = myToken.balanceOf(msg.sender); 
        registeredPlayers[msg.sender].active = true;

        emit playerRegistered(msg.sender); //MODIFIED
    }

    //Select items (create gladiator)
    function createGladiator(Skin newSkin, Weapon newWeapon) external {
        Player storage currentPlayer = registeredPlayers[msg.sender];

        require(currentPlayer.active, "Player is not registered");
        

        //MODIFIED
        currentPlayer.tokens = myToken.balanceOf(msg.sender); //Actualizar la información de los tokens por si el 
                                                              //usuario ha comprado tokens antes de crear el gladiador
        //Mint the correct NFT 
        if(newSkin == Skin.boots){
            require(currentPlayer.tokens - 15 ether >= 5 ether, "Player doesn't have enough tokens");
            setNewElement(15 ether, 1);
            
            if(newWeapon == Weapon.sword){
                require(currentPlayer.tokens - 15 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(15 ether, 1);
                myNFT.mint(msg.sender, 1);
            } else if(newWeapon == Weapon.spear){
                require(currentPlayer.tokens - 25 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(25 ether, 2);
                myNFT.mint(msg.sender, 2);
            } else if(newWeapon == Weapon.trident) {
                require(currentPlayer.tokens - 30 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(30 ether, 3);
                myNFT.mint(msg.sender, 3);
            } else {
                revert nonValidWeapon();
            }

        } else if(newSkin == Skin.helmet){
            require(currentPlayer.tokens - 25 ether >= 5 ether, "Player doesn't have enough tokens");
            setNewElement(25 ether, 2);
            
            if(newWeapon == Weapon.sword){
                require(currentPlayer.tokens - 15 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(15 ether, 1);
                myNFT.mint(msg.sender, 4);
            } else if(newWeapon == Weapon.spear){
                require(currentPlayer.tokens - 25 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(25 ether, 2);
                myNFT.mint(msg.sender, 5);
            } else if(newWeapon == Weapon.trident) {
                require(currentPlayer.tokens - 30 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(30 ether, 3);
                myNFT.mint(msg.sender, 6);
            } else {
                revert nonValidWeapon();
            }
        } else if(newSkin == Skin.armor){
            require(currentPlayer.tokens - 30 ether >= 5 ether, "Player doesn't have enough tokens");
            setNewElement(30 ether, 3);

            if(newWeapon == Weapon.sword){
                require(currentPlayer.tokens - 15 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(15 ether, 1);
                myNFT.mint(msg.sender, 7);
            } else if(newWeapon == Weapon.spear){
                require(currentPlayer.tokens - 25 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(25 ether, 2);
                myNFT.mint(msg.sender, 8);
            } else if(newWeapon == Weapon.trident) {
                require(currentPlayer.tokens - 30 ether >= 5 ether, "Player doesn't have enough tokens");
                setNewElement(30 ether, 3);
                myNFT.mint(msg.sender, 9);
            } else {
                revert nonValidWeapon();
            }
        } else {
            revert nonValidSkin();
        }

        currentPlayer.gladiator.strengthPoints += ((currentPlayer.tokens/1 ether) / 2); //MODIFIED
        currentPlayer.gladiator.skin = newSkin;
        currentPlayer.gladiator.weapon = newWeapon;
        currentPlayer.gladiator.isActive = true;
    }
    
    //Fight 
    function fight() external returns(address) {
        require(registeredPlayers[msg.sender].active, "Player not registered");
        require(registeredPlayers[msg.sender].gladiator.isActive, "Gladiator is not activated yet");
        require(playerOne == address(0) || playerTwo == address(0), "There are no slots available");

        Player storage currentPlayer = registeredPlayers[msg.sender];
        require(currentPlayer.tokens >= 5 ether, "You don't have enough tokens to play"); //MODIFIED

        myToken.sendTokens(msg.sender, address(this), 5 ether ); //MODIFIED

        currentPlayer.tokens = myToken.balanceOf(msg.sender);
        tipJar += 5 ether; //MODIFIED

        if(playerOne == address(0)){
            playerOne = msg.sender;
        } else {
            playerTwo = msg.sender;

            address winnerAddress = startFight(playerOne, playerTwo);
            require(winnerAddress != address(0), "Something went wrong");

            myToken.sendTokens(address(this), winnerAddress, tipJar);
            tipJar = 0;

            registeredPlayers[winnerAddress].tokens = myToken.balanceOf(winnerAddress);
            playerOne = address(0);
            playerTwo = address(0);

            return registeredPlayers[winnerAddress].id;
        }

        return registeredPlayers[address(0)].id;
    }
    
    function startFight(address p1, address p2) private view returns(address) {

        uint256 p1GlaPts = registeredPlayers[p1].gladiator.strengthPoints;
        uint256 p2GlaPts = registeredPlayers[p2].gladiator.strengthPoints;

        if(p1GlaPts >= p2GlaPts){ 
            return p1;
        } else if(p1GlaPts < p2GlaPts){
            return p2;
        }

        return address(0);
    }

    //Get my data
    function getMyData() external view returns(Player memory){
        return registeredPlayers[msg.sender];
    }

    function getMyTokenAddress() external view returns(address){
        return address(myToken);
    }

    //setters
    function setNewElement(uint256 amount, uint256 points) private {
        Player storage currentPlayer = registeredPlayers[msg.sender];
        myToken.sendTokens(msg.sender, address(myToken), amount);
        currentPlayer.tokens = myToken.balanceOf(msg.sender);
        currentPlayer.gladiator.strengthPoints += points;
    }
}