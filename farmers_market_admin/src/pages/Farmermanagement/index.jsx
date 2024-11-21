import { Helmet } from "react-helmet";
import {
  SelectBox,
  Img,
  Text,
  Input,
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

export default function FarmermanagementPage() {
  const [searchBarValue25, setSearchBarValue25] = React.useState("");

  return (
    <>
      <Helmet>
        <title>Farmer Management – View and Edit Farmer Details</title>
        <meta
          name="description"
          content="Manage farmer accounts with ease. View and edit details such as account ID, full name, contact information, farm name, and location. Ensure your farmer database is up-to-date and accurate."
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
              Farmers' Market
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
                        className="border border-solid border-black-900 bg-light_green-200 px-[2.13rem] py-[0.50rem] text-[1.63rem] font-normal text-black-900 md:text-[1.50rem] sm:px-[1.25rem] sm:text-[1.44rem]"
                      >
                        Dashboard
                      </Text>
                      <Text
                        as="p"
                        className="border-4 border-solid border-teal-800 bg-light_green-200 pb-[0.63rem] pl-[1.88rem] pr-[2.13rem] pt-[0.38rem] text-[1.63rem] font-normal text-black-900 md:text-[1.50rem] sm:px-[1.25rem]"
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
                        className="border border-solid border-black-900 bg-light_green-200 px-[2.13rem] pb-[0.63rem] pt-[0.38rem] text-[1.63rem] font-normal text-black-900 md:text-[1.50rem] sm:px-[1.25rem] sm:text-[1.38rem]"
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
                  placeholder={`Search`}
                  value={searchBarValue25}
                  onChange={(e) => setSearchBarValue25(e.target.value)}
                  suffix={
                    searchBarValue25?.length > 0 ? (
                      <CloseSVG
                        onClick={() => setSearchBarValue25("")}
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
                        className="absolute right-[1.56rem] top-[1.25rem] m-auto h-[2.25rem]"
                      />
                      <div className="absolute bottom-0 left-0 right-0 top-0 m-auto h-max flex-1">
                        <div className="flex flex-col items-start">
                          <div className="h-[6.50rem] self-stretch border-[3px] border-solid border-black-900 bg-blue_gray-100" />
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
                            className="relative ml-[2.25rem] mt-[-5.25rem] w-[32%] gap-[1.00rem] border-4 border-solid border-teal-800 md:ml-0 md:py-[1.25rem]"
                          />
                        </div>
                        <div className="relative mx-[1.50rem] mt-[-4.00rem] flex flex-col gap-[0.75rem] overflow-auto overflow-x-scroll md:mx-0">
                          <div className="flex w-[113.00rem] items-center gap-[0.38rem] overflow-x-scroll md:flex-col">
                            <div className="flex w-[18.88rem] flex-1 items-center gap-[0.38rem] md:self-stretch">
                              <Input
                                shape="square"
                                name="ID Edit"
                                placeholder="`1`"
                                className="w-[12%] px-[0.13rem]"
                              />
                              <Img
                                src="images/img_folder.svg"
                                alt="Folder Image"
                                className="h-[2.25rem] w-[18%] object-contain"
                              />
                              <div className="flex flex-1 bg-white-a700 px-[1.38rem] sm:px-[1.25rem]">
                                <Input
                                  shape="square"
                                  name="Account ID Edit"
                                  placeholder="Account ID"
                                  className="w-[80%] px-[0.13rem]"
                                />
                              </div>
                            </div>
                            <div className="flex w-[15.25rem] bg-white-a700 px-[0.75rem]">
                              <Input
                                shape="square"
                                type="text"
                                name="Full Name Edit"
                                placeholder="Full name"
                                className="w-[52%] px-[0.13rem]"
                              />
                            </div>
                            <div className="flex w-[15.25rem] bg-white-a700 px-[0.75rem]">
                              <Input
                                shape="square"
                                type="number"
                                name="Phone Edit"
                                placeholder="Phone"
                                className="w-[34%] px-[0.13rem]"
                              />
                            </div>
                            <div className="flex h-[2.38rem] w-[15.25rem] items-center bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto">
                              <Input
                                shape="square"
                                type="email"
                                name="Email Edit"
                                placeholder="Email"
                                className="w-[30%] px-[0.13rem]"
                              />
                            </div>
                            <div className="flex h-[2.25rem] w-[15.25rem] items-center bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto">
                              <Text
                                size="texts"
                                as="p"
                                className="text-[1.69rem] font-normal text-black-900 md:text-[1.56rem] sm:text-[1.44rem]"
                              >
                                Farm name
                              </Text>
                            </div>
                            <div className="flex h-[2.25rem] w-[15.25rem] items-center bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto">
                              <Text
                                size="texts"
                                as="p"
                                className="text-[1.69rem] font-normal text-black-900 md:text-[1.56rem] sm:text-[1.44rem]"
                              >
                                Farm location
                              </Text>
                            </div>
                            <div className="flex h-[2.25rem] w-[15.25rem] items-center bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto">
                              <Text
                                size="texts"
                                as="p"
                                className="text-[1.69rem] font-normal text-black-900 md:text-[1.56rem] sm:text-[1.44rem]"
                              >
                                Farm size
                              </Text>
                            </div>

                            <div className="flex w-[113.00rem] items-center gap-[0.38rem] overflow-x-scroll md:flex-col">
                              <div className="flex w-[18.88rem] flex-1 items-center gap-[0.38rem] md:self-stretch">
                                <div className="flex w-[12%] flex-col items-end justify-center bg-white-a700 px-[0.38rem]">
                                  <Input
                                    shape="square"
                                    name="ID Edit Field"
                                    placeholder="{n}"
                                    className="w-[72%] px-[0.13rem]"
                                  />
                                </div>
                                <Img
                                  src="images/img_folder.svg"
                                  alt="Second Folder Image"
                                  className="h-[2.25rem] w-[18%] object-contain"
                                />
                                <div className="flex flex-1 bg-white-a700 px-[1.38rem] sm:px-[1.25rem]">
                                  <Input
                                    shape="square"
                                    name="Second Account ID Edit"
                                    placeholder="{Account ID}"
                                    className="w-[80%] px-[0.13rem]"
                                  />
                                </div>

                                <div className="flex w-[15.25rem] bg-white-a700 px-[0.75rem]">
                                  <Input
                                    shape="square"
                                    type="text"
                                    name="Second Full Name Edit"
                                    placeholder="{Full name}"
                                    className="w-[52%] px-[0.13rem]"
                                  />
                                </div>
                                <Input
                                  shape="square"
                                  type="number"
                                  name="Second Phone Edit"
                                  placeholder="{Phone}"
                                  className="w-[15.25rem] px-[0.13rem]"
                                />

                                <div className="flex h-[2.38rem] w-[15.25rem] items-center bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto">
                                  <Input
                                    shape="square"
                                    type="email"
                                    name="Second Email Edit"
                                    placeholder="{Email}"
                                    className="w-[30%] px-[0.13rem]"
                                  />
                                </div>
                                <div className="flex h-[2.25rem] w-[15.25rem] items-center self-start bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto md:self-auto">
                                  <Text
                                    size="texts"
                                    as="p"
                                    className="text-[1.69rem] font-normal text-black-900 md:text-[1.56rem] sm:text-[1.44rem]"
                                  >
                                    Farm name
                                  </Text>
                                </div>

                                <div className="flex h-[2.25rem] w-[15.25rem] items-center self-start bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto md:self-auto">
                                  <Text
                                    size="texts"
                                    as="p"
                                    className="text-[1.69rem] font-normal text-black-900 md:text-[1.56rem] sm:text-[1.44rem]"
                                  >
                                    Farm location
                                  </Text>
                                </div>

                                <div className="flex h-[2.25rem] w-[15.25rem] items-center self-start bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto md:self-auto">
                                  <Text
                                    size="texts"
                                    as="p"
                                    className="text-[1.69rem] font-normal text-black-900 md:text-[1.56rem] sm:text-[1.44rem]"
                                  >
                                    Farm size
                                  </Text>
                                </div>
                              </div>

                              <div className="flex w-[113.00rem] items-center gap-[0.38rem] overflow-x-scroll md:flex-col">
                                <div className="flex w-[18.88rem] flex-1 items-center gap-[0.38rem] md:self-stretch">
                                  <div className="flex w-[12%] flex-col items-end justify-center bg-white-a700 px-[0.38rem]">
                                    <Input
                                      shape="square"
                                      name="Third ID Edit"
                                      placeholder={" "}
                                      className="w-[72%] px-[0.13rem]"
                                    />
                                  </div>
                                  <Img
                                    src="images/img_folder.svg"
                                    alt="Third Folder Image"
                                    className="h-[2.25rem] w-[18%] object-contain"
                                  />
                                  <div className="flex flex-1 bg-white-a700 px-[1.38rem] sm:px-[1.25rem]">
                                    <Input
                                      shape="square"
                                      name="Third Account ID Edit"
                                      placeholder={"Account ID"}
                                      className="w-[80%] px-[0.13rem]"
                                    />
                                  </div>
                                </div>
                                <div className="flex w-[15.25rem] bg-white-a700 px-[0.75rem]">
                                  <Input
                                    shape="square"
                                    type="text"
                                    name="Third Full Name Edit"
                                    placeholder={"Full name"}
                                    className="w-[52%] px-[0.13rem]"
                                  />
                                </div>
                                <Input
                                  shape="square"
                                  type="number"
                                  name="Third Phone Edit"
                                  placeholder={"Phone"}
                                  className="w-[15.25rem] px-[0.13rem]"
                                />
                                <div className="flex h-[2.38rem] w-[15.25rem] items-center bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto">
                                  <Input
                                    shape="square"
                                    type="email"
                                    name="Third Email Edit"
                                    placeholder={"Email"}
                                    className="w-[30%] px-[0.13rem]"
                                  />
                                </div>
                                <div className="flex h-[2.25rem] w-[15.25rem] items-center self-start bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto md:self-auto">
                                  <Text
                                    size="texts"
                                    as="p"
                                    className="text-[1.69rem] font-normal text-black-900 md:text-[1.56rem] sm:text-[1.44rem]"
                                  >
                                    Farm name
                                  </Text>
                                </div>
                                <div className="flex h-[2.25rem] w-[15.25rem] items-center self-start bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto md:self-auto">
                                  <Text
                                    size="texts"
                                    as="p"
                                    className="text-[1.69rem] font-normal text-black-900 md:text-[1.56rem] sm:text-[1.44rem]"
                                  >
                                    Farm location
                                  </Text>
                                </div>
                                <div className="flex h-[2.25rem] w-[15.25rem] items-center self-start bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto md:self-auto">
                                  <Text
                                    size="texts"
                                    as="p"
                                    className="text-[1.69rem] font-normal text-black-900 md:text-[1.56rem] sm:text-[1.44rem]"
                                  >
                                    Farm size
                                  </Text>
                                </div>
                                <div className="mb-[14.63rem] flex w-[113.00rem] items-center gap-[0.38rem] overflow-x-scroll md:flex-col">
                                  <div className="flex w-[18.88rem] flex-1 items-center gap-[0.38rem] md:self-stretch">
                                    <CheckBox
                                      name="Checkbox Field"
                                      label="n"
                                      id="CheckboxField"
                                      className="pr-[0.38rem] text-[1.69rem] text-black-900"
                                    />
                                    <Img
                                      src="images/img_folder.svg"
                                      alt="Fourth Folder Image"
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
                                      name="Fourth Full Name Edit"
                                      placeholder={`Full name`}
                                      className="w-[52%] px-[0.13rem]"
                                    />
                                  </div>

                                  <div className="flex w-[15.25rem] bg-white-a700 px-[0.75rem]">
                                    <Input
                                      shape="square"
                                      type="number"
                                      name="Fourth Phone Edit"
                                      placeholder={`Phone`}
                                      className="w-[34%] px-[0.13rem]"
                                    />
                                  </div>

                                  <div className="flex h-[2.38rem] w-[15.25rem] items-center bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto">
                                    <Input
                                      shape="square"
                                      type="email"
                                      name="Fourth Email Edit"
                                      placeholder={`Email`}
                                      className="w-[30%] px-[0.13rem]"
                                    />
                                  </div>
                                  <div className="flex h-[2.25rem] w-[15.25rem] items-center self-start bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto md:self-auto">
                                    <Text
                                      size="texts"
                                      as="p"
                                      className="text-[1.69rem] font-normal text-black-900 md:text-[1.56rem] sm:text-[1.44rem]"
                                    >
                                      Farm name
                                    </Text>
                                  </div>

                                  <div className="flex h-[2.25rem] w-[15.25rem] items-center self-start bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto md:self-auto">
                                    <Text
                                      size="texts"
                                      as="p"
                                      className="text-[1.69rem] font-normal text-black-900 md:text-[1.56rem] sm:text-[1.44rem]"
                                    >
                                      Farm location
                                    </Text>
                                  </div>

                                  <div className="flex h-[2.25rem] w-[15.25rem] items-center self-start bg-[url(/public/images/img_group_22.svg)] bg-cover bg-no-repeat px-[0.75rem] md:h-auto md:self-auto">
                                    <Text
                                      size="texts"
                                      as="p"
                                      className="text-[1.69rem] font-normal text-black-900 md:text-[1.56rem] sm:text-[1.44rem]"
                                    >
                                      Farm size
                                    </Text>
                                  </div>
                                </div>
                              </div>
                            </div>
                            <div className="absolute left-0 right-0 top-[1.19rem] m-auto flex w-[46%] justify-end">
                              <SelectBox
                                size="xs"
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
                                className="mb-[7.88rem] w-[68%] gap-[1.00rem]"
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
