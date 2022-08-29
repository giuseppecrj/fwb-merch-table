// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {DataTypes} from "../libraries/DataTypes.sol";

abstract contract MerchTableStorage {
  mapping(address => mapping(uint256 => DataTypes.Product))
    internal productByStoreById;
  mapping(uint256 => address payable) internal storeByProductId;

  mapping(uint256 => address) internal escrowByProductId;
}
