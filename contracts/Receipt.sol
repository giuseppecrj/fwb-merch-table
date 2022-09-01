// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {MerchTable} from "./MerchTable.sol";

contract Receipt is ERC721 {
  MerchTable public merchTable;

  constructor(address _merchTable) ERC721("Receipt", "RCPT") {
    merchTable = MerchTable(_merchTable);
  }

  modifier onlyMerch() {
    require(msg.sender == address(merchTable), "Only MerchTable can mint");
    _;
  }

  function mint(address to, uint256 tokenId) public onlyMerch {
    _mint(to, tokenId);
  }
}
