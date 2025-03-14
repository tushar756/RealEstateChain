// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealEstateChain is ERC721URIStorage, Ownable {
    uint256 public propertyCounter;

    struct Property {
        uint256 id;
        string location;
        uint256 price;
        address owner;
        bool isListed;
    }

    mapping(uint256 => Property) public properties;

    event PropertyListed(uint256 indexed propertyId, address indexed owner, uint256 price);
    event PropertySold(uint256 indexed propertyId, address indexed newOwner, uint256 price);

    // Fix: Pass msg.sender to the Ownable constructor
    constructor() ERC721("RealEstateNFT", "RESTATE") Ownable(msg.sender) {}

    function mintProperty(string memory _location, uint256 _price, string memory _tokenURI) public onlyOwner {
        uint256 propertyId = propertyCounter;
        _safeMint(msg.sender, propertyId);
        _setTokenURI(propertyId, _tokenURI);

        properties[propertyId] = Property(propertyId, _location, _price, msg.sender, true);
        propertyCounter++;

        emit PropertyListed(propertyId, msg.sender, _price);
    }

    function buyProperty(uint256 _propertyId) public payable {
        Property storage property = properties[_propertyId];

        require(property.isListed, "Property is not for sale");
        require(msg.value >= property.price, "Insufficient payment");

        address previousOwner = property.owner;
        property.owner = msg.sender;
        property.isListed = false;
        
        _transfer(previousOwner, msg.sender, _propertyId);
        payable(previousOwner).transfer(msg.value);

        emit PropertySold(_propertyId, msg.sender, msg.value);
    }

    function listPropertyForSale(uint256 _propertyId, uint256 _price) public {
        require(ownerOf(_propertyId) == msg.sender, "You are not the owner");
        properties[_propertyId].isListed = true;
        properties[_propertyId].price = _price;
        
        emit PropertyListed(_propertyId, msg.sender, _price);
    }
}
