import { Helmet } from "react-helmet";
import {
  SelectBox,
  Img,
  Input,
  Text,
  CheckBox,
  Button,
} from "../../components";
import Header from "../../components/Header";
import { CloseSVG } from "../../components/Input/close.jsx";
import React from "react";

const dropDownOptions = [
  { label: "Option1", value: "option1" },
  { label: "Option2", value: "option2" },
  { label: "Option3", value: "option3" },
];

export default function BuyermanagementPage() {
  const [searchBarValue44, setSearchBarValue44] = React.useState("");

  return (
    <>
      <Helmet>
        <title>Buyer Management - Monitor and Manage Buyer Accounts</title>
        <meta
          name="description"
          content="Efficiently manage buyer accounts. Oversee account details including ID, full name, phone, and email. Maintain a robust and active buyer community."
        />
      </Helmet>
      <div className="w-full bg-white-a700">
        <div className="mb-[5.13rem] flex flex-col items-center gap-[1.38rem]">
          <div className="relative h-[10.50rem] self-stretch">
            <Header />
            <Text
              size="textmd"
              as="p"
              className="text-shadow-ts absolute bottom-[0.00rem] left-[10%] m-auto font-inriaserif text-[1.88rem] font-normal text-white-a700 md:text-[1.75rem] sm:text-[1.63rem]"
            >
              Farmers’ Market
            </Text>
          </div>
          <div className="container-xs md:px-[1.25rem]">
            <div className="flex items-center gap-[2.63rem] md:flex-col">
              <div className="w-[24%] md:w-full">
                <div className="flex flex-col gap-[1.38rem]">
                  <Button
                    size="md"
                    shape="square"
                    rightIcon={
                      <Img
                        src="images/img_menu_2.svg"
                        alt="Menu 1"
                        className="h-[2.88rem] w-[2.00rem]"
                      />
                    }
                    className="gap-[2.13rem] self-stretch border"
                  >
                    Menu
                  </Button>
                  <div className="relative h-[40.50rem] content-center md:h-auto">
                    <div className="h-[40.13rem] w-[18%] bg-blue_gray-100" />
                    <div className="absolute bottom-0 left-0 right-0 top-0 m-auto flex h-max flex-1 flex-col items-center justify-center gap-[4.50rem] border-4 border-solid border-black-900 bg-white-a700 px-[1.38rem] py-[3.13rem] md:gap-[3.38rem] md:py-[1.25rem] sm:gap-[2.25rem] sm:p-[1.25rem]">
                      <Text
                        as="p"
                        className="border border-solid border-black-900 bg-light_green-200 px-[2.13rem] py-[0.50rem] text-[1.63rem] font-normal text-black-900 md:text-[1.50rem] sm:px-[1.25rem] sm:text-[1.38rem]"
                      >
                        Dashboard
                      </Text>
                      <Text
                        as="p"
                        className="border-4 border-solid border-teal-800 bg-light_green-200 pb-[0.63rem] pl-[1.88rem] pr-[2.13rem] pt-[0.38rem] text-[1.63rem] font-normal text-black-900 md:text-[1.50rem] sm:px-[1.25rem] sm:text-[1.38rem]"
                      >
                        User management
                      </Text>
                      <Text
                        as="p"
                        className="border border-solid border-black-900 bg-light_green-200 py-[0.50rem] pl-[1.63rem] pr-[2.13rem] text-[1.63rem] font-normal text-black-900 md:text-[1.50rem] sm:px-[1.25rem] sm:text-[1.38rem]"
                      >
                        Product categories
                      </Text>
                      <Text
                        as="p"
                        className="border border-solid border-black-900 bg-light_green-200 py-[0.50rem] pl-[1.63rem] pr-[2.13rem] text-[1.63rem] font-normal text-black-900 md:text-[1.50rem] sm:px-[1.25rem] sm:text-[1.38rem]"
                      >
                        Payments
                      </Text>
                      <Button
                        color="light_green_200"
                        size="xs"
                        shape="square"
                        className="self-stretch border px-[2.06rem] sm:px-[1.25rem]"
                      >
                        System analytics
                      </Button>
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
                  placeholder="Search"
                  value={searchBarValue44}
                  onChange={(e) => setSearchBarValue44(e.target.value)}
                  suffix={
                    searchBarValue44?.length > 0 ? (
                      <CloseSVG
                        onClick={() => setSearchBarValue44("")}
                        height={38}
                        width={38}
                        fillColor="#000000ff"
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
                <div className="self-stretch border-[3px] border-solid border-black-900 bg-blue_gray-100">
                  <div className="mb-[0.75rem] flex flex-col gap-[1.63rem]">
                    <div className="relative h-[36.50rem]">
                      <Img
                        src="images/img_maximize_2_1.svg"
                        alt="Maximize Image"
                        className="absolute right-[-1.56rem] top-[1.25rem] m-auto h-[2.25rem]"
                      />
                      <div className="absolute bottom-0 left-0 right-0 top-0 m-auto h-max flex-1">
                        <div className="flex flex-col items-start">
                          <div className="h-[6.50rem] self-stretch border-[3px] border-solid border-black-900 bg-blue_gray-100">
                            <SelectBox
                              shape="square"
                              indicator={
                                <Img
                                  src="images/img_arrowdown.svg"
                                  alt="Arrow Down"
                                  className="h-[0.63rem] w-[0.88rem]"
                                />
                              }
                              name="Farmers Dropdown"
                              placeholder={`Farmers`}
                              options={dropDownOptions}
                              className="relative ml-[2.25rem] mt-[-5.25rem] w-[32%] gap-[1.00rem] md:ml-0 md:py-[1.25rem]"
                            />
                          </div>
                          <div className="relative mx-[1.50rem] mt-[-4.00rem] overflow-auto overflow-x-scroll md:mx-0">
                            <div className="mb-[14.63rem] flex w-[73.75rem] flex-col gap-[0.75rem]">
                              <div className="flex items-center justify-end md:flex-col">
                                <Input
                                  shape="square"
                                  name="Group ID Field"
                                  placeholder={`1`}
                                  className="w-[3%] px-[0.13rem] md:w-full"
                                />
                                <Img
                                  src="images/img_folder.svg"
                                  alt="Folder Image"
                                  className="ml-[-0.38rem] h-[2.25rem] w-[5%] object-contain md:ml-0 md:w-full"
                                />
                                <div className="ml-[-0.38rem] flex w-[18%] bg-white-a700 px-[1.38rem] md:ml-0 md:w-full sm:px-[1.25rem]">
                                  <Input
                                    shape="square"
                                    name="Account ID Field"
                                    placeholder={`Account ID`}
                                    className="w-[80%] px-[0.13rem]"
                                  />
                                </div>
                                <div className="ml-[-0.38rem] flex w-[20%] bg-white-a700 px-[0.75rem] md:ml-0 md:w-full">
                                  <Input
                                    shape="square"
                                    type="text"
                                    name="Full Name Field"
                                    placeholder={`Full name`}
                                    className="w-[52%] px-[0.13rem]"
                                  />
                                </div>
                                <div className="ml-[0.38rem] flex w-[20%] bg-white-a700 px-[0.75rem] md:ml-0 md:w-full">
                                  <Input
                                    shape="square"
                                    type="number"
                                    name="Phone Field"
                                    placeholder={`Phone`}
                                    className="w-[34%] px-[0.13rem]"
                                  />
                                </div>
                                <div className="ml-[0.38rem] flex h-[2.38rem] w-[20%] items-center bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:ml-0 md:h-auto md:w-full">
                                  <Input
                                    shape="square"
                                    type="email"
                                    name="Email Field"
                                    placeholder={`Email`}
                                    className="w-[30%] px-[0.13rem]"
                                  />
                                </div>
                                <div className="ml-[7.63rem] flex items-center gap-[0.38rem] overflow-x-scroll md:ml-0 md:flex-col">
                                  <div className="flex w-[18.88rem] flex-1 items-center gap-[0.38rem] md:self-stretch">
                                    <div className="flex w-[12%] flex-col items-end justify-center bg-white-a700 px-[0.38rem]">
                                      <Input
                                        shape="square"
                                        name="Group N Field"
                                        placeholder={`n`}
                                        className="w-[72%] px-[0.13rem]"
                                      />
                                    </div>
                                    <Img
                                      src="images/img_folder.svg"
                                      alt="Folder Three Image"
                                      className="h-[2.25rem] w-[18%] object-contain"
                                    />
                                    <div className="flex flex-1 bg-white-a700 px-[1.38rem] sm:px-[1.25rem]">
                                      <Input
                                        shape="square"
                                        name="Account ID Three Field"
                                        placeholder={`Account ID`}
                                        className="w-[80%] px-[0.13rem]"
                                      />
                                    </div>
                                    <div className="flex w-[15.25rem] bg-white-a700 px-[0.75rem]">
                                      <Input
                                        shape="square"
                                        type="text"
                                        name="Full Name One Field"
                                        placeholder={`Full name`}
                                        className="w-[52%] px-[0.13rem]"
                                      />
                                    </div>
                                    <Input
                                      shape="square"
                                      type="number"
                                      name="Phone One Field"
                                      placeholder={`Phone`}
                                      className="w-[15.25rem] px-[0.13rem]"
                                    />
                                    <div className="flex h-[2.38rem] w-[15.25rem] items-center bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto">
                                      <Input
                                        shape="square"
                                        type="email"
                                        name="Email One Field"
                                        placeholder={`Email`}
                                        className="w-[30%] px-[0.13rem]"
                                      />
                                    </div>
                                    <div className="ml-[7.63rem] flex items-center gap-[0.38rem] overflow-x-scroll md:ml-0 md:flex-col">
                                      <div className="flex w-[18.88rem] flex-1 items-center gap-[0.38rem] md:self-stretch">
                                        <div className="flex w-[12%] flex-col items-end justify-center bg-white-a700 px-[0.38rem]">
                                          <Input
                                            shape="square"
                                            name="Group N Three Field"
                                            placeholder={`n`}
                                            className="w-[72%] px-[0.13rem]"
                                          />
                                        </div>
                                        <Img
                                          src="images/img_folder.svg"
                                          alt="Folder Five Image"
                                          className="h-[2.25rem] w-[18%] object-contain"
                                        />
                                        <div className="flex flex-1 bg-white-a700 px-[1.38rem] sm:px-[1.25rem]">
                                          <Input
                                            shape="square"
                                            name="Account ID Five Field"
                                            placeholder={`Account ID`}
                                            className="w-[80%] px-[0.13rem]"
                                          />
                                        </div>
                                      </div>
                                      <div className="flex w-[15.25rem] bg-white-a700 px-[0.75rem]">
                                        <Input
                                          shape="square"
                                          type="text"
                                          name="Full Name Four Field"
                                          placeholder={`Full name`}
                                          className="w-[52%] px-[0.13rem]"
                                        />
                                      </div>
                                      <Input
                                        shape="square"
                                        type="number"
                                        name="Phone Two Field"
                                        placeholder={`Phone`}
                                        className="w-[15.25rem] px-[0.13rem]"
                                      />
                                      <div className="flex h-[2.38rem] w-[15.25rem] items-center bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto">
                                        <Input
                                          shape="square"
                                          type="email"
                                          name="Email Two Field"
                                          placeholder={`Email`}
                                          className="w-[30%] px-[0.13rem]"
                                        />
                                      </div>
                                    </div>
                                    <div className="ml-[7.63rem] flex items-center gap-[0.38rem] overflow-x-scroll md:ml-0 md:flex-col">
                                      <div className="flex w-[18.88rem] flex-1 items-center gap-[0.38rem] md:self-stretch">
                                        <CheckBox
                                          name="CheckBox N Four"
                                          label="n"
                                          id="CheckBoxNFour"
                                          className="pr-[0.38rem] text-[1.69rem] text-black-900"
                                        />
                                        <Img
                                          src="images/img_folder.svg"
                                          alt="Folder Seven Image"
                                          className="h-[2.25rem] w-[18%] object-contain"
                                        />
                                        <Text
                                          size="texts"
                                          as="p"
                                          className="bg-white-a700 pl-[1.38rem] pr-[2.13rem] text-[1.69rem] font-normal text-black-900 md:text-[1.56rem] sm:px-[1.25rem] sm:text-[1.44rem]"
                                        >
                                          Account ID
                                        </Text>
                                      </div>
                                      <div className="flex w-[15.25rem] bg-white-a700 px-[0.75rem]">
                                        <Input
                                          shape="square"
                                          type="text"
                                          name="Full Name Seven Field"
                                          placeholder={`Full name`}
                                          className="w-[52%] px-[0.13rem]"
                                        />
                                      </div>
                                      <Input
                                        shape="square"
                                        type="number"
                                        name="Phone Three Field"
                                        placeholder={`Phone`}
                                        className="w-[15.25rem] px-[0.13rem]"
                                      />
                                      <div className="flex h-[2.38rem] w-[15.25rem] items-center bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto">
                                        <Input
                                          shape="square"
                                          type="email"
                                          name="Email Three Field"
                                          placeholder={`Email`}
                                          className="w-[30%] px-[0.13rem]"
                                        />
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                              <SelectBox
                                shape="square"
                                indicator={
                                  <Img
                                    src="images/img_arrowdown.svg"
                                    alt="Arrow Down"
                                    className="h-[0.63rem] w-[0.88rem]"
                                  />
                                }
                                name="Buyers Dropdown"
                                placeholder={`Buyers`}
                                options={dropDownOptions}
                                className="absolute right-[27%] top-[1.19rem] m-auto w-[42%] gap-[1.00rem] border-4 border-solid border-teal-800 md:py-[1.25rem]"
                              />
                            </div>
                            <div className="mx-[1.13rem] flex rounded-md bg-white-a700 px-[0.63rem] md:mx-0">
                              <div className="h-[1.13rem] w-[10%] rounded-lg bg-gray-400" />
                            </div>
                          </div>
                        </div>
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
