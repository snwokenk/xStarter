<template>
  <q-page class="justify-center ">
    <div class="row justify-center q-pb-lg q-gutter-y-lg">
      <div class="col-auto">
        <img :src="logo" style="min-width: 300px; max-width: 90%" />
      </div>

      <div v-if="gif" class="col-12 content-center justify-center row q-my-lg">
        <img class="col-auto" :src="gif" width="300" height="300" />
      </div>
      <div class="text-h6 col-9 col-lg-10" >
        {{ description }}
      </div>

      <div class="row  col-9 col-lg-10 q-mt-md content-center justify-center">
        <div v-if="socialMedia.website" class="col-auto">
          <q-btn icon="fas fa-globe" size="lg" round flat  target="_blank" type="a" :href="socialMedia.website" />
        </div>
        <div v-if="socialMedia.telegram" class="col-auto">
          <q-btn icon="fab fa-telegram-plane" size="lg" round flat  target="_blank" type="a" :href="socialMedia.telegram" />
        </div>

        <div v-if="socialMedia.twitter" class="col-auto">
          <q-btn icon="fab fa-twitter" size="lg" round flat target="_blank" type="a" :href="socialMedia.twitter" />
        </div>
        <div v-if="socialMedia.discord" class="col-auto">
          <q-btn icon="fab fa-discord" size="lg" round flat target="_blank" type="a" :href="socialMedia.discord" />
        </div>
        <div v-if="socialMedia.instagram" class="col-auto">
          <q-btn icon="fab fa-instagram" size="lg" round flat target="_blank" type="a" :href="socialMedia.instagram" />
        </div>
      </div>

      <div class="text-body1 text-center col-9 col-lg-7" >
        Total Minted: &nbsp; <span class="text-bold">{{ numberMinted }}</span>
      </div>
      <div class="text-body1 text-center col-9 col-lg-7" >
        Reserved: &nbsp; <span class="text-bold">{{ reservedAmt }}</span>
      </div>
      <div class="text-body1 text-center col-9 col-lg-7" >
        Available: &nbsp; <span class="text-bold">{{ totalMint - numberMinted - reservedAmt }}</span>
      </div>
      <div class="text-body1 text-center col-9 col-lg-7" >
        Number Of {{ name }} NFTs You Own : &nbsp; <span class="text-bold">{{ noOfUserNFTs }}</span>
      </div>
      <div class="text-body1 text-center col-9 col-lg-7" >
        Mint Price: <span class="text-bold">{{ mintPrice }} {{ fundingTokenSymbol }}</span>
      </div>
      <div class="text-body1 text-center col-9 col-lg-7 wrap-word" >
        <span class="text-bold">Contract Address</span>: {{ contractAddress }} <q-btn flat icon="content_copy" @click="copyContract" />
      </div>

    </div>

<!--    <q-card  flat square  clickable>-->
<!--      <q-card-section class="justify-between account-display-text text-center">-->
<!--       -->
<!--      </q-card-section>-->
<!--    </q-card>-->

    <div v-if="isWrongNetwork || !chainId" class="row justify-center">
      <div class="display-card accountDisplayCard q-mb-lg col-10 col-lg-5 q-pa-xl">
        <NetworkSwitcher :requiredNetworkId="nftChainId" />
      </div>
    </div>

    <div class="row justify-center q-mb-xl " v-else-if="dataInfo">
      <ABIGeneratedForm
        class="col-12 col-lg-7 q-pa-xl accountDisplayCard display-card"
        v-if="showABIForm"
        :abi="currentABI"
        :title="formTitle"
        :success-call-back="updateNumberNFTs"
        :native-currency-symbol="fundingTokenSymbol"
        :function-name="currentFunctionName"
        :connected-contract="connectedContract"
        :actionBtnLabel="'Mint'"
        :parameterToPayable="{paramName: 'noOfBirds', amtPerEach: 0.60}"
        :input-styling="{class: 'q-pl-sm', style: 'border: 2px Solid; border-radius: 10px;'}"
      />
      <!--        <div ref="#abiForm"></div>-->
    </div>

  </q-page>
</template>

