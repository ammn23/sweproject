import { Button, Img } from "..";
import React from "react";

export default function Header({ ...props }) {
  return (
    <header
      {...props}
      className={`${props.className} flex justify-center items-center top-[0.00rem] right-0 left-0 py-[2.00rem] m-auto sm:py-[1.25rem] bg-teal-800 flex-1 absolute`}
    >
      <div className="container-xs flex justify-center md:px-[1.25rem]">
        <div className="flex w-full items-center justify-between gap-[1.25rem]">
          <Img
            src="images/img_a_pngtreea_clean.png"
            alt="Logo Image"
            className="h-[5.50rem] w-[6%] rounded-[42px] object-contain"
          />
          <Button
            shape="round"
            className="min-w-[10.25rem] rounded-[30px] border-[3px] px-[1.81rem] sm:px-[1.25rem]"
          >
            Log out
          </Button>
        </div>
      </div>
    </header>
  );
}
