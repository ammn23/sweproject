import React from "react";
import PropTypes from "prop-types";

const shapes = {
  round: "rounded-[30px]",
  square: "rounded-[0px]",
};

const variants = {
  fill: {
    light_green_200: "bg-light_green-200 text-black-900",
    blue_gray_100: "bg-blue_gray-100 text-black-900",
  },
};

const sizes = {
  xs: "h-[3.13rem] px-[2.13rem] text-[1.63rem]",
  sm: "h-[3.88rem] px-[2.00rem] text-[1.88rem]",
  md: "h-[4.88rem] pl-[2.00rem] pr-[1.38rem] text-[2.19rem]",
};

const Button = ({
  children,
  className = "",
  leftIcon,
  rightIcon,
  shape,
  variant = "fill",
  size = "sm",
  color = "blue_gray_100",
  ...restProps
}) => {
  return (
    <button
      className={`${className} flex flex-row items-center justify-center text-center cursor-pointer whitespace-nowrap text-black-900 border-black-900 border-solid ${
        shape && shapes[shape]
      } ${size && sizes[size]} ${variant && variants[variant]?.[color]}`}
      {...restProps}
    >
      {!!leftIcon && { leftIcon }}
      {children}
      {!!rightIcon && { rightIcon }}
    </button>
  );
};

Button.propTypes = {
  className: PropTypes.string,
  children: PropTypes.node,
  leftIcon: PropTypes.node,
  rightIcon: PropTypes.node,
  shape: PropTypes.oneOf(["round", "square"]),
  variant: PropTypes.oneOf(["fill"]),
  size: PropTypes.oneOf(["xs", "sm", "md"]),
  color: PropTypes.oneOf(["light_green_200", "blue_gray_100"]),
};

export { Button };
