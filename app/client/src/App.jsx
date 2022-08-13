import { EthProvider } from "./contexts/EthContext";
import "./App.css";
import "./components/Contract"
import Contract from "./components/Contract";

function App() {
  return (
    <EthProvider>
      <Contract />
    </EthProvider>
  );
}

export default App;
