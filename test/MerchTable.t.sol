// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {MerchTable, DataTypes} from "../contracts/MerchTable.sol";
import {Receipt} from "../contracts/Receipt.sol";
import {FWB} from "./mocks/MockFWB.sol";

contract MerchTableTest is Test {
  MerchTable public _merchTable;
  Receipt public _receipt;
  FWB public _fwb;

  address public _arbiter;

  address public _bob;
  address public _sally;

  uint256 internal constant PRODUCT_PRICE = 10;

  function setUp() public {
    _arbiter = address(1);
    _sally = address(2);
    _bob = address(3);

    _fwb = new FWB();
    _merchTable = new MerchTable(_arbiter, address(_fwb));
    _receipt = new Receipt(address(_merchTable));
    _merchTable.setReceipt(address(_receipt));
  }

  function addProduct(string memory productName) internal returns (uint256) {
    DataTypes.Product memory product = DataTypes.Product({
      id: 0,
      name: productName,
      category: "Sone Category", // could be a standard
      imageLink: "http://image.com/1",
      descLink: "http://desc.com/1",
      startTime: 0,
      price: PRODUCT_PRICE,
      condition: DataTypes.ProductCondition.NEW,
      quantity: 2,
      seller: msg.sender,
      buyers: new address[](0),
      isSold: false
    });

    return _merchTable.addProductToStore(product);
  }

  function buyProduct(uint256 productId) internal {
    _fwb.transfer(_bob, PRODUCT_PRICE);

    vm.startPrank(_bob);
    _fwb.approve(address(_merchTable), PRODUCT_PRICE);
    _merchTable.buyProduct(productId, 1);
    vm.stopPrank();
  }

  function testAddProduct() public {
    vm.prank(_sally);
    uint256 productId = addProduct("Product 1");

    DataTypes.Product memory _product = _merchTable.getProduct(productId);
    assertEq(_product.id, productId);
  }

  function testBuyProduct() public {
    vm.prank(_sally);
    uint256 productId = addProduct("Product 1");

    buyProduct(productId);
    DataTypes.Product memory product = _merchTable.getProduct(productId);

    assertEq(product.buyers.length, 1);
    assertEq(product.quantity, 1);

    bool isBuyer = false;

    for (uint256 i = 0; i < product.buyers.length; i++) {
      if (product.buyers[i] == _bob) {
        isBuyer = true;
      }
    }

    assertTrue(isBuyer);
  }
}
