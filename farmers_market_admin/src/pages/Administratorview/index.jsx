import { Helmet } from "react-helmet";
import { Text, Input, Img, Button } from "../../components";
import Header from "../../components/Header";
import { CloseSVG } from "../../components/Input/close.jsx";
import React from "react";

export default function AdministratorviewRage() {
  const [searchBarValue6, setSearchBarValue6] = React.useState("");

  return (
    <>
      <Helmet>
        <title>Admin Dashboard - User and Product Management</title>
        <meta
          name="description"
          content="Access the admin dashboard to manage user accounts, product categories, payments, and view system analytics. Keep track of flagged and active accountr for buyers and farmers."
        />
      </Helmet>
      <div className="w-full bg-white-a700">
        <div className="mb-[5.13rem] flex flex-col items-center gap-[1.38rem]">
          <div className="relative h-[10.50rem] self-stretch">
            <Header />
            <Text
              size="textmd"
              as="p"
              className="text-shadow-ts absolute bottom- [0.00rem] left-[10%] m-auto font-inriaserif text-[1.88rem] font-normal text-white-a700 md:text-[1.75rem] sm:text-[1.63rem]"
            >
              Farmers' Market
            </Text>
          </div>
          <div className="container-xs md:px-[1.25rem]">
            <div className="flex items-center gap-[2.63rem] md:flex-col">
              <div className="flex w-[24%] flex-col gap-[1.38rem] md:w-full">
                <Button
                  size="md"
                  shape="square"
                  rightIcon={
                    <Img
                      src="images/img_menu_2.svg"
                      alt="Menu-2"
                      className="h-[2.88rem] w-[2.00rem]"
                    />
                  }
                  className="gap-[2.13rem] self-stretch border"
                >
                  Menu
                </Button>
                <div className="border-4 border-solid border-black-900 bg-white-a700">
                  <div className="flex items-center">
                    <div className="h-[40.13rem] w-[16%] bg-blue_gray-100" />
                    <div className="relative ml-[-2.38rem] flex flex-1 flex-col items-start gap-[4.50rem] md:gap-[3.38rem] sm:gap-[2.25rem]">
                      <Text
                        as="p"
                        className="border border-solid border-black-900 bg-light_green-200 px-[2.13rem] py-[0.50rem] text-[1.63rem] font-normal text-black-900 md:text-[1.50rem] sm:px-[1.25rem] sm:text-[1.38rem]"
                      >
                        Dashboard
                      </Text>
                      <a
                        href="https://www.youtube.com/embed/db8Fxk0sz7I"
                        target="_blank"
                      >
                        <Text
                          as="p"
                          className="border border-solid border-black-900 bg-light_green-200 pb-[0.63rem] pl-[1.88rem] pr-[2.13rem] pt-[0.38rem] text-[1.63rem] font-normal text-black-900 md:text-[1.50rem] sm:px-[1.25rem] sm:text-[1.38rem]"
                        >
                          User management
                        </Text>
                      </a>
                      <Text
                        as="p"
                        className="border border-solid border-black-900 bg-light_green-200 py-[0.50rem] pl-[1.63rem] pr-[2.13rem] text-[1.63rem] font-normal text-black-900 md:text-[1.50rem] sm:px-[1.25rem] sm:text-[1.38rem]"
                      >
                        Product categories
                      </Text>
                      <Text
                        as="p"
                        className="border border-solid border-black-900 bg-light_green-200 px-[2.13rem] pb-[0.50rem] pt-[0.38rem] text-[1.63rem] font-normal text-black-900 md:text-[1.50rem] sm:px-[1.25rem] sm:text-[1.38rem]"
                      >
                        Payments
                      </Text>
                      <div className="mr-[1.13rem] flex justify-center self-stretch border border-solid border-black-900 bg-light_green-200 p-[0.50rem] md:mr-0">
                        <Text
                          as="p"
                          className="text-[1.63rem] font-normal text-black-900 md:text-[1.50rem] sm:text-[1.39rem]"
                        >
                          System analytics
                        </Text>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div className="flex flex-1 flex-col items-end gap-[1.75rem] md:self-stretch">
                <Input
                  color="blue_gray_100"
                  size="sm"
                  shape="round"
                  name="Search Field"
                  placeholder={`Search`}
                  value={searchBarValue6}
                  onChange={(e) => setSearchBarValue6(e.target.value)}
                  suffix={
                    searchBarValue6?.length > 0 ? (
                      <CloseSVG
                        onClick={() => setSearchBarValue6("")}
                        height={38}
                        width={38}
                        fillColor="#00000ff"
                      />
                    ) : (
                      <Img
                        src="images/img_search_1.svg"
                        alt="Search 1"
                        className="h-[2.38rem] w-[2.38rem]"
                      />
                    )
                  }
                  className="mr-[1.25rem] w-[60%] gap-[1.00rem] rounded-[30px] border border-solid border-black-900 font-light md:mr-0"
                />
                <div className="flex justify-center self-stretch border-[3px] border-solid border-black-900 bg-blue_gray-100 px-[3.50rem] py-[6.25rem] md:p-[1.25rem]">
                  <div className="mb-[0.63rem] flex w-[90%] justify-center md:w-full">
                    <div className="flex w-full flex-col gap-[6.63rem] md:gap-[4.94rem] sm:gap-[3.13rem]">
                      <div className="flex justify-between gap-[1.25rem] md:flex-col">
                        <div className="flex w-[26%] flex-col items-start gap-[0.75rem] border border-solid border-black-900 bg-white-a700 px-[1.38rem] py-[0.38rem] md:w-full sm:px-[1.25rem]">
                          <div className="ml-[2.63rem] mt-[1.25rem] flex w-[50%] justify-center rounded-[26px] bg-blue_gray-100 py-[0.25rem] md:ml-0 md:w-full md:px-[1.25rem]">
                            <Input
                              shape="square"
                              name="Flagged Input"
                              placeholder={`Num`}
                              className="mt-[0.38rem] w-full px-[0.13rem]"
                            />
                          </div>
                        </div>
                        <Text
                          as="p"
                          className="w-[98%] text-[1.63rem] font-normal leading-[1.94rem] text-black-900 md:w-full md:text-[1.50rem] sm:text-[1.38rem]"
                        >
                          Flagged Users
                        </Text>
                      </div>
                      <div className="flex w-[26%] flex-col items-center gap-[0.75rem] border border-solid border-black-900 bg-white-a700 p-[0.38rem] md:w-full">
                        <div className="mt-[1.25rem] flex w-[30%] justify-center rounded-[26px] bg-blue_gray-100 py-[0.25rem] md:w-full md:px-[1.25rem]">
                          <Input
                            shape="square"
                            name="Active Buyers Input"
                            placeholder={`Num`}
                            className="mt-[0.38rem] w-full px-[0.13rem]"
                          />
                        </div>
                        <Text
                          as="p"
                          className="w-[82%] text-[1.63rem] font-normal leading-[1.94rem] text-black-900 md:w-full md:text-[1.50rem] sm:text-[1.38rem]"
                        >
                          Active Buyer accounts
                        </Text>
                      </div>

                      <div className="flex w-[24%] flex-col items-center gap-[0.75rem] border border-solid border-black-900 bg-white-a700 py-[0.25rem] md:w-full">
                        <div className="mt-[1.50rem] flex w-[28%] justify-center rounded-[26px] bg-blue_gray-100 py-[0.25rem] md:w-full md:px-[1.25rem]">
                          <Input
                            shape="square"
                            name="Disabled Buyers Input"
                            placeholder={`Num`}
                            className="mt-[0.38rem] w-full px-[0.13rem]"
                          />
                        </div>
                        <Text
                          as="p"
                          className="w-[98%] text-[1.63rem] font-normal leading-[1.94rem] text-black-900 md:w-full md:text-[1.50rem] sm:text-[1.38rem]"
                        >
                          Disabled Buyer accounts
                        </Text>
                      </div>
                    </div>
                    <div className="flex justify-between gap-[1.25rem] md:flex-col">
                      <div className="flex w-[26%] flex-col items-start gap-[0.75rem] border border-solid border-black-900 bg-white-a700 px-[0.63rem] py-[0.38rem] md:w-full">
                        <div className="ml-[3.50rem] mt-[1.25rem] flex w-[44%] justify-center rounded-[26px] bg-blue_gray-100 py-[0.25rem] md:ml-0 md:w-full md:px-[1.25rem]">
                          <Input
                            shape="square"
                            name="Active Farmers Input"
                            placeholder={`Num`}
                            className="mt-[0.38rem] w-full px-[0.13rem]"
                          />
                        </div>
                        <Text
                          as="p"
                          className="w-[92%] self-end text-[1.63rem] font-normal leading-[1.94rem] text-black-900 md:w-full md:text-[1.50rem] sm:text-[1.38rem]"
                        >
                          Active Farmer accounts
                        </Text>
                      </div>

                      <div className="flex w-[26%] flex-col items-center gap-[0.88rem] border border-solid border-black-900 bg-white-a700 py-[0.25rem] md:w-full">
                        <div className="mt-[1.38rem] flex w-[26%] justify-center rounded-[26px] bg-blue_gray-100 py-[0.25rem] md:w-full md:px-[1.25rem]">
                          <Input
                            shape="square"
                            name="Pending Farmers Input"
                            placeholder={`Num`}
                            className="mt-[0.38rem] w-full px-[0.13rem]"
                          />
                        </div>
                        <Text
                          as="p"
                          className="w-[98%] text-[1.63rem] font-normal leading-[1.94rem] text-black-900 md:w-full md:text-[1.50rem] sm:text-[1.38rem]"
                        >
                          Farmers pending approval
                        </Text>
                      </div>

                      <div className="flex w-[24%] flex-col items-center gap-[0.75rem] border border-solid border-black-900 bg-white-a700 py-[0.25rem] md:w-full">
                        <div className="mt-[1.50rem] flex w-[28%] justify-center rounded-[26px] bg-blue_gray-100 py-[0.25rem] md:w-full md:px-[1.25rem]">
                          <Input
                            shape="square"
                            name="Disabled Farmers Input"
                            placeholder={`Num`}
                            className="mt-[0.38rem] w-full px-[0.13rem]"
                          />
                        </div>
                        <Text
                          as="p"
                          className="w-[98%] text-[1.63rem] font-normal leading-[1.94rem] text-black-900 md:w-full md:text-[1.50rem] sm:text-[1.38rem]"
                        >
                          Disabled Farmer accounts
                        </Text>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
