import { Drizzle } from '@drizzle/store';
import xStarterPoolPairB from './artifacts/contracts/xStarterPoolPairB.sol/xStarterPoolPairB.json'


const drizzleOptions = {
    contracts: [xStarterPoolPairB]
}

const drizzle = new Drizzle(drizzleOptions)
export default drizzle;

