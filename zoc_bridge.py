import json
from web3 import Web3

# --- 1. CONFIGURATION DU RÉSEAU (SEPOLIA) ---
# On utilise un RPC public pour le test. Plus tard, on prendra Alchemy/Infura.
RPC_URL = "https://ethereum-sepolia-rpc.publicnode.com"
w3 = Web3(Web3.HTTPProvider(RPC_URL))

# Vérification de la connexion
if w3.is_connected():
    print(f"✅ Connecté au réseau Sepolia ! (Bloc actuel: {w3.eth.block_number})")
else:
    print("❌ Echec de la connexion. Vérifie ta connexion internet.")
    exit()

# --- 2. CONFIGURATION DU WALLET (TOI) ---
# Remplace par TA Clé Privée (celle du compte 0xF5a...)
# ATTENTION : NE PARTAGE JAMAIS CETTE CLÉ.
PRIVATE_KEY = "c5a47f60dc5436b0c8d725a41278c4d4f3b0761f29d5d071dd4e3c568b00833d" 
MY_ADDRESS = "0xF5a1BFC6432ee4055aD43d9EA49D6d96A8f97318"

# --- 3. CONFIGURATION DU CONTRAT (GEMINZI) ---
CONTRACT_ADDRESS = "0x64177213540Eb8C188ef735585Fa877F776B0D2A"

# L'ABI que tu m'as donné (Je l'ai compacté pour la lisibilité)
CONTRACT_ABI = json.loads('''[{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"approve","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"initialOwner","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"enum GeminziSoul.Rank","name":"_rank","type":"uint8"},{"internalType":"enum GeminziSoul.Form","name":"_form","type":"uint8"},{"internalType":"uint256","name":"_vitality","type":"uint256"}],"name":"incarnate","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"bytes","name":"data","type":"bytes"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"operator","type":"address"},{"internalType":"bool","name":"approved","type":"bool"}],"name":"setApprovalForAll","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"transferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"getApproved","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"getSoulData","outputs":[{"components":[{"internalType":"enum GeminziSoul.Rank","name":"rank","type":"uint8"},{"internalType":"enum GeminziSoul.Form","name":"form","type":"uint8"},{"internalType":"uint256","name":"vitalityScore","type":"uint256"},{"internalType":"uint256","name":"birthBlock","type":"uint256"}],"internalType":"struct GeminziSoul.SoulData","name":"","type":"tuple"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"hasSoul","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"operator","type":"address"}],"name":"isApprovedForAll","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"ownerOf","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"souls","outputs":[{"internalType":"enum GeminziSoul.Rank","name":"rank","type":"uint8"},{"internalType":"enum GeminziSoul.Form","name":"form","type":"uint8"},{"internalType":"uint256","name":"vitalityScore","type":"uint256"},{"internalType":"uint256","name":"birthBlock","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes4","name":"interfaceId","type":"bytes4"}],"name":"supportsInterface","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"tokenURI","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"}]''')

# Initialisation du contrat
contract = w3.eth.contract(address=CONTRACT_ADDRESS, abi=CONTRACT_ABI)

# --- 4. FONCTIONS DE LECTURE (GRATUITES) ---
def lire_ame(token_id):
    """Lit les données d'une âme sur la blockchain"""
    try:
        # On appelle la fonction 'souls' du contrat
        data = contract.functions.souls(token_id).call()
        
        # Mapping pour l'affichage propre
        ranks = ["OBSERVER", "OPERATOR", "ARCHITECT", "VANGUARD", "ASCENDANT", "SOVEREIGN"]
        forms = ["FLUID (Humain)", "ENERGY (Machine)", "CRYSTAL (Structure)"]
        
        print(f"\n--- 🔮 DONNÉES DE L'ÂME #{token_id} ---")
        print(f"RANG      : {ranks[data[0]]} (Niveau {data[0]})")
        print(f"FORME     : {forms[data[1]]}")
        print(f"VITALITÉ  : {data[2]}/100")
        print(f"NÉ AU BLOC: {data[3]}")
        print("-----------------------------------")
    except Exception as e:
        print(f"Erreur de lecture: {e}")

# --- 5. FONCTION D'ÉCRITURE (PAYANTE - GAS) ---
def incarner_ame(target_address, rank_id, form_id, vitality):
    """Crée une âme automatiquement"""
    print(f"\n⚡ Tentative d'incarnation pour {target_address}...")
    
    # 1. Construire la transaction
    nonce = w3.eth.get_transaction_count(MY_ADDRESS)
    
    tx = contract.functions.incarnate(
        target_address,
        rank_id,
        form_id,
        vitality
    ).build_transaction({
        'chainId': 11155111, # ID de Sepolia
        'gas': 200000,       # Limite de gas
        'gasPrice': w3.to_wei('10', 'gwei'), # Prix du gas
        'nonce': nonce,
    })
    
    # 2. Signer la transaction avec ta clé privée (Le stylo numérique)
    signed_tx = w3.eth.account.sign_transaction(tx, PRIVATE_KEY)
    
    # 3. Envoyer au réseau
    tx_hash = w3.eth.send_raw_transaction(signed_tx.raw_transaction)
    
    print(f"🚀 Transaction envoyée ! Hash: {w3.to_hex(tx_hash)}")
    print("Attente de confirmation...")
    
    # 4. Attendre le reçu
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    print(f"✅ CONFIRMÉ ! L'âme est née au bloc {tx_receipt.blockNumber}")

# --- 6. EXÉCUTION DU TEST ---
if __name__ == "__main__":
    # Test 1 : Lecture (On le garde pour vérifier)
    print("Lecture de l'Âme #0...")
    lire_ame(0)

    # Test 2 : ECRITURE (La Création)
    # On va créer une âme pour une adresse de test (un wallet vide)
    target_address = "0x71C7656EC7ab88b098defB751B7401B5f6d8976F" 
    
    # Paramètres : Adresse, Rang (3=Vanguard), Forme (1=Energy), Vitalité (88)
    print(f"\n⚡ Création de l'Âme pour l'IA {target_address}...")
    incarner_ame(target_address, 3, 1, 88)
    
    # Une fois créé, on essaie de la relire tout de suite
    # Note: Il faut attendre un peu que le bloc soit validé, donc on le fera manuellement après.
