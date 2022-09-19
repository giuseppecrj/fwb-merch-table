// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DataTypes} from "./libraries/DataTypes.sol";
import {Events} from "./libraries/Events.sol";
import {MerchTableStorage} from "./storage/MerchTableStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Receipt} from "./Receipt.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";

contract MerchTable is MerchTableStorage, Ownable {
  uint256 internal _purchasesMade;
  mapping(uint256 => bytes32) public _receiptsById;

  address internal immutable ARBITER_NFT;
  address internal RECEIPT_NFT;
  address internal immutable FWB_TOKEN;

  constructor(address arbiter_, address fwb_) {
    ARBITER_NFT = arbiter_;
    FWB_TOKEN = fwb_;
  }

  function setReceipt(address receipt_) public onlyOwner {
    RECEIPT_NFT = receipt_;
  }

  function addProductToStore(DataTypes.Product calldata vars)
    public
    returns (uint256)
  {
    uint256 _productId = ++_productCounter;

    DataTypes.Product memory product = DataTypes.Product({
      id: _productId,
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

    _productByStoreById[_msgSender()][_productId] = product;
    _storeByProductId[_productId] = payable(_msgSender());

    emit Events.NewProduct(product);

    return (_productId);
  }

  function getProduct(uint256 _productId)
    public
    view
    returns (DataTypes.Product memory)
  {
    return _productByStoreById[_storeByProductId[_productId]][_productId];
  }

  function buyProduct(uint256 _productId, uint256 _amount) public {
    DataTypes.Product storage product = _productByStoreById[
      _storeByProductId[_productId]
    ][_productId];

    if (product.isSold) revert("Product is already sold");
    if (product.quantity < _amount) revert("Not enough quantity");
    if (product.seller == _msgSender())
      revert("You can't buy your own product");
    if (product.seller == address(0)) revert("Product is not for sale");
    if (product.quantity == 0) revert("Product is out of stock");

    if (
      IERC20(FWB_TOKEN).allowance(_msgSender(), address(this)) < product.price
    ) revert("Not enough allowance");

    product.buyers.push(_msgSender());
    product.quantity -= _amount;

    if (product.quantity == 0) {
      product.isSold = true;
    }

    _productByStoreById[_storeByProductId[_productId]][_productId] = product;
    _transferTokens(_msgSender(), _storeByProductId[_productId], product.price);

    bytes32 _receipt = keccak256(
      abi.encodePacked(
        _productId,
        product.name,
        product.price,
        _amount,
        _msgSender(),
        block.timestamp
      )
    );

    uint256 _receiptId = ++_purchasesMade;

    _receiptsById[_receiptId] = _receipt;
    Receipt(RECEIPT_NFT).mint(_msgSender(), _receiptId);
  }

  function _transferTokens(
    address from,
    address to,
    uint256 amount
  ) internal {
    bool success = IERC20(FWB_TOKEN).transferFrom(from, to, amount);
    if (!success) revert("Transfer failed");
  }
}
