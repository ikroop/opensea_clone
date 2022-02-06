//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Nft is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress; // this address is market's address built for nft interaction with market and vice versa moreover this address is allowed by other nft to transfer them  

     constructor(address marketplaceAddress) ERC721("Metaverse", "METT") {
        contractAddress = marketplaceAddress;
    }

    function createToken(string memory tokenURI) public returns (uint) {
        _tokenIds.increment(); // every time a token is created tokenid is incremented
        uint256 newItemId = _tokenIds.current(); // storing the latest token id in a variable

        _mint(msg.sender, newItemId); // minting a token
        _setTokenURI(newItemId, tokenURI); // sets tokenurl (Api call over https , ipfs hash or anything unique)
        setApprovalForAll(contractAddress, true); // approving this address to transfer on their senders behalf
        return newItemId; // for frontend purpose
    }
}
