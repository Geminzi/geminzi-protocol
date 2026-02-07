import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("=========================================");
  console.log("🚀 PILOTE :", deployer.address);
  console.log("💼 SOLDE  :", ethers.utils.formatEther(await deployer.getBalance()), "ETH");
  console.log("=========================================");

  // --- PARAMÈTRES LAYERZERO SEPOLIA ---
  // Endpoint V2 officiel pour Sepolia
  const LZ_ENDPOINT = "0x6EDCE65403992e310A62460808c4b910D972f10f"; 
  
  // Tes adresses (On met ton wallet partout pour l'instant pour éviter les erreurs)
  const DELEGATE = deployer.address;
  const TREASURY = deployer.address;
  const GHOST = deployer.address;
  const IS_MAIN_CHAIN = true; // C'est Sepolia, donc on Mint le supply

  console.log("🔨 Construction de GEMINZI OMNICHAIN (OFT)...");

  const GeminziOFT = await ethers.getContractFactory("GeminziOFT");
  const geminzi = await GeminziOFT.deploy(
    "Geminzi Omnichain", // Nom
    "GMNZ",              // Symbole
    LZ_ENDPOINT,         // LayerZero Endpoint
    DELEGATE,            // Owner/Delegate
    IS_MAIN_CHAIN,       // Est-ce la chaine mère ? OUI
    TREASURY,            // Wallet Trésorerie (virtuel pour l'instant)
    GHOST                // Wallet Ghost (virtuel pour l'instant)
  );

  console.log("⏳ En attente de la validation du bloc...");
  await geminzi.deployed();

  console.log("=========================================");
  console.log("✅ GEMINZI OMNICHAIN DÉPLOYÉ !");
  console.log("📍 ADRESSE :", geminzi.address);
  console.log("=========================================");
  console.log("⚠️  NOTE CETTE ADRESSE PRÉCIEUSEMENT");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
