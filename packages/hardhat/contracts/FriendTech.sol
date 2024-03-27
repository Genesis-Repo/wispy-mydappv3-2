// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Import the ERC20 contract from the OpenZeppelin library
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// Import the AccessControl contract from the OpenZeppelin library
import "@openzeppelin/contracts/access/AccessControl.sol";

// Contract declaration inheriting from ERC20 and AccessControl
contract FriendTech is ERC20, AccessControl {
    // Define a public owner variable to store the contract owner's address
    address public owner;

    // Define mappings to store share prices and total shares for each address
    mapping(address => uint256) private sharePrice;
    mapping(address => uint256) public totalShares;

    // Role definition for the owner
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    // Constructor to set the initial values and assign the contract deployer as the owner
    constructor() ERC20("FriendTech", "FTK") {
        owner = msg.sender;
        _setupRole(OWNER_ROLE, msg.sender);
    }

    // Function to set the share price, restricted to the owner
    function setSharePrice(uint256 price) external onlyRole(OWNER_ROLE) {
        require(price > 0, "Price must be greater than zero");
        sharePrice[msg.sender] = price;
    }

    // Function to get the share price for a specific user
    function getSharePrice(address user) public view returns (uint256) {
        return sharePrice[user];
    }

    // Function to set the total shares, restricted to the owner
    function setTotalShares(uint256 amount) external onlyRole(OWNER_ROLE) {
        require(amount > 0, "Amount must be greater than zero");
        totalShares[msg.sender] = amount;
    }

    // Function to get the total shares for a specific user
    function getTotalShares(address user) public view returns (uint256) {
        return totalShares[user];
    }

    // Function for a user to buy shares from another user
    function buyShares(address seller, uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than zero");
        require(totalShares[seller] >= amount, "Seller does not have enough shares");
        require(sharePrice[seller] <= msg.value, "Insufficient payment");

        totalShares[seller] -= amount;
        totalShares[msg.sender] += amount;

        // Calculate the amount of tokens to mint based on the share price
        uint256 tokensToMint = (msg.value * 10**decimals()) / sharePrice[seller];
        _mint(msg.sender, tokensToMint);
    }

    // Function for a user to sell shares to another user
    function sellShares(address buyer, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(totalShares[msg.sender] >= amount, "Insufficient shares");

        totalShares[msg.sender] -= amount;
        totalShares[buyer] += amount;

        // Calculate the amount of tokens to burn based on the share price
        uint256 tokensToBurn = (amount * sharePrice[msg.sender]) / 10**decimals();
        _burn(msg.sender, tokensToBurn);
        payable(buyer).transfer(tokensToBurn);
    }

    // Function for a user to transfer shares to another user
    function transferShares(address to, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(totalShares[msg.sender] >= amount, "Insufficient shares");

        totalShares[msg.sender] -= amount;
        totalShares[to] += amount;

        // Transfer the corresponding amount of tokens
        _transfer(msg.sender, to, amount);
    }
}