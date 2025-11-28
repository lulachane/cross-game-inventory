// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title CrossGameAssetMapper
 * @dev Definisce le regole di mapping tra NFT di contratti diversi.
 * Usato dai backend dei giochi compatibili per l'interpretazione.
 */
contract CrossGameAssetMapper {

    // Struttura che definisce le proprietà che l'oggetto deve assumere nel Gioco Target.
    struct GameAssetProperties {
        uint256 targetId;       // ID dell'oggetto nel database del Gioco B
        string displayName;     // Nome specifico nel Gioco B
        uint256 derivedStat;    // Statistica derivata (es. Power Level tradotto)
        bool isTradeable;       // Se è scambiabile nel Gioco B
    }

    // Mapping: NFT Contract Address (Gioco A) => Token ID => Game Asset Properties (Gioco B)
    mapping(address => mapping(uint256 => GameAssetProperties)) public assetMap;
    
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Mapper: Not the contract owner");
        _;
    }

    /**
     * @dev Registra o aggiorna una regola di mapping.
     */
    function setAssetMapping(
        address _sourceContract,
        uint256 _sourceTokenId,
        GameAssetProperties memory _props
    ) public onlyOwner {
        // QUI si possono implementare controlli strict per i parametri _props
        assetMap[_sourceContract][_sourceTokenId] = _props;
    }

    /**
     * @dev Ottiene le proprietà mappate. Chiamato dal backend di un gioco compatibile.
     */
    function getMappedProperties(
        address _sourceContract,
        uint256 _sourceTokenId
    ) public view returns (GameAssetProperties memory) {
        return assetMap[_sourceContract][_sourceTokenId];
    }
}