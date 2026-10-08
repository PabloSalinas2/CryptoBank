// LICENsE 

//SPDX-License-Identifier: MIT

// solidity version 

pragma solidity 0.8.24;

import "../src/CryptoBank.sol";
import "lib/forge-std/src/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Testbank is Test {

    // variables

    CryptoBank public cryptobank;
    address public user1= vm.addr(1);
    address public admin = vm.addr(2);
    // events


    // modifiers


    // constructor 
    function setUp() public {
        cryptobank= new CryptoBank(admin);

    }

    // functions 

    function testExcededLimitDepositEth() external {
        vm.startPrank(user1);
        uint256 amountDeposit= 5e18;
        vm.deal(user1, amountDeposit);
        
        vm.expectRevert("exceded limit");
        (bool success,)=address(cryptobank).call{value: amountDeposit}("");
        require(success);

        vm.stopPrank();

    }


    function testDepositAmountCorrect() external {
        uint256 amountDeposit= 3e18;
        
        vm.startPrank(user1);
        vm.deal(user1, amountDeposit);
        
        
        uint256 balanceBefore= cryptobank.balanceUserEth(user1);
        (bool success,)=address(cryptobank).call{value: amountDeposit}("");
        require(success);
        uint256 balanceAfter= cryptobank.balanceUserEth(user1);

        assert(balanceAfter - balanceBefore == amountDeposit);

        vm.stopPrank();


    }



    function testDepositMaxBalanceETHexeded() external {
        vm.startPrank(user1);
        uint256 amountDeposit= 7e18;
        uint256 deposit1= 3e18;
        uint256 deposit2= 4e18;

        vm.deal(user1, amountDeposit);
        
        
        uint256 balanceBefore= cryptobank.balanceUserEth(user1);
        (bool success,)=address(cryptobank).call{value: deposit1}("");
        require(success);
        uint256 balanceAfter= cryptobank.balanceUserEth(user1);

        assert(balanceAfter - balanceBefore == deposit1);


        vm.expectRevert("Exceded maxBalanceEth");
        (bool success2,)=address(cryptobank).call{value: deposit2}("");
        require(success2);



        vm.stopPrank();


    }


    function testWithrawEthAmounExededMaxBalance() external {
        uint256 amountWithraw= 5e18;
        uint256 amountDeposit= 4e18;

    

        vm.startPrank(user1);
        vm.deal(user1, amountDeposit);
        
        
        uint256 balanceBefore= cryptobank.balanceUserEth(user1);
        (bool success,)=address(cryptobank).call{value: amountDeposit}("");
        require(success);
        uint256 balanceAfter= cryptobank.balanceUserEth(user1);

        assert(balanceAfter - balanceBefore == amountDeposit);

        vm.expectRevert("Incorrect amount");
        cryptobank.withrawETH(user1,amountWithraw);




        vm.stopPrank();
    

    }


    function testWithrawEthCorrectAmount () external {
        uint256 amountWithraw= 3e18;
        uint256 amountDeposit= 4e18;

    

        vm.startPrank(user1);
        vm.deal(user1, amountDeposit);
        
        
        uint256 balanceBefore= cryptobank.balanceUserEth(user1);
        (bool success,)=address(cryptobank).call{value: amountDeposit}("");
        require(success);
        uint256 balanceAfter= cryptobank.balanceUserEth(user1);

        assert(balanceAfter - balanceBefore == amountDeposit);

        uint256 balanceBefore2 = cryptobank.balanceUserEth(user1);
        cryptobank.withrawETH(user1,amountWithraw);
        uint256 balanceAfter2= cryptobank.balanceUserEth(user1);

        assert(balanceBefore2 - balanceAfter2 == amountWithraw);



        vm.stopPrank();
    
    }


    function testDepositUsdcExcededLimit() external {

        uint256 amount=10100e6;

        vm.startPrank(user1);
        vm.deal(user1,amount);

        vm.expectRevert("Exceded amount per transaction");
        cryptobank.depositUsdc(amount);

        vm.stopPrank();
    }



    function testDepositUsdcCorrectLimit() external {
        uint256 amount=9800e6;
        address usdc = 0x86E721b43d4ECFa71119Dd38c0f938A75Fdb57B3;
        deal(usdc,user1,amount);
        vm.startPrank(user1);
        
        IERC20(usdc).approve(address(cryptobank),amount);



        
        uint256 balanceBefore= cryptobank.balanceUserUsdc(user1);
        cryptobank.depositUsdc(amount);
        uint256 balanceAfter= cryptobank.balanceUserUsdc(user1);


        assert(balanceAfter - balanceBefore == amount);

        vm.stopPrank();

    }

    function testWithrawUsdcIncorrectAmount() external {
        uint256 amountDesposit= 5000e6;
        uint256 amountWithraw = 5100e6;
        address usdc = 0x86E721b43d4ECFa71119Dd38c0f938A75Fdb57B3;

        deal(usdc,user1,amountDesposit);
        vm.startPrank(user1);
        
        IERC20(usdc).approve(address(cryptobank),amountDesposit);

        uint256 balanceBefore= cryptobank.balanceUserUsdc(user1);
        cryptobank.depositUsdc(amountDesposit);
        uint256 balanceAfter= cryptobank.balanceUserUsdc(user1);

        assert(balanceAfter - balanceBefore == amountDesposit);

        vm.expectRevert("Incorrect Amount");
        cryptobank.withrawUsdc(amountWithraw);


        vm.stopPrank();

    }


    function testWithrawUsdcCorrectAmount() external {
        
        uint256 amountDesposit= 5000e6;
        uint256 amountWithraw = 4900e6;
        address usdc = 0x86E721b43d4ECFa71119Dd38c0f938A75Fdb57B3;

        deal(usdc,user1,amountDesposit);
        vm.startPrank(user1);
        
        IERC20(usdc).approve(address(cryptobank),amountDesposit);

        uint256 balanceBefore= cryptobank.balanceUserUsdc(user1);
        cryptobank.depositUsdc(amountDesposit);
        uint256 balanceAfter= cryptobank.balanceUserUsdc(user1);

        assert(balanceAfter - balanceBefore == amountDesposit);

        uint256 balanceBefore2= cryptobank.balanceUserUsdc(user1);
        cryptobank.withrawUsdc(amountWithraw);
        uint256 balanceAfter2 = cryptobank.balanceUserUsdc(user1);

        assert(balanceAfter2 + amountWithraw == balanceBefore2);

        vm.stopPrank();

    }

    function testSetMaxBalanceEthRandomUser() external {
        uint256 newBalance= 12e18;
        
        vm.startPrank(user1);

        vm.expectRevert("User is not Admin");
        cryptobank.setMaxBalanceEth(newBalance);

        
        vm.stopPrank();
    }

    function testSetMaxBalanceEthAdmin() external {
        uint256 newBalance= 12e18;
        
        vm.startPrank(admin);

        
        cryptobank.setMaxBalanceEth(newBalance);
        uint256 maxBalanceETH =cryptobank.maxBalanceUserEth();
        assert(maxBalanceETH == newBalance);
        
        vm.stopPrank();
    }


    function testSetMaxBalanceUsdcRandomUser() external {
        uint256 newBalance = 20000e6;

        vm.startPrank(user1);

        vm.expectRevert("User is not Admin");
        cryptobank.setMaxBalanceUsdc(newBalance);

        vm.stopPrank();
    }

    function testSetMaxBalanceUsdcAdmin() external {
        uint256 newBalance = 20000e6;

        vm.startPrank(admin);

        
        cryptobank.setMaxBalanceUsdc(newBalance);
        uint256 maxBalanceUserUsdc=cryptobank.maxBalanceUserUsdc();

        assert(maxBalanceUserUsdc == newBalance);

        vm.stopPrank();
    }

    function testSetMaxDepositEthRandomUser() external {
        uint256 newMaxDeposit = 5e18;

        vm.startPrank(user1);

        vm.expectRevert("User is not Admin");
        cryptobank.setMaxDepositEth(newMaxDeposit);


        vm.stopPrank();

    }

        function testSetMaxDepositEthAdmin() external {
        uint256 newMaxDeposit = 5e18;

        vm.startPrank(admin);

        uint256 maxDepositEthBefore= cryptobank.depositLimitEth();
        cryptobank.setMaxDepositEth(newMaxDeposit);
        uint256 maxDepositEthAfter= cryptobank.depositLimitEth();

        assert(maxDepositEthAfter == newMaxDeposit);


        vm.stopPrank();

    }


    function testSetMaxDepositUsdcRandomUser() external {
        uint256 newMaxDepositUsdc = 12000e6;

        vm.startPrank(user1);

        vm.expectRevert("User is not Admin");
        cryptobank.setMaxDepostiUsdc(newMaxDepositUsdc);

        vm.stopPrank();
    }

        function testSetMaxDepositUsdcAdmin() external {
        uint256 newMaxDepositUsdc = 12000e6;

        vm.startPrank(admin);

        uint256 limitDepositUsdcBefore= cryptobank.depositLimitUsdc();
        cryptobank.setMaxDepostiUsdc(newMaxDepositUsdc);
        uint256 limitDepositUsdcAfter= cryptobank.depositLimitUsdc();

        assert(limitDepositUsdcAfter == newMaxDepositUsdc);

        vm.stopPrank();
    }
}