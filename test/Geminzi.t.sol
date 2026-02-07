// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MyOApp} from "../src/MyOApp.sol";

// Test Simplifié V6 (Sans Mock LayerZero manquant)
contract GeminziTest is Test {
    MyOApp public oapp;
    address public endpoint = address(0x123); // Fausses adresses pour le test local
    address public owner = address(this);

    function setUp() public {
        // On vérifie juste que le contrat V6 est capable de naître
        oapp = new MyOApp(endpoint, owner);
    }

    function test_SanityCheck() public {
        // Vérifie qu'on est bien le propriétaire
        assertEq(oapp.owner(), owner);
        console.log("Le Symbole V6 compile et se deploie correctement en local.");
    }
}
