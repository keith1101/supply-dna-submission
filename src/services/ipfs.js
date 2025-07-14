import axios from 'axios';

// IPFS Gateway URLs
const IPFS_GATEWAYS = [
  'https://ipfs.io/ipfs/',
  'https://gateway.pinata.cloud/ipfs/',
  'https://cloudflare-ipfs.com/ipfs/',
  'https://dweb.link/ipfs/'
];

// Configurable upload endpoint
const UPLOAD_ENDPOINT = process.env.REACT_APP_PINATA_UPLOAD_ENDPOINT || 
  (process.env.NODE_ENV === 'development' ? 'http://localhost:5001/upload' : '/api/pinata-upload');

if (!UPLOAD_ENDPOINT) {
  console.warn('Pinata upload endpoint is not set. Registration will fail.');
}

// Simple IPFS service using HTTP gateways
export const uploadToIPFS = async (data) => {
  if (!data || Object.keys(data).length === 0) {
    throw new Error('No metadata provided for IPFS upload');
  }
  try {
    console.log('Uploading to Pinata …', data);
    const response = await fetch(UPLOAD_ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    
    if (!response.ok) {
      let errorMsg = `Upload failed with status ${response.status}`;
      try {
        const errorData = await response.json();
        errorMsg = errorData.error || errorMsg;
      } catch {}
      console.error('Pinata upload error:', errorMsg);
      throw new Error(errorMsg);
    }
    
    const result = await response.json();
    if (!result.IpfsHash) {
      console.error('No IPFS hash received from Pinata:', result);
      throw new Error('No IPFS hash received from Pinata');
    }
    
    console.log('Successfully uploaded to IPFS:', result.IpfsHash);
    return result.IpfsHash;
  } catch (error) {
    console.error('IPFS upload error:', error);
    throw new Error(error.message || 'Failed to upload to IPFS');
  }
};

export const getFromIPFS = async (hash) => {
  try {
    // Try multiple gateways for redundancy
    for (const gateway of IPFS_GATEWAYS) {
      try {
        const response = await axios.get(`${gateway}${hash}`, {
          timeout: 5000
        });
        return response.data;
      } catch (gatewayError) {
        console.warn(`Gateway ${gateway} failed, trying next...`);
        continue;
      }
    }
    throw new Error('All IPFS gateways failed');
  } catch (error) {
    console.error('IPFS fetch error:', error);
    throw new Error(error.message || 'Failed to fetch from IPFS');
  }
};

// Helper function to create metadata for NFT
export const createNFTMetadata = (componentData) => {
  return {
    name: `SupplyDNA Component - ${componentData.id}`,
    description: `Component ${componentData.id} registered in SupplyDNA blockchain traceability system`,
    image: "https://via.placeholder.com/400x400/3498db/ffffff?text=SupplyDNA+Component",
    attributes: [
      {
        trait_type: "Component ID",
        value: componentData.id
      },
      {
        trait_type: "Name",
        value: componentData.name
      },
      {
        trait_type: "Supplier",
        value: componentData.supplier
      },
      {
        trait_type: "Batch",
        value: componentData.batch
      },
      {
        trait_type: "Manufacturing Date",
        value: componentData.date
      },
      {
        trait_type: "Registration Date",
        value: new Date().toISOString().split('T')[0]
      }
    ],
    external_url: "https://supplydna.com",
    background_color: "3498db"
  };
};