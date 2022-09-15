import React, { useState, useEffect } from 'react';
import './App.css';

import ApolloClient from 'apollo-boost';
import { gql } from 'apollo-boost';
import { useQuery, ApolloProvider, useMutation } from '@apollo/react-hooks';


const client = new ApolloClient({
  uri: 'http://localhost:8000/graphql'
})

const ALL_IP_ADDRESSES_QUERY = gql`
query {
  allIpAddresses {
    id
    ipAddress
  }
}
`;

const IPAddressListing = () => {
  const useQueryResult = useQuery(ALL_IP_ADDRESSES_QUERY, {variables: {offset: 0, limit: 20}})
  if (useQueryResult.loading) return 'loading...'
  if (useQueryResult.error) return 'failed loading all IP addresses.'
  const allIpAddresses = useQueryResult.data.allIpAddresses;
  return <div>
      <ul>
      {allIpAddresses.map((ip) => {
        return (
          <div>
            <li key={ip.id}>{ip.ipAddress}</li>
          </div>
        )
      })}
    </ul>
  </div>
}


function Welcome(props) {
    console.log(props)
    return <h1>Hello, {props.name}</h1>
}

const CreateIPAddressForm = () => {
  const [ipAddress, setIpAddress] = useState('')
  const [createIpAddress, { loading, error }] = useMutation(gql`
    mutation CreateIPAddressMutation ( $ipAddress: String! ) {
      createIpAddress( ipAddress: $ipAddress ) {
        ipAddress
      }
    }
  `, {
    refetchQueries: [
      { query: ALL_IP_ADDRESSES_QUERY },
    ]
  })
  if (loading) return 'loading.....'
  if (error) return 'error'
  return (
    <>
      <input type="text" value={ipAddress} onChange={e => setIpAddress(e.target.value)}/>
      <button onClick={() => {
        createIpAddress({variables:{ ipAddress: ipAddress }})
      }}>Submit</button>
    </>
  )
}

function IPCallback() {
  const [error, setError] = useState(null);
  const [isLoaded, setIsLoaded] = useState(false);
  const [items, setItems] = useState([]);

  useEffect(() => {
    fetch("https://geolocation-db.com/json/")
      .then(res => res.json())
      .then(
        (result) => {
          setIsLoaded(true);
          setItems(result);
          console.log(result);
        },
        (error) => {
          setIsLoaded(true);
          setError(error);
        }
      )
  }, [])
  if (error) {
    return <div>Error: {error.message}</div>;
  } else if (!isLoaded) {
    return <div>Loading...</div>;
  } else {
    return <div>OK</div>;
  }
}

function App() {
  return (
    <div className="App">
      <ApolloProvider client={client}>
        <IPCallback/>
        <Welcome name="bob"/>
        <IPAddressListing/>
        <CreateIPAddressForm/>
      </ApolloProvider>
    </div>
  );
}

export default App;