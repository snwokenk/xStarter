// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

enum OFFERACTION {
    DELETE,
    PAUSE
}
struct OfferOption {
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
    uint tokenDeposit; // amount to deposit
    address tokenAddr;
    OfferOption[] options;
    
}

contract StorageV1 {
    uint constant version = 1;
    mapping(address => Offer[]) offerers;
            //countryId     stateId         catId           subCatID
    mapping(uint => mapping(uint => mapping(uint => mapping(uint => Offer[]) ))) offers;
    // [offer][subCatID][catId][stateId][countryId]
    OfferOption[] offer1;
    
    function getOffer(uint countryId, uint stateId, uint catId, uint subCatID, uint index) public view returns(Offer memory) {
        return offers[countryId][stateId][catId][subCatID][index];
    }
    
    function addOffer(uint countryId, uint stateId,  uint cityId, uint catId, uint subCatID, uint expiration, string memory urlInfo,  OfferOption[] memory options) payable public returns(uint index) {
        
        // todo: have a way of setting the max seconds change from hardcoded to a changeable variable
        // todo: have a way of receiving xstn tokens for deposit or Native token
        require(expiration > block.timestamp && (expiration - block.timestamp) > 2592000, 'Listing Greater than 30 days');
        offers[countryId][stateId][catId][subCatID].push();
        Offer storage anOffer = offers[countryId][stateId][catId][subCatID][offers[countryId][stateId][catId][subCatID].length - 1];
        anOffer.creator = msg.sender;
        anOffer.urlInfo = urlInfo;
        anOffer.countryId = countryId;
        anOffer.stateId = stateId;
        anOffer.cityId = cityId;
        anOffer.catId = catId;
        anOffer.subCatID = subCatID;
        anOffer.created = block.timestamp;
        anOffer.exp = expiration ;
        for (uint i=0; i<options.length; i++) {
            anOffer.options.push(options[i]);
        }
        return offers[countryId][stateId][catId][subCatID].length - 1;
    }
    
    function deleteOrPauseOffer(uint countryId, uint stateId, uint catId, uint subCatID, uint index, OFFERACTION action)  public returns(Offer memory) {
        Offer storage anOffer = offers[countryId][stateId][catId][subCatID][index];
        
        require(anOffer.creator == msg.sender, "not authorized");
        
        if(action == OFFERACTION.PAUSE) {
            anOffer.isPaused = true;
        }else if (action == OFFERACTION.DELETE) {
            anOffer.isDeleted = true;
            uint tmpAmt = anOffer.tokenDeposit;
            anOffer.tokenDeposit = 0;
            //  todo: using token add
        }else {
            revert("Invalid Action");
        }
        
        return anOffer;
        
    }
    
    function getSubCatOffers(uint countryId, uint stateId, uint catId, uint subCatID) public view returns(Offer[] memory) {
        return offers[countryId][stateId][catId][subCatID];
    }
    
    // function getCatOffers(uint countryId, uint stateId, uint catId, uint subCatID) view 
}

contract DiscountOffer is Ownable {
    
    
    
}