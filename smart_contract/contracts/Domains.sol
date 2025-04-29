// SPDX-License-Identifier: UNLICENSED

/* Please use solidity extension version { 0.0135 } by Juan Blanco */

// updated as per latest changes

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { StringUtils } from "./libraries/StringUtils.sol";
import {Base64} from "./libraries/Base64.sol";

import "hardhat/console.sol";

// -------------------------------------------------------------------------------------------------------
contract Domains is ERC721URIStorage {

  using Counters for Counters.Counter;  // Counter struct in Counters.sol(lib Counters)
  Counters.Counter private _tokenIds;  // _tokenIds is of struct type
                                          // Here's our domain TLD! `.ninja` in this case
  string public tld;

  address payable public owner;
                                        // We'll be storing our NFT images on chain as SVGs
  string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#B)" d="M0 0h270v270H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path d="M72.863 42.949c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-10.081 6.032-6.85 3.934-10.081 6.032c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-8.013-4.721a4.52 4.52 0 0 1-1.589-1.616c-.384-.665-.594-1.418-.608-2.187v-9.31c-.013-.775.185-1.538.572-2.208a4.25 4.25 0 0 1 1.625-1.595l7.884-4.59c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v6.032l6.85-4.065v-6.032c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595L41.456 24.59c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-14.864 8.655a4.25 4.25 0 0 0-1.625 1.595c-.387.67-.585 1.434-.572 2.208v17.441c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l10.081-5.901 6.85-4.065 10.081-5.901c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v9.311c.013.775-.185 1.538-.572 2.208a4.25 4.25 0 0 1-1.625 1.595l-7.884 4.721c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-7.884-4.59a4.52 4.52 0 0 1-1.589-1.616c-.385-.665-.594-1.418-.608-2.187v-6.032l-6.85 4.065v6.032c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l14.864-8.655c.657-.394 1.204-.95 1.589-1.616s.594-1.418.609-2.187V55.538c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595l-14.993-8.786z" fill="#fff"/><defs><linearGradient id="B" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#cb5eee"/><stop offset="1" stop-color="#0cd7e4" stop-opacity=".99"/></linearGradient></defs><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
  string svgPartTwo = '</text></svg>';

 // ------------------------------------------ for storing/mapping Domain Name with Address
  mapping(string => address) public domains;
 // This will store values
  mapping(string => string) public records;
  // This will store all Domain names via _tokenIds
  mapping(uint => string) public names;

  error Unauthorized();
  error AlreadyRegistered();
  error InvalidName(string name);

 // ---------------CONSTRUCTOR------------------------ NNS NFT's Symbol
  constructor(string memory _tld) ERC721("Ninja Name Service", "NNS") payable {
    owner = payable(msg.sender);
    tld = _tld;
  }


//-------------- FUNCTION REGISTER -----------------------------------------------

  // A register function that adds their names to our mapping address
  function register(string calldata name) public payable {    
                                          // Check that the name is unregistered   
    // require(domains[name] == address(0));
    if(domains[name] != address(0)) revert AlreadyRegistered();
    if(!valid(name)) revert InvalidName(name); 
    uint _price = price(name);
    require(msg.value >= _price, "Not enough Matic paid");
                                            // Combining the name passed into the function  with the TLD
    string memory _name = string(abi.encodePacked(name, '.', tld ));
                                            // Creating the SVG (image) for the NFT with the name
    string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));
    uint newRecordId = _tokenIds.current();
    uint length = StringUtils.strlen(name);
    string memory strLen = Strings.toString(length);

    console.log("Registering %s.%s on the contract with tokenID %d", name, tld, newRecordId);

          // Creating the JSON metadata of our NFT.Doing this by combining strings and encoding as base64
    // We Converted `json` to -base64- because we are passing it to finalTokenUri and it needed as base64 format 
    // We are using abi.encodePacked() to CONCATENATE String bytes and converting back to String by using string()
    string memory json = Base64.encode(
      abi.encodePacked(
        '{"name": "',
        _name,
        '", "description": "A domain on the Ninja name service", "image": "data:image/svg+xml;base64,',
        Base64.encode(bytes(finalSvg)),
        '","length":"',
        strLen,
        '"}'
      )
    );

    string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

    console.log("\n--------------------------------------------------------");
    console.log("Final tokenURI", finalTokenUri);
    console.log("--------------------------------------------------------\n");
    string memory abc = string(Base64.encode(bytes(finalSvg)));
    // string memory xyz = "data:image/svg+xml;base64,";
    
    bytes memory b;

    b = abi.encodePacked("data:image/svg+xml;base64,");
    b = abi.encodePacked(b,abc);

    string memory s = string(b);

    console.log("Check {{ %s.%s }} IMAGE NFT at --->>>  ",name,tld,s);


    // console.log(string(xyz) + string(abc)); 

    console.log("--------------------------------------------------------\n");
                                       // Mint the NFT to newRecordId
    _safeMint(msg.sender, newRecordId);
                // Set the NFTs data(metadata) -- in this case the JSON blob w/ our domain's info!
    _setTokenURI(newRecordId, finalTokenUri);
    domains[name] = msg.sender;

    names[newRecordId] = name;
    _tokenIds.increment();
    console.log("%s has registered a domain!", msg.sender);
  }

  // ---------------- Function Price() -------------------------------------------------------------
                                      // This function will give us the price of a domain based on length
  function price(string calldata name) public pure returns (uint) {
    uint len = StringUtils.strlen(name);
    require(len > 0);
    if (len == 3){
      return 5 * 10**17; // 5 MATIC = 5 000 000 000 000 000 000 (18 decimals), 0.5 Matic, Since the MATIC token has 18 decimals, we need to put ` * 10**18 ` at the end of the prices.
    } else if (len == 4) { 
      return 3 * 10**17; // To charge smaller amounts, reducing the decimals. This is 0.3
    } else {
      return 1 * 10**17; // 0.1 Matic
    }  
  }

