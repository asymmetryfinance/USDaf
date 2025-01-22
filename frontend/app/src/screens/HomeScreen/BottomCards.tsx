import React from "react";
import { css } from "@/styled-system/css";

export const BottomCards: React.FC = () => {
  return (
    <div
      className={css({
        display: "flex",
        justifyContent: "space-around",
        alignItems: "flex-start",
        gap: "24px",
        padding: "20px",
        backgroundColor: "#f9f9f9",
        borderTop: "2px solid #e6c7a0",
        borderRadius: "12px 12px 0 0",
      })}
    >
      {/* Borrow with USDaf Card */}
      <div
        className={css({
          flex: "1",
          display: "flex",
          flexDirection: "column",
          gap: "16px",
          backgroundColor: "#f5e6d4",
          padding: "16px",
          borderRadius: "8px",
          boxShadow: "0px 4px 12px rgba(0, 0, 0, 0.1)",
        })}
      >
        <div
          className={css({
            width: "48px",
            height: "48px",
            backgroundColor: "#f8efe2",
            border: "2px solid #036eee",
            borderRadius: "50%",
          })}
        />
        <h3 className={css({ fontSize: "20px", fontWeight: 700, color: "#402108" })}>
          Borrow with USDaf
        </h3>
        <p
          className={css({
            fontSize: "14px",
            color: "#804e13",
            lineHeight: 1.5,
          })}
        >
          Cover liquidations to earn USDaf and collateral assets.
        </p>
        <button
          className={css({
            alignSelf: "flex-start",
            textDecoration: "underline",
            fontWeight: 600,
            color: "#804e13",
            backgroundColor: "transparent",
            border: "none",
            cursor: "pointer",
          })}
        >
          Borrow
        </button>
      </div>

      {/* Earn with USDaf Card */}
      <div
        className={css({
          flex: "1",
          display: "flex",
          flexDirection: "column",
          gap: "16px",
          backgroundColor: "#f5e6d4",
          padding: "16px",
          borderRadius: "8px",
          boxShadow: "0px 4px 12px rgba(0, 0, 0, 0.1)",
        })}
      >
        <div
          className={css({
            width: "48px",
            height: "48px",
            backgroundColor: "#4d9efd",
            border: "2px solid #036eee",
            borderRadius: "50%",
          })}
        />
        <h3 className={css({ fontSize: "20px", fontWeight: 700, color: "#402108" })}>
          Earn with USDaf
        </h3>
        <p
          className={css({
            fontSize: "14px",
            color: "#804e13",
            lineHeight: 1.5,
          })}
        >
          Cover liquidations to earn USDaf and collateral assets.
        </p>
        <button
          className={css({
            alignSelf: "flex-start",
            textDecoration: "underline",
            fontWeight: 600,
            color: "#804e13",
            backgroundColor: "transparent",
            border: "none",
            cursor: "pointer",
          })}
        >
          Earn
        </button>
      </div>

      {/* Lock ASF Card */}
      <div
        className={css({
          flex: "1",
          display: "flex",
          flexDirection: "column",
          gap: "16px",
          backgroundColor: "#f5e6d4",
          padding: "16px",
          borderRadius: "8px",
          boxShadow: "0px 4px 12px rgba(0, 0, 0, 0.1)",
        })}
      >
        <div
          className={css({
            width: "48px",
            height: "48px",
            backgroundColor: "#036eee",
            borderRadius: "50%",
          })}
        />
        <h3 className={css({ fontSize: "20px", fontWeight: 700, color: "#402108" })}>
          Lock ASF
        </h3>
        <p
          className={css({
            fontSize: "14px",
            color: "#804e13",
            lineHeight: 1.5,
          })}
        >
          Accrue voting power by staking your ASF.
        </p>
        <button
          className={css({
            alignSelf: "flex-start",
            textDecoration: "underline",
            fontWeight: 600,
            color: "#804e13",
            backgroundColor: "transparent",
            border: "none",
            cursor: "pointer",
          })}
        >
          Lock
        </button>
      </div>
    </div>
  );
};
