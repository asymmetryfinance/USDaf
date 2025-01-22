"use client";

import type { CollateralSymbol } from "@/src/types";

import { Amount } from "@/src/comps/Amount/Amount";
import { Positions } from "@/src/comps/Positions/Positions";
import { SUSDafBanner } from "@/src/screens/HomeScreen/SUSDafBanner"; // Importing the SUSDafBanner component
import { getContracts } from "@/src/contracts";
import { DNUM_1 } from "@/src/dnum-utils";
import {
  getCollIndexFromSymbol,
  getCollToken,
  useAverageInterestRate,
  useEarnPool,
} from "@/src/liquity-utils";
import { useAccount } from "@/src/services/Ethereum";
import { css } from "@/styled-system/css";
import {
  AnchorTextButton,
  IconBorrow,
  IconEarn,
  TokenIcon,
} from "@liquity2/uikit";
import * as dn from "dnum";
import Link from "next/link";
import { HomeTable } from "./HomeTable";

export function HomeScreen() {
  const account = useAccount();

  const { collaterals } = getContracts();
  const collSymbols = collaterals.map((coll) => coll.symbol);

  return (
    <div
      className={css({
        flexGrow: 1,
        display: "flex",
        flexDirection: "column",
        gap: 64,
        width: "100%",
      })}
    >
      {/* Render the Positions component */}
      <Positions address={account.address ?? null} />

      {/* Borrow and Earn Rewards Section */}
      <div
        className={css({
          display: "grid",
          gap: 24,
          gridTemplateColumns: "1fr 1fr", // Two-column layout
        })}
      >
        {/* Borrow Table */}
        <HomeTable
          title="Borrow USDaf"
          subtitle="You can adjust your loans, including your interest rate, at any time"
          icon={<IconBorrow />}
          columns={["Collateral", "Avg rate, p.a.", "Max LTV", null] as const}
          rows={collSymbols.map((symbol) => (
            <BorrowingRow
              key={symbol}
              symbol={symbol} // Passing the symbol prop
            />
          ))}
        />

        {/* Earn Table with Banner */}
        <HomeTable
          title="Earn rewards with BOLD"
          subtitle="Earn BOLD & (staked) ETH rewards by putting your BOLD in a stability pool"
          icon={<IconEarn />}
          columns={["Pool", "Current APR", "Pool size", null] as const}
          rows={[
            // Add the SUSDafBanner as a table row above the EarnRewardsRows
            <tr key="banner">
              <td colSpan={4}>
                <SUSDafBanner
                  apy="21.69%" // Set default APY value
                  onEarnClick={() => {
                    console.log("Earn button clicked!"); // Handle Earn button clicks
                  }}
                />
              </td>
            </tr>,
            // Map over the collSymbols array to render EarnRewardsRow components
            ...collSymbols.map((symbol) => (
              <EarnRewardsRow key={symbol} symbol={symbol} />
            )),
          ]}
        />
      </div>
    </div>
  );
}

// BorrowingRow Component - Handles Borrow Table Rows
function BorrowingRow({
  symbol,
}: {
  symbol: CollateralSymbol;
}) {
  const collIndex = getCollIndexFromSymbol(symbol); // Fetch collateral index by symbol
  const collateral = getCollToken(collIndex); // Retrieve collateral token details
  const avgInterestRate = useAverageInterestRate(collIndex); // Fetch average interest rate

  const maxLtv =
    collateral?.collateralRatio && dn.gt(collateral.collateralRatio, 0)
      ? dn.div(DNUM_1, collateral.collateralRatio) // Calculate max LTV
      : null;

  return (
    <tr>
      <td>
        <div
          className={css({
            display: "flex",
            alignItems: "center",
            gap: 8,
          })}
        >
          <TokenIcon symbol={symbol} size="mini" /> {/* Display token icon */}
          <span>{collateral?.name}</span> {/* Show collateral name */}
        </div>
      </td>
      <td>
        <Amount
          fallback="…" // Fallback value while loading
          percentage
          value={avgInterestRate.data} // Display percentage value
        />
      </td>
      <td>
        <Amount value={maxLtv} percentage /> {/* Show max LTV */}
      </td>
      <td>
        <div
          className={css({
            display: "flex",
            gap: 8,
            justifyContent: "flex-end", // Align buttons to the right
          })}
        >
          {/* Borrow button */}
          <Link
            href={`/borrow/${symbol.toLowerCase()}`}
            legacyBehavior
            passHref
          >
            <AnchorTextButton
              label={
                <div
                  className={css({
                    display: "flex",
                    alignItems: "center",
                    gap: 8,
                    fontSize: 14,
                  })}
                >
                  Borrow
                  <TokenIcon symbol="BOLD" size="mini" /> {/* Icon next to Borrow */}
                </div>
              }
              title={`Borrow ${collateral?.name} from ${symbol}`} // Tooltip for Borrow button
            />
          </Link>
          {
            /* Commented out Leverage button for future use */
            /* <Link
            href={`/leverage/${symbol.toLowerCase()}`}
            legacyBehavior
            passHref
          >
            <AnchorTextButton
              label={
                <div
                  className={css({
                    display: "flex",
                    alignItems: "center",
                    gap: 8,
                    fontSize: 14,
                  })}
                >
                  Leverage
                  <TokenIcon symbol={symbol} size="mini" />
                </div>
              }
              title={`Leverage ${collateral?.name} from ${symbol}`}
            />
          </Link> */
          }
        </div>
      </td>
    </tr>
  );
}

// EarnRewardsRow Component - Handles Earn Table Rows
function EarnRewardsRow({
  symbol,
}: {
  symbol: CollateralSymbol;
}) {
  const collIndex = getCollIndexFromSymbol(symbol); // Fetch collateral index by symbol
  const collateral = getCollToken(collIndex); // Retrieve collateral token details
  const earnPool = useEarnPool(collIndex); // Fetch earn pool data

  return (
    <tr>
      <td>
        <div
          className={css({
            display: "flex",
            alignItems: "center",
            gap: 8,
          })}
        >
          <TokenIcon symbol={symbol} size="mini" /> {/* Display token icon */}
          <span>{collateral?.name}</span> {/* Show collateral name */}
        </div>
      </td>
      <td>
        <Amount
          fallback="…" // Fallback value while loading
          percentage
          value={earnPool.data?.apr} // Display APR
        />
      </td>
      <td>
        <Amount
          fallback="…" // Fallback value while loading
          format="compact"
          prefix="$"
          value={earnPool.data?.totalDeposited} // Display total deposited amount
        />
      </td>
      <td>
        {/* Earn button */}
        <Link
          href={`/earn/${symbol.toLowerCase()}`}
          legacyBehavior
          passHref
        >
          <AnchorTextButton
            label={
              <div
                className={css({
                  display: "flex",
                  alignItems: "center",
                  gap: 8,
                  fontSize: 14,
                })}
              >
                Earn
                <TokenIcon.Group size="mini">
                  <TokenIcon symbol="BOLD" />
                  <TokenIcon symbol={symbol} />
                </TokenIcon.Group> {/* Grouped icons */}
              </div>
            }
            title={`Earn USDaf with ${collateral?.name}`} // Tooltip for Earn button
          />
        </Link>
      </td>
    </tr>
  );
}
