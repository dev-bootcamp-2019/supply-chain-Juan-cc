pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {
    
    // Truffle looks for `initialBalance` when it compiles the test suite 
  // and funds this test contract with the specified amount on deployment.
    uint public initialBalance = 10 ether;

    SupplyChain supplyChain;
    ThrowProxy proxy;
    uint constant SKU_NOT_PRESENT = 1000;

    // TODO Juan - Refactor needed
    function beforeAll() public{
        supplyChain = new SupplyChain();
        proxy = new ThrowProxy(address(supplyChain)); 
        // Adding one item as part of the setup.
        SupplyChain(address(proxy)).addItem("Article 1", 1);
        bool r = proxy.execute.gas(200000)(); 
        Assert.isTrue(r, "We are not able to add items.");
    }

    function testOwnerViaConstructor() public {
        Assert.equal(supplyChain.owner(), this, "An owner is different than a deployer");
    }

    function testOwnerViaDeployedContract() public {
        SupplyChain anotherSupplyChain = SupplyChain(DeployedAddresses.SupplyChain());
        Assert.equal(anotherSupplyChain.owner(), msg.sender, "An owner is different than a deployer");
    }


    // Test for failing conditions in this contracts
    // test that every modifier is working
    function testAddItem() public {
        uint previousAmount = supplyChain.skuCount();
        SupplyChain(address(proxy)).addItem("Article 2", 2);
        bool r = proxy.execute.gas(200000)(); 
        Assert.isTrue(r, "Should be ok to add an item!");
        Assert.isTrue(supplyChain.skuCount() == previousAmount + 1, "Item not added");
    }

    // buyItem
    /*function testBuyItemPresent() public  {
        supplyChain.buyItem(1);
       // SupplyChain(address(proxy)).buyItem(1);
        //bool r = proxy.execute.value(30)(); 
        //Assert.isTrue(r, "Error buying an item!");
       
    }*/

    // test for failure if user does not send enough funds
    // test for purchasing an item that is not for Sale


    // shipItem

    // test for calls that are made by not the seller
    // test for trying to ship an item that is not marked Sold

    // receiveItem

    // test calling the function from an address that is not the buyer
    // test calling the function on an item not marked Shipped


}


// Proxy contract for testing throws
contract ThrowProxy {
    address public target;
    bytes data;

    constructor(address _target) public {
        target = _target;
    }

    //prime the data using the fallback function.
    function() public {
        data = msg.data;
    }

    function execute() public returns (bool){
        return target.call(data);
    }
}
