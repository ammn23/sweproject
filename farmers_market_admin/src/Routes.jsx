import React from "react";
import { useRoutes } from "react-router-dom";
import Home from "pages/Home";
import NotFound from "pages/NotFound";
import Administratorview from "pages/Administratorview";
import Farmermanagement from "pages/Farmermanagement";
import Buyermanagement from "pages/Buyermanagement";

const ProjectRoutes = () => {
  let element = useRoutes([
    { path: "/", element: <Home /> },
    { path: "*", element: <NotFound /> },
    {
      path: "administratorview",
      element: <Administratorview />,
    },
    {
      path: "farmermanagement",
      element: <Farmermanagement />,
    },
    {
      path: "buyermanagement",
      element: <Buyermanagement />,
    },
  ]);

  return element;
};

export default ProjectRoutes;
