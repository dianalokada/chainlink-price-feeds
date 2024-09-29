// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    //a fucntion to get a price for ethereum in US dollars
  function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
    //it returns 5 things so thats is why 5 comas - bc we just need 1 thing
    (, int256 answer, , , ) = priceFeed.latestRoundData();
    //the answer here gives us the answer with 8 decimals but we need to have 10 decimals.
    //1 ether = 10 ** 18 
    //so we need to multiply the answer by 10 decimal places
    return uint256(answer * 10000000000);
  } 

  function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
    //get the price of eth in usd
    uint256 ethPrice = getPrice(priceFeed);
    //get the price and multiply by the amount of ethereum. the amount is gonna be in wei
    uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1 ether;
    return ethAmountInUsd;
  }
}
