// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//get funds from users, withdraw funds, set a minimum funding value is USD

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    uint public constant MINIMUM_USD = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }


    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Send more biatch"); //1e18 wei = 1eth
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }


    function withdraw() public onlyOwner {
        // boucle pour remettre les compteurs des "funders" à 0.
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
        address funder = funders[funderIndex];
        addressToAmountFunded[funder] = 0;
        }
    // reset le tableau en créant un nouveau tout simplement
    funders = new address[](0);
    // withdraw les fonds    
    //transfer  
    //payable(msg.sender).transfer(address(this).balance);
    //send
    //bool sendSuccess = payable(msg.sender).send(address(this).balance);
    //require(sendSuccess, "Send Failed");
    //call
    (bool callSuccess, )= payable(msg.sender).call{value: address(this).balance}("");
    require(callSuccess, "call Failed");
    }

    modifier onlyOwner {
        require(msg.sender == i_owner, "Sender is not owner!");
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
    //receive / fallback
}