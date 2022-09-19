// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

/**
* @title IAthenaWrap.
* @author Anthony (fps) https://github.com/0xfps.
* @dev  Interface for control of AthenaWrap.
*/
interface IAthenaWrap {
    /// @dev Emitted when a wrap is done.
    event Wrap(address indexed _wrapper, uint256 indexed _amount);
    /// @dev Emitted when an uwrap is done.
    event Unwrap(address indexed _unwrapper, uint256 indexed _amount);
    /// @dev Emitted when the protocol taxes are withdrawn.
    event Withdraw(address indexed _to, uint256 indexed _amount);
    
    /**
    * @dev  Returns the total amount of native token wrapped 
    *       by the `AthenaWrap` contract.
    */
    function totalWrapped() external view returns(uint256);

    /**
    * @dev  Returns the total amount of native token unwrapped 
    *       by the `AthenaWrap` contract.
    */
    function totalUnwrapped() external view returns(uint256);

    /**
    * @dev  Returns the total number of native tokens wrapped by `_address`
    *       in the `AthenaWrap` contract.
    *
    * @param _address Address of wrapper.
    */
    function totalWrappedByAddress(address _address) 
    external 
    view 
    returns(uint256);

    /**
    * @dev  Returns the total number of native tokens unwrapped by `_address`
    *       in the `AthenaWrap` contract.
    *
    * @param _address Address of unwrapper.
    */
    function totalUnwrappedByAddress(address _address) 
    external 
    view 
    returns(uint256);

    /**
    * @dev  Returns the total amount of tax that will be charged for the wraping
    *       of `_amount` amount of native tokens.
    *
    * @param _amount Amount to calculate.
    */
    function precalculateTaxForWrap(uint256 _amount) 
    external 
    pure 
    returns(uint256);

    /**
    * @dev  Wraps `msg.value` amount of tokens, by transferring `msg.value` amount 
    *       of AETH tokens after deducting tax.
    *       This function increments the `_totalWrapped` variable.
    *       Emits a `Wrap()` event.
    */
    function wrap() external payable;

    /**
    * @dev  Unraps `_amount` amount of tokens, by transferring `_amount` amount
    *       of native tokens to caller after deducting tax.
    *       This function increments the `_totalUnwrapped` variable.
    *       Emits an `Unwrap()` event.
    *
    * @param _amount Amount to unwrap.
    */
    function unwrap(uint256 _amount) external;

    /**
    * @dev  Transfers the total taxes to the protocol owner's address.
    *       Emits a `Withdraw()` event.
    */
    function withdraw() external;
}