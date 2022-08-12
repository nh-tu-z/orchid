import { EthProvider } from "./contexts/EthContext";
import "./App.css";

function App() {
  return (
    <EthProvider>
      <h1>Tuhngo hello blockchain</h1>
    </EthProvider>
  );
}

export default App;
