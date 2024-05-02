import { getContract, getProvider, readContract } from '@wagmi/core';
import React, { useEffect, useState } from 'react'
// import { ethers } from 'ethers'
import { erc20ABI } from 'wagmi';

export const Ethers = () => {
    const [data, setData] = useState("");

    // const provider = getProvider({ chainId: 5 });
    // const contract = getContract("0xccF6772F52D007E082bF4A01757C4091F5f4dD92",
    //     erc20ABI, provider)
    // console.log(contract)
    const jery = async () => {
        const data = await readContract({
                address: "0x6c07ebb84bd92d6bbbac6cf2d4ac0610fab6e39f",
                    abi: erc20ABI,
                    functionName: 'name',
        })
        
        setData(data)
    
    }
    useEffect(() => {
        jery()
    })
    console.log(data);

  return (
      <div>Ethers {data} </div>
  )
}
