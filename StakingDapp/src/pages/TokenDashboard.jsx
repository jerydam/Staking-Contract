import { erc20ABI, useContractReads } from "wagmi"
import standard from "../utils/abi/StandardERC20.json"

export const TokenDashboard = () => {
    const def = {
        address: "0xC84a23b8C65d3d7a4c793bb846258123456b7777",
        abi: erc20ABI,
    }
    const { data, isError, isLoading } = useContractReads({
        contracts: [
            {
                ...def,
                abi: standard,
            functionName: 'tokenName'
            },
            {
            ...def,
            functionName: 'symbol'
            },
            {
            ...def,
            functionName: 'decimal'
            }
        ]
    }
    )
    if (isLoading) {
        return <div>Loading</div>
    } return (
        <div>
            {data}
            {data.forEach((e, i) => {
                return (
                    <div> {e}</div>
                )
            })}
        </div>
    )
}