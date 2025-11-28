// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Utilizzo ERC721URIStorage per supportare _setTokenURI
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CrossGameAssetNFT - Contratto Corretto
 * @dev Contratto NFT (ERC-721) per gli asset di gioco.
 */
contract CrossGameAssetNFT is ERC721URIStorage, Ownable {
    // Contatore per gli ID dei token emessi
    uint256 private _nextTokenId;

    // CORREZIONE: Chiamare il costruttore di Ownable
    constructor() 
        ERC721("CrossGameItem", "CGI") 
        Ownable(msg.sender) // <-- Questa è la riga mancante!
    {}

    /**
     * @dev Funzione per coniare un nuovo asset di gioco. 
     * Eseguibile solo dal proprietario del contratto (il sistema di gioco).
     */
    function mintItem(address to, string memory uri) public onlyOwner returns (uint256) {
        // Incrementa l'ID del token e conia l'NFT
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }
}