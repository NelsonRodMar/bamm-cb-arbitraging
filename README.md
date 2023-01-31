# BAMM Arbitrage 

This project use Aave V3 FlashLoan to make profit by buying the ETH discounted sell by B.Protocol Chicken Bond Stability pool [contract](https://etherscan.io/address/0x896d8a30C32eAd64f2e1195C2C8E0932Be7Dc20B). 
<br>
This project use Aave V3 FlashLoan + Uniswap.


## How to install

1. Clone the repo


2. Copy/paste the .env.example file and rename it to .env and fill in the variables


3. Run `forge install`


## How to run test

1. Be sure to have set the 'FOUNDRY_ETH_RPC_URL' variable in the .env file, because the test will fork the mainnet

2. Run the following command 
```bash
forge test
or
forge test -vv #To get more logs
```

## How to deploy

1. Be sure to have set the 'FOUNDRY_ETH_RPC_URL', 'PRIVATE_KEY' and 'ETHERSCAN_API_KEY' variable in the .env file, because the test will fork the mainnet

2. Run the `forge script script/deploy/Deploy.s.sol --broadcast --verify` to deploy and verify the contract

To see the cost of the deployement use `forge script script/deploy/Deploy.s.sol -f 'RPC_URL_CHAIN_TO_DEPLOY'`