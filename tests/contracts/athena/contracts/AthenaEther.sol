// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
* @title AthenaEther.
* @author Anthony (fps) https://github.com/0xfps.
* @dev Contract for minted AthenaEther to be transferred on successful wraps.
*/
contract AthenaEther is ERC20 {
    /// @dev Emitted on a new Deployment.
    event AthenaLaunch(address, uint256);

    /// @dev Constructor, mints 1 billion tokens to the Wrap contract.
    /// @param _wrap Address of AthenaWrap contract.
    constructor(address _wrap) ERC20("AthenaEther", "AETH") {
        /// @dev Mint 1 billion tokens to the AthenaEther Contract.
        _mint(_wrap, (10 ** 9) * (10 ** 18)); // 1 Billion Tokens.
        /// @dev Emit {AthenaLaunch} event.
        emit AthenaLaunch(_wrap, (10 ** 9) * (10 ** 18));
    }
}