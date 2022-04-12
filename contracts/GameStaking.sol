// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";
import "./GameToken.sol";

contract ItemStake {
    IERC721 public gameItem;
    GameToken token;
    struct StakedItem {
        uint256 tokenId;
        uint256 timestamp;
        address owner;
    }

    event NFTStaked(address owner, uint256 tokenId, uint256 value);
    event NFTUnstaked(address owner, uint256 tokenId, uint256 value);

    mapping(uint256 => StakedItem) public stakedItems;

    constructor() {
        gameItem = IERC721(0xAc40c9C8dADE7B9CF37aEBb49Ab49485eBD3510d);
        token = GameToken(0x8431717927C4a3343bCf1626e7B5B1D31E240406);
    }

    function stake(uint256[] calldata _tokenIds) external {
        uint256 tokenId;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            tokenId = _tokenIds[i];
            require(
                gameItem.ownerOf(tokenId) == msg.sender,
                "Not owner of token"
            );
            require(stakedItems[tokenId].tokenId == 0, "Token already staked");
            gameItem.safeTransferFrom(msg.sender, address(this), tokenId);
            emit NFTStaked(msg.sender, tokenId, block.timestamp);
            stakedItems[tokenId] = StakedItem({
                tokenId: uint32(tokenId),
                owner: msg.sender,
                timestamp: block.timestamp
            });
        }
    }

    function unstake(uint256[] calldata _tokenIds) public {
        uint256 tokenId;
        uint256 tokensToClaim;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            tokenId = _tokenIds[i];
            require(
                gameItem.ownerOf(tokenId) == msg.sender,
                "Not owner of token"
            );
            StakedItem memory item = stakedItems[tokenId];
            //864 for 100 tokens
            tokensToClaim += (block.timestamp - item.timestamp) / 1;
            console.log(tokensToClaim);

            emit NFTUnstaked(msg.sender, tokenId, item.timestamp);
            delete stakedItems[tokenId];
        }
        if (tokensToClaim > 0) {
            token.mint(msg.sender, tokensToClaim);
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
}
