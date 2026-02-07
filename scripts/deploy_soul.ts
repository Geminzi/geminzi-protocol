import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  
  // ADRESSE DU TOKEN GMNZ SUR SEPOLIA (Celle que nous utilisons déjà)
  const GMNZ_ADDRESS = "0x5f2eA208e85d00D3322043bf558eE1035883C4d6";

  console.log("=========================================");
  console.log("🕯️ DÉPLOIEMENT DE L'AUTEL (V2)");
  console.log("👤 Architecte :", deployer.address);
  console.log("=========================================");

  // 1. Déploiement
  const GeminziSoul = await ethers.getContractFactory("GeminziSoul");
  const soulContract = await GeminziSoul.deploy();
  await soulContract.deployed();

  console.log("✅ AUTEL DÉPLOYÉ :", soulContract.address);
  
  console.log("⏳ Cablage des circuits (10s)...");
  await new Promise(r => setTimeout(r, 10000));

  // 2. Connexion au Token
  console.log("🔗 Connexion au Token GMNZ...");
  const txLink = await soulContract.setToken(GMNZ_ADDRESS);
  await txLink.wait();

  // 3. Naissance du Patient Zéro
  console.log("⚡ Renaissance du Patient Zéro...");
  const txMint = await soulContract.mintIdentity();
  await txMint.wait();

  // 4. Trinité
  console.log("✨ Rituel de la Trinité (+23)...");
  const txAnoint = await soulContract.grow(0, 23); 
  await txAnoint.wait();

  console.log("=========================================");
  console.log("🏆 SYSTÈME OPÉRATIONNEL");
  console.log("📍 Nouvelle Adresse Autel :", soulContract.address);
  console.log("=========================================");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
