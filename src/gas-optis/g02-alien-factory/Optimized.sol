// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IAlienFactory} from "./Common.sol";

contract AlienFactory is IAlienFactory {
    // Pack the storage as efficiently as possible based on the required numbers
    uint8 internal _hasNose; // 1 byte Slot 0
    uint16 internal _eyesNumber; // 2 bytes Slot 0
    uint16 internal _legsNumber; // 2 bytes Slot 0
    uint16 internal _armsNumber; // 2 bytes Slot 0
    uint16 internal _antennaNumber; // 2 bytes Slot 0
    uint16 internal _age; // 2 bytes Slot 0
    uint40 internal _height; // 5 bytes Slot 0
    Color internal _color; // 1 byte (enum) Slot 0
    Planet internal _planet; // 1 byte (enum) Slot 0
    // |00|00|00|00|00|00|00|00|00|00|00|00|00|00|_planet|_color|_height|_height|_height|_height|_height|_age|_age|_antennaNumber|_antennaNumber|_armsNumber|_armsNumber|_legsNumber|_legsNumber|_eyesNumber|_eyesNumber|_hasNose| - our bytes array
    address internal _parent; // 20 bytes slot 1

    function setAlienAttributes(
        address parent,
        uint256 eyesNumber,
        uint256 legsNumber,
        uint256 armsNumber,
        uint256 antennaNumber,
        bool hasNose,
        uint256 height,
        Color color,
        uint256 age,
        Planet planet
    ) external {
        assembly {
            // require(eyesNumber <= 1000);
            if gt(eyesNumber, 1000) {
                revert(0, 0)
            }
            // require(legsNumber <= 1000);
            if gt(legsNumber, 1000) {
                revert(0, 0)
            }
            // require(armsNumber <= 1000);
            if gt(armsNumber, 1000) {
                revert(0, 0)
            }
            // require(antennaNumber <= 1000);
            if gt(antennaNumber, 1000) {
                revert(0, 0)
            }
            // require(height <= 1e10);
            if gt(
                height,
                0x00000000000000000000000000000000000000000000000000000002540be400
            ) {
                revert(0, 0)
            }
            // require(age <= 2e4);
            if gt(
                age,
                0x0000000000000000000000000000000000000000000000000000000000004e20
            ) {
                revert(0, 0)
            }
            // Store the variables in storage.
            sstore(0x01, parent) // Store address in its own slot

            // Create the 32 byte representation for storage
            let result := hasNose
            // Shift eyesNumber by 1 byte (8 bits) and append to result using or
            result := or(shl(8, eyesNumber), result)
            // Shift legsNumber by 3 bytes and append using or
            result := or(shl(24, legsNumber), result)
            // Shift armsNumber by 5 bytes and append using or
            result := or(shl(40, armsNumber), result)
            // Shift antennaNumber by 7 bytes and append using or
            result := or(shl(56, antennaNumber), result)
            // Shift age by 9 bytes and append using or
            result := or(shl(72, age), result)
            // Shift height by 11 bytes and append using or
            result := or(shl(88, height), result)
            // Shift color by 16 bytes and append using or
            result := or(shl(128, color), result)
            // Shift planet by 17 bytes and append using or
            result := or(shl(136, planet), result)
            sstore(0x00, result)
        }
    }

    function getAlienAttributes()
        external
        view
        returns (
            address parent,
            uint256 eyesNumber,
            uint256 legsNumber,
            uint256 armsNumber,
            uint256 antennaNumber,
            bool hasNose,
            uint256 height,
            Color color,
            uint256 age,
            Planet planet
        )
    {
        assembly {
            parent := sload(0x01) // Load the parent address
            let valueSlotTwo := sload(0x00) // Load slot 0
            // Set the masks for 8, 16 and 40 bits
            let mask8Bit := 0xff
            let mask16Bit := 0xffff
            let mask40Bit := 0xffffffffff
            // To read each value, get offset and multiply by 8 bits, then mask with relevant mask
            // 16 Bit masks
            eyesNumber := and(
                mask16Bit,
                shr(mul(_eyesNumber.offset, 8), valueSlotTwo)
            )
            legsNumber := and(
                mask16Bit,
                shr(mul(_legsNumber.offset, 8), valueSlotTwo)
            )
            armsNumber := and(
                mask16Bit,
                shr(mul(_armsNumber.offset, 8), valueSlotTwo)
            )
            antennaNumber := and(
                mask16Bit,
                shr(mul(_antennaNumber.offset, 8), valueSlotTwo)
            )
            age := and(mask16Bit, shr(mul(_age.offset, 8), valueSlotTwo))
            // 8 Bit masks
            hasNose := and(mask8Bit, shr(mul(_hasNose.offset, 8), valueSlotTwo))
            color := and(mask8Bit, shr(mul(_color.offset, 8), valueSlotTwo))
            planet := and(mask8Bit, shr(mul(_planet.offset, 8), valueSlotTwo))
            // 40 bit masks
            height := and(mask40Bit, shr(mul(_height.offset, 8), valueSlotTwo))
        }
    }
}
