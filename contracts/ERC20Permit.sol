// SPDX-License-Identifier: GPL-3.0-or-later
// Adapted from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/53516bc555a454862470e7860a9b5254db4d00f5/contracts/token/ERC20/ERC20Permit.sol
pragma solidity ^0.8.0;

import "acc-erc20/contracts/ERC20.sol";

/**
 * @author Alberto Cuesta Cañada
 * @dev Extension of {ERC20} that allows token holders set allowances or approve a single `transferFrom` using off-chain signatures.
 *
 * The mechanisms don't conform to the {IERC2612} interface.
 */
abstract contract ERC20Permit is ERC20 {
    mapping (address => uint256) public nonces;

    bytes32 public immutable PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public immutable TRANSFERFROM_TYPEHASH = keccak256("TransferFrom(address sender,address recipient,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public immutable DOMAIN_SEPARATOR;

    constructor(string memory name_, string memory symbol_) internal ERC20(name_, symbol_) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name_)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    /**
     * @dev Similar to {IERC2612-permit}, but with a packed signature.
     *
     * In cases where the free option is not a concern, deadline can simply be
     * set to uint(-1), so it should be seen as an optional parameter.
     */
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        bytes memory signature
    ) public virtual {
        require(deadline >= block.timestamp, "ERC20Permit: expired deadline");

        bytes32 hashStruct = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                amount,
                nonces[owner]++,
                deadline
            )
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                hashStruct
            )
        );

        (bytes32 r, bytes32 s, uint8 v) = unpack(signature);
        address signer = ecrecover(hash, v, r, s);
        require(
            signer != address(0) && signer == owner,
            "ERC20Permit::permit: invalid signature"
        );

        _approve(owner, spender, amount);
    }

    /**
     * @dev Similar to {IERC20-transferFrom}, but with a packed signature. It doesn't check or change allowances.
     *
     * In cases where the free option is not a concern, deadline can simply be
     * set to uint(-1), so it should be seen as an optional parameter.
     */
    function transferFromWithSignature(
        address sender,
        address recipient,
        uint256 amount,
        uint256 deadline,
        bytes memory signature
    ) public virtual returns(bool) {
        require(deadline >= block.timestamp, "ERC20Permit: expired deadline");

        bytes32 hashStruct = keccak256(
            abi.encode(
                TRANSFERFROM_TYPEHASH,
                sender,
                recipient,
                amount,
                nonces[sender]++,
                deadline
            )
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                hashStruct
            )
        );

        (bytes32 r, bytes32 s, uint8 v) = unpack(signature);
        address signer = ecrecover(hash, v, r, s);
        require(
            signer != address(0) && signer == sender,
            "ERC20Permit::transferFrom: invalid signature"
        );

        _transfer(sender, recipient, amount);
        return true;
    }

    /// @dev Unpack r, s and v from a `bytes` signature.
    /// @param signature A packed signature.
    function unpack(bytes memory signature) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
    }
}
