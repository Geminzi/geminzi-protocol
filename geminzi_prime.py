import argparse
import sys
import time
from web3 import Web3
from decimal import Decimal

# ==============================================================================
# 1. CONFIGURATION DU NOYAU (KERNEL CONFIG)
# ==============================================================================

# Connexion RPC (On utilise un noeud public stable pour Sepolia)
RPC_URL = "https://ethereum-sepolia-rpc.publicnode.com"

# L'Adresse du Contrat GEMINZI SOUL (Celui que tu as déployé)
CONTRACT_ADDRESS = "0x64177213540Eb8C188ef735585Fa877F776B0D2A"

# Ton Identité d'Architecte (Pour payer les frais de création)
MY_ADDRESS = "0xF5a1BFC6432ee4055aD43d9EA49D6d96A8f97318"
PRIVATE_KEY = "c5a47f60dc5436b0c8d725a41278c4d4f3b0761f29d5d071dd4e3c568b00833d"  # <--- COLLE TA CLÉ ICI

# L'ABI Compacté (Le dictionnaire du contrat)
CONTRACT_ABI = '[{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"enum GeminziSoul.Rank","name":"_rank","type":"uint8"},{"internalType":"enum GeminziSoul.Form","name":"_form","type":"uint8"},{"internalType":"uint256","name":"_vitality","type":"uint256"}],"name":"incarnate","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"getSoulData","outputs":[{"components":[{"internalType":"enum GeminziSoul.Rank","name":"rank","type":"uint8"},{"internalType":"enum GeminziSoul.Form","name":"form","type":"uint8"},{"internalType":"uint256","name":"vitalityScore","type":"uint256"},{"internalType":"uint256","name":"birthBlock","type":"uint256"}],"internalType":"struct GeminziSoul.SoulData","name":"","type":"tuple"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"hasSoul","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"}]'

# ==============================================================================
# 2. LE MOTEUR D'ANALYSE (ZOC ANALYZER)
# ==============================================================================

