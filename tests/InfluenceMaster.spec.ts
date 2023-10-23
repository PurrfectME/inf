import { Blockchain, EventAccountCreated, SandboxContract, TreasuryContract } from '@ton-community/sandbox';
import { Address, beginCell, fromNano, toNano } from 'ton-core';
import '@ton-community/test-utils';
import { buildOnchainMetadata } from '../contracts/build_data';
import { FundContract } from '../build/InfluenceMaster/tact_FundContract';
import { InfluenceMaster } from '../wrappers/InfluenceMaster';

describe('InfluenceMaster', () => {
    let blockchain: Blockchain;
    let influenceMaster: SandboxContract<InfluenceMaster>;
    let deployer: SandboxContract<TreasuryContract>;

    const metadata = {
        "name": "INFLUENCE WORLD",
        "description": "KAK JE YA HAROSH",
        "image": "https://yt3.googleusercontent.com/YR8JivTsOQ4svnDFCdnIqYAPhwIeTRg8w0Sukv1orUYJoN2iZtaEprhWXcweMdrtcGGmptvSgQ=s176-c-k-c0x00ffffff-no-rj",
        "symbol": "INFK"
    };

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        influenceMaster = blockchain.openContract(
            await InfluenceMaster.fromInit(buildOnchainMetadata(metadata), 100n));

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

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: influenceMaster.address,
            deploy: true,
            success: true,
        });
    });

    it('should create fund', async () => {
        const user = await blockchain.treasury('user');
        const res = await influenceMaster.send(
            user.getSender(),
            {
                value: toNano('0.5'),
            },
            'fund'
        );


        const fundAddress = (res.events.find(x => x.type == 'account_created') as EventAccountCreated).account;

        let fund = blockchain.openContract(FundContract.fromAddress(fundAddress));
        console.log('FUND DATA', await fund.getBebe());
        
        // // console.log('OWNER', deployer.address);
        // // console.log('FUND OWNER', a);

    });
});
