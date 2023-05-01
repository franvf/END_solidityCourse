//SPDX-License-Identifier: MIT

import "./myToken.sol";
import "./myNFT.sol";

pragma solidity ^0.8.17;

contract GladiatorsGameEfficient {

    address private owner;
    address private playerOne;
    address private playerTwo;
    bool private gameStarted;
    uint256 tipJar = 0;

    MyToken myToken;
    GladiatorNFT myNFT; 

    //Gladiator 
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

    struct Gladiator {
        Skin skin;
        Weapon weapon;
        uint256 strengthPoints;
        bool isActive;
    }
    
    //MODIFIED
    struct Info {
        uint256 tokenId;
        uint256 totalPoints;
        uint256 amountToPay;
    }

    //Player
    struct Player {
        address id;
        uint256 tokens;
        uint256 battlePoints;
        Gladiator gladiator;
        bool active; 
    }

    //Mappings
    mapping(address => Player) registeredPlayers;
    mapping(bytes32 => Info) startInfo; //MODIFIED

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
        myNFT = GladiatorNFT(nftAddress); 
    }
    
    //initialize game
    function startGame() external onlyOwner {
        require(myToken.getGladiatorAddress() == address(this), "Game can't start yet"); 
        require(myNFT.getGladiatorAddress() == address(this), "Game can't start yet"); 
        initializeInfo(); //MODIFIED
        gameStarted = true;

        emit startedGame(); 
    }

    //register players
    function registerPlayer() external {
        require(gameStarted, "Game not started yet");
        require(!registeredPlayers[msg.sender].active, "Player already registered");

        registeredPlayers[msg.sender].id = address(msg.sender);
        myToken.mint(msg.sender, 50 ether); 
        registeredPlayers[msg.sender].tokens = myToken.balanceOf(msg.sender); 
        registeredPlayers[msg.sender].active = true;

        emit playerRegistered(msg.sender); 
    }

    //Select items (create gladiator)
    function createGladiator(Skin newSkin, Weapon newWeapon) external {
        Player storage currentPlayer = registeredPlayers[msg.sender];
        require(currentPlayer.active, "Player is not registered");

        //calculate hash key
        bytes32 key = keccak256(abi.encodePacked(newSkin, newWeapon));
        Info memory currentInfo = startInfo[key];

        require(myToken.balanceOf(currentPlayer.id) >= currentInfo.amountToPay, "sender balance is too low"); //El jugador debe poder pagar el gladiador
        currentPlayer.tokens = myToken.balanceOf(msg.sender);

        uint256 amount = currentInfo.amountToPay;
        uint256 points = currentInfo.totalPoints;
        uint256 tokenId = currentInfo.tokenId;

        setNewElement(amount, points);   
        myNFT.mint(msg.sender, tokenId);     

        currentPlayer.gladiator.strengthPoints += ((currentPlayer.tokens/1 ether) / 2); 
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
        require(currentPlayer.tokens >= 5 ether, "You don't have enough tokens to play");

        myToken.sendTokens(msg.sender, address(this), 5 ether);

        currentPlayer.tokens = myToken.balanceOf(msg.sender);
        tipJar += 5 ether;

        if(playerOne == address(0)){
            playerOne = msg.sender;
        } else {
            playerTwo = msg.sender;

            address winnerAddress = startFight(playerOne, playerTwo);
            require(winnerAddress != address(0), "Something went wrong");

            myToken.sendTokens(address(this), winnerAddress, tipJar);
            tipJar = 0;

            registeredPlayers[winnerAddress].battlePoints += 2;
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

    //Private functions
    function setNewElement(uint256 amount, uint256 points) private {
        Player storage currentPlayer = registeredPlayers[msg.sender];
        myToken.sendTokens(msg.sender, address(myToken), amount);
        currentPlayer.tokens = myToken.balanceOf(msg.sender);
        currentPlayer.gladiator.strengthPoints += points;
    }

    function initializeInfo() private {
        uint256 counter = 1;
        Info memory currentInfo;
        uint256 tokensToPay;

        for(uint8 i = 0; i <= 2; i++){           
            for(uint8 j = 0; j <= 2; j++){
                if(i == 0){
                    tokensToPay = 15 ether;
                    if(j == 0) tokensToPay += 15 ether;
                    else if(j == 1) tokensToPay += 25 ether;
                    else if(j == 2) tokensToPay += 30 ether;
                } else if (i == 1){
                    tokensToPay = 25 ether;
                    if(j == 0) tokensToPay += 15 ether;
                    else if(j == 1) tokensToPay += 25 ether;
                    else if(j == 2) tokensToPay += 30 ether;
                } else if(i == 2){
                    tokensToPay = 30 ether;
                    if(j == 0) tokensToPay += 15 ether;
                    else if(j == 1) tokensToPay += 25 ether;
                    else if(j == 2) tokensToPay += 30 ether;
                }

                currentInfo.tokenId = counter;
                currentInfo.totalPoints = (i+1)+(j+1);
                currentInfo.amountToPay = tokensToPay;

                bytes32 key = keccak256(abi.encodePacked(i, j));
                startInfo[key] = currentInfo;
                counter++;
            }
        }
    }

    function getInfo(uint8 skin, uint8 weapon) external view returns(Info memory) {
        bytes32 key = keccak256(abi.encodePacked(skin, weapon));
        return startInfo[key];
    }
}