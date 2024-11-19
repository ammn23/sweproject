import React from "react";

const sizes = {
  textxs:
    "text-[1.63rem] font-normal not-italic md:text-[1.50rem] sm:text-[1.38rem]",
  texts:
    "text-[1.69rem] font-normal not-italic md:text-[1.56rem] sm:text-[1.44rem]",
  textmd:
    "text-[1.88rem] font-normal not-italic md:text-[1.75rem] sm:text-[1.63rem]",
};

const Text = ({
  children,
  className = "",
  as,
  size = "textxs",
  ...restProps
}) => {
  const Component = as || "p";

  return (
    <Component
      className={`text-black-900 font-inriasans ${className} ${sizes[size]}`}
      {...restProps}
    >
      {children}
    </Component>
  );
};

export { Text };
