// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameItem is ERC721, Ownable {
    using Strings for uint256;
    uint256 public maxTotalSupply = 4444;
    uint256 public maxMintPerTx = 3;
    uint256 public tokenID;

    constructor() ERC721("GameItem", "GI") {}

    function mint(uint256 _amount) public payable {
        require(_amount <= maxMintPerTx, "3_PER_TX_MAX");
        require(_amount + tokenID <= maxTotalSupply, "MAX_SUPPLY_REACHED");
        for (uint256 i = 1; i <= _amount; i++) {
            _safeMint(msg.sender, tokenID + i);
        }
        tokenID += _amount;
    }
}
