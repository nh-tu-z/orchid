import React, { useReducer, useCallback, useEffect, useState } from "react";
import Web3 from "web3";
import EthContext from "./EthContext";
import { reducer, actions, initialState } from "./state";

function EthProvider({ children }) {
  const [state, dispatch] = useReducer(reducer, initialState);
  const [contractState, setContractState] = useState({cost: 0, itemName: "exampleItem1", loaded: false})

  const init = useCallback(
    async artifact => {
      if (artifact) {
        // connect to local blockchain Ganache
        const web3 = new Web3("HTTP://127.0.0.1:7545")

        let accounts;
        await web3.eth.getAccounts()
          .then(accs => accounts = accs)
          .catch(err => console.log(err))
        console.log(accounts)

        let networkID;
        await web3.eth.net.getId()
          .then(id => networkID = id)
          .catch(err => console.log(err))
        console.log(networkID)

        setContractState({loaded: true})
        console.log(contractState)

        const { abi } = artifact
        let address, contract
        try {
          address = artifact.networks[networkID].address
          contract = new web3.eth.Contract(abi, address)
        } catch (err) {
          console.error(err)
        }
        dispatch({
          type: actions.init,
          data: { artifact, web3, accounts, networkID, contract }
        })
      }
    }, [])

  useEffect(() => {
    console.log('we\'re in useEffect() no dependencies')
    const tryInit = async () => {
      try {
        const artifact = require("../../contracts/ItemManager.json")
        console.log('artifact', artifact)
        init(artifact)
      } catch (err) {
        console.error(err)
      }
    };

    tryInit()
  }, [init])

  useEffect(() => {
    console.log('we\'re in useEffect() with some dependencies');
    const events = ["chainChanged", "accountsChanged"];
    const handleChange = () => {
      init(state.artifact);
    };

    events.forEach(e => window.ethereum.on(e, handleChange));
    return () => {
      events.forEach(e => window.ethereum.removeListener(e, handleChange));
    };
  }, [init, state.artifact]);

  return (
    <EthContext.Provider value={{
      state,
      dispatch
    }}>
      {children}
    </EthContext.Provider>
  );
}

export default EthProvider;
