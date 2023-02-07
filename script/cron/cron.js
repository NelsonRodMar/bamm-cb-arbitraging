const {ethers} = require("ethers");
const {FlashbotsBundleProvider,} = require("@flashbots/ethers-provider-bundle");
require('dotenv').config({path: __dirname + '/./../../.env'});
const AbiBammArbitrage = require('./abi/BammArbitrage.json');
const AbiBammCb = require('./abi/BammCb.json');

async function main() {
    console.log("--- Begin of the script ", new Date(), "---")
    const flashbotsUrl = process.env.FLASHBOT_URL,
        bammArbitrageAdresse = process.env.BAMM_ARBITRAGE_ADDRESS,
        bammCbAdresse = '0x896d8a30C32eAd64f2e1195C2C8E0932Be7Dc20B',
        minPrice = 5000, // ETH price in $LUSD
        blockSubmitionFlashbot = 1; // Number of block where the bundle will be submited
    const provider = new ethers.providers.JsonRpcProvider(process.env.FOUNDRY_ETH_RPC_URL);
    const bammCb = new ethers.Contract(bammCbAdresse, AbiBammCb, provider);
    let getLUSDValue = await bammCb.getLUSDValue();
    let ethLusdValue = ethers.utils.formatUnits(getLUSDValue.ethLUSDValue);
    var argv = require('minimist')(process.argv.slice(2));
    //TODO : Add a better check to see if the price is not too high compare to benefit
    if ((ethLusdValue >= minPrice && argv.minPrice === undefined)  || ethLusdValue >= argv.minPrice || argv.force === 'true') {
        console.log("[info] There is : " + ethLusdValue + " Ether in $LUSD");
        const authSigner = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
        console.log('[info] Start request flash loan');
        let ifaceBammArbitrage = new ethers.utils.Interface(AbiBammArbitrage.abi);
        let data = ifaceBammArbitrage.encodeFunctionData("requestFlashLoan");
        const flashbotsProvider = await FlashbotsBundleProvider.create(
            provider,
            authSigner,
            flashbotsUrl,
            "mainnet"
        );
        const wallet = new ethers.Wallet(process.env.PRIVATE_KEY);
        const feeInfo = await provider.getFeeData();
        const signedTransactions = await flashbotsProvider.signBundle([{
            signer: wallet,
            transaction: {
                to: bammArbitrageAdresse,
                type: 2,
                value: 0,
                gasLimit: 352360,
                chainId: 1,
                maxFeePerGas: feeInfo.maxFeePerGas * 100, // TODO : Add a better way to calculate the fee
                maxPriorityFeePerGas: feeInfo.maxPriorityFeePerGas * 10,
                data: data,
            }
        }]);

        const blockNumber = await provider.getBlockNumber();
        console.log("[info] Block number :", blockNumber);

        console.log("[info] Simulate bundle");
        const simulation = await flashbotsProvider.simulate(signedTransactions, blockNumber + 1);
        if ("error" in simulation) {
            throw new Error(`[error]Simulation Error : ${simulation.error.message}`);

        } else {
            console.log("[info] Simulation Success");
            for (var i = 1; i <= blockSubmitionFlashbot; i++) {
                flashbotsProvider.sendRawBundle(signedTransactions, blockNumber + i);
                console.log("[info] Submitted for block # ", blockNumber + i);
            }
            //TODO : Add event listener to know the profit made
        }
    } else {
        console.log("[info] Not enough value, only " + ethers.utils.formatUnits(getLUSDValue.ethLUSDValue) + " Ether in $LUSD");
    }
    console.log("--- End of the script ", new Date(), "---")

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

