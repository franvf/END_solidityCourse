import React, {Component} from 'react'
import {BrowserRouter, Route, Routes} from 'react-router-dom'
import 'semantic-ui-css/semantic.min.css'
import Header from './Header'
import Game from './Game'
import Profile from './Profile'
import Token from './Token'

class App extends Component {
    render(){
        return(
            <BrowserRouter>
                <Header />
                <main>
                    <Routes>
                        <Route exact path='/' element={<Game />} />
                        <Route exact path='/profile' element={<Profile />} />
                        <Route exact path='/token' element={<Token />} />
                    </Routes>
                </main>
            </BrowserRouter>
        )
    }
} export default App;