<script>
// import xStarterERC721Code from 'src/artifacts/contracts/xStarterConvertibleNFT.json'
import { copyToClipboard } from 'quasar'
import {defineComponent, inject, provide} from 'vue';
import ABIGeneratedForm from "components/ABIGenerated/ABIGeneratedForm";
// import xStarterProposalCode from 'src/artifacts/contracts/xStarterProposal.sol/xStarterProposal.json'
import {ethers} from "boot/ethers";
import ILOInteractionAddressesInfoDisplay from "components/CardDisplays/ILOInteractionAddressesInfoDisplay";
import ILOInteractionInfoDisplay from "components/CardDisplays/ILOInteractionInfoDisplay";
import {DEFAULT_CHAIN_FUNDING_TOKEN, SUPPORTED_FUNDING_TOKENS} from "src/constants";
import NetworkSwitcher from "components/NetworkSwitcher";

// http://localhost:8081/#/nft/mint/Qmf7ztkSF71GJjVoJA65z6GhbZSyVTECaVDHsm9hP3sXgt
// /nft/mint/QmX51xhLTxZbWvJN3ZuJ39zeDqsDT2aV7PadaJbqZLiDn1  - for Goerl

let aData = {
  name: "HungryBirds",
  website: 'https://www.hungrybirds.io/',
  logoCID: 'QmPBNPEMJg7zDknEn4AonCGZEZ9dehjjNsYFvQwyZvhneT',
  logoURL: 'https://ipfs.io/ipfs/QmPBNPEMJg7zDknEn4AonCGZEZ9dehjjNsYFvQwyZvhneT',
  description: `HungryBirds are a mix of programmatically generated NFT art and an ERC20 token. HungryBird uses a unique structure to provide instant liquidity for holders of HungryBirds NFTs and allows for indirect fractional ownership of it’s NFT Collection. In the HungryBird ecosystem, collectors can either hold a HungryBirds NFT or 10,000 NFT tokens and can easily convert between the two.
       A Total of 10,500 NFTs will be minted.`,
  arrayOfImages: [],
  gif: 'https://i.imgur.com/7HPrer8.gif',
  socialMedia: {
    twitter: 'https://twitter.com/hungrybirdsnft',
    discord: 'https://discord.com/invite/R2GzHBmR77',
    telegram: 'https://t.me/HungryBirdsTokenNFT',
    instagram: 'https://www.instagram.com/hungrybirdsnft/'
  },
  NFTMeta: {
    maxMint: 10200,
    reservedAmt: 300,
    totalMint: 10500,
    maxMintPerTX: 20,
    maxPerAddr: 30,
    mintPriceInEthers: '0.60',
    contractAddress: '0x55fcfd221cf2393fd215d1b0a6b9c9fb6061b03c',
    chainId: '56',
    mintFunction: 'mintBirds',
    abi: [
      {
        "inputs": [
          {
            "internalType": "string",
            "name": "_name",
            "type": "string"
          },
          {
            "internalType": "string",
            "name": "_symbol",
            "type": "string"
          },
          {
            "internalType": "string",
            "name": "_baseNFTURI",
            "type": "string"
          },
          {
            "internalType": "uint256",
            "name": "_maxSupply",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "_maxPerTx",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "_maxPerAddr",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "_mintPrice",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "_supplyReserved",
            "type": "uint256"
          }
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "owner",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "approved",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "uint256",
            "name": "tokenId",
            "type": "uint256"
          }
        ],
        "name": "Approval",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "owner",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "operator",
            "type": "address"
          },
          {
            "indexed": false,
            "internalType": "bool",
            "name": "approved",
            "type": "bool"
          }
        ],
        "name": "ApprovalForAll",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "previousOwner",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "newOwner",
            "type": "address"
          }
        ],
        "name": "OwnershipTransferred",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": false,
            "internalType": "address",
            "name": "account",
            "type": "address"
          }
        ],
        "name": "Paused",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "bytes32",
            "name": "role",
            "type": "bytes32"
          },
          {
            "indexed": true,
            "internalType": "bytes32",
            "name": "previousAdminRole",
            "type": "bytes32"
          },
          {
            "indexed": true,
            "internalType": "bytes32",
            "name": "newAdminRole",
            "type": "bytes32"
          }
        ],
        "name": "RoleAdminChanged",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "bytes32",
            "name": "role",
            "type": "bytes32"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "account",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "sender",
            "type": "address"
          }
        ],
        "name": "RoleGranted",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "bytes32",
            "name": "role",
            "type": "bytes32"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "account",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "sender",
            "type": "address"
          }
        ],
        "name": "RoleRevoked",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "from",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "to",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "uint256",
            "name": "tokenId",
            "type": "uint256"
          }
        ],
        "name": "Transfer",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": false,
            "internalType": "address",
            "name": "account",
            "type": "address"
          }
        ],
        "name": "Unpaused",
        "type": "event"
      },
      {
        "inputs": [],
        "name": "DEFAULT_ADMIN_ROLE",
        "outputs": [
          {
            "internalType": "bytes32",
            "name": "",
            "type": "bytes32"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "MINTER_ROLE",
        "outputs": [
          {
            "internalType": "bytes32",
            "name": "",
            "type": "bytes32"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "PAUSER_ROLE",
        "outputs": [
          {
            "internalType": "bytes32",
            "name": "",
            "type": "bytes32"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "to",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "tokenId",
            "type": "uint256"
          }
        ],
        "name": "approve",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "owner",
            "type": "address"
          }
        ],
        "name": "balanceOf",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "uint256",
            "name": "tokenId",
            "type": "uint256"
          }
        ],
        "name": "burn",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "bool",
            "name": "_mintingAllowed",
            "type": "bool"
          }
        ],
        "name": "changeMintingAllowed",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "uint256",
            "name": "tokenId",
            "type": "uint256"
          }
        ],
        "name": "getApproved",
        "outputs": [
          {
            "internalType": "address",
            "name": "",
            "type": "address"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "bytes32",
            "name": "role",
            "type": "bytes32"
          }
        ],
        "name": "getRoleAdmin",
        "outputs": [
          {
            "internalType": "bytes32",
            "name": "",
            "type": "bytes32"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "bytes32",
            "name": "role",
            "type": "bytes32"
          },
          {
            "internalType": "uint256",
            "name": "index",
            "type": "uint256"
          }
        ],
        "name": "getRoleMember",
        "outputs": [
          {
            "internalType": "address",
            "name": "",
            "type": "address"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "bytes32",
            "name": "role",
            "type": "bytes32"
          }
        ],
        "name": "getRoleMemberCount",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "account",
            "type": "address"
          }
        ],
        "name": "grantAndRenounceMinterAdminRole",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "bytes32",
            "name": "role",
            "type": "bytes32"
          },
          {
            "internalType": "address",
            "name": "account",
            "type": "address"
          }
        ],
        "name": "grantRole",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "bytes32",
            "name": "role",
            "type": "bytes32"
          },
          {
            "internalType": "address",
            "name": "account",
            "type": "address"
          }
        ],
        "name": "hasRole",
        "outputs": [
          {
            "internalType": "bool",
            "name": "",
            "type": "bool"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "owner",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "operator",
            "type": "address"
          }
        ],
        "name": "isApprovedForAll",
        "outputs": [
          {
            "internalType": "bool",
            "name": "",
            "type": "bool"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "maxPerAddr",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "maxPerTx",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "maxSupply",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "to",
            "type": "address"
          }
        ],
        "name": "mint",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "uint256",
            "name": "noOfBirds",
            "type": "uint256"
          }
        ],
        "name": "mintBirds",
        "outputs": [],
        "stateMutability": "payable",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "mintPrice",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "mintingAllowed",
        "outputs": [
          {
            "internalType": "bool",
            "name": "",
            "type": "bool"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "name",
        "outputs": [
          {
            "internalType": "string",
            "name": "",
            "type": "string"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "owner",
        "outputs": [
          {
            "internalType": "address",
            "name": "",
            "type": "address"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "uint256",
            "name": "tokenId",
            "type": "uint256"
          }
        ],
        "name": "ownerOf",
        "outputs": [
          {
            "internalType": "address",
            "name": "",
            "type": "address"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "pause",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "paused",
        "outputs": [
          {
            "internalType": "bool",
            "name": "",
            "type": "bool"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "renounceOwnership",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "bytes32",
            "name": "role",
            "type": "bytes32"
          },
          {
            "internalType": "address",
            "name": "account",
            "type": "address"
          }
        ],
        "name": "renounceRole",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "bytes32",
            "name": "role",
            "type": "bytes32"
          },
          {
            "internalType": "address",
            "name": "account",
            "type": "address"
          }
        ],
        "name": "revokeRole",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "from",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "to",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "tokenId",
            "type": "uint256"
          }
        ],
        "name": "safeTransferFrom",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "from",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "to",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "tokenId",
            "type": "uint256"
          },
          {
            "internalType": "bytes",
            "name": "_data",
            "type": "bytes"
          }
        ],
        "name": "safeTransferFrom",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "operator",
            "type": "address"
          },
          {
            "internalType": "bool",
            "name": "approved",
            "type": "bool"
          }
        ],
        "name": "setApprovalForAll",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "supplyReserved",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "bytes4",
            "name": "interfaceId",
            "type": "bytes4"
          }
        ],
        "name": "supportsInterface",
        "outputs": [
          {
            "internalType": "bool",
            "name": "",
            "type": "bool"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "symbol",
        "outputs": [
          {
            "internalType": "string",
            "name": "",
            "type": "string"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "uint256",
            "name": "index",
            "type": "uint256"
          }
        ],
        "name": "tokenByIndex",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "owner",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "index",
            "type": "uint256"
          }
        ],
        "name": "tokenOfOwnerByIndex",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "uint256",
            "name": "tokenId",
            "type": "uint256"
          }
        ],
        "name": "tokenURI",
        "outputs": [
          {
            "internalType": "string",
            "name": "",
            "type": "string"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "operator",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "from",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "to",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "amount",
            "type": "uint256"
          },
          {
            "internalType": "bytes",
            "name": "userData",
            "type": "bytes"
          },
          {
            "internalType": "bytes",
            "name": "operatorData",
            "type": "bytes"
          }
        ],
        "name": "tokensReceived",
        "outputs": [],
        "stateMutability": "pure",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "operator",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "from",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "to",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "amount",
            "type": "uint256"
          },
          {
            "internalType": "bytes",
            "name": "userData",
            "type": "bytes"
          },
          {
            "internalType": "bytes",
            "name": "operatorData",
            "type": "bytes"
          }
        ],
        "name": "tokensToSend",
        "outputs": [],
        "stateMutability": "pure",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "totalSupply",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "from",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "to",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "tokenId",
            "type": "uint256"
          }
        ],
        "name": "transferFrom",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "newOwner",
            "type": "address"
          }
        ],
        "name": "transferOwnership",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "unpause",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "withdraw",
        "outputs": [
          {
            "internalType": "bool",
            "name": "success",
            "type": "bool"
          }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
      }
    ],
  }
}

