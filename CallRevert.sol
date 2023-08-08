// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract CallRevert {
    uint public valueA;

    event CallBFailed(uint newValue);
    event CallBSucced(uint newValue);

    function setValueA(uint newValue) external {
        valueA = newValue;
    }

    function getValueA() external view returns (uint) {
        return valueA;
    }

    function callContractB(address contractB, uint newValue) external {
        // 调用 ContractB 合约中的 setValueB 函数
        ContractB B = ContractB(contractB);
        valueA = 100;
        try B.setValueB(newValue) {
        } catch Error(string memory revertReason) {
            revert (string.concat("revert: ", revertReason));
        } catch {
            revert("Others");
        }
        // 如果直接调用setValueB方法，那么子调用一旦revert，所有调用都会revert，但是如果用底层call，子调用不会影响主调用
        valueA = 20;

        // valueA = 100;
        // (bool success, ) = contractB.call(abi.encodeWithSignature("setValueB(uint256)", newValue));
        // if(success) {
        //     emit CallBSucced(newValue);
        // } else {
        //     emit CallBFailed(newValue);
        // }

        // valueA = 10;
        // require(success, "ContractB call failed");

        // 继续执行其他逻辑
        // ...
        // valueA = 10;
    }
}

contract ContractB {
    uint public valueB;

    function setValueB(uint newValue) external {
        valueB = newValue;

        // 在某些条件下触发 revert
        if (newValue > 100) {
            revert("Value too high");
        }
    }

    function getValueB() external view returns (uint) {
        return valueB;
    }
}