import React, {Component} from 'react'
import Web3 from 'web3'
import GladiatorsGame from '../abis/GladiatorsGame.json'

class Game extends Component {

    async componentDidMount(){ //Ejecutar las funciones al refrescar/iniciar la página
        await this.loadMetamask()
        await this.loadBlockchainData()
    }

    //Comprobar wallet instalada (metamask)
    async loadMetamask(){ 
        if(window.ethereum){ //Si la API de metamask está disponible
            window.web3 = new Web3(window.ethereum)
            await window.ethereum.request({method: 'eth_requestAccounts'}) //Petición a la API de metamask para
                                                                           //salta un pop-up de la api de metamask
        } else if(window.web3){ //Versión antigua de la API
            window.web3 = Web3(window.web3.currentProvider)
        } else {
            window.alert("No metamask wallet available")
        }
    }

    //Cargar datos de la blockchain y del smart contract al 
    //que queremos conectarnos
    async loadBlockchainData(){
        const web3 = window.web3 //objeto de la librería web3 que permite interactuar con la blockchain

        const accounts = await web3.eth.getAccounts() 
        this.setState({account: accounts[0]}) //Current account
        const isDeployed = GladiatorsGame.networks[this.state.networkId] //obtener información del contrato desplegado en la red elegida
                                                                          //Devuelve true o false dependiendo de sí lo ha podido cargar o no
        if(isDeployed){
            const abi = GladiatorsGame.abi //Obtener la interfaz del contrato
            const address = isDeployed.address
            const contract = new web3.eth.Contract(abi, address) //
            this.setState({gameContract: contract})
        } else {
            window.alert("Contract not deployed on the blockchain")
        }

    }

    constructor(props){
        super(props)
        this.state = {
            account: "",
            networkId: 5777, //ID de la red con la que interactuamos (localhost)
            gameContract: null
        }
    }

    //Registrar usuario
    registerPlayer = async() => {
        try{
            await this.state.gameContract.methods.registerPlayer().send({from: this.state.account})
        } catch(e){
            console.log(e)
        }
    }

    //crear gladiador
    createGladiator = async(numSkin, numWeapon) => {
        try{
            await this.state.gameContract.methods.createGladiator(numSkin, numWeapon).send({from: this.state.account})
            window.alert("Gladiador creado con éxito")
        } catch(e){
            console.log(e)
        }
    }

    //Luchar
    fight = async() => {
        try{
            await this.state.gameContract.methods.fight().send({from: this.state.account})
        } catch(e) {
            console.log(e)
        }
    }

    render() {
        return(
            <div>
                <form onSubmit={(event) => {
                    event.preventDefault() // No disparar el evento con el valor por    
                                           //defecto a no ser que lo disparemos explicitamente
                    this.registerPlayer()  
                }}>
                    <input type="submit"
                            className="btn btn-primary w-20"
                            value="register" />

                </form>
                <br></br>
                <form onSubmit={(event) => {
                    event.preventDefault()
                    const numSkin = this.numSkin.value
                    const numWeapon = this.numWeapon.value
                    this.createGladiator(numSkin, numWeapon)
                }}>
                    <input type="text"
                           className='form-control mb1'
                           placeholder='Skin number (0 to 2)'
                           ref={(input) => this.numSkin = input} />

                           
                    <input type="text"
                           className='form-control mb1'
                           placeholder='Weapon number (0 to 2)'
                           ref={(input) => this.numWeapon = input} />
                    
                    <input type="submit"
                           className='btn btn-success w-20'
                           value="register gladiator" />
                </form>
                <br></br>
                <form onSubmit={(event) => {
                    event.preventDefault()
                    this.fight()
                }}>
                    <input type="submit"
                           className='btn btn-danger w-20'
                           value="Start fight" />

                </form>
            </div>
        )
    }

} export default Game