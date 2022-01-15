// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./opensea_meta.sol";

contract NapostarToken is ERC721, ERC721Enumerable, ERC721URIStorage, ContextMixin, NativeMetaTransaction, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    string private _contractURI;

    constructor() ERC721("NapostarToken", "NAPO") {
        _initializeEIP712("NapostarToken");
    }

    /**
     * Mint auto-incrementing tokens using the provided uri
     */
    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /**
     * Required override for Solidity
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable){
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * Required override for Solidity
     */
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    /**
     * Required override for Solidity
     */
    function tokenURI(uint256 tokenId) public  view override(ERC721, ERC721URIStorage) returns (string memory){
        return super.tokenURI(tokenId);
    }

    /**
     * Contract-level metadata for opensea for storefront data
     */
    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    /**
     * Support updating the contract uri for the opensea storefront
     */
    function updateContractURI(string memory uri) public onlyOwner{
        _contractURI = uri;
    }

    /**
     * Required override
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool){
        return super.supportsInterface(interfaceId);
    }

    /**
     * For Meta Transactions this is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function _msgSender() internal override view  returns (address sender){
        return ContextMixin.msgSender();
    }

    /**
    * As another option for supporting trading without requiring meta transactions, override isApprovedForAll to whitelist OpenSea proxy accounts on Matic
    */
    function isApprovedForAll(address _owner, address _operator) public override view returns (bool isOperator) {
        if (_operator == address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE)) {
            return true;
        }
        return ERC721.isApprovedForAll(_owner, _operator);
    }
}
