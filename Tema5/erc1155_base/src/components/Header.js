import React from 'react';
import {Menu, Button} from 'semantic-ui-react';
import {Link} from 'react-router-dom';

export default() => {
    return(
        <Menu stackable stryle={{marginTop: '25px'}}>
            <Button color='blue' as={Link} to='/'> Game </Button>
        </Menu>
    )
}