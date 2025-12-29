// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DonationVault {
    address public owner;
    uint256 public totalDonations;

    event DonationReceived(address indexed donor, uint256 amount);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // Donate ETH to the contract
    function donate() external payable {
        require(msg.value > 0, "Donation must be greater than 0");
        totalDonations += msg.value;

        emit DonationReceived(msg.sender, msg.value);
    }

    // Withdraw all funds (only owner)
    function withdraw() external {
        require(msg.sender == owner, "Not owner");

        uint256 balance = address(this).balance;
        require(balance > 0, "No funds");

        payable(owner).transfer(balance);
        emit FundsWithdrawn(owner, balance);
    }

    // Get contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
