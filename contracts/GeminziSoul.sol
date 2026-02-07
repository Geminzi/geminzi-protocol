// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // <--- Pour parler au GMNZ

contract GeminziSoul is ERC721, Ownable {
    uint256 private _nextTokenId;
    IERC20 public gmnzToken; // L'adresse officielle du token GMNZ

    struct SoulStats {
        uint128 vitality;
        uint128 scars;
    }

    mapping(uint256 => SoulStats) public souls;
    
    // Mapping pour retrouver l'ID depuis l'adresse (nécessaire pour le frontend)
    mapping(address => uint256) public addressToId;
    mapping(address => bool) public hasSoul;

    constructor() ERC721("Geminzi Identity", "GSOUL") Ownable(msg.sender) {}

    // CONFIGURATION : On définit quel token est accepté pour le sacrifice
    function setToken(address _token) external onlyOwner {
        gmnzToken = IERC20(_token);
    }

    // 1. NAISSANCE
    function mintIdentity() public {
        require(!hasSoul[msg.sender], "Une seule ame par personne.");
        
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        
        souls[tokenId] = SoulStats(10, 0);
        
        // On lie l'adresse à l'ID pour faciliter la recherche
        addressToId[msg.sender] = tokenId;
        hasSoul[msg.sender] = true;
    }

    // 2. LE RITUEL DU SACRIFICE (Public)
    function sacrifice(uint256 amount) external {
        require(hasSoul[msg.sender], "Vous devez avoir une ame pour sacrifier.");
        require(address(gmnzToken) != address(0), "L'Autel n'est pas connecte au Token.");

        // A. Le Prélèvement (Le token doit avoir été 'Approved' avant)
        // On envoie les tokens au cimetière (Burning)
        bool success = gmnzToken.transferFrom(msg.sender, address(0xdead), amount);
        require(success, "Le sacrifice a ete rejete (Fonds insuffisants ou non approuves).");

        // B. La Récompense (1 Token = 1 Point de Vitalité)
        // On divise par 10^18 pour simplifier (1 GMNZ entier = +1 point)
        uint128 points = uint128(amount / 10**18);
        if (points == 0) points = 1; // Minimum 1 point pour les petits dons

        uint256 tokenId = addressToId[msg.sender];
        souls[tokenId].vitality += points;
    }

    // FONCTIONS ADMIN (Oracle)
    function grow(uint256 tokenId, uint128 amount) external onlyOwner {
        souls[tokenId].vitality += amount;
    }

    function scar(uint256 tokenId, uint128 severity) external onlyOwner {
        souls[tokenId].scars += severity;
        if (souls[tokenId].vitality > severity) {
            souls[tokenId].vitality -= severity;
        } else {
            souls[tokenId].vitality = 1;
        }
    }

    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) {
            revert("Votre ame est liee a jamais.");
        }
        return super._update(to, tokenId, auth);
    }
    
    function getSoul(uint256 tokenId) external view returns (uint128, uint128) {
        return (souls[tokenId].vitality, souls[tokenId].scars);
    }
    
    // Nouvelle fonction utile pour le Frontend
    function getMySoul(address user) external view returns (uint128, uint128, uint256) {
        if (!hasSoul[user]) return (0,0,0);
        uint256 id = addressToId[user];
        return (souls[id].vitality, souls[id].scars, id);
    }
}
