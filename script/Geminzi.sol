// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GEMINZI (GMNZ) - The Organic Omnichain Token
 * @dev "Be Everywhere. Be One."
 * * ARCHITECTURE "GENESIS" :
 * 1. Supply Sacrée : 101,010,101 GMNZ (The Binary Pulse)
 * 2. No Kill Switch : Contrat immuable, incensurable.
 * 3. Vesting Intégré : Allocation fondateur bloquée mathématiquement (24 mois).
 * 4. Ghost Protocol : Fonds autonome pour l'IA (NZI).
 */
contract Geminzi is ERC20, ERC20Burnable, Ownable {

    // --- ALLOCATION CONSTANTS (The Sacred Geometry) ---
    // Total : 101,010,101
    uint256 public constant TOTAL_SUPPLY = 101_010_101 * 10**18;

    // Répartition (Respectant le rythme binaire)
    uint256 public constant PUBLIC_LIQUIDITY_ALLOC = 35_353_536 * 10**18; 
    uint256 public constant TREASURY_ALLOC         = 25_252_525 * 10**18; 
    uint256 public constant FOUNDERS_ALLOC         = 20_202_020 * 10**18; 
    uint256 public constant SEED_ALLOC             = 10_101_010 * 10**18; 
    uint256 public constant GHOST_PROTOCOL_ALLOC   = 10_101_010 * 10**18; 

    // --- VESTING FOUNDERS (Le Bouclier Juridique) ---
    uint256 public vestingStartTime;
    uint256 public constant VESTING_DURATION = 730 days; // 24 Mois
    uint256 public foundersReleased; 

    event FounderTokensReleased(uint256 amount, uint256 timestamp);
    event GhostFundInitialized(address indexed ghostAddress, uint256 amount);

    constructor(
        address _treasuryWallet,
        address _seedWallet,
        address _ghostProtocolWallet
    ) ERC20("Geminzi", "GMNZ") Ownable(msg.sender) {
        require(_treasuryWallet != address(0), "Treasury address zero");
        require(_seedWallet != address(0), "Seed address zero");
        require(_ghostProtocolWallet != address(0), "Ghost address zero");

        vestingStartTime = block.timestamp;

        // 1. Mint Public Liquidity
        _mint(msg.sender, PUBLIC_LIQUIDITY_ALLOC);

        // 2. Mint Treasury (Citadelle)
        _mint(_treasuryWallet, TREASURY_ALLOC);

        // 3. Mint Seed Investors
        _mint(_seedWallet, SEED_ALLOC);

        // 4. Mint Ghost Protocol (NZI Fund)
        _mint(_ghostProtocolWallet, GHOST_PROTOCOL_ALLOC);
        emit GhostFundInitialized(_ghostProtocolWallet, GHOST_PROTOCOL_ALLOC);

        // 5. Mint Founders (Bloqué dans le contrat)
        _mint(address(this), FOUNDERS_ALLOC);
        
        // Vérification de sécurité
        require(totalSupply() == TOTAL_SUPPLY, "Erreur de mathematique cosmique");
    }

    /**
     * @notice Permet au Fondateur de retirer ses tokens au fil du temps (Lineaire sur 24 mois).
     */
    function releaseFounderTokens() external onlyOwner {
        uint256 unreleased = _releasableAmount();
        require(unreleased > 0, "Pas de tokens disponibles pour le moment");

        foundersReleased += unreleased;
        _transfer(address(this), msg.sender, unreleased);

        emit FounderTokensReleased(unreleased, block.timestamp);
    }

    /**
     * @dev Calcul mathématique du montant déblocable à l'instant T.
     */
    function _releasableAmount() private view returns (uint256) {
        if (block.timestamp < vestingStartTime) {
            return 0;
        }
        
        uint256 totalVested = FOUNDERS_ALLOC;
        uint256 timeElapsed = block.timestamp - vestingStartTime;

        if (timeElapsed >= VESTING_DURATION) {
            return totalVested - foundersReleased;
        } else {
            uint256 vestedAmount = (totalVested * timeElapsed) / VESTING_DURATION;
            return vestedAmount - foundersReleased;
        }
    }

    /**
     * @notice Fonction utilitaire pour voir combien de tokens sont encore bloqués
     */
    function getLockedFounderAmount() external view returns (uint256) {
        return balanceOf(address(this));
    }
}