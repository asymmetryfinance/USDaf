export function generateStaticParams() {
  return [
    { collateral: "eth" },
    { collateral: "reth" },
    { collateral: "wsteth" },
    { collateral: "spot" },
  ];
}

export default function LeverageCollateralPage() {
  // see layout in parent folder
  return null;
}
