import React from "react";
import PropTypes from "prop-types";

const shapes = {
  round: "rounded-[30px]",
  square: "rounded-[0px]",
};

const variants = {
  fill: {
    blue_gray_100: "bg-blue_gray-100",
    white_A700: "bg-white-a700 text-black-900",
  },
};

const sizes = {
  sm: "h-[4.50rem] pl-[0.75rem] pr-[1.63rem] text-[1.88rem]",
  xs: "h-[2.38rem] px-[0.13rem] text-[1.69rem]",
};

const Input = React.forwardRef(
  (
    {
      className = "",
      name = "",
      placeholder = "",
      type = "text",
      label = "",
      prefix,
      suffix,
      onChange,
      shape,
      variant = "fill",
      size = "xs",
      color = "white_A700",
      ...restProps
    },
    ref
  ) => {
    return (
      <label
        className={`${className} flex items-center justify-center cursor-text text-black-900 ${
          shape && shapes[shape]
        } ${variant && (variants[variant]?.[color] || variants[variant])} ${
          size && sizes[size]
        }`}
      >
        {!!label && label}
        {!!prefix && prefix}
        <input
          ref={ref}
          type={type}
          name={name}
          placeholder={placeholder}
          onChange={onChange}
          {...restProps}
        />
        {!!suffix && suffix}
      </label>
    );
  }
);

Input.propTypes = {
  className: PropTypes.string,
  name: PropTypes.string,
  placeholder: PropTypes.string,
  type: PropTypes.string,
  label: PropTypes.string,
  prefix: PropTypes.node,
  suffix: PropTypes.node,
  shape: PropTypes.oneOf(["round", "square"]),
  size: PropTypes.oneOf(["sm", "xs"]),
  variant: PropTypes.oneOf(["fill"]),
  color: PropTypes.oneOf(["blue_gray_100", "white_A700"]),
};

export { Input };
