import React, { useEffect, useState } from "react";
import "./single.scss";
import Sidebar from "../../components/sidebar/Sidebar";
import Navbar from "../../components/navbar/Navbar";
import List from "../../components/table/Table";

{
  /* 
const Single = () => {
  const [user, setUser] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({});
  const userId = "12345"; // Replace with dynamic ID logic if needed

  // Fetch user data
  useEffect(() => {
    // Mock data for testing
    const mockData = {
      role: "buyer", // Change to "buyer" to test buyer-specific fields
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
      document: "https://example.com/document.pdf",
    };

    // Simulate API delay
    setTimeout(() => {
      setUser(mockData);
      setFormData(mockData);
    }, 1000); // 1-second delay to mimic an API call
  }, []);
//comment from this
    const fetchUserData = async () => {
      try {
        // Replace with your actual API call
        const response = await fetch(`/api/users/${userId}`);
        const userData = await response.json();
        setUser(userData);
      } catch (error) {
        console.error("Error fetching user data:", error);
      }
    };

    fetchUserData();
  }, [userId]);
 
  // to this
  if (!user) {
    return <div>Loading...</div>;
  }

  // Destructure user data
  const {
    role,
    name,
    email,
    phone,
    username,
    userID,
    profilePicture,
    address, // delivery address for buyers or farm address for farmers
    farmSize,
    crops,
    governmentID,
    farmName,
    document,
  } = user;

  return (
    <div className="single">
      <Sidebar />
      <div className="singleContainer">
        <Navbar />
        <div className="top">
          <div className="left">
            <div className="editButton">Edit</div>
            <h1 className="title">Information</h1>
            <div className="item">
              <img
                src={profilePicture || "https://via.placeholder.com/100"}
                alt="Profile"
                className="itemImg"
              />
              <div className="details">
                <h1 className="itemTitle">{name}</h1>
                <div className="detailItem">
                  <span className="itemKey">Email:</span>
                  <span className="itemValue">{email}</span>
                </div>
                <div className="detailItem">
                  <span className="itemKey">Phone:</span>
                  <span className="itemValue">{phone}</span>
                </div>
                <div className="detailItem">
                  <span className="itemKey">Username:</span>
                  <span className="itemValue">{username}</span>
                </div>
                <div className="detailItem">
                  <span className="itemKey">User ID:</span>
                  <span className="itemValue">{userID}</span>
                </div>
                <div className="detailItem">
                  <span className="itemKey">
                    {role === "buyer" ? "Delivery Address:" : "Farm Address:"}
                  </span>
                  <span className="itemValue">{address}</span>
                </div>
                {role === "farmer" && (
                  <>
                    <div className="detailItem">
                      <span className="itemKey">Farm Name:</span>
                      <span className="itemValue">{farmName}</span>
                    </div>
                    <div className="detailItem">
                      <span className="itemKey">Farm Size:</span>
                      <span className="itemValue">{farmSize}</span>
                    </div>
                    <div className="detailItem">
                      <span className="itemKey">Types of Crops:</span>
                      <span className="itemValue">{crops}</span>
                    </div>
                    <div className="detailItem">
                      <span className="itemKey">Government ID:</span>
                      <span className="itemValue">{governmentID}</span>
                    </div>
                    <div className="detailItem">
                      <span className="itemKey">Verification Document:</span>
                      <span className="itemValue">{document}</span>
                    </div>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
        <div className="bottom">
          <h1 className="title">Last Transactions</h1>
          <List />
        </div>
      </div>
    </div>
  );
};

export default Single;
*/
}

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

    // Simulate fetching data
    setTimeout(() => {
      setUser(mockUser);
      setFormData(mockUser);
    }, 1000);
  }, []);

  const handleEditClick = () => {
    setIsEditing(true);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSaveClick = () => {
    // For now, just update the user state locally
    setUser(formData);
    setIsEditing(false);
    alert("Changes saved locally!");
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
        <div className="bottom">
          <h1 className="title">Last Transactions</h1>
          <List />
        </div>
      </div>
    </div>
  );
};

export default Single;
