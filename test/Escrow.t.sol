// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Escrow} from "../contracts/Escrow.sol";

contract EscrowTest is Test {
  Escrow public escrow;

  address public buyer = address(2);
  address public seller = address(3);
  address public arbiter = address(4);

  function setUp() public {
    escrow = new Escrow{value: 1 ether}(
      0,
      payable(buyer),
      payable(seller),
      arbiter
    );
  }

  function testReleaseAmountToSeller() public {
    escrow.releaseAmountToSeller(buyer);
    escrow.releaseAmountToSeller(seller);
    (
      ,
      ,
      ,
      bool _isFinalized,
      uint256 _releaseCount,
      uint256 _refundCount
    ) = escrow.getEscrow();

    assertEq(seller.balance, 1 ether);
    assertEq(_isFinalized, true);
    assertEq(_releaseCount, 2);
    assertEq(_refundCount, 0);
  }

  function testRefundAmountToBuyer() public {
    escrow.refundAmountToBuyer(buyer);
    escrow.refundAmountToBuyer(arbiter);

    (
      ,
      ,
      ,
      bool _isFinalized,
      uint256 _releaseCount,
      uint256 _refundCount
    ) = escrow.getEscrow();

    assertEq(buyer.balance, 1 ether);
    assertEq(_isFinalized, true);
    assertEq(_refundCount, 2);
    assertEq(_releaseCount, 0);
  }

  function testGetEscrow() public {
    (
      address _buyer,
      address _seller,
      address _arbiter,
      bool _isFinalized,
      uint256 _releaseCount,
      uint256 _refundCount
    ) = escrow.getEscrow();

    assertEq(_buyer, buyer);
    assertEq(_seller, seller);
    assertEq(_arbiter, arbiter);
    assertEq(_isFinalized, false);
    assertEq(_releaseCount, 0);
    assertEq(_refundCount, 0);
  }
}