// ----------- FUNCTION GET_ALL_DOMAIN_NAMES --------------------------------------  

  function getAllNames() public view returns (string[] memory) {
    console.log("Getting all names from contract");
    string[] memory allNames = new string[](_tokenIds.current()); // declaring array of size current tokenId
    for (uint i=0; i < _tokenIds.current(); i++) {
      allNames[i] = names[i];
      console.log("Name for token %d is %s", i, allNames[i]);
    }

    return allNames;
  }

// ------------- FUNCTION GET_ADDRESS ---------------------------------------------

  // This will give us the domain owners' address
  function getAddress(string calldata name) public view returns (address) {
      return domains[name];
  }

// ------------- FUNCTION SET_RECORD ---------------------------------------------
  function setRecord(string calldata name, string calldata record) public {
    // Check that the owner is the transaction sender
    // require(domains[name] == msg.sender);
    if(msg.sender != domains[name]) revert Unauthorized();
    records[name] = record;
  }

// ------------- FUNCTION GET_RECORD ---------------------------------------------
  function getRecord(string calldata name) public view returns(string memory) {
    return records[name];
  }

  modifier onlyOwner() {
    require(isOwner());  // here msg.sender == owner will execute and returns true or false
    _;  // if TRUE, it will fetch our withdraw() function statements
  }

  function isOwner() public view returns (bool) {
    return msg.sender == owner;
  }

  function withdraw() public onlyOwner {
    uint amount = address(this).balance;

    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Failed to withdraw Matic");
  }

  function valid(string calldata name) public pure returns (bool) {
    return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 10;
  }
  
}

// NFTs are just links that point to an image hosting service. If these services go down, our NFT no longer has an image! By putting it on the blockchain with Base64, it becomes permanent.

// Contracts have a length limit!

// We can't make an incredibly complex SVG that is super duper long. The way ENS does it is they generate the SVG using a web server at the time of registration and store it off-chain. We can do something similar!



// CallData vs Memory vs Storage

// https://ethereum.stackexchange.com/questions/107028/in-what-cases-would-i-set-a-parameter-to-use-storage-instead-of-memory

/* 
  <svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none">
	<path fill="url(#B)" d="M0 0h270v270H0z"/>
		<defs>
			<filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270">
				<feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/>
			</filter>
		</defs>
	<path d="M72.863 42.949c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-10.081 6.032-6.85 3.934-10.081 6.032c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-8.013-4.721a4.52 4.52 0 0 1-1.589-1.616c-.384-.665-.594-1.418-.608-2.187v-9.31c-.013-.775.185-1.538.572-2.208a4.25 4.25 0 0 1 1.625-1.595l7.884-4.59c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v6.032l6.85-4.065v-6.032c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595L41.456 24.59c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-14.864 8.655a4.25 4.25 0 0 0-1.625 1.595c-.387.67-.585 1.434-.572 2.208v17.441c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l10.081-5.901 6.85-4.065 10.081-5.901c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v9.311c.013.775-.185 1.538-.572 2.208a4.25 4.25 0 0 1-1.625 1.595l-7.884 4.721c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-7.884-4.59a4.52 4.52 0 0 1-1.589-1.616c-.385-.665-.594-1.418-.608-2.187v-6.032l-6.85 4.065v6.032c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l14.864-8.655c.657-.394 1.204-.95 1.589-1.616s.594-1.418.609-2.187V55.538c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595l-14.993-8.786z" fill="#fff"/>
	<defs>
		<linearGradient id="B" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse">
			<stop stop-color="#cb5eee"/><stop offset="1" stop-color="#0cd7e4" stop-opacity=".99"/>
		</linearGradient>
	</defs>
	<text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">
		mortal.ninja
	</text>
</svg>

 */
