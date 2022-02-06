//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Nftmarket is ReentrancyGuard {

using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

address payable owner;
uint256 listingPrice = 0.025 ether; 

constructor() {
    owner = payable(msg.sender);
  }

struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
  }

mapping(uint256 => MarketItem) private idToMarketItem;

event MarketItemCreated (
    uint indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    bool sold
  );

function getListingPrice() public view returns (uint256) {
    return listingPrice;
  }

// Function to place an item for sale on marketplace

 function createMarketItem(
    address nftContract,
    uint256 tokenId,
    uint256 price
  ) public payable nonReentrant {
      require(price > 0, "Price must be at least 1 wei");
      require(msg.value == listingPrice, "Price must be equal to listing price");
      _itemIds.increment();
      uint256 itemId = _itemIds.current();
      idToMarketItem[itemId] =  MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      price,
      false
    );

IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);


  }


    // Function to create a sale for the marketplace item 
    // Transfers ownership of the item, as well as funds between parties 
  
  function createMarketSale(
    address nftContract,
    uint256 itemId
    ) public payable nonReentrant {

        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");
        idToMarketItem[itemId].seller.transfer(msg.value); // Transfering ether to seller 
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId); // transfering ownership of nft to buyer from marketplace
        idToMarketItem[itemId].owner = payable(msg.sender); // updating mapping
        idToMarketItem[itemId].sold = true; // updating sale mapping 
        _itemsSold.increment(); 
        payable(owner).transfer(listingPrice);
    }

// Funtion to return all unsold market items 
  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint itemCount = _itemIds.current();
    uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
    uint currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](unsoldItemCount); // array items of type MarketItem of size that of equal to unsoldItemCount
    for (uint i = 0; i < itemCount; i++) { // looping over all items
      if (idToMarketItem[i + 1].owner == address(0)) { // finding items which are unsold by ensuring the owner address is zero
        uint currentId = i + 1; // storing the id of unsold item in variable
        MarketItem storage currentItem = idToMarketItem[currentId]; //
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

// Function to return only items that a user has purchased 
  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

// looping over items purchased by the owner
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);// array items of type MarketItem of size that of equal to purchased by the owner
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

//  Function to return only items a user has created themselves
  function fetchItemsCreated() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

}