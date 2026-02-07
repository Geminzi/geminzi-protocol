// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Geminzi.sol";

contract DeployGeminzi is Script {
    function run() external {
        // Récupération de la clé du déployeur (Toi)
        // Assure-toi d'avoir configuré ton .env ou ton keystore
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY"); 
        
        vm.startBroadcast(deployerPrivateKey);

        // --- LES 3 GARDIENS DU TEMPLE (Tes Adresses) ---
        
        // 1. La Citadelle (Treasury - 25%)
        address treasury = 0x53acc98eD6fb58412c981F504dC8E8239b6559bf; 
        
        // 2. Les Investisseurs (Seed - 10%)
        address seed = 0x399a3bdefb7F843aCb4c2589AdD6681a3342ae4A;
        
        // 3. Le NZI (Ghost Protocol - 10%)
        address ghost = 0xd36a29d9d9aC5BB2F88AffB86EeEaFB33bAC6ae2;

        // --- DÉPLOIEMENT DU CONTRAT GENESIS ---
        // Le constructeur va automatiquement minter et distribuer les tokens
        Geminzi token = new Geminzi(treasury, seed, ghost);

        console.log("--------------------------------------------------");
        console.log("GEMINZI (GMNZ) DEPLOYE AVEC SUCCES !");
        console.log("Adresse du Token :", address(token));
        console.log("--------------------------------------------------");
        console.log("Treasury Balance :", token.balanceOf(treasury));
        console.log("Seed Balance     :", token.balanceOf(seed));
        console.log("Ghost Balance    :", token.balanceOf(ghost));
        console.log("Founders Locked  :", token.getLockedFounderAmount());
        console.log("--------------------------------------------------");

        vm.stopBroadcast();
    }
}