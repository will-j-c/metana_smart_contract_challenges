// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ILoops} from "./Common.sol";

contract Loops is ILoops {
    function loop1(
        uint256[] calldata array
    ) external pure returns (uint256 result) {
        assembly {
            let len := array.length // Load array length
            let ptr := array.offset // Get base offset of the array data

            for {
                let i := 0
            } lt(i, len) {
                i := add(i, 1)
            } {
                // Read element at (ptr + i*32)
                let element := calldataload(add(ptr, mul(i, 0x20)))
                result := add(result, element)
            }
        }
    }

    function loop2(
        uint256[10] calldata array
    ) external pure returns (uint256 result) {
        assembly {
            for {
                let i := 0
            } lt(i, 10) {
                i := add(i, 1)
            } {
                // array points to array[0] as no other function param. Offset by 32 bytes
                // for each loop
                let element := calldataload(add(array, mul(i, 0x20)))
                result := add(result, element)
            }
        }
    }

    function loop3(
        uint256[] calldata array
    ) external pure returns (uint256 result) {
        assembly {
            let len := array.length // Load array length

            // Check if len is greater than 10 and revert if true
            if gt(len, 10) {
                revert(0, 0)
            }

            let ptr := array.offset // Get base offset of the array data

            for {
                let i := 0
            } lt(i, len) {
                i := add(i, 1)
            } {
                // Read element at (ptr + i*32)
                let element := calldataload(add(ptr, mul(i, 0x20)))
                result := add(result, element)
            }
        }
    }
}
