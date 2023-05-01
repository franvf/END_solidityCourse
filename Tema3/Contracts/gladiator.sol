
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract GladiatorsGame {

    address owner;
    address playerOne;
    address playerTwo;
    uint256 tipJar = 0;
    bool gameStarted;

    //Mappings
    mapping(address => Player) registeredPlayers;

    //Player
    struct Player{
        address id;
        uint256 points;
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

    constructor(){
        owner = msg.sender;
    }

    //initialize game
    function startGame() external onlyOwner {
        gameStarted = true;
    }

    //register player
    function registerPlayer() external {
        require(gameStarted, "Game not started yet");
        require(!registeredPlayers[msg.sender].active, "Player already registerd");

        registeredPlayers[msg.sender].id = address(msg.sender);
        registeredPlayers[msg.sender].points = 50;
        registeredPlayers[msg.sender].active = true;
    }

    //Select items
    function createGladiator(Skin newSkin, Weapon newWeapon) external {
        Player storage currentPlayer = registeredPlayers[msg.sender];
        require(currentPlayer.active, "Player is not registered");
 
        if(newSkin == Skin.helmet) {
            require(currentPlayer.points - 15 >= 5, "Player doesn't have enough points");
            currentPlayer.points -= 15;
            currentPlayer.gladiator.strengthPoints += 1;
        } else if(newSkin == Skin.armor){
            require(currentPlayer.points - 25 >= 5, "Player doesn't have enough points");
            currentPlayer.points -= 25;
            currentPlayer.gladiator.strengthPoints += 2;
        } else if (newSkin == Skin.boots){
            require(currentPlayer.points - 30 >= 5, "Player doesn't have enough points");
            currentPlayer.points -= 30;
            currentPlayer.gladiator.strengthPoints += 3;
        } else {
            revert nonValidSkin();
        }

        if(newWeapon == Weapon.sword) {
            require(currentPlayer.points - 15 >= 5, "Player doesn't have enough points");
            currentPlayer.points -= 15;
            currentPlayer.gladiator.strengthPoints += 1;
        } else if(newWeapon == Weapon.trident){
            require(currentPlayer.points - 25 >= 5, "Player doesn't have enough points");
            currentPlayer.points -= 25;
            currentPlayer.gladiator.strengthPoints += 2;
        } else if (newWeapon == Weapon.spear){
            require(currentPlayer.points - 30 >= 5, "Player doesn't have enough points");
            currentPlayer.points -= 30;
            currentPlayer.gladiator.strengthPoints += 3;
        } else {
            revert nonValidWeapon();
        }

        currentPlayer.gladiator.strengthPoints += (currentPlayer.points/2);
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
        require(currentPlayer.points >= 5, "You don't have enough points to play");

        currentPlayer.points -= 5;
        tipJar += 5;

        if(playerOne == address(0)){
            playerOne = msg.sender;
        } else {
            playerTwo = msg.sender;

            //Start fight
            address winnerAddress = startFight(playerOne, playerTwo);

            //Give points
            registeredPlayers[winnerAddress].points += tipJar;
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
}