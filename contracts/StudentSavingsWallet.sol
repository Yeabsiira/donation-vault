// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract StudentSavingsWallet {

    // Custom Errors for Gas Efficiency
    error InsufficientBalance(uint256 available, uint256 required);
    error DepositAmountMustBeGreaterThanZero();
    error TransferFailed();

    // Enum to categorize transactions
    enum TransactionType { Deposit, Withdrawal }

    // Struct to store transaction metadata
    struct Transaction {
        address user;
        uint256 amount;
        uint256 timestamp;
        TransactionType txType;
    }

    // State Variables
    mapping(address => uint256) private balances;
    Transaction[] public transactionHistory;

    // Events for off-chain indexing (Bonus Requirement)
    event FundsDeposited(address indexed user, uint256 amount);
    event FundsWithdrawn(address indexed user, uint256 amount);

    /**
     * @notice Allows a user to deposit ETH into their savings wallet.
     * @dev Updates the mapping and pushes a record to the transaction array.
     */
    function deposit() public payable {
        if (msg.value == 0) {
            revert DepositAmountMustBeGreaterThanZero();
        }

        // Update state: Increase user balance
        balances[msg.sender] += msg.value;

        // Record transaction in history
        transactionHistory.push(Transaction({
            user: msg.sender,
            amount: msg.value,
            timestamp: block.timestamp,
            txType: TransactionType.Deposit
        }));

        emit FundsDeposited(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public {
        uint256 userBalance = balances[msg.sender];

        // 1. CHECK: Ensure user has enough funds
        if (userBalance < _amount) {
            revert InsufficientBalance(userBalance, _amount);
        }

        // 2. EFFECT: Update state before external interaction
        balances[msg.sender] -= _amount;

        // Record transaction in history
        transactionHistory.push(Transaction({
            user: msg.sender,
            amount: _amount,
            timestamp: block.timestamp,
            txType: TransactionType.Withdrawal
        }));

        // 3. INTERACTION: Send ETH to the user
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert TransferFailed();
        }

        emit FundsWithdrawn(msg.sender, _amount);
    }


    function getMyBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    
    function getTransactionCount() public view returns (uint256) {
        return transactionHistory.length;
    }

   
    function getFullHistory() public view returns (Transaction[] memory) {
        return transactionHistory;
    }


    function getContractTotalBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
