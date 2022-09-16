// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

import {IAthenaWrap} from "./interfaces/IAthenaWrap.sol";
import {AthenaEther} from "./AthenaEther.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
* @title AthenaWrap.
* @author Anthony (fps) https://github.com/0xfps.
* @dev  AthenaWrap, a simple wrapping protocol. It takes in ETH, MATIC or
*       AVAX, and sends AETH tokens to the caller.
*/
abstract contract AthenaWrap is 
IAthenaWrap, 
AthenaEther, 
Ownable 
{
    /// @dev Total wrapped in the protocol.
    uint256 private totalWrapped;
    /// @dev Tota unwrapped in the protocol.
    uint256 private totalUnwrapped;

    /// @dev Total amount wrapped by an address in the protocol.
    mapping(address => uint256) private totalWrappedForCaller;
    /// @dev Total amount unwrapped by an address in the protocol.
    mapping(address => uint256) private totalUnwrappedForCaller;

    constructor() AthenaEther(address(this)) {}
}