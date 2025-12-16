# Anleitung: Deployment der Smart Contracts mit Remix

Diese Anleitung beschreibt das neutrale und unveränderte Aufsetzen der folgenden Smart Contracts mit Remix:

- GameCardsCore.sol  
- CardTemplateRegistry.sol  
- PackMinter.sol  

Der Contract-Code wird nicht verändert.

---

## 1. Voraussetzungen

- Webbrowser  
- Zugriff auf https://remix.ethereum.org  
- Optional: MetaMask (für Testnet oder Mainnet)

---

## 2. Workspace in Remix anlegen

1. Remix öffnen  
2. Workspaces → New Workspace  
3. Name z. B. `ProjectKryvan`  
4. Im Ordner `contracts/` folgende Dateien anlegen:
   - GameCardsCore.sol  
   - CardTemplateRegistry.sol  
   - PackMinter.sol  
5. Code unverändert einfügen  

---

## 3. Solidity Compiler konfigurieren

- Tab: Solidity Compiler  
- Compiler Version: `0.8.24`  
- Auto Compile: deaktiviert  
- Optimization: optional  
- PackMinter.sol kompilieren  

---

## 4. Deployment-Reihenfolge

Die Contracts müssen in der folgenden Reihenfolge deployt werden.

---

## 4.1 GameCardsCore deployen

- Tab: Deploy & Run Transactions  
- Environment:
  - Remix VM (Cancun) oder  
  - Injected Provider – MetaMask  
- Contract: GameCardsCore  

Constructor:
- name_: Project Kryvan  
- symbol_: KRY  

Deploy ausführen.

Optional:
- setBaseURI("ipfs://CID/")

---

## 4.2 CardTemplateRegistry deployen

- Contract: CardTemplateRegistry  
- Constructor: keine Parameter  
- Deploy ausführen  

---

## 4.3 PackMinter deployen

- Contract: PackMinter  

Constructor:
- coreAddr = Adresse von GameCardsCore  
- registryAddr = Adresse von CardTemplateRegistry  

Deploy ausführen.

---

## 5. Berechtigungen setzen

Nach dem Deployment muss der PackMinter als Minter freigeschaltet werden.

### GameCardsCore
- setMinter(PACK_MINTER_ADRESSE, true)

### CardTemplateRegistry
- setMinter(PACK_MINTER_ADRESSE, true)

Beide Funktionen müssen vom Owner ausgeführt werden.

---

## 6. Templates anlegen

Damit Packs geöffnet werden können, müssen Templates existieren.

Funktion:
- addTemplate(rarity, maxSupply, contentHash)

Parameter:
- rarity  
  - 0 = Common  
  - 1 = Rare  
  - 2 = Epic  
  - 3 = Legendary  
- maxSupply  
  - 0 = unbegrenzt  
- contentHash  
  - bytes32 Hash  

Für jede Rarity muss mindestens ein Template existieren.

---

## 7. Pack öffnen

Optional:
- setPackPrice(wei)

Pack öffnen:
- openPack()

Hinweise:
- Falls ein Preis gesetzt ist, muss der Betrag im Value-Feld mitgesendet werden  
- Maximal 3 Packs pro Wallet und Tag  

---

## 8. Karten verifizieren

Im GameCardsCore:

- ownerOf(tokenId)  
- tokenTemplateId(tokenId)  
- tokenURI(tokenId)  

---

## 9. Ergebnis

Nach Abschluss sind aktiv:

- ERC721 Karten-Contract  
- Template-Registry  
- Pack-Minting-Logik  
- Daily-Pack-Limit  
- Bedienung vollständig über Remix  
