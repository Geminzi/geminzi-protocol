// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MyOApp} from "../src/MyOApp.sol";
import {console} from "forge-std/console.sol";

contract InteractGeminzi is Script {
    address constant ADDR_SEPOLIA = 0x0562A3508FfA50f385afB5f68E71549B0C495aB9;
    
    // IDs LayerZero V2
    uint32 constant EID_ARB_SEP = 40231; 
    uint32 constant EID_OP      = 40232; 

    function run() external {
        vm.startBroadcast(); 

        MyOApp myOApp = MyOApp(ADDR_SEPOLIA);

        // Options standard
        bytes memory options = hex"00030100110100000000000000000000000000030d40"; 

        console.log("--- FRAPPE CHIRURGICALE SUR OPTIMISM ---");
        
        // 1. ARBITRUM : DESACTIVE (ECONOMIE D'ENERGIE)
        // console.log("1. Tir vers Arbitrum...");
        // myOApp.train{value: 0.003 ether}(EID_ARB_SEP, options);

        // 2. OPTIMISM : CIBLE PRIORITAIRE
        // On ajuste à 0.0015 ether (Le compromis parfait)
        console.log("2. Tir vers Optimism...");
        myOApp.train{value: 0.0015 ether}(
            EID_OP, 
            options
        );

        console.log("--- ONDE ENVOYEE VERS LE CIEL ---");

        vm.stopBroadcast();
    }
}
