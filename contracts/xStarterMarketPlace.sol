// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

enum OFFERACTION {
    DELETE,
    PAUSE,
    ADD
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

struct Seller {
    address addr;
    offerMappingInfo[] createdOffers;
    // token address to uint
    mapping(address => uint) tokenDeposits;
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
    // OfferOption[] options;
    
}

contract StorageV1 {
    uint constant version = 1;
    mapping(address => Seller) creators;
            //countryId     stateId         catId           subCatID
    mapping(uint => mapping(uint => mapping(uint => mapping(uint => Offer[]) ))) offers;
    // [offer][subCatID][catId][stateId][countryId]
    OfferOption[] offer1;
    
    function getOffer(uint countryId, uint stateId, uint catId, uint subCatID, uint index) public view returns(Offer memory) {
        return offers[countryId][stateId][catId][subCatID][index];
    }
    
    function getSubCatOffers(uint countryId, uint stateId, uint catId, uint subCatID) public view returns(Offer[] memory) {
        return offers[countryId][stateId][catId][subCatID];
    }
    function _getOffer(offerMappingInfo memory mappingInfo) internal view returns(Offer memory) {
        return offers[mappingInfo.countryId][mappingInfo.stateId][mappingInfo.catId][mappingInfo.subCatID][mappingInfo.index];
    }
    
    function getCreatorOffers(address creator, uint page, uint resultPerPage) public view returns(Offer[] memory creatorOffers, bool endOfArray) {
        Seller storage aSeller = creators[creator];
         uint len = aSeller.createdOffers.length;
        // return empty list for c without offers
        if(aSeller.addr == address(0) || len == 0) {
            return (creatorOffers, true);
        }
        if(resultPerPage < 5) {
            resultPerPage = 5;
        }
        
        // get end and last index
        uint end = (page * resultPerPage) + resultPerPage;
        endOfArray =  end >= len;
        end = endOfArray ? len : end;
        uint start = end <= resultPerPage ? 0 : end - resultPerPage;
        creatorOffers = new Offer[](end - start);
        uint ind = 0;
        for (uint i=start ; i < end; i++) {
            creatorOffers[ind] = _getOffer(aSeller.createdOffers[i]);
            ind++;
        }
        
    }
    
    event OfferAction(Offer indexed anOffer, OFFERACTION anAction);
    function addOffer(uint countryId, uint stateId,  uint cityId, uint catId, uint subCatID, uint expiration, string memory urlInfo) payable public returns(uint index) {
        
        // todo: have a way of setting the max seconds change from hardcoded to a changeable variable
        // todo: have a way of receiving xstn tokens for deposit or Native token
        require(expiration > block.timestamp && (expiration - block.timestamp) <= 2592000, 'Listing Greater than 30 days');
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
        // for (uint i=0; i<options.length; i++) {
        //     anOffer.options.push(options[i]);
        // }

        offerMappingInfo[] storage createdOffer = creators[msg.sender].createdOffers;
        // create a new storage mapping info
        createdOffer.push();
        // retrieve new mapping info
        offerMappingInfo storage mappedOffer = createdOffer[createdOffer.length - 1];
        
        // populate it with relevant data
        mappedOffer.countryId = countryId;
        mappedOffer.stateId = stateId;
        mappedOffer.index = offers[countryId][stateId][catId][subCatID].length - 1;
        mappedOffer.catId = catId;
        mappedOffer.subCatID = subCatID;
        
        emit OfferAction(anOffer, OFFERACTION.ADD);
        return mappedOffer.index;
    }
    
    function deleteOrPauseOffer(uint countryId, uint stateId, uint catId, uint subCatID, uint index, OFFERACTION action)  public returns(Offer memory) {
        Offer storage anOffer = offers[countryId][stateId][catId][subCatID][index];
        
        require(anOffer.creator == msg.sender, "not authorized");
        
        if(action == OFFERACTION.PAUSE) {
            anOffer.isPaused = true;
            emit OfferAction(anOffer, OFFERACTION.PAUSE);
        }else if (action == OFFERACTION.DELETE) {
            anOffer.isDeleted = true;
            // uint tmpAmt = anOffer.tokenDeposit;
            anOffer.tokenDeposit = 0;
            emit OfferAction(anOffer, OFFERACTION.DELETE);
            //  todo: using token address and amount send back token to creator
        }else {
            revert("Invalid Action");
        }
        
        return anOffer;
        
    }
    
    
    // function getCatOffers(uint countryId, uint stateId, uint catId, uint subCatID) view 
}

contract DiscountOffer is Ownable {
    
    
    
}