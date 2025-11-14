// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract GameCardsCore is ERC721, Ownable {
    using Strings for uint256;

    uint256 private _nextTokenId = 1;

    mapping(uint256 => uint256) private _tokenTemplateId;

    mapping(address => bool) public minters;

    string private _baseTokenURI;

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
        Ownable(msg.sender)
    {}

    function setMinter(address minter, bool allowed) external onlyOwner {
        minters[minter] = allowed;
    }

    function mintTo(address to, uint256 templateId)
        external
        returns (uint256 tokenId)
    {
        require(minters[msg.sender], "Not minter");

        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _tokenTemplateId[tokenId] = templateId;
    }

    function tokenTemplateId(uint256 tokenId) external view returns (uint256) {
        require(_ownerOf(tokenId) != address(0), "Non-existent");
        return _tokenTemplateId[tokenId];
    }

    function setBaseURI(string calldata uri) external onlyOwner {
        _baseTokenURI = uri;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_ownerOf(tokenId) != address(0), "Non-existent");

        uint256 template = _tokenTemplateId[tokenId];

        return string(
            abi.encodePacked(_baseURI(), template.toString(), ".json")
        );
    }
}
