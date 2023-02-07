# BAMM Arbitrage 

This project use Aave V3 FlashLoan to make profit by buying the ETH discounted sell by B.Protocol Chicken Bond Stability pool [contract](https://etherscan.io/address/0x896d8a30C32eAd64f2e1195C2C8E0932Be7Dc20B). 
This project also contain a JS script that call the contrat using MEV for two reason 
<br>
1. Be sure to be the first one to call the BAMM CB contrat <br>
2. Avoid to be sandwich attack when swapping the token on Uniswap<br>

This project use Aave V3 FlashLoan + Uniswap and MEV Flashbot for the script.


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

## How to run the script 

1. Be sure to have deploy the contrat and then copy-past the .env.example file and rename it to .env and fill in the variables.


2. Run `npm install` to install the dependencies


3. Now you can run the script with 
```bash
node script/cron/cron.js 
```
ℹ️ : There is two options on the script :
    
- `--force true` to force the script to be executed

- `--minPrice MIN_PRICE` to set a minimum price where the script will be executed.
Actually the script is configured to be run when the BAMM CB have at least 5000 $ETH in LUSD.