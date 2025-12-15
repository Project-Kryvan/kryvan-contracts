# Project Kryvan – Card & Pack Smart Contracts

This repository contains the core smart contracts that power the Project Kryvan card system.
The architecture is designed to be transparent, fair, and scalable, while keeping gameplay logic
clearly separated from ownership and data definitions.

The system is composed of three smart contracts, each with a clearly defined responsibility:

1. CardTemplateRegistry – Defines what cards exist  
2. GameCardsCore – Manages ownership of cards (NFTs)  
3. PackMinter – Controls how players obtain cards  

---

## High-Level Overview

Players do not mint cards directly.

Instead:
- Cards are defined as templates
- Booster packs use controlled randomness
- NFTs are minted only through authorized game logic

This ensures:
- Verifiable rarity
- Supply limits that cannot be bypassed
- Fair and predictable pack behavior

---

## 1. CardTemplateRegistry

### Purpose

CardTemplateRegistry acts as the master catalog of all card types in the game.

It defines:
- Which cards exist
- Their rarity
- Their maximum supply
- Whether they can still be minted

This contract does not mint NFTs and does not track ownership.

---

### Card Templates

A template represents a card type, not an individual card.

Example:
- Fire Dragon
- Rarity: Legendary
- Max Supply: 100
- Artwork and metadata defined off-chain

Multiple players can own cards created from the same template.

---

### Template Properties

Each template stores:
- rarity – Common, Rare, Epic, or Legendary
- maxSupply – Maximum number of NFTs allowed (0 = unlimited)
- minted – How many NFTs already exist
- active – Whether the template can be used
- contentHash – Reference hash for metadata integrity

---

### Rarity Pools

Templates are automatically grouped by rarity.
This allows booster packs to efficiently request a random template
of a specific rarity.

---

### Mint Authorization

Only approved contracts such as PackMinter are allowed to update mint counts.
This prevents unauthorized supply manipulation.

---

## 2. GameCardsCore

### Purpose

GameCardsCore is the NFT contract.

It is responsible for:
- Minting ERC-721 tokens
- Tracking ownership
- Linking each NFT to a card template

This contract contains no gameplay logic.

---

### Token ID vs Template ID

Each NFT has:
- A Token ID, which uniquely identifies the NFT
- A Template ID, which defines what kind of card it represents

Many NFTs can reference the same template.

---

### Minting

NFTs can only be minted by authorized contracts.
This ensures all cards originate from valid game actions.

---

### Metadata Strategy

The token metadata URL is derived from the template ID:

baseURI + templateId + ".json"

This means:
- All NFTs of the same card share metadata
- Artwork and stats can be updated per card type
- Storage costs are minimized

---

## 3. PackMinter

### Purpose

PackMinter contains the gameplay logic for opening booster packs.

It determines:
- Pack composition
- Rarity probabilities
- Daily limits
- Payment requirements

This contract coordinates the other two contracts.

---

### Pack Structure

Each booster pack contains five cards:

- Three Common cards
- One Rare card
- One final slot with randomized rarity

Final slot probabilities:
- 60 percent Rare
- 35 percent Epic
- 5 percent Legendary

---

### Daily Limits

Each wallet can open up to three packs per day.
This prevents abuse and stabilizes card distribution.

---

### Minting Flow

When a pack is opened:
1. A rarity is determined
2. A valid template is selected from the registry
3. Supply limits are checked
4. The template is marked as minted
5. An NFT is minted and sent to the player

All steps happen atomically in a single transaction.

---

### Randomness

Randomness is derived from on-chain data and is suitable for casual gameplay.
It is not intended for high-stakes or gambling use cases.

---

## Contract Interaction Diagram

Player  
↓  
PackMinter  
↓            ↘  
Registry        GameCardsCore  

---

## Design Goals

- Transparency for players
- Clear separation of concerns
- Supply integrity
- Upgrade-friendly architecture
- Gas efficiency

---

## Trust Model

- Only the contract owner can define card templates
- Only approved contracts can mint cards
- Players never interact with mint functions directly

---

## Summary

This contract system ensures that:
- Card rarity is provable
- Supply limits are enforced on-chain
- Ownership is permanent and verifiable
- Game logic can evolve without breaking existing NFTs

Project Kryvan uses blockchain as a trust layer, not as a gimmick.

---

## License

MIT
