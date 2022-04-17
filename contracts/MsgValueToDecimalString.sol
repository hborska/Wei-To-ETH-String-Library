//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

library MsgValueToDecimalString {
    using SafeMath for uint256;

    // Params: Taking a wei amount (e.g. 1500000000000000000), decimal amount (e.g. 18 for ETH), and currency (e.g. "ETH")
    // Returns a string with the decimal string of the input
    // Ex: msg.value=1500000000000000000, ouput="1.5 ETH")
    function msgValueToString(
        uint256 _value,
        uint256 _decimalAmount,
        string calldata _currency
    ) public pure returns (string memory) {
        require(_value > 0, "Value must be > 0.");

        string memory weiStr = Strings.toString(_value);
        bytes memory nonZeroNums;
        bool lessThan1ETH = bytes(weiStr).length < _decimalAmount;

        // Getting the non zero numbers of the input
        for (uint256 i = 0; i < bytes(weiStr).length; i++) {
            string memory currNum = getSlice(i + 1, i + 1, weiStr);
            if (
                keccak256(abi.encodePacked(currNum)) !=
                keccak256(abi.encodePacked("0"))
            ) {
                nonZeroNums = abi.encodePacked(nonZeroNums, bytes(currNum));
            } else {
                break;
            }
        }

        // If number is less than 1.0, need to account for decimal shift (e.g. "0.00015 ETH")
        if (lessThan1ETH) {
            bytes memory finalStr;

            // Length of output string has to include leading zeroes
            uint256 toShiftBy = _decimalAmount - bytes(weiStr).length;
            // Beginning of the #
            finalStr = abi.encodePacked(finalStr, "0.");
            // Shift to left
            for (uint256 i = 0; i < toShiftBy; i++) {
                finalStr = abi.encodePacked(finalStr, "0");
            }
            for (uint256 i = 0; i < nonZeroNums.length; i++) {
                finalStr = abi.encodePacked(finalStr, nonZeroNums[i]);
            }
            return string(abi.encodePacked(finalStr, " ", _currency));
        }
        // If number is >= 1.0, right decimal shift (e.g. "1.23 ETH")
        else {
            bytes memory finalStr;

            uint256 toShiftBy = bytes(weiStr).length - _decimalAmount;
            for (uint256 i = 0; i < toShiftBy; i++) {
                finalStr = abi.encodePacked(finalStr, nonZeroNums[i]);
            }
            finalStr = abi.encodePacked(finalStr, ".");
            // We'd want "1.0 ETH" and not "1. ETH"
            if (nonZeroNums.length == 1) {
                finalStr = abi.encodePacked(finalStr, "0");
            }
            for (uint256 i = toShiftBy; i < nonZeroNums.length; i++) {
                finalStr = abi.encodePacked(finalStr, nonZeroNums[i]);
            }
            return string(abi.encodePacked(finalStr, " ", _currency));
        }
    }

    // Getting a slice of a string
    function getSlice(
        uint256 begin,
        uint256 end,
        string memory text
    ) internal pure returns (string memory) {
        bytes memory a = new bytes(end - begin + 1);
        for (uint256 i = 0; i <= end - begin; i++) {
            a[i] = bytes(text)[i + begin - 1];
        }
        return string(a);
    }
}
