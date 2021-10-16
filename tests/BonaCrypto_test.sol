// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/Bonacrypto.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite is BonaCrypto {
    
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    address payable public charityOneAddress = payable(0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C);
    address payable public charityTwoAddress = payable(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
    address payable public charityThreeAddress = payable(0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c);
    
    string public charityNameOne = "testCharityOne";
    string public charityNameTwo = "testCharityTwo";
    string public charityNameThree= "testCharityThree";
    
    /// 'beforeAll' runs before all other tests
    function beforeAll() public {
        this.registerCharity(charityNameOne, charityOneAddress);
        this.registerCharity(charityNameTwo, charityTwoAddress);
        this.registerCharity(charityNameThree, charityThreeAddress);
    }
    
    string[] public expectedCharityNames;
    function checkRegisterCharity() public {
        
        expectedCharityNames.push("testCharityOne");
        expectedCharityNames.push("testCharityTwo");
        expectedCharityNames.push("testCharityThree");
        
        string[] memory returnedCharityNames = this.viewCharityNames();
        
        for (uint i = 0; i< 3; i++) {
            Assert.equal(returnedCharityNames[i], expectedCharityNames[i], "Verify charity names are identical.");
        }
        
        Assert.equal(expectedCharityNames.length, returnedCharityNames.length, "Verify size of charity names list is identical.");
    }
    
    function checkCharitySummary() public {
        
        (string memory charityName, address payable charityAddress, uint totalDonations) = this.viewCharitySummary(charityNameOne);
        
        Assert.equal(charityName, charityNameOne, "Verify charity name is correct.");
        Assert.equal(charityAddress, charityOneAddress, "Verify charity address is correct.");
        Assert.equal(totalDonations, 0, "Verify total donation amount is correct.");
    }

    /// #value: 100
    function checkDonateToCharity() public payable {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        
        Assert.equal(msg.value, 100, "Verify that value being sent is equal to 100");
        
        this.donateToCharity(charityNameTwo, 100);
        
        (string memory charityName, address payable charityAddress, uint totalDonations) = this.viewCharitySummary(charityNameTwo);
        
        Assert.equal(charityName, charityNameTwo, "Verify charity name is correct.");
        Assert.equal(charityAddress, charityTwoAddress, "Verify charity address is correct.");
        Assert.equal(totalDonations, 100, "Verify total donation amount is correct.");
    }
    
    // Should abort with an error. Comment out charitySummary line to see if it passes. 
    function checkRemoveCharity() public {
        
        // Verify that charityNameTwo has money donated. 
        (string memory charityName, address payable charityAddress, uint totalDonations) = this.viewCharitySummary(charityNameTwo);
        
        Assert.equal(charityName, charityNameTwo, "Verify charity name is correct.");
        Assert.equal(charityAddress, charityTwoAddress, "Verify charity address is correct.");
        Assert.equal(totalDonations, 100, "Verify total donation amount is correct.");
        Assert.equal(this.viewCharityNames()[1], charityNameTwo, "Second element of charityNames list should be charityNameTwo.");
        
        // Remove charity.
        this.removeCharity(charityName);
        Assert.notEqual(this.viewCharityNames()[1], charityNameTwo, "Second element of charityNames should no longer be charityNameThree.");
        
        // (string memory removedCharityName, address payable removedCharityAddress, uint removedTotalDonations) = this.viewCharitySummary(charityNameTwo);
    }
}
