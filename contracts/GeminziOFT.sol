// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { OFT } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GEMINZI OMNICHAIN (GMNZ)
 * @dev "Be Everywhere. Be One."
 * Version OFT (LayerZero V2)
 */
contract GeminziOFT is OFT {

    // --- ALLOCATION CONSTANTS ---
    // Note: Sur les chaînes secondaires, on ne mint PAS tout le supply.
    // Le supply arrive par le pont. Mais pour la chaîne MAÎTRE (Sepolia), on garde la logique.
    
    // --- VESTING FOUNDERS (Le Bouclier) ---
    uint256 public vestingStartTime;
    uint256 public constant VESTING_DURATION = 730 days; // 24 Mois
    uint256 public constant FOUNDERS_ALLOC_TOTAL = 20_202_020 * 10**18;
    uint256 public foundersReleased;
    // Mapping pour suivre les fonds bloqués spéciquement sur cette chaine
    uint256 public initialLockedAmount;

    event FounderTokensReleased(uint256 amount, uint256 timestamp);

    /**
     * @param _name Nom du token
     * @param _symbol Symbole
     * @param _lzEndpoint L'adresse du bureau de poste LayerZero sur cette blockchain
     * @param _delegate L'adresse qui gère la config du pont (Toi)
     * @param _isMainChain Si TRUE, on mint le supply initial. Si FALSE, on attend que les tokens arrivent.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate,
        bool _isMainChain,
        address _treasuryWallet,
        address _ghostWallet
    ) OFT(_name, _symbol, _lzEndpoint, _delegate) Ownable(_delegate) {
        
        vestingStartTime = block.timestamp;

        if (_isMainChain) {
            // SUR LA CHAINE MÈRE (Sepolia) : On crée la matière.
            // Le Supply Total vise 101M, mais ici on mint ce qui est nécessaire.
            
            // Liquidity + Treasury + Seed + Ghost
            uint256 liquidSupply = 80_808_081 * 10**18; 
            _mint(msg.sender, liquidSupply); // On envoie tout au déployeur pour distribution (ou aux wallets spécifiques)

            // Founders Vesting (Bloqué sur le contrat)
            _mint(address(this), FOUNDERS_ALLOC_TOTAL);
            initialLockedAmount = FOUNDERS_ALLOC_TOTAL;
        }
    }

    // --- LOGIQUE VESTING (Identique à la V1) ---

    function releaseFounderTokens() external onlyOwner {
        uint256 unreleased = _releasableAmount();
        require(unreleased > 0, "Pas de tokens disponibles");

        foundersReleased += unreleased;
        _transfer(address(this), msg.sender, unreleased);

        emit FounderTokensReleased(unreleased, block.timestamp);
    }

    function _releasableAmount() private view returns (uint256) {
        if (block.timestamp < vestingStartTime) {
            return 0;
        }
        uint256 totalVested = initialLockedAmount; // On se base sur ce qui a été bloqué ici
        if (totalVested == 0) return 0;

        uint256 timeElapsed = block.timestamp - vestingStartTime;

        if (timeElapsed >= VESTING_DURATION) {
            return totalVested - foundersReleased;
        } else {
            uint256 vestedAmount = (totalVested * timeElapsed) / VESTING_DURATION;
            return vestedAmount - foundersReleased;
        }
    }

    // Fonction de lecture pour le Dashboard (Compatible V1)
    function lockedFounderAmount() external view returns (uint256) {
        return balanceOf(address(this));
    }
}
