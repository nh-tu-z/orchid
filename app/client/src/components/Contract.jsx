import { EthContext } from "../contexts/EthContext";
import React from "react";
function Contract(props) {

    const {state, dispatch} = React.useContext(EthContext);
    console.log("helloo ",state, dispatch);

    console.log(props)
    return (
        <h1>tuhngo</h1>
      );
}

export default Contract