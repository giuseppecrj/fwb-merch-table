# FWB Merch Table

This repository holds the proof-of-concept contracts for a Merch Table for FWB DAO

## Structure

The contracts are structured as followed:

### Participants

- buyer
- seller / store
- arbiter

### Contracts

`MerchTable.sol` - In charge of adding products to catalog and settling escrow arbitration once product is delivered.

`Escrow.sol` - This contract gets created internally when a buyer purchases from a seller. The `ETH` goes into this escrow contract until 2 of the 3 participants agree to either release or refund the amount once the transaction is settled.

### TODO

- Allow for ERC20 Payments
- Shipping capabilities off-chain

## Installation

```bash
  git clone https://github.com/giuseppecrj/fwb-merch-table.git
  cd fwb-merch-table
  forge install
```

## Usage

Here's a list of the most frequently needed commands.

### Build

Build the contracts:

```sh
$ forge build
```

### Clean

Delete the build artifacts and cache directories:

```sh
$ forge clean
```

### Compile

Compile the contracts:

```sh
$ forge build
```

### Test

Test the contracts:

```sh
$ forge test
```

### Deploy

Deploy to Anvil:

```sh
$ make deploy-anvil contract=MerchTable
```
