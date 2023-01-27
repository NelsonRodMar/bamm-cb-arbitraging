// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {FlashLoanSimpleReceiverBase} from "@aave/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "@aave/contracts/interfaces/IPoolAddressesProvider.sol";
import {ISwapRouter} from "./interfaces/ISwapRouter.sol";
import {IBAmm} from "./interfaces/IBAmm.sol";
import {TransferHelper} from "./librairies/TransferHelper.sol";
import {IWETH9} from "./interfaces/IWETH9.sol";

contract BammArbitrage is FlashLoanSimpleReceiverBase {
    ISwapRouter public immutable swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IBAmm public immutable bamm = IBAmm(0x896d8a30C32eAd64f2e1195C2C8E0932Be7Dc20B);
    IWETH9 public immutable iWETH9 = IWETH9(payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));

    address public constant LUSD = 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint24 public constant poolFee = 3000; // 0.3%
    uint160 constant MIN_SQRT_RATIO = 4295128739;

    mapping(address => bool) public isAuthorized;

    modifier onlyAuthorized() {
        require(isAuthorized[msg.sender], "LQTYArb: not authorized");
        _;
    }

    constructor() FlashLoanSimpleReceiverBase(IPoolAddressesProvider(0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e)) {
        isAuthorized[msg.sender] = true;
    }

    /*
    * This function initiates the flash loan
    */
    function requestFlashLoan(uint256 _amount) external onlyAuthorized {
        // FlashLoan of wETH to buy LUSD
        POOL.flashLoanSimple(
            address(this),
            WETH,
            _amount,
            "",
            0
        );

        emit FlashLoanRequested(WETH, _amount);
    }


    /*
    * This function is called after the contract has received the flash loaned amount
    */
    function executeOperation(
        address,
        uint256 _amount,
        uint256 _premium,
        address,
        bytes calldata
    ) external override returns (bool)
    {
        emit FlashLoanReceived(WETH, _amount, _premium);
        // Approve the Aave Pool to repay the loan
        uint256 amountOwing = _amount + _premium;
        IERC20(WETH).approve(address(POOL), amountOwing);

        // Swap wETH received to LUSD on Uniswap
        TransferHelper.safeApprove(WETH, address(swapRouter), _amount);
        ISwapRouter.ExactInputSingleParams memory params =
        ISwapRouter.ExactInputSingleParams({
            tokenIn : WETH,
            tokenOut : LUSD,
            fee : poolFee,
            recipient : address(this),
            deadline : block.timestamp,
            amountIn : _amount,
            amountOutMinimum : 0,
            sqrtPriceLimitX96 : MIN_SQRT_RATIO
        });

        uint256 lusdAmount = swapRouter.exactInputSingle(params);

        // Sell LUSD against ETH on the B.AMM
        bamm.swap(lusdAmount, _amount, payable(address(this)));

        // Wrap ETH to repay the Loan
        iWETH9.deposit{value: address(this).balance}();

        return true;
    }


    /**
     * @dev Change the authorization of an address
     *
     * @param _address Address to change authorization
     */
    function changeAuthorization(address _address) external onlyAuthorized {
        isAuthorized[_address] = !isAuthorized[_address];
    }

    /**
     * @dev Withdraw the WETH from the contract
     */
    function withdraw() external onlyAuthorized {
        iWETH9.transferFrom(address(this), msg.sender, IERC20(WETH).balanceOf(address(this)));
    }

    receive() external payable {}

    // Events
    event FlashLoanRequested(address asset, uint256 amount);
    event FlashLoanReceived(address asset, uint256 amount, uint256 premium);
}
