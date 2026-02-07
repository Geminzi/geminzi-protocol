import { ethers } from "hardhat";
import { Options } from "@layerzerolabs/lz-v2-utilities";

async function main() {
  const [deployer] = await ethers.getSigners();
  
  // CONFIG SEPOLIA -> BASE
  const SEPOLIA_ADDR = "0x5f2eA208e85d00D3322043bf558eE1035883C4d6";
  const EID_BASE = 40245;
  const AMOUNT = ethers.utils.parseEther("10"); // 10 GMNZ

  const GeminziOFT = await ethers.getContractFactory("GeminziOFT");
  const contract = GeminziOFT.attach(SEPOLIA_ADDR);

  console.log("🚀 TÉLÉPORTATION DE 10 GMNZ VERS BASE...");
  console.log("Source:", SEPOLIA_ADDR);

  // 1. Options (Gas Limit pour l'arrivée)
  const options = Options.newOptions().addExecutorLzReceiveOption(200000, 0).toHex().toString();

  const sendParam = {
    dstEid: EID_BASE,
    to: ethers.utils.zeroPad(deployer.address, 32),
    amountLD: AMOUNT,
    minAmountLD: AMOUNT,
    extraOptions: options,
    composeMsg: "0x",
    oftCmd: "0x"
  };

  // 2. Estimation (Quote)
  // On récupère TOUTE la structure de frais (le ticket complet), pas juste le chiffre
  const messagingFee = await contract.quoteSend(sendParam, false);
  const nativeFee = messagingFee.nativeFee;

  console.log("💰 Coût estimé (ETH):", ethers.utils.formatEther(nativeFee));

  // 3. Envoi (Send) CORRIGÉ
  console.log("⚡ Envoi en cours...");
  
  // L'ordre des arguments est CRUCIAL pour LayerZero V2 :
  // arg1: sendParam
  // arg2: messagingFee (Le ticket qu'on a reçu du quote)
  // arg3: refundAddress
  // arg4: { value: ... } (Le paiement effectif)
  const tx = await contract.send(
    sendParam,
    messagingFee,     // <--- C'était l'élément manquant !
    deployer.address, 
    { value: nativeFee } 
  );

  console.log("✅ TRANSACTION ENVOYÉE !");
  console.log("🔗 Hash:", tx.hash);
  console.log("👉 Suis ton paquet ici : https://testnet.layerzeroscan.com/tx/" + tx.hash);
  
  await tx.wait();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
