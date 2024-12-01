import React, { useEffect, useState } from "react";
import "./single.scss";
import Sidebar from "../../components/sidebar/Sidebar";
import Navbar from "../../components/navbar/Navbar";

const Single = () => {
  const [user, setUser] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({});

  useEffect(() => {
    // Mock user data for testing
    const mockUser = {
      role: "farmer", // Change to "buyer" to test buyer-specific fields
      name: "John Doe",
      email: "john.doe@example.com",
      phone: "+1 555-1234",
      username: "john_doe",
      userID: "12345",
      profilePicture: "https://via.placeholder.com/100",
      address: "123 Farm Lane",
      farmSize: "50 acres",
      crops: "Corn, Wheat",
      governmentID: "123456789",
      farmName: "Green Acres",
      document: "N/A",
    };

    // fetch from table
    setUser(mockUser);
    setFormData(mockUser);
  }, []);

  const handleEditClick = () => {
    setIsEditing(true);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  //update query
  const handleSaveClick = () => {
    setUser(formData);
    setIsEditing(false);
  };

  if (!user) {
    return <div>Loading...</div>;
  }

  const isFarmer = user.role === "farmer";

  return (
    <div className="single">
      <Sidebar />
      <div className="singleContainer">
        <Navbar />
        <div className="top">
          <div className="left">
            {isEditing ? (
              <>
                <h1 className="title">Edit Information</h1>
                <form>
                  <input
                    type="text"
                    name="name"
                    value={formData.name}
                    onChange={handleInputChange}
                    placeholder="Name"
                  />
                  <input
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleInputChange}
                    placeholder="Email"
                  />
                  <input
                    type="text"
                    name="phone"
                    value={formData.phone}
                    onChange={handleInputChange}
                    placeholder="Phone"
                  />
                  <input
                    type="text"
                    name="username"
                    value={formData.username}
                    onChange={handleInputChange}
                    placeholder="Username"
                  />
                  {isFarmer && (
                    <>
                      <input
                        type="text"
                        name="address"
                        value={formData.address}
                        onChange={handleInputChange}
                        placeholder="Farm Address"
                      />
                      <input
                        type="text"
                        name="farmSize"
                        value={formData.farmSize}
                        onChange={handleInputChange}
                        placeholder="Farm Size"
                      />
                      <input
                        type="text"
                        name="crops"
                        value={formData.crops}
                        onChange={handleInputChange}
                        placeholder="Crops"
                      />
                    </>
                  )}
                </form>
                <button
                  type="button"
                  className="saveButton"
                  onClick={handleSaveClick}
                >
                  Save
                </button>
              </>
            ) : (
              <>
                <div className="editButton" onClick={handleEditClick}>
                  Edit
                </div>
                <h1 className="title">Information</h1>
                <div className="item">
                  <img
                    src={
                      user.profilePicture || "https://via.placeholder.com/100"
                    }
                    alt="Profile"
                    className="itemImg"
                  />
                  <div className="details">
                    <h1 className="itemTitle">{user.name}</h1>
                    <div className="detailItem">
                      <span className="itemKey">Email:</span>
                      <span className="itemValue">{user.email}</span>
                    </div>
                    <div className="detailItem">
                      <span className="itemKey">Phone:</span>
                      <span className="itemValue">{user.phone}</span>
                    </div>
                    <div className="detailItem">
                      <span className="itemKey">Username:</span>
                      <span className="itemValue">{user.username}</span>
                    </div>
                    <div className="detailItem">
                      <span className="itemKey">
                        {isFarmer ? "Farm Address:" : "Delivery Address:"}
                      </span>
                      <span className="itemValue">{user.address}</span>
                    </div>
                    {isFarmer && (
                      <>
                        <div className="detailItem">
                          <span className="itemKey">Farm Size:</span>
                          <span className="itemValue">{user.farmSize}</span>
                        </div>
                        <div className="detailItem">
                          <span className="itemKey">Crops:</span>
                          <span className="itemValue">{user.crops}</span>
                        </div>
                      </>
                    )}
                  </div>
                </div>
              </>
            )}
          </div>
        </div>
        {/*<div className="bottom">
          <h1 className="title">Last Transactions</h1>
          <List />
        </div>*/}
      </div>
    </div>
  );
};

export default Single;
