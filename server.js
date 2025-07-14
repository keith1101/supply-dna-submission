require('dotenv').config({"path": "./.env"});
const express = require('express');
const cors = require('cors');
const PinataSDK = require('@pinata/sdk');

const app = express();
const PORT = process.env.PORT || 5001;

app.use(cors());
app.use(express.json());

const pinata = new PinataSDK(process.env.PINATA_API_KEY, process.env.PINATA_SECRET_API_KEY);

app.post('/upload', async (req, res) => {
  try {
    console.log('Uploading to Pinata:', req.body);

    if (!process.env.PINATA_API_KEY || !process.env.PINATA_SECRET_API_KEY) {
      return res.status(500).json({
        error: 'Pinata API keys not configured. Please set PINATA_API_KEY and PINATA_SECRET_API_KEY environment variables.'
      });
    }

    const result = await pinata.pinJSONToIPFS(req.body);
    console.log('Pinata upload successful:', result);

    res.json({ IpfsHash: result.IpfsHash });
  } catch (error) {
    console.error('Pinata upload error:', error);
    res.status(500).json({
      error: 'Failed to upload to Pinata: ' + error.message
    });
  }
});

app.listen(PORT, () => {
  console.log(`Local Pinata upload server running on http://localhost:${PORT}`);
  console.log('Make sure to set PINATA_API_KEY and PINATA_SECRET_API_KEY environment variables');
});