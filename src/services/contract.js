//require('dotenv').config();
import { Contract, BrowserProvider } from "ethers";
import contractABI from "../SupplyDNANFT_ABI.json";

const contractAddress = process.env.REACT_APP_CONTRACT_ADDRESS;
//const contractAddress = "0x205a19B7029091c668BEf932f434Bf2a01558Fc2";
console.log('SupplyDNA Contract Address:', contractAddress);

export async function getSupplyDNANFTContract() {
  if (!window.ethereum) throw new Error("MetaMask is required.");
  const provider = new BrowserProvider(window.ethereum);
  const signer = await provider.getSigner();
  return new Contract(contractAddress, contractABI, signer);
}