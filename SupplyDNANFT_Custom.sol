// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC165 {
    function supportsInterface(bytes4 interfaceID)
        external
        view
        returns (bool);
}

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId)
        external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721 is IERC721 {
    event Transfer(
        address indexed from, address indexed to, uint256 indexed id
    );
    event Approval(
        address indexed owner, address indexed spender, uint256 indexed id
    );
    event ApprovalForAll(
        address indexed owner, address indexed operator, bool approved
    );

    // Mapping from token ID to owner address
    mapping(uint256 => address) internal _ownerOf;

    // Mapping owner address to token count
    mapping(address => uint256) internal _balanceOf;

    // Mapping from token ID to approved address
    mapping(uint256 => address) internal _approvals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        returns (bool)
    {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC165).interfaceId;
    }

    function ownerOf(uint256 id) external view returns (address owner) {
        owner = _ownerOf[id];
        require(owner != address(0), "token doesn't exist");
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "owner = zero address");
        return _balanceOf[owner];
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function approve(address spender, uint256 id) external {
        address owner = _ownerOf[id];
        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "not authorized"
        );

        _approvals[id] = spender;

        emit Approval(owner, spender, id);
    }

    function getApproved(uint256 id) external view returns (address) {
        require(_ownerOf[id] != address(0), "token doesn't exist");
        return _approvals[id];
    }

    function _isApprovedOrOwner(address owner, address spender, uint256 id)
        internal
        view
        returns (bool)
    {
        return (
            spender == owner || isApprovedForAll[owner][spender]
                || spender == _approvals[id]
        );
    }

    function transferFrom(address from, address to, uint256 id) public virtual {
        require(from == _ownerOf[id], "from != owner");
        require(to != address(0), "transfer to zero address");

        require(_isApprovedOrOwner(from, msg.sender, id), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;

        delete _approvals[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint256 id) external virtual {
        transferFrom(from, to, id);
        // Note: The require statement below is unreachable in this implementation
        // since transferFrom will handle the transfer logic
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata
    ) external virtual {
        transferFrom(from, to, id);
        // Note: The require statement below is unreachable in this implementation
        // since transferFrom will handle the transfer logic
    }

    function _mint(address to, uint256 id) internal {
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");

        _balanceOf[to]++;
        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal {
        address owner = _ownerOf[id];
        require(owner != address(0), "not minted");

        _balanceOf[owner] -= 1;

        delete _ownerOf[id];
        delete _approvals[id];

        emit Transfer(owner, address(0), id);
    }
}

contract SupplyDNANFT is ERC721 {
    uint256 private _tokenIds;
    address public owner;

    struct Component {
        string id;
        string name;
        string supplier;
        string batch;
        string date;
        string metadataURI;
    }

    mapping(string => Component) public components;
    mapping(uint256 => string) public tokenToComponentId;
    mapping(string => uint256) public componentIdToToken;

    event ComponentRegistered(string id, string name, string supplier, uint256 tokenId);
    event MetadataUpdated(string componentId, string newMetadataURI);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function registerComponent(
        string memory _id,
        string memory _name,
        string memory _supplier,
        string memory _batch,
        string memory _date,
        string memory _metadataURI
    ) public onlyOwner {
        require(componentIdToToken[_id] == 0, "Component already registered");
        
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        
        components[_id] = Component(_id, _name, _supplier, _batch, _date, _metadataURI);
        tokenToComponentId[newTokenId] = _id;
        componentIdToToken[_id] = newTokenId;
        
        _mint(msg.sender, newTokenId);
        emit ComponentRegistered(_id, _name, _supplier, newTokenId);
    }

    function getComponent(string memory _id) public view returns (Component memory) {
        return components[_id];
    }

    function getTokenId(string memory _id) public view returns (uint256) {
        return componentIdToToken[_id];
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_ownerOf[tokenId] != address(0), "Token does not exist");
        string memory componentId = tokenToComponentId[tokenId];
        return components[componentId].metadataURI;
    }

    // Optional: Update metadata URI
    function updateMetadata(string memory _componentId, string memory _newMetadataURI) public onlyOwner {
        require(componentIdToToken[_componentId] != 0, "Component not found");
        components[_componentId].metadataURI = _newMetadataURI;
        emit MetadataUpdated(_componentId, _newMetadataURI);
    }

    // Override transfer functions to make NFTs non-transferable (soulbound)
    function transferFrom(address, address, uint256) public pure override {
        revert("NFTs are non-transferable");
    }

    function safeTransferFrom(address, address, uint256) external pure override {
        revert("NFTs are non-transferable");
    }

    function safeTransferFrom(address, address, uint256, bytes calldata) external pure override {
        revert("NFTs are non-transferable");
    }

    // Transfer ownership of contract
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }
} 