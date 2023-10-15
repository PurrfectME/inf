import { Address, toNano } from 'ton-core';
import { NetworkProvider } from '@ton-community/blueprint';
import { InfluenceMasterContract } from '../build/InfluenceMaster/tact_InfluenceMasterContract';

export async function run(provider: NetworkProvider) {
    const influenceMaster = provider.open(await InfluenceMasterContract.fromInit(100n));

    await influenceMaster.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(influenceMaster.address);

    await influenceMaster.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Mint',
            amount: toNano("0.2"),
            receiver: Address.parse("UQAFFZBZR55rbYzO7c4mQCwscxZIhw8pr8ZmrchN1W7eIMLx")
        }
    );

    // run methods on `influenceMaster`
}
