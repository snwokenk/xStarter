// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

enum OFFERACTION {
    DELETE,
    PAUSE
}
struct OfferOption {
    uint id;
    uint oPrice; // original price
    uint dPrice; // discounted price
    uint oQuantity; // quantity 
    uint currQuantity; // current quantity
}
struct offerMappingInfo {
    uint countryId;
    uint stateId;
    uint catId;
    uint subCatID;
    uint index;
}

struct Offerer {
    address addr;
    Offer[] createdOffers;
    uint tokenDeposits;
}

struct Offer {
    address creator;
    string urlInfo;
    uint countryId;
    uint stateId;
    uint cityId;
    uint catId;
    uint subCatID;
    uint created; // timestamp
    uint exp; // expiration, distance between created should not be greater than 2592000 when divided by renewals + 1
    uint renewals; 
    bool isDeleted;
    bool isPaused;
    OfferOption[] options;
    
}

contract StorageV1 {
    uint constant version = 1;
    mapping(address => Offer[]) offerers;
            //countryId     stateId         catId           subCatID
    mapping(uint => mapping(uint => mapping(uint => mapping(uint => Offer[]) ))) offers;
    // [offer][subCatID][catId][stateId][countryId]
    
    function getOffer(uint countryId, uint stateId, uint catId, uint subCatID, uint index) public view returns(Offer memory) {
        return offers[countryId][stateId][catId][subCatID][index];
    }
    function addOffer(uint countryId, uint stateId,  uint cityId, uint catId, uint subCatID, uint expiration, string memory urlInfo, OfferOption[] memory options) public returns(uint index) {
        
        // todo: have a way of setting the max seconds change from hardcoded
        require(expiration > block.timestamp && (expiration - block.timestamp) > 2592000, 'Listing Greater than 30 days');
        offers[countryId][stateId][catId][subCatID].push(Offer(msg.sender, urlInfo, countryId, stateId, cityId, catId, subCatID, block.timestamp, block.timestamp + 2500000, 0, false, false, options));
        return offers[countryId][stateId][catId][subCatID].length - 1;
    }
    function deleteOrPauseOffer(uint countryId, uint stateId, uint catId, uint subCatID, uint index, OFFERACTION action)  public returns(Offer memory) {
        
    }
    function getSubCatOffers(uint countryId, uint stateId, uint catId, uint subCatID) public view returns(Offer[] memory) {
        return offers[countryId][stateId][catId][subCatID];
    }
    
    // function getCatOffers(uint countryId, uint stateId, uint catId, uint subCatID) view 
}

contract DiscountOffer is Ownable {
    
    
    
    
    
}