export default defineComponent({
  name: 'NFTMintingAndConversion',
  components: {NetworkSwitcher, ABIGeneratedForm},
  setup() {
    const getProvider = inject('$getProvider')
    const getSigner = inject('$getSigner')
    const getLaunchPadContract = inject('$getLaunchPadContract')
    const connectedAccount = inject('$connectedAccounts')
    let chainId = inject('$chainId')
    const getConnectedAndPermissioned = inject('$getConnectedAndPermissioned')
    // const mintABi = xStarterERC721Code.abi
    console.log('provider is ', getProvider())
    return {getProvider, getSigner, getLaunchPadContract, getConnectedAndPermissioned, connectedAccount, chainId}
  },
  data() {
    return {
      form: {
        numberToMint: 0
      },
      dataInfo: null,
      showABIForm: true,
      connectedContract: null,
      totalMintedNFTs: 0,
      noOfUserNFTs: 0
    }
  },
  computed: {
    fundingTokenSymbol() {
      let fundingSymbol = SUPPORTED_FUNDING_TOKENS['0x0000000000000000000000000000000000000000-' + this.nftChainId]
      if (fundingSymbol) {
        return fundingSymbol
      }else if (!this.connectedAndPermissioned) {
        return DEFAULT_CHAIN_FUNDING_TOKEN
      }
      return 'Custom Token'
    },
    isWrongNetwork() {
      return this.chainId && parseInt(this.chainId) !== parseInt(this.nftChainId)
    },
    name() {
      return this.dataInfo ? this.dataInfo.name : ''
    },
    logo() {
      return this.dataInfo ? this.dataInfo.logoURL : ''
    },
    socialMedia() {
      return this.dataInfo ?
        // {website: this.dataInfo.website, this.dataInfo.socialMedia.twitter, this.dataInfo.socialMedia.discord, this.dataInfo.socialMedia.telegram}
        { website: this.dataInfo.website, ...this.dataInfo.socialMedia }
        :
        []
    },
    description() {
      return this.dataInfo ? this.dataInfo.description : ''
    },
    gif() {
      return this.dataInfo ? this.dataInfo.gif : ''
    },
    currentABI() {
      return this.dataInfo ? this.dataInfo.NFTMeta.abi : ''
    },
    nftChainId() {
      return this.dataInfo ? this.dataInfo.NFTMeta.chainId : ''
    },
    currentFunctionName() {
      return this.dataInfo ? this.dataInfo.NFTMeta.mintFunction : ''
    },
    maxMint() {
      return this.dataInfo ? this.dataInfo.NFTMeta.maxMint : 0
    },
    totalMint(){
      return this.dataInfo ? this.dataInfo.NFTMeta.totalMint : 0
    },
    reservedAmt(){
      return this.dataInfo ? this.dataInfo.NFTMeta.reservedAmt : 0
    },
    maxMintPerTx() {
      return this.dataInfo ? this.dataInfo.NFTMeta.maxMintPerTX : 0
    },
    mintPrice() {
      return this.dataInfo ? this.dataInfo.NFTMeta.mintPriceInEthers : ''
    },
    numberMinted() {
      return this.totalMintedNFTs
    },
    contractAddress() {
      return this.dataInfo ? this.dataInfo.NFTMeta.contractAddress : ''
    },
    formTitle() {
      return {class:'form-title text-center', style: 'font-size: 41px;', name: `Mint NFTs For ${this.dataInfo.name}`}
    },
    mintContract() {
      console.log('signeer for provider is', this.getProvider(),this.getSigner(), this.getSigner().getAddress(), this.connectedAccount[0])
      return new ethers.Contract(this.contractAddress, this.currentABI, this.getProvider());
    },
  },
  methods: {
    checkIt() {
      console.log('provider', this.getProvider())
    },
    async showMint() {
      this.connectedContract = await this.getConnectedContract()
      this.showABIForm = true
    },
    async copyContract() {
      await copyToClipboard(this.contractAddress)
      this.$q.notify('Contract Address Copied!')
    },
    checkMax(val) {
      val = parseInt(val)
      if (val > 0 && val <= this.maxMintPerTx) { return  true }
      return `Must Mint Between 1 to ${this.maxMintPerTx} NFTs per transaction`
    },
    async getConnectedContract() {
      if (!this.mintContract) {return null}
      return await this.mintContract.connect(this.getSigner())
    },
    async updateNumberNFTs() {
      this.totalMintedNFTs = (await this.getTotalSupply()).toNumber()
      this.noOfUserNFTs = (await this.getBalanceOf()).toNumber()
    },
    async getTotalSupply() {
      if (!this.connectedContract) {
        this.connectedContract = await this.getConnectedContract()
      }
      return await this.connectedContract.totalSupply()
    },
    async getBalanceOf() {
      if (!this.connectedContract) {
        this.connectedContract = await this.getConnectedContract()
      }
      return await this.connectedContract.balanceOf(this.connectedAccount[0])
    }
  },
  async mounted() {
    // console.log(this.$ipfs_utils)
    // console.log('ipfs utils', await this.$ipfs_utils.saveILOInfo(aData))
    // "Qmd2BQs1vkDKLyvpNjw5dq35Hj8xuhyjvFUQRLH8nCwGxs" BNB main
    // "QmX51xhLTxZbWvJN3ZuJ39zeDqsDT2aV7PadaJbqZLiDn1" Goerli
    //"QmYXRCAjfAR4FkpWUP22RiShK1NEZ4e88ip96V9BXq3uqE" BNB test
    //"Qmf7ztkSF71GJjVoJA65z6GhbZSyVTECaVDHsm9hP3sXgt" hard hat
    const dataInfo  = await this.$ipfs_utils.getILOInfo(this.$route.params.ipfs_cid)
    if (dataInfo) {
      this.dataInfo = dataInfo
    }
    await this.updateNumberNFTs()
    await this.showMint()
    console.log('data info is', dataInfo)
  },
  watch: {
    connectedAccount: async function () {
      await this.updateNumberNFTs()
    },
  }
})
</script>
<style scoped lang="scss">
.display-container{
  width: 80%;
  min-height: 300px;

}
</style>
