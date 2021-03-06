// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameItem is ERC721, Ownable {
    using Strings for uint256;
    uint256 public maxTotalSupply = 4444;
    uint256 public mintPrice = 0.01 ether;
    uint256 public maxMintPerTx = 10;
    uint256 public tokenID;
    string private baseURI;
    bool public paused = false;

    constructor() ERC721("GameItem", "GI") {}

    function mint(uint256 _amount) public payable {
        require(_amount <= maxMintPerTx, "3_PER_TX_MAX");
        require(!paused, "MINTING_IS_PAUSED");
        require(_amount + tokenID <= maxTotalSupply, "MAX_SUPPLY_REACHED");
        for (uint256 i = 1; i <= _amount; i++) {
            _safeMint(msg.sender, tokenID + i);
        }
        tokenID += _amount;
    }

    function setBaseURI(string memory _newURI) public onlyOwner {
        baseURI = _newURI;
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    function setContractPaused(bool _val) public onlyOwner {
        paused = _val;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }
}
