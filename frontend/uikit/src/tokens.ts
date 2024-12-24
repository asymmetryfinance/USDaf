import type { Token } from "./types";

import tokenBold from "./token-icons/bold.svg";
import tokenEth from "./token-icons/eth.svg";
import tokenLqty from "./token-icons/lqty.svg";
import tokenLusd from "./token-icons/lusd.svg";
import tokenReth from "./token-icons/reth.svg";
import tokenSpot from "./token-icons/spot.svg";
import tokenUsdaf from "./token-icons/usdaf.svg";
import tokenSteth from "./token-icons/wsteth.svg";

export type CollateralSymbol = "ETH" | "SPOT" | "RETH" | "WSTETH";

export function isCollateralSymbol(symbol: string): symbol is CollateralSymbol {
  return symbol === "ETH" || symbol === "SPOT" || symbol === "RETH" || symbol === "WSTETH";
}

export type CollateralToken = Token & {
  collateralRatio: number;
  symbol: CollateralSymbol;
};

export const LUSD: Token = {
  icon: tokenLusd,
  name: "LUSD",
  symbol: "LUSD" as const,
} as const;

export const USDAF: Token = {
  icon: tokenUsdaf,
  name: "USDaf",
  symbol: "USDAF" as const,
} as const;

export const BOLD: Token = {
  icon: tokenBold,
  name: "BOLD",
  symbol: "BOLD" as const,
} as const;

export const LQTY: Token = {
  icon: tokenLqty,
  name: "LQTY",
  symbol: "LQTY" as const,
} as const;

export const ETH: CollateralToken = {
  collateralRatio: 1.1,
  icon: tokenEth,
  name: "ETH",
  symbol: "ETH" as const,
} as const;

export const RETH: CollateralToken = {
  collateralRatio: 1.2,
  icon: tokenReth,
  name: "rETH",
  symbol: "RETH" as const,
} as const;

export const WSTETH: CollateralToken = {
  collateralRatio: 1.2,
  icon: tokenSteth,
  name: "wstETH",
  symbol: "WSTETH" as const,
} as const;

export const SPOT: CollateralToken = {
  collateralRatio: 1.2,
  icon: tokenSpot,
  name: "SPOT",
  symbol: "SPOT" as const,
} as const;

export const COLLATERALS: CollateralToken[] = [
  ETH,
  SPOT,
  RETH,
  WSTETH,
];

export const TOKENS_BY_SYMBOL = {
  BOLD,
  SPOT,
  ETH,
  LQTY,
  RETH,
  WSTETH,
  LUSD,
  USDAF,
} as const;
