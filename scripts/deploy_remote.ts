import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("=========================================");
  console.log("👻 DÉPLOIEMENT DU REFLET (REMOTE)");
  console.log("🚀 PILOTE :", deployer.address);
  // On affiche le solde pour vérifier qu'on a de l'ETH sur Base
  console.log("💼 SOLDE  :", ethers.utils.formatEther(await deployer.getBalance()), "ETH (Base)");
  console.log("=========================================");

  // --- PARAMÈTRES LAYERZERO BASE SEPOLIA ---
  // Endpoint V2 pour Base Sepolia (C'est souvent la même adresse sur les testnets, mais c'est un autre réseau)
  const LZ_ENDPOINT = "0x6EDCE65403992e310A62460808c4b910D972f10f"; 
  
  const DELEGATE = deployer.address;
  
  // ⚠️ DIFFÉRENCE CRUCIALE : Remote Chain = FALSE
  // Ce contrat nait VIDE. Il n'a pas de tokens.
  const IS_MAIN_CHAIN = false; 

  // Les wallets (Mêmes que Sepolia pour l'instant)
  const TREASURY = deployer.address;
  const GHOST = deployer.address;

  console.log("🔨 Forge du Miroir GEMINZI sur BASE...");

  const GeminziOFT = await ethers.getContractFactory("GeminziOFT");
  const geminzi = await GeminziOFT.deploy(
    "Geminzi Omnichain", 
    "GMNZ",              
    LZ_ENDPOINT,         
    DELEGATE,            
    IS_MAIN_CHAIN,      // FALSE -> Pas de Mint initial
    TREASURY,            
    GHOST                
  );

  await geminzi.deployed();

  console.log("=========================================");
  console.log("✅ MIROIR DÉPLOYÉ SUR BASE !");
  console.log("📍 ADRESSE :", geminzi.address);
  console.log("=========================================");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
