// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

/** BonaCrypto is a smart contract that allows easy cryptocurrency donations to charities. 
    Charities are registered to the blockchain as an object containing their charity name,
    ethereum address, and total amount of donations given via BonaCrypto. The contract owner
    has the sole authority to update the list of charities eligible for donation. All users can
    view the list of charities registered with BonaCrypto and donate to these charities
    by simply providing the charity name and donation amount. */
contract BonaCrypto {
	
	// address of the contract owner. 
	address payable public owner = payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);

    // representation of a charity. 
	struct Charity {
		string charityName;
		address payable charityAddress;
		uint totalDonations;
	}

    // list of all charity names registered with BonaCrypto. 
	string[] private charityNames;
	
	// mapping of all charities from name of charity to the struct representation of charity. 
	mapping(string => Charity) private charities; 
	
	// event emitted whenever a donation is successfully executed. 
	event DonationEvent(Charity charity, uint donationAmount);
	
	// event emitted whenever a new charity is successfully registered.
	event RegisterCharityEvent(Charity charity);
	
	// event emitted whenever an existing charity is successfully removed.
	event RemoveCharityEvent(Charity charity);
	
	// error propagated whenever registration is attempted on existing charity. 
	error CharityAlreadyRegistered();
	
	// error propagated whenver donation or summary request is triggered on non-existing charity. 
	error CharityNotRegistered();
	
	// error propagated when non-owners attempt to call owner only methods. 
	error OwnerAccessOnly();
	
	/** Allows registration of a new charity with BonaCrypto. */
	function registerCharity(string memory name, address payable charityAddress) external {
		
		// require(payable(msg.sender) == owner, "Only owner of BonaCrypto can register a charity.");
		require(bytes(name).length != 0, "Name of charity should be a non-empty string.");

		Charity storage newCharity = charities[name];
		
		if (bytes(newCharity.charityName).length != 0)
		    revert CharityAlreadyRegistered();
		
		newCharity.charityName = name;
		newCharity.charityAddress= charityAddress;
		newCharity.totalDonations = 0;
		
		charityNames.push(name);

		emit RegisterCharityEvent(newCharity);
	}
	
	/** Allows removal of an existing charity registered with BonaCrypto. */
	function removeCharity(string memory name) external {
	    
	    // require(payable(msg.sender) == owner, "Only owner of BonaCrypto can remove a charity.");
	    require(bytes(name).length != 0, "Name of charity should be a non-empty string.");
	    
	    Charity storage charity = charities[name];
	    
	    if (bytes(charity.charityName).length == 0)
	        revert CharityNotRegistered();
	    
	    delete charities[name];
	    removeCharityName(name);
	    
	    emit RemoveCharityEvent(charity);
	}
	
	/** Allows removal of existing charity name in charityNames list. */
	function removeCharityName(string memory name) private {
	    for (uint i = 0; i < charityNames.length; i++) {
	        if (keccak256(abi.encodePacked(charityNames[i])) == keccak256(abi.encodePacked(name))) {
	            delete charityNames[i];
	        }
	    }   
	}

    /** Allows donation to a charity that has been registered with BonaCrypto. donationAmount should be given in # of ether. */
	function donateToCharity(string memory name, uint donationAmount) external payable {
	    
	    require(donationAmount > 0, "Donation amount must be greater than zero");
	
		Charity storage charity = charities[name];
		
		if (bytes(charity.charityName).length == 0)
		    revert CharityNotRegistered();
		
		charity.charityAddress.transfer(msg.value);
		charity.totalDonations += donationAmount;

		emit DonationEvent(charity, msg.value);
	}

    /** Provides summary of charity by charity name. The charity name, ethereum address, and total amount donated is displayed to user. */
	function viewCharitySummary(string memory name) external view returns (string memory charityName, address payable charityAddress, uint totalDonations) {
		
		Charity storage charity = charities[name];
		
		if (bytes(charity.charityName).length == 0)
		    revert CharityNotRegistered();
		    
		charityName = charity.charityName;
		charityAddress = charity.charityAddress;
		totalDonations = charity.totalDonations;
		
		return (charityName, charityAddress, totalDonations);
	}
	
	/** Provides total list of charities registered with BonaCrypto. */
	function viewCharityNames() external view returns (string[] memory names) {
	    return charityNames;
	}
}