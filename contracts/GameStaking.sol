// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
    uint256 stakedTokenAmount;

    constructor(address _gameToken, address _gameItem) {
        gameItem = IERC721(_gameItem);
        token = GameToken(_gameToken);
    }

    function stake(uint32[] calldata _tokenIds) external {
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
            stakedTokenAmount++;
        }
    }

    function unstake(uint32[] calldata _tokenIds) public {
        uint256 tokenId;
        uint256 tokensToClaim;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            tokenId = _tokenIds[i];
            StakedItem memory item = stakedItems[tokenId];
            require(item.owner == msg.sender, "Not owner of token");
            //864 for 100 tokens
            tokensToClaim += (block.timestamp - item.timestamp) / 1;
            console.log(tokensToClaim);
            gameItem.safeTransferFrom(address(this), msg.sender, tokenId);
            emit NFTUnstaked(msg.sender, tokenId, item.timestamp);
            delete stakedItems[tokenId];
            stakedTokenAmount--;
        }
        if (tokensToClaim > 0) {
            token.mint(msg.sender, tokensToClaim);
        }
    }

    function getStakedTokens(address _account)
        public
        view
        returns (uint32[] memory)
    {
        uint32[] memory arr = new uint32[](stakedTokenAmount);
        for (uint256 i = 0; i < stakedTokenAmount; i++) {
            StakedItem memory item = stakedItems[i];
            if (item.owner == _account) {
                arr[i] = uint32(item.tokenId);
            }
        }
        return arr;
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
