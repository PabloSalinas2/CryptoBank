// LICENSE
// SPDX-License-Identifier: MIT

// VERSION SOLIDITY
pragma solidity 0.8.24;

// CONTRACT
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract CryptoBank {
    // variables de estado

    mapping(address => uint256) public balanceUserEth;
    mapping(address => uint256) public balanceUserUsdc;
    uint256 public maxBalanceUserEth;
    uint256 public maxBalanceUserUsdc;
    uint256 public depositLimitEth;
    uint256 public depositLimitUsdc;
    address public admin;
    address public usdc;

    // events
    event EventDepositEth(address direccion, uint256 amount);
    event EventWithrawETH(address retiro, uint256 amount);
    event EventDespositUsdc(address direccion, uint256 amount);
    event EventWithrawUsdc(address direccion, uint256 amount);

    // modifiers

    modifier onlyAdmin() {
        require(msg.sender == admin, "User is not Admin");
        _;
    }

    // constructor

    constructor(address addressAdmin_) {
        maxBalanceUserEth = 6e18;
        maxBalanceUserUsdc = 15000e6;
        depositLimitEth = 4e18;
        depositLimitUsdc = 10000e6;
        usdc = 0x86E721b43d4ECFa71119Dd38c0f938A75Fdb57B3;

        admin = addressAdmin_;
    }

    // functions

    receive() external payable {
        require(msg.value <= depositLimitEth, "exceded limit");
        require((balanceUserEth[msg.sender] + msg.value) <= maxBalanceUserEth, "Exceded maxBalanceEth");

        balanceUserEth[msg.sender] += msg.value;
        emit EventDepositEth(msg.sender, msg.value);
    }

    function withrawETH(address to_, uint256 amount_) public {
        require(amount_ <= balanceUserEth[msg.sender], "Incorrect amount");

        uint256 amount = amount_;
        balanceUserEth[msg.sender] -= amount_;
        (bool success,) = to_.call{value: amount}("");
        require(success);
        emit EventWithrawETH(msg.sender, amount);
    }

    function depositUsdc(uint256 amount_) public {
        require(amount_ <= depositLimitUsdc, "Exceded amount per transaction");
        require((amount_ + balanceUserUsdc[msg.sender]) <= maxBalanceUserUsdc, "Exceded Balance");

        bool success = IERC20(usdc).transferFrom(msg.sender, address(this), amount_);
        require(success, "Deposit Fail");

        balanceUserUsdc[msg.sender] += amount_;
        emit EventDespositUsdc(msg.sender, amount_);
    }

    function withrawUsdc(uint256 amount_) public {
        require(amount_ <= balanceUserUsdc[msg.sender], "Incorrect Amount");

        balanceUserUsdc[msg.sender] -= amount_;

        bool success = IERC20(usdc).transfer(msg.sender, amount_);
        require(success, "Withraw usdc Fail");

        emit EventWithrawUsdc(msg.sender, amount_);
    }

    function setMaxBalanceEth(uint256 newBalance) public onlyAdmin {
        maxBalanceUserEth = newBalance;
    }

    function setMaxBalanceUsdc(uint256 newBalance_) public onlyAdmin {
        maxBalanceUserUsdc = newBalance_;
    }

    function setMaxDepositEth(uint256 newMaxDepositEth_) public onlyAdmin {
        depositLimitEth = newMaxDepositEth_;
    }

    function setMaxDepostiUsdc(uint256 newMaxDepositUsdc_) public onlyAdmin {
        depositLimitUsdc = newMaxDepositUsdc_;
    }
}
