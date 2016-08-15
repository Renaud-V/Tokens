/*
This Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20) as well as the following OPTIONAL extras intended for use by humans to manage assets.

In other words. This is intended for deployment in something like a Token Factory or Mist wallet, and then used by humans to manage assets.
Imagine all kind of objects such as clothes, games, toys, etc.
Machine-based, rapid creation of many tokens would not necessarily need these extra features or will be minted in other manners.

1) Initial Finite Supply (upon creation one specifies how much is minted).
2) In the absence of a token registry: Optional Decimal, Symbol & Name.
3) Optional approveAndCall() functionality to notify a contract if an approval() has occurred.
4) mintToken functionality to add tokens when new assets enter the inventory.
5) removeToken functionality when assets are removed from the inventory.

.*/

import "StandardToken.sol";
import "Owned.sol";

contract HumanAssetStandardToken is StandardToken, Owned {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Gogos
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 GOG = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg GOG
    string public version = 'HA0.1';      //human assets 0.1 standard. Just an arbitrary versioning scheme.

    function HumanAssetStandardToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
	/* Owner can mint new tokens */
	function mintToken(address target, uint256 mintedAmount) onlyOwner {
		balances[target] += mintedAmount;
		totalSupply += mintedAmount;
		Transfer(0, owner, mintedAmount);
		Transfer(owner, target, mintedAmount);
	}
	/* Owner can remove tokens */
	function removeToken(address target, uint256 removedAmount) onlyOwner returns (bool success) {
		if (balances[target] >= removedAmount && removedAmount > 0) {
			balances[target] -= removedAmount;
			totalSupply -= removedAmount;
			return true;
		} else { return false; }
	}
}
