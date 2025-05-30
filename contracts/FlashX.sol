// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IFlashLoanProvider {
    function flashLoan(
        uint256 amount,
        address borrower,
        bytes calldata data
    ) external;
}

interface IDEX {
    function swap(address tokenIn, address tokenOut, uint256 amountIn) external returns (uint256);
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract FlashX {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner");
        _;
    }

    function executeArbitrage(
        address loanProvider,
        address tokenA,
        address tokenB,
        uint256 amount,
        address dex1,
        address dex2
    ) external onlyOwner {
        bytes memory data = abi.encode(tokenA, tokenB, dex1, dex2);
        IFlashLoanProvider(loanProvider).flashLoan(amount, address(this), data);
    }

    function onFlashLoan(
        address initiator,
        address tokenA,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bool) {
        require(initiator == address(this), "Unauthorized loan callback");

        (address tokenIn, address tokenOut, address dex1, address dex2) = abi.decode(data, (address, address, address, address));

        // Swap tokenA to tokenB on dex1
        IERC20(tokenA).approve(dex1, amount);
        uint256 tokenBAmount = IDEX(dex1).swap(tokenA, tokenOut, amount);

        // Swap tokenB back to tokenA on dex2
        IERC20(tokenOut).approve(dex2, tokenBAmount);
        uint256 finalAmount = IDEX(dex2).swap(tokenOut, tokenA, tokenBAmount);

        require(finalAmount > amount + fee, "No arbitrage profit");

        // Repay flash loan
        IERC20(tokenA).transfer(msg.sender, amount + fee);

        return true;
    }

    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner, amount);
    }
}
