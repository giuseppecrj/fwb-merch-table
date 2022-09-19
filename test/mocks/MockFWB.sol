// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FWB is ERC20("Friends With Benefits", "FWB") {
  constructor() {
    _mint(msg.sender, 1000000000000000000000000);
  }
}
