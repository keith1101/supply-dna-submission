# SupplyDNA: Blockchain & AIoT Component Traceability System

SupplyDNA is a modern web application for tracking, verifying, and analyzing supply chain components using blockchain, NFTs, and IPFS. It enables manufacturers, OEMs, logistics, and regulators to register, trace, and authenticate components with full transparency and security.

## Key Features
- **Component Registration:** Register components with unique metadata and mint a non-transferable NFT certificate. Metadata is stored on IPFS via Pinata.
- **Component Lookup & QR Scanning:** Instantly look up components by UUID or scan QR codes to retrieve blockchain-verified details and lifecycle.
- **NFT Certificate Display:** View NFT metadata, attributes, and blockchain explorer links for each registered component.
- **Traceability & Analytics:** (Planned) Visualize full trace history, chain of custody, and supply chain analytics.
- **Reports & Compliance:** (Planned) Generate and review supply chain reports for compliance and business insights.

## Technologies Used
- **Frontend:** React, ethers.js, recharts, react-icons, QR scanning
- **Smart Contract:** Custom ERC-721 (soulbound) NFT for supply chain, written in Solidity
- **IPFS Integration:** Pinata for storing NFT metadata and images
- **Blockchain:** Lisk Sepolia Testnet

## Smart Contract Overview
- **ERC-721 NFT:** Each component is registered with unique metadata (ID, name, supplier, batch, date, IPFS URI)
- **Non-transferable NFTs:** Ensures authenticity and traceability
- **Main Functions:**
  - `registerComponent`: Register and mint NFT (owner only)
  - `getComponent`: Retrieve component details by ID
  - `getTokenId`: Get NFT token ID for a component
  - `tokenURI`: Get IPFS metadata URI for a token
  - `updateMetadata`: Update component metadata URI (owner only)

## Getting Started
1. **Clone the repository:**
   ```bash
   git clone <repo-url>
   cd supplydna-frontend-2
   ```
2. **Configure environment:**
   Create a `.env` file in the root directory:
   ```bash
   PINATA_API_KEY=your_pinata_api_key_here
   PINATA_SECRET_API_KEY=your_pinata_secret_api_key_here
   REACT_APP_CONTRACT_ADDRESS=your_contract_address_here
   # Optional: REACT_APP_PINATA_UPLOAD_ENDPOINT=http://localhost:5001/upload
   ```
3. **Install dependencies:**
   ```bash
   npm install
   ```
4. **Start the development servers:**
   ```bash
   npm run dev
   # or
   npm start
   ```
   The app will be available at [http://localhost:3000](http://localhost:3000).

## Usage
- **Register a Component:** Go to "Register", fill in details, and submit. NFT is minted and metadata stored on IPFS.
- **Lookup a Component:** Enter UUID or scan QR code to view details and NFT certificate.
- **Traceability & Analytics:** (Planned) Explore supply chain insights and reports.

## Project Structure
- `src/components/` – UI components
- `src/services/` – Blockchain and IPFS logic
- `api/pinata-upload.js` – Vercel serverless function for IPFS uploads
- `SupplyDNANFT_Custom.sol` – Solidity smart contract
- `public/` – Static assets

## Powered by
- IPFS
- Pinata
- Lisk
---
*This MVP is under active development. Planned features (traceability, analytics, reports) are coming soon.*
