// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DataTypes} from "./libraries/DataTypes.sol";
import {Escrow} from "./Escrow.sol";
import {Events} from "./libraries/Events.sol";
import {MerchTableStorage} from "./storage/MerchTableStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Receipt} from "./Receipt.sol";

contract MerchTable is MerchTableStorage, Ownable {
  uint256 public productId;
  address public arbiter;
  address public receipt;

  constructor(address _arbiter) {
    arbiter = _arbiter;
  }

  function setReceipt(address _receipt) public onlyOwner {
    receipt = _receipt;
  }

  function addProductToStore(DataTypes.Product calldata vars)
    public
    returns (uint256)
  {
    ++productId;

    DataTypes.Product memory product = DataTypes.Product({
      id: productId,
      name: vars.name,
      category: vars.category,
      imageLink: vars.imageLink,
      descLink: vars.descLink,
      startTime: vars.startTime,
      price: vars.price,
      condition: DataTypes.ProductCondition(vars.condition),
      quantity: vars.quantity,
      seller: _msgSender(),
      buyers: new address[](0),
      isSold: false
    });

    productByStoreById[_msgSender()][productId] = product;
    storeByProductId[productId] = payable(_msgSender());

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
    DataTypes.Product storage product = productByStoreById[
      storeByProductId[_productId]
    ][_productId];

    if (product.isSold) revert("Product is already sold");
    if (product.price > msg.value) revert("Not enough ether");
    if (product.seller == _msgSender())
      revert("You can't buy your own product");
    if (product.seller == address(0)) revert("Product is not for sale");
    if (product.quantity == 0) revert("Product is out of stock");

    product.buyers.push(_msgSender());
    product.quantity -= 1;

    if (product.quantity == 0) {
      product.isSold = true;
    }

    productByStoreById[storeByProductId[_productId]][_productId] = product;

    Escrow escrow = new Escrow{value: msg.value}(
      productId,
      payable(_msgSender()),
      payable(product.seller),
      arbiter
    );

    escrowByProductId[_productId] = address(escrow);

    Receipt(receipt).mint(_msgSender(), _productId);
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
    escrow.releaseAmountToSeller(_msgSender());
  }

  function refundAmountToBuyer(uint256 _productId) public {
    Escrow escrow = Escrow(escrowByProductId[_productId]);
    escrow.refundAmountToBuyer(_msgSender());
  }
}
