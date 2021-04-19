// todo: change from using drizzle use usedapp.io
// https://github.com/EthWorks/useDApp/tree/master/packages/example
// https://usedapp.readthedocs.io/en/latest/

import react, { Component } from 'react';
import { Drizzle } from '@drizzle/store';
// import drizzle from './drizzleOptions'
import xStarterPoolPairB from './artifacts/contracts/xStarterPoolPairB.sol/xStarterPoolPairB.json'
import { DrizzleContext } from '@drizzle/react-plugin'
import Container from "./Container";


const drizzleOptions = {
  contracts: [xStarterPoolPairB]
}

const drizzle = new Drizzle(drizzleOptions)


class App extends Component {
  render() {
    return (
      <DrizzleContext.Provider drizzle={drizzle}>
        <DrizzleContext.Consumer>
      {drizzleContext => {
        const {drizzle, drizzleState, initialized} = drizzleContext;
        console.log('drizzle', drizzleContext)
        if(!initialized) {
          return "Loading..."
        }

        return (
            <Container drizzle={drizzle} drizzleState={drizzleState} />
          )
        }}
    </DrizzleContext.Consumer>
      </DrizzleContext.Provider>
    )
  }
}


export default App;
