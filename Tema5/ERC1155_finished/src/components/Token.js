import React, {Component} from 'react'
import Web3 from 'web3'
import MyToken from '../abis/MyToken.json'

class Token extends Component {

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
        const isDeployed = MyToken.networks[this.state.networkId] //obtener información del contrato desplegado en la red elegida
                                                                          //Devuelve true o false dependiendo de sí lo ha podido cargar o no
        if(isDeployed){
            const abi = MyToken.abi //Obtener la interfaz del contrato
            const address = isDeployed.address
            const contract = new web3.eth.Contract(abi, address) //
            this.setState({tokenContract: contract})
        } else {
            window.alert("Contract not deployed on the blockchain")
        }

    }

    constructor(props){
        super(props)
        this.state = {
            account: "",
            networkId: 5777, //ID de la red con la que interactuamos (localhost)
            tokenContract: null
        }
    }

    //Comprar tokens
    buyTokens = async(amount) => {
        try{
            const amountInWei = Web3.utils.toWei(amount, 'ether');
            console.log(amountInWei)
            let value = amount * 0.01
            value = Web3.utils.toWei(value.toString(), 'ether')
            const tokens = await this.state.tokenContract.methods.buyTokens(amountInWei).send({from: this.state.account, value: value})
            console.log("You bought: ", tokens, " tokens of myToken")
        } catch(e){
            console.log(e)
        }
    }

    render(){
        return(
            <div>
                <form onSubmit={(event) => {
                    event.preventDefault()
                    const amount = this.amount.value
                    this.buyTokens(amount)
                }}>
                    <input type="text"
                           className='form-control mb-1'
                           placeholder='Token amount'
                           ref={(input) => this.amount = input} />

                    <input type='submit'
                           className='btn btn-warning w-20'
                           value="Comprar tokens"/>     
                </form>
            </div>
        )
    }

} export default Token