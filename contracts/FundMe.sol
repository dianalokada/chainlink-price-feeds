// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity ^0.8.7;
// 2. Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    //so for any uin256 value you have you can use the price converter library methods on it 
    using PriceConverter for uint256;
    //this variable will be assigned at compile time
    uint public constant MINIMUM_USD = 50 * 1 ether;
    //immutable variable will be assigned at run time
    //i before it is just a convention in solidity
    address public immutable i_owner;
    //s is a convention as well bc it is a state storage variable
    address[] public s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeed) {
        i_owner = msg.sender;   
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

//a function to send money to a contract (to fund a contract)
    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    //only the owner is able to use this function to withdraw money from a contract
    function withdraw() public onlyOwner {
        //iterate over all the funders and set their amount to 0
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            //this is a way to get the address of the funder at a specific index in the array
            address funder = s_funders[funderIndex];
            //this is a way to set the amount of money that a specific funder has funded to 0
            s_addressToAmountFunded[funder] = 0;
        }   
        //reset the array
        s_funders = new address[](0);
        //send the money back to the owner
        //payable is a type and msg.sender is the sender of the transaction
        //address(this).balance is the balance of the contract
        //"" is the data part of the call
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Call failed");
    }

    //a function to get the amount of money that a specific funder has funded
    function getAmountFunded(address funder) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }   

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {   
        return s_priceFeed;
    }
}

