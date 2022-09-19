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
contract AthenaWrap is 
IAthenaWrap, 
AthenaEther, 
Ownable 
{
    /// @dev Total wrapped in the protocol.
    uint256 private _totalWrapped;
    /// @dev Tota unwrapped in the protocol.
    uint256 private _totalUnwrapped;
    /// @dev Protocol tax revenue.
    uint256 private tax;

    /// @dev Total amount wrapped by an address in the protocol.
    mapping(address => uint256) private _totalWrappedByAddress;
    /// @dev Total amount unwrapped by an address in the protocol.
    mapping(address => uint256) private _totalUnwrappedByAddress;

    constructor() AthenaEther(address(this)) {}

    receive() external payable {}

    /**
    * @inheritdoc IAthenaWrap
    */
    function totalWrapped() public view returns(uint256) {
        /// @dev Return total wrapped by protocol.
        return _totalWrapped;
    }

    /**
    * @inheritdoc IAthenaWrap
    */
    function totalUnwrapped() public view returns(uint256) {
        /// @dev Return total unwrapped by protocol.
        return _totalUnwrapped;
    }

    /**
    * @inheritdoc IAthenaWrap
    */
    function totalWrappedByAddress(address _address) 
    public 
    view 
    returns(uint256)
    {
        /// @dev Ensure Address is not a zero address.
        require(_address != address(0), "0x0 Address");
        /// @dev Return total wrapped by address.
        return _totalWrappedByAddress[_address];
    }

    /**
    * @inheritdoc IAthenaWrap
    */
    function totalUnwrappedByAddress(address _address) 
    public 
    view 
    returns(uint256)
    {
        /// @dev Ensure Address is not a zero address.
        require(_address != address(0), "0x0 Address");
        /// @dev Return total wrapped by address.
        return _totalUnwrappedByAddress[_address];
    }

    /**
    * @inheritdoc IAthenaWrap
    */
    function precalculateTaxForWrap(uint256 _amount) 
    public 
    pure 
    returns(uint256)
    {
        /// @dev Require that amount is not 0.
        require(_amount != 0, "Amount == 0");

        /// @dev Calculate tax [0.7% of `_amount`].
        uint256 taxOnAmount = (7 * _amount) / 1000;

        /// @dev Return value.
        return taxOnAmount;
    }

    /**
    * @inheritdoc IAthenaWrap
    */
    function wrap() public payable {
        /// @dev Require money sent is not 0.
        require(msg.value != 0, "Wrapping 0");

        /// @dev Calculate tax.
        uint256 _tax = precalculateTaxForWrap(msg.value);
        /// @dev Subtract tax.
        uint256 amountToWrap = msg.value - _tax;
        /// @dev Add that to taxes.
        tax += _tax;
        /// @dev Increment total wrapped by the value.
        _totalWrapped += msg.value;
        /// @dev Increment the total wrapped by caller by value.
        _totalWrappedByAddress[msg.sender] += msg.value;

        /// @dev Transfer tokens.
        transfer(address(this), amountToWrap);

        /// @dev Emit the {Wrap()} event.
        emit Wrap(msg.sender, msg.value);
    }

    /**
    * @inheritdoc IAthenaWrap
    */
    function unwrap(uint256 _amount) public {
        /// @dev Require money sent is not 0.
        require(_amount != 0, "Wrapping 0");
        /// @dev    Require that this contract has some 
        ///         allowance to spend for caller's tokens.
        require(
            allowance(msg.sender, address(this)) >= _amount, 
            "Allowance < Amount."
        );

        /// @dev Calculate tax.
        uint256 _tax = precalculateTaxForWrap(_amount);
        /// @dev Subtract tax.
        uint256 amountToUnwrap = _amount - _tax;
        /// @dev Increment amount unwrapped.
        _totalUnwrapped += _amount;
        /// @dev Increment amount unwrapped by the caller.
        _totalUnwrappedByAddress[msg.sender] += _amount;

        /// @dev Transfer amount from caller to contract.
        transferFrom(
            msg.sender, 
            address(this), 
            _amount
        );

        /// @dev Send transferable value after tax to caller.
        (bool sent, ) = payable(msg.sender).call{value: amountToUnwrap}("");
        sent; // Unused.

        /// @dev Emit the {Unwrap()} event.
        emit Unwrap(msg.sender, _amount);
    }

    /**
    * @inheritdoc IAthenaWrap
    */
    function withdraw() public onlyOwner {
        /// @dev Require that taxes have been collected.
        require(tax != 0, "Tax == 0");

        /// @dev Reset tax.
        tax = 0;

        /// @dev Transfer tax earnings.
        (bool sent, ) = payable(owner()).call{value: tax}("");
        sent; // Unused.

        /// @dev Emit the {Withdraw()} event.
        emit Withdraw(msg.sender, tax);
    }
}