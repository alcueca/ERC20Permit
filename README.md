# ERC20 Permit

This project is an implementation of an ERC2612 enabled ERC20 token.

It allows to use signatures calculated off-chain to increase allowances using `permit`. The call to `permit` doesn't need to be done by the `holder`, so this contract allows the implementation of "gas-less" tokens, or the replacement of `approve` transactions by methods that call `permit` and `transferFrom` atomically.

Most of the code in this repository was written by Georgios Konstantopoulos.

## How to Use

`ERC20Permit` is an `ERC20` contract. You can just inherit it and you are done from the smart contracts point of view.

```
contract MyContract is ERC20Permit {

    constructor (string memory _name, string memory _symbol) public ERC20Permit(_name, _symbol) {...}

    ...
}
```

The `utils/signatures.ts` file contains useful functions to compute the `DOMAIN_SEPARATOR`, `digest` and `signature` from typescript.

## Further reading

[This article](https://hackernoon.com/how-to-code-gas-less-tokens-on-ethereum-43u3ew4) explains in detail how to use the code in this repository.