// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC20} from "./utils/mocks/MockERC20.sol";
import {MockERC4626} from "./utils/mocks/MockERC4626.sol";
import {ERC4626User} from "./utils/users/ERC4626User.sol";

// NOTE: dapp test -m ':ERC4626Test\.'
// NOTE: dapp test -m ':ERC4626Test\.testMultipleAtomicDepositWithdraw'

// TODO: verify hooks are being called
contract ERC4626Test is DSTestPlus {
    MockERC4626 vault;
    MockERC20 underlying;

    function setUp() public {
        underlying = new MockERC20("Mock Token", "TKN", 18);
        vault = new MockERC4626(underlying, "Mock Token Vault", "vwTKN");
    }

    function invariantMetadata() public {
        assertEq(vault.name(), "Mock Token Vault");
        assertEq(vault.symbol(), "vwTKN");
        assertEq(vault.decimals(), 18);
    }

    function testMetaData() public {
        assertEq(vault.name(), "Mock Token Vault");
        assertEq(vault.symbol(), "vwTKN");
        assertEq(vault.decimals(), 18);
    }

    /*///////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL TESTS
    //////////////////////////////////////////////////////////////*/

    function testSingleAtomicDepositWithdraw() public {
        // TODO: make amount fuzzable, currently appears to overflow
        uint256 underlyingAmount = 2e18;

        underlying.mint(address(this), underlyingAmount);
        underlying.approve(address(vault), underlyingAmount);

        uint256 preDepositBal = underlying.balanceOf(address(this));

        uint256 shareAmount = vault.deposit(address(this), underlyingAmount);
        assertEq(vault.calculateUnderlying(shareAmount), underlyingAmount);
        assertEq(vault.calculateShares(underlyingAmount), shareAmount);

        assertEq(vault.totalHoldings(), underlyingAmount);
        assertEq(vault.balanceOf(address(this)), underlyingAmount);
        assertEq(vault.balanceOfUnderlying(address(this)), underlyingAmount);
        assertEq(underlying.balanceOf(address(this)), preDepositBal - underlyingAmount);

        vault.withdraw(address(this), address(this), underlyingAmount);

        assertEq(vault.totalHoldings(), 0);
        assertEq(vault.balanceOf(address(this)), 0);
        assertEq(vault.balanceOfUnderlying(address(this)), 0);
        assertEq(underlying.balanceOf(address(this)), preDepositBal);
    }

    function testSingleAtomicMintWithdraw() public {
        // TODO: make amount fuzzable, currently appears to overflow
        uint256 shareAmount = 2e18;

        underlying.mint(address(this), shareAmount);
        underlying.approve(address(vault), shareAmount);

        uint256 preDepositBal = vault.calculateUnderlying(underlying.balanceOf(address(this)));

        uint256 underlyingAmount = vault.mint(address(this), shareAmount);
        assertEq(vault.calculateUnderlying(shareAmount), underlyingAmount);
        assertEq(vault.calculateShares(underlyingAmount), shareAmount);

        assertEq(vault.totalHoldings(), underlyingAmount);
        assertEq(vault.balanceOf(address(this)), underlyingAmount);
        assertEq(vault.balanceOfUnderlying(address(this)), underlyingAmount);
        assertEq(underlying.balanceOf(address(this)), preDepositBal - underlyingAmount);

        vault.withdraw(address(this), address(this), underlyingAmount);

        assertEq(vault.totalHoldings(), 0);
        assertEq(vault.balanceOf(address(this)), 0);
        assertEq(vault.balanceOfUnderlying(address(this)), 0);
        assertEq(underlying.balanceOf(address(this)), preDepositBal);
    }

    function testMultipleAtomicDepositWithdraw() public {
        ERC4626User alice = new ERC4626User(vault, underlying);
        ERC4626User bob = new ERC4626User(vault, underlying);

        uint256 aliceUnderlyingAmount = 2e18;
        uint256 bobUnderlyingAmount = 3e18;

        underlying.mint(address(alice), aliceUnderlyingAmount);
        alice.approve(address(vault), aliceUnderlyingAmount);

        underlying.mint(address(bob), bobUnderlyingAmount);
        bob.approve(address(vault), bobUnderlyingAmount);

        uint256 alicePreDepositBal = underlying.balanceOf(address(alice));
        uint256 bobPreDepositBal = underlying.balanceOf(address(bob));

        assertEq(alicePreDepositBal, aliceUnderlyingAmount);
        assertEq(bobPreDepositBal, bobUnderlyingAmount);
        assertEq(underlying.allowance(address(alice), address(vault)), aliceUnderlyingAmount);
        assertEq(underlying.allowance(address(bob), address(vault)), bobUnderlyingAmount);

        uint256 aliceShareAmount = alice.deposit(address(alice), aliceUnderlyingAmount);
        assertEq(vault.calculateUnderlying(aliceShareAmount), aliceUnderlyingAmount);
        assertEq(vault.calculateShares(aliceUnderlyingAmount), aliceShareAmount);

        assertEq(vault.totalHoldings(), aliceUnderlyingAmount);
        assertEq(vault.balanceOf(address(alice)), aliceUnderlyingAmount);
        assertEq(vault.balanceOfUnderlying(address(alice)), aliceUnderlyingAmount);
        assertEq(underlying.balanceOf(address(alice)), alicePreDepositBal - aliceUnderlyingAmount);

        uint256 bobShareAmount = bob.deposit(address(bob), bobUnderlyingAmount);
        assertEq(vault.calculateUnderlying(bobShareAmount), bobUnderlyingAmount);
        assertEq(vault.calculateShares(bobUnderlyingAmount), bobShareAmount);

        assertEq(vault.totalHoldings(), aliceUnderlyingAmount + bobUnderlyingAmount);
        assertEq(vault.balanceOf(address(bob)), bobUnderlyingAmount);
        assertEq(vault.balanceOfUnderlying(address(bob)), bobUnderlyingAmount);
        assertEq(underlying.balanceOf(address(bob)), bobPreDepositBal - bobUnderlyingAmount);

        alice.withdraw(address(alice), address(alice), aliceUnderlyingAmount);

        assertEq(vault.totalHoldings(), bobUnderlyingAmount);
        assertEq(vault.balanceOf(address(alice)), 0);
        assertEq(vault.balanceOfUnderlying(address(alice)), 0);
        assertEq(underlying.balanceOf(address(alice)), alicePreDepositBal);

        bob.withdraw(address(bob), address(bob), bobUnderlyingAmount);

        assertEq(vault.totalHoldings(), 0);
        assertEq(vault.balanceOf(address(bob)), 0);
        assertEq(vault.balanceOfUnderlying(address(bob)), 0);
        assertEq(underlying.balanceOf(address(bob)), bobPreDepositBal);
    }

    function testSingleAtomicDepositRedeem() public {
        // TODO: make amount fuzzable, currently appears to overflow
        uint256 underlyingAmount = 2e18;

        underlying.mint(address(this), underlyingAmount);
        underlying.approve(address(vault), underlyingAmount);

        uint256 preDepositBal = underlying.balanceOf(address(this));

        uint256 shareAmount = vault.deposit(address(this), underlyingAmount);
        assertEq(vault.calculateUnderlying(shareAmount), underlyingAmount);
        assertEq(vault.calculateShares(underlyingAmount), shareAmount);

        assertEq(vault.totalHoldings(), underlyingAmount);
        assertEq(vault.balanceOf(address(this)), underlyingAmount);
        assertEq(vault.balanceOfUnderlying(address(this)), underlyingAmount);
        assertEq(underlying.balanceOf(address(this)), preDepositBal - underlyingAmount);

        vault.redeem(address(this), address(this), underlyingAmount);

        assertEq(vault.totalHoldings(), 0);
        assertEq(vault.balanceOf(address(this)), 0);
        assertEq(vault.balanceOfUnderlying(address(this)), 0);
        assertEq(underlying.balanceOf(address(this)), preDepositBal);
    }

    /*///////////////////////////////////////////////////////////////
                 DEPOSIT/WITHDRAWAL SANITY CHECK TESTS
    //////////////////////////////////////////////////////////////*/

    function testFailDepositWithNotEnoughApproval() public {
        underlying.mint(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);
        assertEq(underlying.allowance(address(this), address(vault)), 0.5e18);

        vault.deposit(address(this), 1e18);
    }

    function testFailWithdrawWithNotEnoughBalance() public {
        underlying.mint(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);

        vault.deposit(address(this), 0.5e18);

        vault.withdraw(address(this), address(this), 1e18);
    }

    function testFailRedeemWithNotEnoughBalance() public {
        underlying.mint(address(this), 0.5e18);
        underlying.approve(address(vault), 0.5e18);

        vault.deposit(address(this), 0.5e18);

        vault.redeem(address(this), address(this), 1e18);
    }

    function testFailRedeemWithNoBalance() public {
        vault.redeem(address(this), address(this), 1e18);
    }

    function testFailWithdrawWithNoBalance() public {
        vault.withdraw(address(this), address(this), 1e18);
    }

    function testFailDepositWithNoApproval() public {
        vault.deposit(address(this), 1e18);
    }
}
