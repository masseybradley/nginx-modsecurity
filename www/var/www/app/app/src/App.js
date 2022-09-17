import React, { useState, useEffect } from 'react';
import axios from 'axios'
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
    ipv4
    longitude
    latitude
  }
}
`;

const CREATE_IP_ADDRESS_MUTATION = gql`
mutation CreateIPAddressMutation ( $ipv4: String!, $longitude: String!, $latitude: String! ) {
  createIpAddress( ipv4: $ipv4, longitude: $longitude, latitude: $latitude ) {
    ipv4
    longitude
    latitude
  }
}
`;

function IPAddressListing() {
  const useQueryResult = useQuery(ALL_IP_ADDRESSES_QUERY, { variables: { offset: 0, limit: 20 } });
  if (useQueryResult.loading)
    return 'loading...';
  if (useQueryResult.error)
    return 'failed loading all IP addresses.';
  const allIpAddresses = useQueryResult.data.allIpAddresses;
  return <div>
    <ul>
      {allIpAddresses.map((ip) => {
        return (
          <div>
            <li key={ip.id}>IP: {ip.ipv4} ({ip.longitude}, {ip.latitude})</li>
          </div>
        );
      })}
    </ul>
  </div>;
}


function IPCallback(props) {
  const [createIpAddress, { loading, error }] = useMutation(CREATE_IP_ADDRESS_MUTATION)
  createIpAddress({variables: {ipv4: props.ipv4, longitude: props.longitude, latitude: props.latitude}})
}

function App() {
  const [ipv4, setIPv4] = useState('');
  const [longitude, setLongitude] = useState('');
  const [latitude, setLatitude] = useState('');

  const getData = async () => {
    const res = await axios.get('https://geolocation-db.com/json/')
    console.log(res.data);
    setIPv4(res.data.IPv4)
    setLongitude(res.data.longitude)
    setLatitude(res.data.latitude)
  }

  useEffect( () => {
    getData()
  }, [])

  return (
    <div className="App">
      <h2>Your IP Address is</h2>
      <h4>{ipv4}</h4>
      <ApolloProvider client={client}>
        <IPCallback ipv4={ipv4} longitude={longitude} latitude={latitude}/>
        <IPAddressListing/>
      </ApolloProvider>
    </div>
  );
}

export default App;