// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./ERC777ReceiveSend.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC1820Implementer.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC721XSTN {
    function mint(address to) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}


// contract receives ERCToken of rate amount and either mints new to send to recipient or sends one available from holdings
// contract receives NFT and sends ERCToken equals to the rate
// ie if rate is 10,000 tokens, contract will mint  NFT till the maxNFTSupply is reached, it then checks to see if it has already minted supply
contract xStarterNFTLiquidityCenter is Ownable, IERC721Receiver, ERC1820Implementer, IERC777Sender, IERC777Recipient{
    
    IERC1820Registry constant internal _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    string NFTName;
    string NFTSymbol;
    address ERCToken; // erc20 token for conversion to NFT
    address NFT;
    uint rate;
    uint reserveFee;
    uint noPerTX;
    uint maxNFTSupply;
    uint noOfNFTMinted;
    bool maxReached;
    // mapping(address => uint) balances;
    uint[] unclaimedNFTs;
    mapping(address => uint[]) reservedNFTs;
    mapping(address => uint[]) preDepositNFTs;
    
    // function balanceOf(address _holder) public view returns(uint) {
    //     return balances[_holder];
    // }
    
    constructor(
        string memory _NFTName,
        string  memory _NFTSymbol,
        address _ERC777Token,
        uint _ERC20ToERC77Rate,
        uint _maxNFTSupply
    )
    {
        NFTName = _NFTName;
        NFTSymbol = _NFTSymbol;
        ERCToken = _ERC777Token;
        rate = _ERC20ToERC77Rate;
        maxNFTSupply = _maxNFTSupply;
        bytes32  _interfaceHashSender = _ERC1820_REGISTRY.interfaceHash("ERC777TokensSender");
        bytes32  _interfaceHashReceiver = _ERC1820_REGISTRY.interfaceHash("ERC777TokensRecipient");
        _registerInterfaceForAddress(_interfaceHashSender, address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(0), _interfaceHashSender, address(this));
        _registerInterfaceForAddress(_interfaceHashReceiver, address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(0), _interfaceHashReceiver, address(this));
    }
    
    // called when an ERC777 token is about to be sent to contract
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external view  override {
        // check to see if NFTs available
        // check balance of this address
        // revert('not token sender');
        // require(msg.sender == ERCToken, 'not associated token');
    }
    
    function setup(address _NFT, uint _noPerTX) public onlyOwner returns(bool) {
        require(
            IERC721XSTN(_NFT).getRoleMemberCount(MINTER_ROLE) == 1 
            && IERC721XSTN(_NFT).getRoleMemberCount(PAUSER_ROLE) == 1
            && IERC721XSTN(_NFT).getRoleMemberCount(DEFAULT_ADMIN_ROLE) == 0 
            && IERC721XSTN(_NFT).hasRole(MINTER_ROLE, address(this)) 
            && IERC721XSTN(_NFT).hasRole(PAUSER_ROLE, address(this)),
            "nft management contract must have sole minting and pausing role"
        );
        NFT = _NFT;
        noPerTX = _noPerTX;
        return true;
    }
    
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) public  override returns(bytes4) {
        preDepositNFTs[from].push(tokenId);
        return this.onERC721Received.selector;
    }
    
    // if reserved is true, the rate minus reserve fee is sent
    // todo: finsih up logic
    function completeNFTConversion(bool reserved) public returns(bool) {
        uint len = preDepositNFTs[msg.sender].length;
        uint tokenID;
        require(len > 0, "No NFTs deposited");
        uint amountToSend;
        
        while(len > 0) {
            tokenID = preDepositNFTs[msg.sender][len - 1];
            preDepositNFTs[msg.sender].pop();
            len = preDepositNFTs[msg.sender].length;
            amountToSend = amountToSend + rate;
            
            if(reserved) {
                amountToSend = amountToSend - reserveFee;
                reservedNFTs[msg.sender].push(tokenID);
            }else {
                unclaimedNFTs.push(tokenID);
            }
            
        }
         IERC777(ERCToken).send(msg.sender, amountToSend, "");
         
         return true;

    }
    
     // called when an ERC777 token is received by this contract
     // this is entry to minting or claiming an unclaimed NFT
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external  override{
        // todo: have a flag that is set when contract has been fully setup, this requires, rate > 0
        // can only receive erctoken associated with NFT
        require(NFT != address(0));
        require(msg.sender == ERCToken, 'not associated token');
        require(amount >= rate, "amount not enough to mint or redeem 1 nft");
        // first check if from address has reservedNFTs
        uint len = reservedNFTs[from].length;
        if(len > 0) {
            
            // todo: possible rentrance vector?
            uint tokenID = reservedNFTs[from][len - 1];
            reservedNFTs[from].pop();
            IERC721XSTN(NFT).safeTransferFrom(address(this), to, tokenID);
        }else {
            uint noOfNfts = _assignNFT(from, amount);
            
            // check how much spent
            uint spent = noOfNfts * rate;
            uint change = amount - spent;
            //todo: verify this is safe
            if(change != 0) {
                IERC777(ERCToken).send(from, change, "");
            }
            
        }

        
    }
    
    function _assignNFT(address _to, uint _amount) internal returns(uint nftsAssigned) {
        // get number of NFTs desired 
        uint desiredNFTs = _amount / rate;
        desiredNFTs = desiredNFTs > noPerTX ? noPerTX : desiredNFTs;
        // get number minted
        uint mintedNFTs = _mintNFT(_to, desiredNFTs);
        uint remNfts = desiredNFTs - mintedNFTs;
        nftsAssigned = desiredNFTs - remNfts;
        // all desired nfts were minted
        if(nftsAssigned == desiredNFTs) {
            return nftsAssigned;
        }
            
        remNfts = remNfts - _claimNFT(_to, remNfts);
        nftsAssigned = desiredNFTs - remNfts;
        
        require(nftsAssigned != 0, "No NFTs available");
    }
    
    function _mintNFT(address _to, uint desiredNoOfNFTS) internal returns(uint nftsMinted) {
        if(noOfNFTMinted >= maxNFTSupply) {
            return nftsMinted;
        }
        uint remainNFTs = maxNFTSupply - noOfNFTMinted;
        uint nftToMint = remainNFTs > desiredNoOfNFTS ? desiredNoOfNFTS : remainNFTs;
        for(uint i=0; i<nftToMint; i++) {
            IERC721XSTN(NFT).mint(_to);
            noOfNFTMinted++;
            nftsMinted++;
            
        }
    }
    
    event NFTClaimed(address indexed _to, uint indexed tokenID);
    function _claimNFT(address _to, uint desiredNoOfNFTS) internal returns(uint nftsClaimed) {
        
        uint len = unclaimedNFTs.length;
        if(len == 0) {
            return nftsClaimed;
        }
        uint tokenID;
        uint nftsToClaim = len > desiredNoOfNFTS ? desiredNoOfNFTS : len;
        for(uint i=0; i<nftsToClaim; i++) {
            tokenID = unclaimedNFTs[len - 1];
            unclaimedNFTs.pop();
            len = unclaimedNFTs.length;
            IERC721XSTN(NFT).safeTransferFrom(address(this), _to, tokenID);
            nftsClaimed++;
            emit NFTClaimed(_to, tokenID);
        }
    }
    function _sendToken(address _addr, uint _amount) internal {
        IERC777(ERCToken).send(_addr, _amount, "");
    }
}