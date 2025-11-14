// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./GameCardsCore.sol";
import "./CardTemplateRegistry.sol";

contract PackMinter is Ownable, ReentrancyGuard {
    GameCardsCore public core;
    CardTemplateRegistry public registry;

    uint8 public constant DAILY_PACK_LIMIT = 3;
    uint256 public packPriceWei = 0;

    mapping(address => mapping(uint64 => uint8)) public packsOpened;

    uint256 private _nonce = 1;

    event PackOpened(address indexed user, uint256[5] tokenIds);

    constructor(address coreAddr, address registryAddr)
        Ownable(msg.sender)
    {
        core = GameCardsCore(coreAddr);
        registry = CardTemplateRegistry(registryAddr);
    }

    function setPackPrice(uint256 price) external onlyOwner {
        packPriceWei = price;
    }

    function openPack() external payable nonReentrant {
        require(msg.value >= packPriceWei, "Too cheap");

        uint64 dayKey = uint64(block.timestamp / 1 days);
        require(
            packsOpened[msg.sender][dayKey] < DAILY_PACK_LIMIT,
            "Daily limit"
        );

        packsOpened[msg.sender][dayKey]++;

        uint256[5] memory ids;

        // 3x Common
        ids[0] = _mintFromRarity(msg.sender, CardTemplateRegistry.Rarity.Common);
        ids[1] = _mintFromRarity(msg.sender, CardTemplateRegistry.Rarity.Common);
        ids[2] = _mintFromRarity(msg.sender, CardTemplateRegistry.Rarity.Common);

        // 1x Rare
        ids[3] = _mintFromRarity(msg.sender, CardTemplateRegistry.Rarity.Rare);

        // Final Slot — 60% Rare, 35% Epic, 5% Legendary
        uint256 roll = _rand() % 10000;

        CardTemplateRegistry.Rarity r;

        if (roll < 6000) {
            r = CardTemplateRegistry.Rarity.Rare;        // 60%
        } else if (roll < 9500) {
            r = CardTemplateRegistry.Rarity.Epic;        // 35%
        } else {
            r = CardTemplateRegistry.Rarity.Legendary;   // 5%
        }

        ids[4] = _mintFromRarity(msg.sender, r);

        emit PackOpened(msg.sender, ids);
    }

    function _mintFromRarity(address to, CardTemplateRegistry.Rarity rarity)
        internal
        returns (uint256)
    {
        uint256 tid = _pickTemplate(rarity);

        registry.markMinted(tid, 1);

        return core.mintTo(to, tid);
    }

    function _pickTemplate(CardTemplateRegistry.Rarity rarity)
        internal
        returns (uint256)
    {
        uint256[] memory pool = registry.getPool(rarity);

        require(pool.length > 0, "Empty pool");

        uint256 idx = _rand() % pool.length;

        for (uint256 i = 0; i < pool.length * 2; i++) {
            uint256 tid = pool[(idx + i) % pool.length];

            CardTemplateRegistry.TemplateInfo memory t =
                registry.getTemplate(tid);

            bool ok = (t.maxSupply == 0 || t.minted < t.maxSupply);

            if (t.active && ok) return tid;
        }

        revert("No template found");
    }

    function _rand() internal returns (uint256) {
        _nonce++;
        return uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, _nonce)
            )
        );
    }

    function withdraw(address payable to) external onlyOwner {
        to.transfer(address(this).balance);
    }
}
