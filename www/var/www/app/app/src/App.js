import React, { useState } from 'react';
import './App.css';

import ApolloClient from 'apollo-boost';
import { gql } from 'apollo-boost';
import { useQuery, ApolloProvider, useMutation } from '@apollo/react-hooks';


const client = new ApolloClient({
  uri: 'http://localhost:8000/graphql'
})

const ALL_IP_ADDRESSES_QUERY = gql`
query {
  allIPAddresses {
    id
    ip_address 
  }
}
`;

const IPAddressListing = () => {
  const useQueryResult = useQuery(ALL_IP_ADDRESSES_QUERY, {variables: {offset: 0, limit: 20}})
  if (useQueryResult.loading) return 'loading...'
  if (useQueryResult.error) return 'failed loading all IP addresses.'
  const allIPAddresses = useQueryResult.data.allIPAddresses;
  return <div>
      <ul>
      {allIPAddresses.map((ip) => {
        return (
          <div>
            <li key={ip.id}>{ip.ip_address}</li>
          </div>
        )
      })}
    </ul>
  </div>
}

// <Doughnut ref={coin.sno} data={coin.name} />
// const Coins = (onCoinSelected) => {
//   const { loading, error, data } = useQuery(ALL_COINS_QUERY);
// 
//   if (loading) return 'Loading...';
//   if (error) return `Error! ${error.message}`;
// 
//   return (
//     <select name="coin" onChange={onCoinSelected}>
//       {data.coins.map(coin => (
//         <option key={coin.id} value={coin.name}>
//           {coin.name}
//         </option>
//       ))}
//     </select>
//   );
// }

// const CreateExampeForm = () => {
//   const [name, setName] = useState('')
//   const [createExample, { loading, error }] = useMutation(gql`
//     mutation CreateExampleMutation ( $name: String! ) {
//       createExample( name: $name ) {
//         id
//         name
//       }
//     }
//   `, {
//     refetchQueries: [
//       { query: ALL_EXAMPLES_QUERY },
//     ]
//   })
//   if (loading) return 'loading.....'
//   if (error) return 'error'
//   return (
//     <>
//       <input type="text" value={name} onChange={e => setName(e.target.value)}/>
//       <button onClick={() => {
//         createExample({variables:{ name: name }})
//       }}>Submit</button>
//     </>
//   )
// }


function App() {
  return (
    <div className="App">
      <ApolloProvider client={client}>
        <IPAddressListing/>
      </ApolloProvider>
    </div>
  );
}

export default App;