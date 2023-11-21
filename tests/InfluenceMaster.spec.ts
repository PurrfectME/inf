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
import { FundContract } from '../build/Fund/tact_FundContract';
import { InfluenceWallet } from '../build/Fund/tact_InfluenceWallet';



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

    // it('should create donater jetton wallet', async () => {
    //     const user = await blockchain.treasury('user');
    //     await influenceMaster.send(
    //         user.getSender(),
    //         {
    //             value: toNano('1'),
    //         },
    //         'buy'
    //     );

    //     const userJettonWalletAddress = await influenceMaster.getGetWalletAddress(user.address);

    //     const jettonWallet = blockchain.openContract(
    //         await InfluenceWallet.fromInit(influenceMaster.address, user.address, 0n)
    //     );

    //     expect(jettonWallet.address.toString()).toEqual(userJettonWalletAddress.toString());
    //     expect((await jettonWallet.getGetWalletData()).balance).toEqual(toNano(1));
    // });

    it('should create item jetton wallet', async () => {
        const user = await blockchain.treasury('user');

        // await influenceMaster.send(
        //     deployer.getSender(),
        //     {
        //         value: toNano('1'),
        //     },
        //     null
        // );
        const fund = blockchain.openContract(await FundContract.fromInit(influenceMaster.address, 1n));

        await influenceMaster.send(
            user.getSender(),
            {
                value: toNano('1'),
            },
            'fund'
        );

        await fund.send(deployer.getSender(), { value: toNano('1') }, null);
        console.log('1', fromNano((await fund.getFundData()).balance));
        // console.log('FUND', await fund.getFundData());

        await fund.send(
            user.getSender(),
            {
                value: toNano('0.2'),
            },
            'item'
        );

        // console.log('ITEM SEQNO', (await fund.getFundData()).itemSeqno);

        const itemJettonWalletAddress = await fund.getGetItemAddress(1n);
        // const adr = (await fund.getAdr()).toString()

        const jettonWallet = blockchain.openContract(
            await InfluenceWallet.fromInit(influenceMaster.address, fund.address, 1n)
        );

        await jettonWallet.send(deployer.getSender(), { value: toNano('1') }, null);


        // console.log('ASD', (await jettonWallet.getGetWalletData()).owner.toString() == fund.address.toString());
        
        expect((await jettonWallet.getGetWalletData()).seqno).toEqual(1n);

        expect(itemJettonWalletAddress.toString()).toEqual(jettonWallet.address.toString());

    });
});
