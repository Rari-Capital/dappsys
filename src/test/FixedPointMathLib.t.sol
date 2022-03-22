// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {FixedPointMathLib} from "../utils/FixedPointMathLib.sol";

contract FixedPointMathLibTest is DSTestPlus {
    function testExpWadDown() public {
        assertEq(FixedPointMathLib.expWadDown(-42139678854452767551), 0);

        assertEq(FixedPointMathLib.expWadDown(-3e18), 49787068367863942);
        assertEq(FixedPointMathLib.expWadDown(-2e18), 135335283236612691);
        assertEq(FixedPointMathLib.expWadDown(-1e18), 367879441171442321);

        assertEq(FixedPointMathLib.expWadDown(-0.5e18), 606530659712633423);
        assertEq(FixedPointMathLib.expWadDown(-0.3e18), 740818220681717866);

        assertEq(
            FixedPointMathLib.expWadDown(0),
            999999999999999999
            // True value: 1000000000000000000 (off by 1 wei)
        );

        assertEq(FixedPointMathLib.expWadDown(0.3e18), 1349858807576003103);
        assertEq(FixedPointMathLib.expWadDown(0.5e18), 1648721270700128146);

        assertEq(FixedPointMathLib.expWadDown(1e18), 2718281828459045235);
        assertEq(FixedPointMathLib.expWadDown(2e18), 7389056098930650227);
        assertEq(FixedPointMathLib.expWadDown(3e18), 20085536923187667740);

        assertEq(
            FixedPointMathLib.expWadDown(10e18),
            22026465794806716516_861
            // True value: 22026465794806716516_957 (21 digits of precision)
        );

        assertEq(
            FixedPointMathLib.expWadDown(50e18),
            5184705528587072464_117909654408922782335
            // True value: 5184705528587072464_087453322933485384827 (19 digits of precision)
        );

        assertEq(
            FixedPointMathLib.expWadDown(100e18),
            2688117141816135448_3982463551405023462056137701762092799015183
            // True value: 2688117141816135448_4126255515800135873611118773741922415191608 (20 digits of precision)
        );

        assertEq(
            FixedPointMathLib.expWadDown(135305999368893231588),
            578960446186580976498_09650847705537384645150747719143657509713249170749644355
            // True value: 578960446186580976498_16762928942336782129491980154662247847962410455084893091 (21 digits of precision)
        );
    }

    function testMulWadDown() public {
        assertEq(FixedPointMathLib.mulWadDown(2.5e18, 0.5e18), 1.25e18);
        assertEq(FixedPointMathLib.mulWadDown(3e18, 1e18), 3e18);
        assertEq(FixedPointMathLib.mulWadDown(369, 271), 0);
    }

    function testMulWadDownEdgeCases() public {
        assertEq(FixedPointMathLib.mulWadDown(0, 1e18), 0);
        assertEq(FixedPointMathLib.mulWadDown(1e18, 0), 0);
        assertEq(FixedPointMathLib.mulWadDown(0, 0), 0);
    }

    function testMulWadUp() public {
        assertEq(FixedPointMathLib.mulWadUp(2.5e18, 0.5e18), 1.25e18);
        assertEq(FixedPointMathLib.mulWadUp(3e18, 1e18), 3e18);
        assertEq(FixedPointMathLib.mulWadUp(369, 271), 1);
    }

    function testMulWadUpEdgeCases() public {
        assertEq(FixedPointMathLib.mulWadUp(0, 1e18), 0);
        assertEq(FixedPointMathLib.mulWadUp(1e18, 0), 0);
        assertEq(FixedPointMathLib.mulWadUp(0, 0), 0);
    }

    function testDivWadDown() public {
        assertEq(FixedPointMathLib.divWadDown(1.25e18, 0.5e18), 2.5e18);
        assertEq(FixedPointMathLib.divWadDown(3e18, 1e18), 3e18);
        assertEq(FixedPointMathLib.divWadDown(2, 100000000000000e18), 0);
    }

    function testDivWadDownEdgeCases() public {
        assertEq(FixedPointMathLib.divWadDown(0, 1e18), 0);
    }

    function testFailDivWadDownZeroDenominator() public pure {
        FixedPointMathLib.divWadDown(1e18, 0);
    }

    function testDivWadUp() public {
        assertEq(FixedPointMathLib.divWadUp(1.25e18, 0.5e18), 2.5e18);
        assertEq(FixedPointMathLib.divWadUp(3e18, 1e18), 3e18);
        assertEq(FixedPointMathLib.divWadUp(2, 100000000000000e18), 1);
    }

    function testDivWadUpEdgeCases() public {
        assertEq(FixedPointMathLib.divWadUp(0, 1e18), 0);
    }

    function testFailDivWadUpZeroDenominator() public pure {
        FixedPointMathLib.divWadUp(1e18, 0);
    }

    function testMulDivDown() public {
        assertEq(FixedPointMathLib.mulDivDown(2.5e27, 0.5e27, 1e27), 1.25e27);
        assertEq(FixedPointMathLib.mulDivDown(2.5e18, 0.5e18, 1e18), 1.25e18);
        assertEq(FixedPointMathLib.mulDivDown(2.5e8, 0.5e8, 1e8), 1.25e8);
        assertEq(FixedPointMathLib.mulDivDown(369, 271, 1e2), 999);

        assertEq(FixedPointMathLib.mulDivDown(1e27, 1e27, 2e27), 0.5e27);
        assertEq(FixedPointMathLib.mulDivDown(1e18, 1e18, 2e18), 0.5e18);
        assertEq(FixedPointMathLib.mulDivDown(1e8, 1e8, 2e8), 0.5e8);

        assertEq(FixedPointMathLib.mulDivDown(2e27, 3e27, 2e27), 3e27);
        assertEq(FixedPointMathLib.mulDivDown(3e18, 2e18, 3e18), 2e18);
        assertEq(FixedPointMathLib.mulDivDown(2e8, 3e8, 2e8), 3e8);
    }

    function testMulDivDownEdgeCases() public {
        assertEq(FixedPointMathLib.mulDivDown(0, 1e18, 1e18), 0);
        assertEq(FixedPointMathLib.mulDivDown(1e18, 0, 1e18), 0);
        assertEq(FixedPointMathLib.mulDivDown(0, 0, 1e18), 0);
    }

    function testFailMulDivDownZeroDenominator() public pure {
        FixedPointMathLib.mulDivDown(1e18, 1e18, 0);
    }

    function testMulDivUp() public {
        assertEq(FixedPointMathLib.mulDivUp(2.5e27, 0.5e27, 1e27), 1.25e27);
        assertEq(FixedPointMathLib.mulDivUp(2.5e18, 0.5e18, 1e18), 1.25e18);
        assertEq(FixedPointMathLib.mulDivUp(2.5e8, 0.5e8, 1e8), 1.25e8);
        assertEq(FixedPointMathLib.mulDivUp(369, 271, 1e2), 1000);

        assertEq(FixedPointMathLib.mulDivUp(1e27, 1e27, 2e27), 0.5e27);
        assertEq(FixedPointMathLib.mulDivUp(1e18, 1e18, 2e18), 0.5e18);
        assertEq(FixedPointMathLib.mulDivUp(1e8, 1e8, 2e8), 0.5e8);

        assertEq(FixedPointMathLib.mulDivUp(2e27, 3e27, 2e27), 3e27);
        assertEq(FixedPointMathLib.mulDivUp(3e18, 2e18, 3e18), 2e18);
        assertEq(FixedPointMathLib.mulDivUp(2e8, 3e8, 2e8), 3e8);
    }

    function testMulDivUpEdgeCases() public {
        assertEq(FixedPointMathLib.mulDivUp(0, 1e18, 1e18), 0);
        assertEq(FixedPointMathLib.mulDivUp(1e18, 0, 1e18), 0);
        assertEq(FixedPointMathLib.mulDivUp(0, 0, 1e18), 0);
    }

    function testFailMulDivUpZeroDenominator() public pure {
        FixedPointMathLib.mulDivUp(1e18, 1e18, 0);
    }

    function testRPow() public {
        assertEq(FixedPointMathLib.rpow(2e27, 2, 1e27), 4e27);
        assertEq(FixedPointMathLib.rpow(2e18, 2, 1e18), 4e18);
        assertEq(FixedPointMathLib.rpow(2e8, 2, 1e8), 4e8);
        assertEq(FixedPointMathLib.rpow(8, 3, 1), 512);
    }

    function testSqrt() public {
        assertEq(FixedPointMathLib.sqrt(0), 0);
        assertEq(FixedPointMathLib.sqrt(1), 1);
        assertEq(FixedPointMathLib.sqrt(2704), 52);
        assertEq(FixedPointMathLib.sqrt(110889), 333);
        assertEq(FixedPointMathLib.sqrt(32239684), 5678);
    }

    function testMulWadDown(uint256 x, uint256 y) public {
        // Ignore cases where x * y overflows.
        unchecked {
            if ((x != 0 && (x * y) / x != y)) return;
        }

        assertEq(FixedPointMathLib.mulWadDown(x, y), (x * y) / 1e18);
    }

    function testFailMulWadDownOverflow(uint256 x, uint256 y) public pure {
        // Ignore cases where x * y does not overflow.
        unchecked {
            if ((x * y) / x == y) revert();
        }

        FixedPointMathLib.mulWadDown(x, y);
    }

    function testMulWadUp(uint256 x, uint256 y) public {
        // Ignore cases where x * y overflows.
        unchecked {
            if ((x != 0 && (x * y) / x != y)) return;
        }

        assertEq(FixedPointMathLib.mulWadUp(x, y), x * y == 0 ? 0 : (x * y - 1) / 1e18 + 1);
    }

    function testFailMulWadUpOverflow(uint256 x, uint256 y) public pure {
        // Ignore cases where x * y does not overflow.
        unchecked {
            if ((x * y) / x == y) revert();
        }

        FixedPointMathLib.mulWadUp(x, y);
    }

    function testDivWadDown(uint256 x, uint256 y) public {
        // Ignore cases where x * WAD overflows or y is 0.
        unchecked {
            if (y == 0 || (x != 0 && (x * 1e18) / 1e18 != x)) return;
        }

        assertEq(FixedPointMathLib.divWadDown(x, y), (x * 1e18) / y);
    }

    function testFailDivWadDownOverflow(uint256 x, uint256 y) public pure {
        // Ignore cases where x * WAD does not overflow or y is 0.
        unchecked {
            if (y == 0 || (x * 1e18) / 1e18 == x) revert();
        }

        FixedPointMathLib.divWadDown(x, y);
    }

    function testFailDivWadDownZeroDenominator(uint256 x) public pure {
        FixedPointMathLib.divWadDown(x, 0);
    }

    function testDivWadUp(uint256 x, uint256 y) public {
        // Ignore cases where x * WAD overflows or y is 0.
        unchecked {
            if (y == 0 || (x != 0 && (x * 1e18) / 1e18 != x)) return;
        }

        assertEq(FixedPointMathLib.divWadUp(x, y), x == 0 ? 0 : (x * 1e18 - 1) / y + 1);
    }

    function testFailDivWadUpOverflow(uint256 x, uint256 y) public pure {
        // Ignore cases where x * WAD does not overflow or y is 0.
        unchecked {
            if (y == 0 || (x * 1e18) / 1e18 == x) revert();
        }

        FixedPointMathLib.divWadUp(x, y);
    }

    function testFailDivWadUpZeroDenominator(uint256 x) public pure {
        FixedPointMathLib.divWadUp(x, 0);
    }

    function testMulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) public {
        // Ignore cases where x * y overflows or denominator is 0.
        unchecked {
            if (denominator == 0 || (x != 0 && (x * y) / x != y)) return;
        }

        assertEq(FixedPointMathLib.mulDivDown(x, y, denominator), (x * y) / denominator);
    }

    function testFailMulDivDownOverflow(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) public pure {
        // Ignore cases where x * y does not overflow or denominator is 0.
        unchecked {
            if (denominator == 0 || (x * y) / x == y) revert();
        }

        FixedPointMathLib.mulDivDown(x, y, denominator);
    }

    function testFailMulDivDownZeroDenominator(uint256 x, uint256 y) public pure {
        FixedPointMathLib.mulDivDown(x, y, 0);
    }

    function testMulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) public {
        // Ignore cases where x * y overflows or denominator is 0.
        unchecked {
            if (denominator == 0 || (x != 0 && (x * y) / x != y)) return;
        }

        assertEq(FixedPointMathLib.mulDivUp(x, y, denominator), x * y == 0 ? 0 : (x * y - 1) / denominator + 1);
    }

    function testFailMulDivUpOverflow(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) public pure {
        // Ignore cases where x * y does not overflow or denominator is 0.
        unchecked {
            if (denominator == 0 || (x * y) / x == y) revert();
        }

        FixedPointMathLib.mulDivUp(x, y, denominator);
    }

    function testFailMulDivUpZeroDenominator(uint256 x, uint256 y) public pure {
        FixedPointMathLib.mulDivUp(x, y, 0);
    }

    function testSqrt(uint256 x) public {
        uint256 root = FixedPointMathLib.sqrt(x);
        uint256 next = root + 1;

        // Ignore cases where next * next overflows.
        unchecked {
            if (next * next < next) return;
        }

        assertTrue(root * root <= x && next * next > x);
    }
}
