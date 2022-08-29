// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
  address payable public immutable buyer;
  address payable public immutable seller;
  address public immutable arbiter;

  uint256 public immutable productId;
  uint256 public immutable amount;

  mapping(address => bool) public releaseAmount;
  mapping(address => bool) public refundAmount;

  uint256 public releaseCount;
  uint256 public refundCount;
  bool public isFinalized;

  address public owner;

  constructor(
    uint256 _productId,
    address payable _buyer,
    address payable _seller,
    address _arbiter
  ) payable {
    productId = _productId;
    buyer = _buyer;
    seller = _seller;
    arbiter = _arbiter;
    amount = msg.value;
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) revert("Only owner can call this function");
    _;
  }

  modifier notFinalized() {
    if (isFinalized == true) revert("Escrow is finalized");
    _;
  }

  function getEscrow()
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
    return (buyer, seller, arbiter, isFinalized, releaseCount, refundCount);
  }

  function releaseAmountToSeller(address _caller)
    public
    onlyOwner
    notFinalized
  {
    if (
      (_caller == buyer || _caller == seller || _caller == arbiter) &&
      releaseAmount[_caller] != true
    ) {
      releaseAmount[_caller] = true;
      releaseCount++;
    }

    if (releaseCount == 2) {
      isFinalized = true;
      seller.transfer(amount);
    }
  }

  function refundAmountToBuyer(address _caller) public onlyOwner notFinalized {
    if (
      (_caller == buyer || _caller == seller || _caller == arbiter) &&
      refundAmount[_caller] != true
    ) {
      refundAmount[_caller] = true;
      refundCount++;
    }

    if (refundCount == 2) {
      isFinalized = true;
      buyer.transfer(amount);
    }
  }
}
