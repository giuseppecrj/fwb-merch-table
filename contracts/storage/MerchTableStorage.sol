// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {DataTypes} from "../libraries/DataTypes.sol";

abstract contract MerchTableStorage {
  uint256 internal _productCounter;

  mapping(address => mapping(uint256 => DataTypes.Product))
    internal _productByStoreById;

  mapping(uint256 => address payable) internal _storeByProductId;

  mapping(uint256 => address) internal _escrowByProductId;
}
