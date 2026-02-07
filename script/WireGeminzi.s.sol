// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MyOApp} from "../src/MyOApp.sol";
import {console} from "forge-std/console.sol";

contract WireGeminzi is Script {
    // --- ADRESSES OFFICIELLES (Vérifiées le 24/01) ---
    address constant ADDR_SEPOLIA = 0x0562A3508FfA50f385afB5f68E71549B0C495aB9;
    address constant ADDR_ARB     = 0x3521EFBC4458cE9FDdEF05f4961324D51A65ECd2;
    // La nouvelle adresse dont tu es propriétaire :
    address constant ADDR_OP      = 0xb8499A427Fd120f289aC198b41175460B61aFEc6; 

    // --- IDENTIFIANTS LAYERZERO V2 ---
    uint32 constant EID_SEPOLIA = 40161;
    uint32 constant EID_ARB_SEP = 40231;
    uint32 constant EID_OP      = 40232; 

    function run() external {
        vm.startBroadcast();

        if (block.chainid == 11155111) {
            // --- SEPOLIA ---
            console.log("Configuration de Sepolia...");
            MyOApp myOApp = MyOApp(ADDR_SEPOLIA);
            // On connecte vers Arbitrum et Optimism
            myOApp.setPeer(EID_ARB_SEP, addressToBytes32(ADDR_ARB));
            myOApp.setPeer(EID_OP, addressToBytes32(ADDR_OP));
            console.log("Sepolia -> OK");

        } else if (block.chainid == 421614) {
            // --- ARBITRUM ---
            console.log("Configuration de Arbitrum...");
            MyOApp myOApp = MyOApp(ADDR_ARB);
            // On connecte vers Sepolia et Optimism
            myOApp.setPeer(EID_SEPOLIA, addressToBytes32(ADDR_SEPOLIA));
            myOApp.setPeer(EID_OP, addressToBytes32(ADDR_OP));
            console.log("Arbitrum -> OK");

        } else if (block.chainid == 11155420) {
            // --- OPTIMISM ---
            console.log("Configuration de Optimism...");
            MyOApp myOApp = MyOApp(ADDR_OP);
            // On connecte vers Sepolia et Arbitrum
            myOApp.setPeer(EID_SEPOLIA, addressToBytes32(ADDR_SEPOLIA));
            myOApp.setPeer(EID_ARB_SEP, addressToBytes32(ADDR_ARB));
            console.log("Optimism -> OK");
        }

        vm.stopBroadcast();
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}
