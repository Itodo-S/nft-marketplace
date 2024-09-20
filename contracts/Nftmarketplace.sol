// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./Counters.sol";

contract NFTMarketplace is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    struct NFTItem {
        uint256 tokenId;
        address payable owner;
        uint256 price;
        bool forSale;
    }

    mapping(uint256 => NFTItem) private _marketItems;

    // Minting role
    mapping(address => bool) private _minters;

    // Events
    event Minted(uint256 tokenId, address owner, string tokenURI);
    event ListedForSale(uint256 tokenId, uint256 price);
    event Sold(uint256 tokenId, address buyer, uint256 price);

    constructor() ERC721("MarketplaceNFT", "MPNFT") Ownable(msg.sender) {}

    // Modifier to check minters
    modifier onlyMinter() {
        require(_minters[msg.sender], "Only minters can perform this action");
        _;
    }

    // Add a new minter
    function addMinter(address minter) public onlyOwner {
        _minters[minter] = true;
    }

    // Mint a new NFT
    function mintNFT(string memory tokenURI) public onlyMinter returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        _marketItems[newTokenId] = NFTItem({
            tokenId: newTokenId,
            owner: payable(msg.sender),
            price: 0,
            forSale: false
        });

        emit Minted(newTokenId, msg.sender, tokenURI);

        return newTokenId;
    }

    // List an NFT for sale
    function listNFTForSale(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can list the NFT");
        require(price > 0, "Price must be greater than 0");

        _marketItems[tokenId].price = price;
        _marketItems[tokenId].forSale = true;

        emit ListedForSale(tokenId, price);
    }

    // Buy an NFT
    function buyNFT(uint256 tokenId) public payable {
        NFTItem memory item = _marketItems[tokenId];
        require(item.forSale, "This NFT is not for sale");
        require(msg.value >= item.price, "Insufficient funds to buy the NFT");

        address seller = item.owner;
        _transfer(seller, msg.sender, tokenId);

        item.owner = payable(msg.sender);
        item.forSale = false;
        _marketItems[tokenId] = item;

        // Transfer payment to seller
        payable(seller).transfer(msg.value);

        emit Sold(tokenId, msg.sender, item.price);
    }

    // Get details of an NFT
    function getNFT(uint256 tokenId) public view returns (NFTItem memory) {
        return _marketItems[tokenId];
    }

    // Get all NFTs listed for sale
    function getAllNFTsForSale() public view returns (NFTItem[] memory) {
        uint256 totalItems = _tokenIds.current();
        uint256 saleCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= totalItems; i++) {
            if (_marketItems[i].forSale) {
                saleCount++;
            }
        }

        NFTItem[] memory itemsForSale = new NFTItem[](saleCount);

        for (uint256 i = 1; i <= totalItems; i++) {
            if (_marketItems[i].forSale) {
                itemsForSale[currentIndex] = _marketItems[i];
                currentIndex++;
            }
        }

        return itemsForSale;
    }
}
