import React, {Component} from 'react'
import Web3 from 'web3'
import axios from 'axios'
import GladiatorsGame from '../abis/GladiatorsGame.json'
import GladiatorNFT from '../abis/GladiatorNFT.json'

class Profile extends Component {

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
            window.alert("GameContract not deployed on the blockchain")
        }

        const isNFTDeployed = GladiatorNFT.networks[this.state.networkId]

        if(isNFTDeployed){
            const abi = GladiatorNFT.abi
            const address = isNFTDeployed.address
            const contract = new web3.eth.Contract(abi, address)
            this.setState({nftContract: contract})
        } else {
            window.alert("NFTContract not deployed on the blockchain")
        }

        this.getMyNFT()
    }

    constructor(props){
        super(props)
        this.state = {
            account: "",
            networkId: 5777, //ID de la red con la que interactuamos (localhost)
            gameContract: null,
            nftContract: null,
            myNftImage: null
        }
    }

    //Mostrar información del perfil y el NFT
    getMyData = async() => {
        try {
            const myData = await this.state.gameContract.methods.getMyData().call({from: this.state.account})
            console.log(myData)
        } catch(e) {
            console.log(e)
        }
    }

    getMyNFT = async() => {
        try{
            const myTokenId = await this.state.nftContract.methods.getMyNFT().call({from: this.state.account})
            const myNFT = await this.state.nftContract.methods.tokenURI(myTokenId).call({from: this.state.account})
            console.log(myNFT)
            const metadata = await axios.get(myNFT)
            this.setState({myNftImage: metadata.data.image})
            console.log(metadata)
        } catch(e){
            console.log(e)
        }
    }

    render() {
        return(
            <div>
                <form onSubmit={(event) => {
                    event.preventDefault()
                    this.getMyData()
                }}>
                    <input type="submit"
                           className="btn btn-success w-20"
                           value="Mostrar mis datos"/>
                </form>
                <br></br>
                {   <div>
                        <h1> My NFT </h1>
                        <img src={this.state.myNftImage} width="200"/>
                    </div>
                }
            </div>
        )
    }

} export default Profile