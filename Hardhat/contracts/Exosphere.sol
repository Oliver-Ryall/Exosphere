// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @author Oliver RYALL
 * @dev Exosphere contract allows users
 * to create market items (list nfts for sale) and create market sales (buy the nft).
 */
contract Exosphere is ReentrancyGuard {
    using Counters for Counters.Counter;

    // NFT id counter
    Counters.Counter private _itemIds;

    // Number of items sold counter
    Counters.Counter private _itemsSold;

    address public owner;

    // Sets the owner address to the user deploying the contract
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Struct representing a MarketItem(nft)
     * @param itemId Represents the contract's id of the item(for storage)
     * @param nftContract Represents the contract of the nft
     * @param tokenId Represents the id of the token (nft)
     * @param seller Represents the address of the seller
     * @param owner Represents the address of the nft owner
     * @param price Represents the price the nft is being listed for sale at
     * @param sold Boolean, True if the nft has been sold, False if it has not
     */
    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // nft id mapped to the nft struct(MarketItem)
    mapping(uint256 => MarketItem) private idToMarketItem;

    // event is emmited when an item is created
    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    /**
     * @dev event is emmited when an item is sold
     * @param itemId Represents the id of the nftContract
     * @param owner Represents the address of the owner
     */
    event MarketItemSold(uint256 indexed itemId, address owner);

    /**
     * @dev event is emmited when the fetchMarketItems function is called
     * @param marketItems Represents an array of all nfts on the marketplace
     */
    event MarketItemsFetched(uint256 marketItems);

    /**
     * @dev Function creates a market item (lists an nft on the marketplace)
     * @param nftContract Represents the contract of the nft being listed
     * @param tokenId Represents the id of the token (nft)
     * @param price Represents the price of the nft
     */
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        console.log(
            "creating market item with nftContract: %s, and tokenId: %s, and price: %s",
            nftContract,
            tokenId,
            price
        );

        require(price > 0, "Price must be greater than 0");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        IERC721(nftContract).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    /**
     * @dev Function used to create a market sale (purchase a market item (nft))
     * @param nftContract Represents the contract address of the nft contract
     * @param itemId Represents the contract's id of the market item
     */
    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        bool sold = idToMarketItem[itemId].sold;
        console.log("Value=%s", msg.value);
        console.log("Price=%s", price);
        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );
        require(sold != true, "This Sale has alredy finnished");
        emit MarketItemSold(itemId, msg.sender);
        idToMarketItem[itemId].owner = payable(msg.sender);
        _itemsSold.increment();
        idToMarketItem[itemId].sold = true;
        idToMarketItem[itemId].seller.transfer(msg.value);
        IERC721(nftContract).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
    }

    /**
     * @dev Function used to get all market items listed on the marketplace
     */
    function fetchMarketItems() public returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;
        emit MarketItemsFetched(unsoldItemCount);
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }
}
