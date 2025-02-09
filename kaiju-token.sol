// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.28.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";

contract KaijuToken is Initializable, ERC20Upgradeable, OwnableUpgradeable, ERC20PermitUpgradeable, UUPSUpgradeable {
    
    event MintedEvent(address to, uint256 amount, uint256 time);
    event BurnedEvent(address from, uint256 amount, uint256 time);
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory name, string memory symbol, address initialOwner, uint256 initialSupply) initializer public {
        __ERC20_init(name, symbol);
        __Ownable_init(initialOwner);
        __ERC20Permit_init(name);
        __UUPSUpgradeable_init();

        mint(msg.sender, initialSupply);
    }
    
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);

        emit MintedEvent(to, amount, block.timestamp);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);

        emit BurnedEvent(msg.sender, amount, block.timestamp);
    }

    function burnFrom(address account, uint256 amount) public {
        uint256 currentAllowance = allowance(account, msg.sender);
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");

        unchecked {
            _approve(account, msg.sender, currentAllowance - amount);
        }

        _burn(account, amount);

        emit BurnedEvent(account, amount, block.timestamp);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}
