// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {DataTypes} from "./DataTypes.sol";

library Events {
  event NewProduct(DataTypes.Product product);
}
