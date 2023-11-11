import { Blockchain, EventAccountCreated, SandboxContract, TreasuryContract } from '@ton-community/sandbox';
import {
    Address,
    BitBuilder,
    BitReader,
    Builder,
    Cell,
    Dictionary,
    Slice,
    beginCell,
    fromNano,
    toNano,
} from 'ton-core';
import '@ton-community/test-utils';
import { buildOnchainMetadata } from '../contracts/build_data';
import { InfluenceMaster } from '../build/InfluenceMaster/tact_InfluenceMaster';
import { FundContract } from '../build/InfluenceMaster/tact_FundContract';

describe('InfluenceMaster', () => {
    let blockchain: Blockchain;
    let influenceMaster: SandboxContract<InfluenceMaster>;
    let deployer: SandboxContract<TreasuryContract>;

    const metadata = {
        name: 'INFLUENCE WORLD',
        description: 'KAK JE YA HAROSH',
        image: 'https://yt3.googleusercontent.com/YR8JivTsOQ4svnDFCdnIqYAPhwIeTRg8w0Sukv1orUYJoN2iZtaEprhWXcweMdrtcGGmptvSgQ=s176-c-k-c0x00ffffff-no-rj',
        symbol: 'INFK',
    };

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        influenceMaster = blockchain.openContract(await InfluenceMaster.fromInit(buildOnchainMetadata(metadata), 100n));

        deployer = await blockchain.treasury('deployer');

        const deployResult = await influenceMaster.send(
            deployer.getSender(),
            {
                value: toNano('0.5'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        console.log('ASD', influenceMaster.address);

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: influenceMaster.address,
            deploy: true,
            success: true,
        });
    });

    it('should return fund items', async () => {
        const user = await blockchain.treasury('user');
        const res = await influenceMaster.send(
            user.getSender(),
            {
                value: toNano('0.5'),
            },
            'fund'
        );

        const fundAddress = (res.events.find((x) => x.type == 'account_created') as EventAccountCreated).account;

        const fund = blockchain.openContract(FundContract.fromAddress(fundAddress));

        await fund.send(
            user.getSender(),
            {
                value: toNano('0.5'),
            },
            'item'
        );

        // const lastAddress = await fund.getLastItemAddress();
        const actualAddress = await fund.getGetAllItemsAddresses();

        // console.log('LAST -', lastAddress);
        console.log('ACTUAL -', actualAddress);
    });

    // it('should create fund', async () => {
    //     const user = await blockchain.treasury('user');
    //     const res = await influenceMaster.send(
    //         user.getSender(),
    //         {
    //             value: toNano('0.5'),
    //         },
    //         'fund'
    //     );

    //     const fundAddress = (res.events.find(x => x.type == 'account_created') as EventAccountCreated).account;

    //     let fund = blockchain.openContract(FundContract.fromAddress(fundAddress));
    //     console.log('FUND DATA', await fund.getFundData());
    // });

    // it('should create fund item', async () => {
    //     const user = await blockchain.treasury('user');
    //     const res = await influenceMaster.send(
    //         user.getSender(),
    //         {
    //             value: toNano('0.5'),
    //         },
    //         'fund'
    //     );

    //     const fundAddress = (res.events.find(x => x.type == 'account_created') as EventAccountCreated).account;

    //     console.log('ADRES', fundAddress);

    //     // let fund = blockchain.openContract(FundContract.fromAddress(fundAddress));
    //     // const itemRes = await fund.send(user.getSender(),
    //     // {
    //     //     value: toNano("0.5")
    //     // },
    //     // 'item'
    //     // );

    //     // const itemAddress = (itemRes.events.find(x => x.type == 'account_created') as EventAccountCreated).account;
    //     // let fundItem = blockchain.openContract(FundItem.fromAddress(itemAddress));

    //     // console.log('FUND ITEM DATA', await fundItem.getItemData());
    // });
});
