// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {MerchTable, DataTypes} from "../contracts/MerchTable.sol";
import {Receipt} from "../contracts/Receipt.sol";

contract MerchTableTest is Test {
  MerchTable public merchTable;
  address public _arbiter;
  Receipt public receipt;

  address public bob;
  address public sally;

  uint256 internal constant PRICE = 1 ether;

  function setUp() public {
    _arbiter = address(1);
    sally = address(2);
    bob = address(3);

    merchTable = new MerchTable(_arbiter);
    receipt = new Receipt(address(merchTable));

    merchTable.setReceipt(address(receipt));
  }

  function addProduct(string memory productName) internal returns (uint256) {
    DataTypes.Product memory product = DataTypes.Product({
      id: 0,
      name: productName,
      category: "Sone Category", // could be a standard
      imageLink: "http://image.com/1",
      descLink: "http://desc.com/1",
      startTime: 0,
      price: PRICE,
      condition: DataTypes.ProductCondition.NEW,
      quantity: 2,
      seller: msg.sender,
      buyers: new address[](0),
      isSold: false
    });

    return merchTable.addProductToStore(product);
  }

  function buyProduct(uint256 productId) internal {
    vm.deal(bob, 1 ether);
    vm.prank(bob);
    merchTable.buyProduct{value: PRICE}(productId);
  }

  function testAddProduct() public {
    vm.prank(sally);
    uint256 productId = addProduct("Product 1");

    DataTypes.Product memory _product = merchTable.getProduct(productId);
    assertEq(_product.id, productId);
  }

  function testBuyProduct() public {
    vm.prank(sally);
    uint256 productId = addProduct("Product 1");

    buyProduct(productId);

    DataTypes.Product memory product = merchTable.getProduct(productId);

    assertEq(product.buyers.length, 1);
    assertEq(product.quantity, 1);

    bool isBuyer = false;

    for (uint256 i = 0; i < product.buyers.length; i++) {
      if (product.buyers[i] == bob) {
        isBuyer = true;
      }
    }

    assertTrue(isBuyer);
  }

  function testGetEscrowByProductId() public {
    vm.prank(sally);
    uint256 productId = addProduct("Product 1");

    buyProduct(productId);

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
    vm.prank(sally);
    uint256 productId = addProduct("Product 1");

    buyProduct(productId);

    vm.prank(bob);
    merchTable.releaseAmountToSeller(productId);

    vm.prank(sally);
    merchTable.releaseAmountToSeller(productId);

    assertEq(sally.balance, PRICE);
    assertEq(bob.balance, 0 ether);
  }

  function testRefundAmountToBuyer() public {
    vm.prank(sally);
    uint256 productId = addProduct("Product 1");

    buyProduct(productId);

    vm.prank(bob);
    merchTable.refundAmountToBuyer(productId);

    vm.prank(_arbiter);
    merchTable.refundAmountToBuyer(productId);

    assertEq(sally.balance, 0 ether);
    assertEq(bob.balance, PRICE);
  }
}
