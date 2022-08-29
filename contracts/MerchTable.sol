// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DataTypes} from "./libraries/DataTypes.sol";
import {Escrow} from "./Escrow.sol";
import {Events} from "./libraries/Events.sol";
import {MerchTableStorage} from "./storage/MerchTableStorage.sol";

contract MerchTable is MerchTableStorage {
  uint256 public productId;
  address public arbiter;

  constructor(address _arbiter) {
    arbiter = _arbiter;
  }

  function addProductToStore(DataTypes.Product calldata vars)
    public
    returns (uint256)
  {
    productId += 1;

    DataTypes.Product memory product = DataTypes.Product({
      id: productId,
      name: vars.name,
      category: vars.category,
      imageLink: vars.imageLink,
      descLink: vars.descLink,
      startTime: vars.startTime,
      price: vars.price,
      condition: DataTypes.ProductCondition(vars.condition),
      seller: msg.sender,
      buyer: address(0),
      isSold: false
    });

    productByStoreById[msg.sender][productId] = product;
    storeByProductId[productId] = payable(msg.sender);

    emit Events.NewProduct(product);

    return (productId);
  }

  function getProduct(uint256 _productId)
    public
    view
    returns (DataTypes.Product memory)
  {
    return productByStoreById[storeByProductId[_productId]][_productId];
  }

  function buyProduct(uint256 _productId) public payable {
    DataTypes.Product memory product = productByStoreById[
      storeByProductId[_productId]
    ][_productId];

    if (product.isSold) revert("Product is already sold");
    if (product.price > msg.value) revert("Not enough ether");
    if (product.seller == msg.sender) revert("You can't buy your own product");
    if (product.buyer != address(0)) revert("Product is already bought");
    if (product.seller == address(0)) revert("Product is not for sale");

    product.buyer = msg.sender;
    product.isSold = true;

    productByStoreById[storeByProductId[_productId]][_productId] = product;

    Escrow escrow = new Escrow{value: msg.value}(
      productId,
      payable(msg.sender),
      payable(product.seller),
      arbiter
    );

    escrowByProductId[_productId] = address(escrow);
  }

  function getEscrowByProductId(uint256 _productId)
    public
    view
    returns (
      address,
      address,
      address,
      bool,
      uint256,
      uint256
    )
  {
    return Escrow(escrowByProductId[_productId]).getEscrow();
  }

  function releaseAmountToSeller(uint256 _productId) public {
    Escrow escrow = Escrow(escrowByProductId[_productId]);
    escrow.releaseAmountToSeller(msg.sender);
  }

  function refundAmountToBuyer(uint256 _productId) public {
    Escrow escrow = Escrow(escrowByProductId[_productId]);
    escrow.refundAmountToBuyer(msg.sender);
  }
}