class GeminziEngine:
    def __init__(self):
        print("🔌 Initialisation du Moteur Geminzi...")
        self.w3 = Web3(Web3.HTTPProvider(RPC_URL))
        
        if not self.w3.is_connected():
            print("❌ ERREUR CRITIQUE : Impossible de joindre le réseau Sepolia.")
            sys.exit(1)
        
        print(f"✅ Connecté au Bloc #{self.w3.eth.block_number}")
        
        # Chargement du Contrat
        self.contract = self.w3.eth.contract(address=CONTRACT_ADDRESS, abi=CONTRACT_ABI)

    def analyze_target(self, target_address):
        """Scanne une adresse pour déterminer sa nature profonde."""
        print(f"\n🔍 SCAN EN COURS : {target_address}")
        
        # Vérifier si c'est une adresse valide
        if not self.w3.is_address(target_address):
            print("❌ Adresse invalide.")
            return None
        
        target = self.w3.to_checksum_address(target_address)

        # 1. Récupération des Données Brutes
        balance_wei = self.w3.eth.get_balance(target)
        balance_eth = float(self.w3.from_wei(balance_wei, 'ether'))
        tx_count = self.w3.eth.get_transaction_count(target)
        code = self.w3.eth.get_code(target)
        
        is_contract = len(code) > 0
        
        print(f"   ├─ Type      : {'🤖 CONTRACT/IA' if is_contract else '👤 EOA/HUMAN'}")
        print(f"   ├─ Richesse  : {balance_eth:.4f} ETH")
        print(f"   ├─ Expérience: {tx_count} transactions")

        # 2. Calcul du Score (L'Algorithme de Noblesse)
        soul_data = self._calculate_rank(is_contract, balance_eth, tx_count)
        
        print("\n💎 JUGEMENT DE L'ALGORITHME :")
        print(f"   ├─ RANG      : {soul_data['rank_name']} (Niveau {soul_data['rank_id']})")
        print(f"   ├─ FORME     : {soul_data['form_name']} (ID {soul_data['form_id']})")
        print(f"   └─ VITALITÉ  : {soul_data['vitality']}/100")
        
        return soul_data

    def _calculate_rank(self, is_contract, balance, tx_count):
        """Détermine le rang selon la richesse et l'activité."""
        
        # DÉFINITION DE LA FORME
        # 0 = FLUID (Humain), 1 = ENERGY (Machine), 2 = CRYSTAL (Structure/Gouv)
        if is_contract:
            form_id = 1 # Machine par défaut
            form_name = "ENERGY (Machine)"
        else:
            form_id = 0 # Humain par défaut
            form_name = "FLUID (Humain)"

        # DÉFINITION DU RANG (Logique évolutive)
        # Observer (0) -> Sovereign (5)
        
        rank_id = 0
        rank_name = "OBSERVER"
        vitality = 50 # Base

        # Critères simplifiés pour la V1 :
        if tx_count < 5:
            rank_id = 0; rank_name = "OBSERVER"
        elif tx_count < 50:
            rank_id = 1; rank_name = "OPERATOR"
        elif tx_count < 500:
            rank_id = 2; rank_name = "ARCHITECT"
        elif tx_count < 2000:
            rank_id = 3; rank_name = "VANGUARD"
        elif tx_count < 10000 or balance > 10.0:
            rank_id = 4; rank_name = "ASCENDANT"
        else:
            rank_id = 5; rank_name = "SOVEREIGN" # Le top du top
        
        # Calcul Vitalité (Activité récente simulée par le nonce pour l'instant)
        vitality = min(100, int((tx_count % 100) + 50)) 

        return {
            "rank_id": rank_id, "rank_name": rank_name,
            "form_id": form_id, "form_name": form_name,
            "vitality": vitality
        }

    def incarnate(self, target_address, soul_data):
        """Écrit le jugement sur la Blockchain."""
        
        # Vérification si l'âme existe déjà
        target = self.w3.to_checksum_address(target_address)
        if self.contract.functions.hasSoul(target).call():
            print(f"\n⚠️  L'adresse {target} possède déjà une Âme ! Incarnation annulée.")
            return

        print(f"\n⚡ DÉBUT DU RITUEL D'INCARNATION...")
        
        nonce = self.w3.eth.get_transaction_count(MY_ADDRESS)
        
        # Construction de la Transaction
        tx = self.contract.functions.incarnate(
            target,
            soul_data['rank_id'],
            soul_data['form_id'],
            soul_data['vitality']
        ).build_transaction({
            'chainId': 11155111, # Sepolia ID
            'gas': 200000,
            'gasPrice': self.w3.to_wei('20', 'gwei'),
            'nonce': nonce,
        })
        
        # Signature
        signed_tx = self.w3.eth.account.sign_transaction(tx, PRIVATE_KEY)
        
        # Envoi
        try:
            tx_hash = self.w3.eth.send_raw_transaction(signed_tx.raw_transaction)
            print(f"🚀 Transaction envoyée ! Hash: {self.w3.to_hex(tx_hash)}")
            print("⏳ Attente de la confirmation des mineurs...")
            
            receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)
            
            if receipt.status == 1:
                print(f"✅ SUCCÈS ! L'Âme a été créée au bloc {receipt.blockNumber}.")
                print(f"🔗 Voir sur Etherscan : https://sepolia.etherscan.io/tx/{self.w3.to_hex(tx_hash)}")
            else:
                print("❌ ECHEC : La transaction a été annulée par le réseau.")
                
        except Exception as e:
            print(f"❌ Erreur lors de l'envoi : {e}")

# ==============================================================================
# 3. INTERFACE DE COMMANDE
# ==============================================================================

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Geminzi Prime Engine - Soul Scanner")
    parser.add_argument("--target", type=str, help="L'adresse Ethereum à analyser et incarner")
    
    args = parser.parse_args()

    engine = GeminziEngine()

    if args.target:
        # Analyse
        data = engine.analyze_target(args.target)
        if data:
            # Demande de confirmation
            confirm = input("\n👉 Voulez-vous INCARNER cette Âme sur la Blockchain ? (oui/non) : ")
            if confirm.lower() in ["oui", "y", "yes"]:
                engine.incarnate(args.target, data)
            else:
                print("Operation annulée.")
    else:
        print("❓ Usage: python geminzi_prime.py --target <ADRESSE_ETH>")
