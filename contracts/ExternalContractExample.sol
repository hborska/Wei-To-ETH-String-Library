//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./MsgValueToDecimalString.sol";

// An example of how you would use this library
contract ExternalContractExample {
    string decimalStr;

    // Function that takes the msg.value and uses our library to return an ETH String
    // E.g. 1500000000000000000 --> "1.5 ETH"
    function parseETHAmount() public payable {
        uint256 ethDecimals = 18;
        string memory ethSymbol = "ETH";

        decimalStr = MsgValueToDecimalString.msgValueToString(
            msg.value,
            ethDecimals,
            ethSymbol
        );
    }

    function getDecimalStr() public view returns (string memory) {
        return decimalStr;
    }
}
