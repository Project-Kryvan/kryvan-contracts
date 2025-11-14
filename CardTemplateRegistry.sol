// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CardTemplateRegistry is Ownable {
    enum Rarity { Common, Rare, Epic, Legendary }

    constructor() Ownable(msg.sender) {}

    struct TemplateInfo {
        Rarity rarity;
        uint32 maxSupply;
        uint32 minted;
        bool active;
        bytes32 contentHash;
    }

    mapping(uint256 => TemplateInfo) public templates;
    uint256 public nextTemplateId = 1;

    uint256[] private _common;
    uint256[] private _rare;
    uint256[] private _epic;
    uint256[] private _legend;

    mapping(address => bool) public minters;

    function setMinter(address minter, bool allowed) external onlyOwner {
        minters[minter] = allowed;
    }

    // ----------------------------------------------------------
    // NEW INTERNAL FUNCTION
    // ----------------------------------------------------------
    function _addTemplate(
        Rarity rarity,
        uint32 maxSupply,
        bytes32 contentHash
    ) internal returns (uint256 templateId) {
        templateId = nextTemplateId++;

        templates[templateId] = TemplateInfo(
            rarity,
            maxSupply,
            0,
            true,
            contentHash
        );

        if (rarity == Rarity.Common) _common.push(templateId);
        else if (rarity == Rarity.Rare) _rare.push(templateId);
        else if (rarity == Rarity.Epic) _epic.push(templateId);
        else _legend.push(templateId);
    }

    // ----------------------------------------------------------
    // EXISTING SINGLE ADD FUNCTION (NOW USES _addTemplate)
    // ----------------------------------------------------------
    function addTemplate(
        Rarity rarity,
        uint32 maxSupply,
        bytes32 contentHash
    ) external onlyOwner returns (uint256 templateId) {
        return _addTemplate(rarity, maxSupply, contentHash);
    }

    // ----------------------------------------------------------
    // NEW BATCH FUNCTION
    // ----------------------------------------------------------
    function addTemplateBatch(
        Rarity[] calldata rarities,
        uint32[] calldata maxSupplies,
        bytes32[] calldata contentHashes
    ) external onlyOwner {
        require(
            rarities.length == maxSupplies.length &&
            rarities.length == contentHashes.length,
            "CardTemplateRegistry: array length mismatch"
        );

        for (uint256 i = 0; i < rarities.length; i++) {
            _addTemplate(
                rarities[i],
                maxSupplies[i],
                contentHashes[i]
            );
        }
    }

    function getPool(Rarity rarity) external view returns (uint256[] memory) {
        if (rarity == Rarity.Common) return _common;
        if (rarity == Rarity.Rare) return _rare;
        if (rarity == Rarity.Epic) return _epic;
        return _legend;
    }

    function markMinted(uint256 templateId, uint32 amount) external {
        require(minters[msg.sender], "Not minter");

        TemplateInfo storage t = templates[templateId];

        if (t.maxSupply != 0) {
            require(t.minted + amount <= t.maxSupply, "Supply exceeded");
        }

        t.minted += amount;
    }

    function getTemplate(uint256 templateId)
        external
        view
        returns (TemplateInfo memory)
    {
        return templates[templateId];
    }
}
