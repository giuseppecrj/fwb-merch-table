// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {MerchTable, DataTypes} from "../contracts/MerchTable.sol";

contract MerchTableTest is Test {
  MerchTable public merchTable;
  uint256 public productId;
  address public _arbiter;

  address public bob;
  address public sally;

  uint256 internal constant PRICE = 1 ether;

  function setUp() public {
    _arbiter = address(1);
    sally = address(2);
    bob = address(3);

    merchTable = new MerchTable(_arbiter);

    DataTypes.Product memory product = DataTypes.Product({
      id: 0,
      name: "Product 1",
      category: "Category 1", // could be a standard
      imageLink: "http://image.com/1",
      descLink: "http://desc.com/1",
      startTime: 0,
      price: PRICE,
      condition: DataTypes.ProductCondition.NEW,
      seller: address(0),
      buyer: address(0),
      isSold: false
    });

    vm.prank(sally);
    productId = merchTable.addProductToStore(product);
  }

  function buyProduct() internal {
    vm.deal(bob, 1 ether);
    vm.prank(bob);
    merchTable.buyProduct{value: PRICE}(productId);
  }

  function testAddProduct() public {
    DataTypes.Product memory product = DataTypes.Product({
      id: 0,
      name: "Product 2",
      category: "Category 2", // could be a standard
      imageLink: "http://image.com/1",
      descLink: "http://desc.com/1",
      startTime: 0,
      price: PRICE,
      condition: DataTypes.ProductCondition.NEW,
      seller: sally,
      buyer: address(0),
      isSold: false
    });

    uint256 _productId = merchTable.addProductToStore(product);
    DataTypes.Product memory _product = merchTable.getProduct(_productId);

    assertEq(_product.id, _productId);
  }

  function testGetProduct() public {
    DataTypes.Product memory product = merchTable.getProduct(productId);
    assertEq(product.id, productId);
  }

  function testBuyProduct() public {
    buyProduct();

    DataTypes.Product memory product = merchTable.getProduct(productId);

    assertEq(product.buyer, bob);
    assertEq(product.isSold, true);
  }

  function testGetEscrowByProductId() public {
    buyProduct();

    (
      address buyer,
      ,
      address arbiter,
      bool isFinalized,
      uint256 releaseCount,
      uint256 refundCount
    ) = merchTable.getEscrowByProductId(productId);

    assertEq(buyer, bob);
    assertEq(_arbiter, arbiter);
    assertEq(isFinalized, false);
    assertEq(releaseCount, 0);
    assertEq(refundCount, 0);
  }

  function testReleaseAmountToSeller() public {
    buyProduct();

    vm.prank(bob);
    merchTable.releaseAmountToSeller(productId);

    vm.prank(sally);
    merchTable.releaseAmountToSeller(productId);

    assertEq(sally.balance, PRICE);
    assertEq(bob.balance, 0 ether);
  }

  function testRefundAmountToBuyer() public {
    buyProduct();

    vm.prank(bob);
    merchTable.refundAmountToBuyer(productId);

    vm.prank(_arbiter);
    merchTable.refundAmountToBuyer(productId);

    assertEq(sally.balance, 0 ether);
    assertEq(bob.balance, PRICE);
  }
}
