"use client";

import React from "react";
import { css } from "@/styled-system/css";
import { keyframes } from "@emotion/react";
import { MagicCard } from "./MagicCard";
import { TokenIcon } from "@liquity2/uikit";
import ASFLines from "./ASFLines";

interface SUSDafBannerProps {
  apy?: string;
  onEarnClick?: () => void;
}

const moveLines = keyframes`
  0% {
    transform: translateX(0);
  }
  100% {
    transform: translateX(-50%);
  }
`;

export const SUSDafBanner: React.FC<SUSDafBannerProps> = ({
  apy = "21.69%",
  onEarnClick,
}) => {
  return (
    <MagicCard
      backgroundColor="#036eee"
      className={css({
        position: "relative",
        width: "100%",
        maxWidth: "610px",
        padding: "0",
        display: "flex",
        overflow: "hidden",
        borderRadius: "16px",
        border: "1px solid #033674",
        backgroundImage: "linear-gradient(90deg, #80bfff 0%, #0047b3 100%)",
      })}
    >
      {/* Animated Background Lines */}
      <div
        className={css({
          position: "absolute",
          top: 0,
          left: 0,
          width: "200%",
          height: "100%",
          display: "flex",
          animation: `${moveLines} 15s linear infinite`,
          zIndex: 0,
          pointerEvents: "none",
          background:
            "radial-gradient(circle, rgba(52, 133, 255, 0.1) 0%, rgba(28, 91, 150, 0) 70%)",
        })}
      >
        <ASFLines
          className={css({
            flexShrink: 0,
            width: "800px",
            height: "100%",
          })}
        />
        <ASFLines
          className={css({
            flexShrink: 0,
            width: "800px",
            height: "100%",
          })}
        />
      </div>

      {/* Main Content Container */}
      <div
        className={css({
          position: "relative",
          zIndex: 1,
          display: "flex",
          flexDirection: "row", // Horizontal layout on desktop
          alignItems: "center",
          justifyContent: "space-between",
          width: "100%",
          padding: "24px",
          "@media (max-width: 768px)": {
            flexDirection: "column", // Stack vertically on mobile
            alignItems: "center",
            gap: "16px",
            padding: "16px",
          },
        })}
      >
        {/* Badge and APY Text Container */}
        <div
          className={css({
            display: "flex",
            flexDirection: "column", // Stack vertically
            alignItems: "flex-start", // Align to the start on desktop
            gap: "8px",
            "@media (max-width: 768px)": {
              alignItems: "center", // Center align on mobile
              textAlign: "center",
            },
          })}
        >
          {/* Badge */}
          <div
            className={css({
              display: "inline-flex",
              alignItems: "center",
              gap: "6px",
              padding: "6px 12px",
              backgroundColor: "#f5e6d4",
              color: "#036eee",
              borderRadius: "999px",
              fontSize: "14px",
              fontWeight: 700,
              textTransform: "uppercase",
              letterSpacing: "0.05em",
              boxShadow: "0px 2px 4px rgba(0, 0, 0, 0.1)",
              border: "1px solid #024ba1",
              backdropFilter: "blur(14px)",
              whiteSpace: "nowrap",
            })}
          >
            <span>Earn with sUSDaf</span>
            <TokenIcon symbol="BOLD" size="small" />
          </div>

          {/* APY Text */}
          <h2
            className={css({
              margin: 0,
              fontFamily: "'DM Sans', sans-serif",
              fontWeight: 800,
              color: "#ffffff",
              fontSize: "28px",
              lineHeight: 1.2,
              "@media (max-width: 768px)": {
                fontSize: "24px",
              },
            })}
          >
            {apy} APY
          </h2>
        </div>

        {/* Earn Now Button */}
        <button
          onClick={onEarnClick}
          aria-label="Earn Now with sUSDaf"
          className={css({
            display: "inline-flex",
            alignItems: "center",
            gap: "6px",
            padding: "10px 20px",
            backgroundColor: "#ffffff",
            color: "#036eee",
            border: "1px solid #f8f0e3",
            borderRadius: "999px",
            fontSize: "16px",
            fontWeight: 700,
            cursor: "pointer",
            transition: "all 0.3s ease",
            boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
            "&:hover": {
              backgroundColor: "#025dca",
              color: "#ffffff",
              transform: "scale(1.05)",
            },
            "&:active": {
              transform: "scale(0.97)",
            },
            "@media (max-width: 768px)": {
              width: "100%", // Full width on mobile
              justifyContent: "center",
            },
          })}
        >
          <div
            className={css({
              width: "12px",
              height: "12px",
              backgroundColor: "#f8f0e3",
              borderRadius: "50%",
            })}
          />
          <span>Earn Now</span>
        </button>
      </div>
    </MagicCard>
  );
};
