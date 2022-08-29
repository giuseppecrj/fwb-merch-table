// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library DataTypes {
  enum ProductCondition {
    NEW,
    USED
  }

  struct Product {
    uint256 id;
    string name;
    string category;
    string imageLink;
    string descLink;
    uint256 startTime;
    uint256 price;
    ProductCondition condition;
    address seller;
    address buyer;
    bool isSold;
  }
}
