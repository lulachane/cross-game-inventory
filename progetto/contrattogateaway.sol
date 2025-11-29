// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// NOTA: Questa interfaccia è concettuale per mostrare l'interazione con la P-Chain 
// tramite una funzione wrapper o un relayer specifico per Avalanche.
interface IPlatformChainRelayer {
    function delegate(
        bytes memory nodeID, 
        uint256 amount, 
        uint256 startTime, 
        uint256 endTime,
        address rewardAddress
    ) external;
}

/**
 * @title AutonomousAgentGateway
 * @dev Gateway per operazioni finanziarie sicure, inclusa la validazione strict per lo staking.
 */
contract AutonomousAgentGateway is Ownable {

    // Indirizzo dell'Agente AI / Utente autorizzato ad eseguire transazioni.
    address public trustedExecutor; 
    
    // Interfaccia USDT (USDC, DAI, ecc.) per scambi o trasferimenti.
    IERC20 public usdtToken; 
    
    // Interfaccia concettuale per la P-Chain (per le chiamate di staking)
    IPlatformChainRelayer public pChainRelayer; 

    // Limiti di sicurezza per l'execution (gestiti dal VSE, ma applicati on-chain)
    uint256 public maxDelegationAmount; 

    // --- Eventi per il VSE (Consecution/Tracciabilità) ---
    event DelegationExecuted(
        address indexed executor, 
        bytes indexed nodeID, 
        uint256 amount
    );
    
    constructor(
        address _executor, 
        address _usdtAddress, 
        address _relayer, 
        uint256 _maxAmount
    ) Ownable(msg.sender) {
        trustedExecutor = _executor;
        usdtToken = IERC20(_usdtAddress);
        pChainRelayer = IPlatformChainRelayer(_relayer);
        maxDelegationAmount = _maxAmount;
    }

    modifier onlyTrustedExecutor() {
        require(msg.sender == trustedExecutor, "Gateway: Caller is not the trusted executor");
        _;
    }

    /**
     * @dev Esegue la delega sulla P-Chain con Validazione Strict.
     * I fondi (AVAX) devono essere già stati spostati sulla P-Chain dall'Executor.
     */
    function executeStrictDelegation(
        bytes memory _nodeID, 
        uint256 _amount, 
        uint256 _startTime, 
        uint256 _endTime
    ) public onlyTrustedExecutor {
        // --- VALIDAZIONE STRICT (Consecution/Sicurezza) ---
        
        // 1. Controllo Limite Massimo
        require(_amount <= maxDelegationAmount, "Gateway: Delegation amount exceeds max limit");
        
        // 2. Controllo Durata (esempio: min 2 settimane, max 1 anno)
        uint256 duration = _endTime - _startTime;
        uint256 minDuration = 14 days; 
        uint256 maxDuration = 365 days;
        require(duration >= minDuration && duration <= maxDuration, "Gateway: Invalid staking duration");

        // 3. Controllo Tempo di Inizio (deve essere futuro e non troppo lontano)
        require(_startTime > block.timestamp && _startTime < block.timestamp + 30 days, "Gateway: Invalid start time");

        // --- EXECUTION (Chiamata P-Chain) ---
        
        // La chiamata al relayer avvierà l'operazione di delega sulla P-Chain.
        pChainRelayer.delegate(_nodeID, _amount, _startTime, _endTime, msg.sender);
        
        emit DelegationExecuted(msg.sender, _nodeID, _amount);
    }
    
    /**
     * @dev Funzione per approvare il trasferimento di USDT a un DEX (Execution).
     * Utile per scambiare USDT in AVAX in modo sicuro.
     */
    function approveUsdtForSwap(address _dexRouter, uint256 _amount) public onlyTrustedExecutor {
        usdtToken.approve(_dexRouter, _amount);
    }
}