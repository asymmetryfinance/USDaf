// MagicCard.tsx
"use client";

import { motion, useMotionTemplate, useMotionValue } from "framer-motion";
import React, { useCallback, useEffect, useRef } from "react";
import { css } from "@/styled-system/css";

interface MagicCardProps extends React.HTMLAttributes<HTMLDivElement> {
  gradientSize?: number;
  gradientColor?: string;
  gradientOpacity?: number;
  gradientFrom?: string;
  gradientTo?: string;
  backgroundColor?: string; // Added prop for dynamic background
}

export const MagicCard: React.FC<MagicCardProps> = ({
  children,
  className,
  gradientSize = 200,
  gradientColor = "#0047b3",
  gradientOpacity = 0.3, // Reduced opacity for subtler effect
  gradientFrom = "#0047b3",
  gradientTo = "#0047b3",
  backgroundColor = "transparent", // Default to transparent
}) => {
  const cardRef = useRef<HTMLDivElement>(null);
  const mouseX = useMotionValue(-gradientSize);
  const mouseY = useMotionValue(-gradientSize);

  const handleMouseMove = useCallback(
    (e: MouseEvent) => {
      if (cardRef.current) {
        const rect = cardRef.current.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        mouseX.set(x);
        mouseY.set(y);
      }
    },
    [mouseX, mouseY]
  );

  const handleMouseEnter = useCallback(() => {
    if (cardRef.current) {
      cardRef.current.addEventListener("mousemove", handleMouseMove);
    }
  }, [handleMouseMove]);

  const handleMouseLeave = useCallback(() => {
    if (cardRef.current) {
      cardRef.current.removeEventListener("mousemove", handleMouseMove);
    }
    mouseX.set(-gradientSize);
    mouseY.set(-gradientSize);
  }, [handleMouseMove, gradientSize, mouseX, mouseY]);

  useEffect(() => {
    const current = cardRef.current;
    if (current) {
      current.addEventListener("mouseenter", handleMouseEnter);
      current.addEventListener("mouseleave", handleMouseLeave);
    }

    return () => {
      if (current) {
        current.removeEventListener("mouseenter", handleMouseEnter);
        current.removeEventListener("mouseleave", handleMouseLeave);
        current.removeEventListener("mousemove", handleMouseMove);
      }
    };
  }, [handleMouseEnter, handleMouseLeave, handleMouseMove]);

  const spotlightGradient = useMotionTemplate`
    radial-gradient(
      ${gradientSize}px circle 
      at ${mouseX}px ${mouseY}px, 
      ${gradientColor}, 
      transparent 100%
    )
  `;

  const accentGradient = useMotionTemplate`
    radial-gradient(
      ${gradientSize}px circle 
      at ${mouseX}px ${mouseY}px,
      ${gradientFrom}, 
      ${gradientTo}, 
      rgba(14, 47, 59, 0.1) 100%
    )
  `;

  return (
    <div
      ref={cardRef}
      className={`${css({
        position: "relative",
        display: "flex",
        width: "100%",
        borderRadius: "12px",
        overflow: "hidden",
      })} ${className || ""}`}
    >
      {/* Inset Background Layer */}
      <div
        className={css({
          position: "absolute",
          inset: "0",
          zIndex: 10,
          borderRadius: "12px",
          backgroundColor: backgroundColor, // Use dynamic background color
          pointerEvents: "none",
        })}
      />

      {/* Content */}
      <div
        className={css({
          position: "relative",
          zIndex: 30,
          width: "100%",
          height: "100%",
        })}
      >
        {children}
      </div>

      {/* Spotlight Gradient */}
      <motion.div
        className={css({
          pointerEvents: "none",
          position: "absolute",
          inset: 0,
          zIndex: 20,
          borderRadius: "12px",
          opacity: gradientOpacity, // Adjusted opacity
          transition: "opacity 0.3s ease",
        })}
        style={{
          background: spotlightGradient,
        }}
      />

      {/* Accent Gradient */}
      <motion.div
        className={css({
          pointerEvents: "none",
          position: "absolute",
          inset: 0,
          zIndex: 15,
          borderRadius: "12px",
          backgroundBlendMode: "overlay",
          transition: "background 0.3s ease",
        })}
        style={{
          background: accentGradient,
        }}
      />
    </div>
  );
};
