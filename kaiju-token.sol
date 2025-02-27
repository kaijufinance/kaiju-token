// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

//KADO
contract KaijuToken is Initializable, ERC20Upgradeable, AccessControlUpgradeable, OwnableUpgradeable, ERC20PermitUpgradeable, UUPSUpgradeable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    
    event MintedEvent(address to, uint256 amount, uint256 time);
    event BurnedEvent(address from, uint256 amount, uint256 time);
    event RoleUpdated(bytes32 role, address account, bool isGranted);
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory name, string memory symbol, address initialOwner, uint256 initialSupply) initializer public {
        __ERC20_init(name, symbol);
        __AccessControl_init();
        __Ownable_init(initialOwner);
        __ERC20Permit_init(name);
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
        _grantRole(MINTER_ROLE, initialOwner);
        _grantRole(BURNER_ROLE, initialOwner);

        _mint(initialOwner, initialSupply);
    }
    
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
        emit MintedEvent(to, amount, block.timestamp);
    }

    function burn(address from, uint256 amount) public onlyRole(BURNER_ROLE) {
        require(hasRole(BURNER_ROLE, msg.sender), "Must have burner role to burn");
        uint256 currentAllowance = allowance(from, msg.sender);
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");

        unchecked {
            _approve(from, msg.sender, currentAllowance - amount);
        }

        _burn(from, amount);
        emit BurnedEvent(from, amount, block.timestamp);
    }

    function updateRoleAssignment(bytes32 role, address account, bool grantRole) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(role == MINTER_ROLE || role == BURNER_ROLE, "Invalid role");
        
        if (grantRole) {
            _grantRole(role, account);
        } else {
            _revokeRole(role, account);
        }
        
        emit RoleUpdated(role, account, grantRole);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
