import { ethers, network } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  
  // --- TES ADRESSES (NE PAS TOUCHER) ---
  const SEPOLIA_ADDR = "0x5f2eA208e85d00D3322043bf558eE1035883C4d6";
  const BASE_ADDR = "0xb146A8CAe83bF88007863A34b9537A855c918CC0";

  // --- LES IDENTIFIANTS LAYERZERO V2 ---
  const EID_SEPOLIA = 40161;
  const EID_BASE = 40245;

  let localContractAddress;
  let remoteContractAddress;
  let remoteEid;

  console.log("=========================================");
  console.log("🔌 PROTOCOLE DE CONNEXION (WIRING)");
  console.log("Réseau actuel :", network.name);
  console.log("Pilote :", deployer.address);

  // DÉTECTION AUTOMATIQUE
  if (network.name === "sepolia") {
    localContractAddress = SEPOLIA_ADDR;
    remoteContractAddress = BASE_ADDR;
    remoteEid = EID_BASE; // On vise Base
    console.log("🎯 CIBLE : BASE SEPOLIA (Eid:", remoteEid, ")");
  } 
  else if (network.name === "base_sepolia") {
    localContractAddress = BASE_ADDR;
    remoteContractAddress = SEPOLIA_ADDR;
    remoteEid = EID_SEPOLIA; // On vise Sepolia
    console.log("🎯 CIBLE : SEPOLIA (Eid:", remoteEid, ")");
  } 
  else {
    throw new Error("Réseau inconnu !");
  }

  // CONNEXION AU CONTRAT LOCAL
  const GeminziOFT = await ethers.getContractFactory("GeminziOFT");
  const contract = GeminziOFT.attach(localContractAddress);

  // PRÉPARATION DE L'ADRESSE DISTANTE (Format Bytes32 obligatoire pour LZ)
  const remoteAddressBytes32 = ethers.utils.zeroPad(remoteContractAddress, 32);

  // VÉRIFICATION AVANT ECRITURE
  const isPeer = await contract.isPeer(remoteEid, remoteAddressBytes32);
  if (isPeer) {
    console.log("✅ DÉJÀ CONNECTÉ ! Pas besoin de payer du gaz.");
    return;
  }

  console.log("⚡ Activation de la liaison...");
  console.log("Remote (Bytes32):", remoteAddressBytes32);

  // L'ACTE DE FOI (SetPeer)
  const tx = await contract.setPeer(remoteEid, remoteAddressBytes32);
  console.log("⏳ Transaction envoyée:", tx.hash);
  await tx.wait();

  console.log("✅ SUCCÈS : Le canal est ouvert !");
  console.log("=========================================");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
