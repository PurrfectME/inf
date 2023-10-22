import { Blockchain, SandboxContract, TreasuryContract } from '@ton-community/sandbox';
import { Address, beginCell, toNano } from 'ton-core';
import '@ton-community/test-utils';
import { InfluenceMasterContract } from '../build/InfluenceMaster/tact_InfluenceMasterContract';
import { buildOnchainMetadata } from '../contracts/build_data';

describe('InfluenceMaster', () => {
    let blockchain: Blockchain;
    let influenceMaster: SandboxContract<InfluenceMasterContract>;
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
            await InfluenceMasterContract.fromInit(buildOnchainMetadata(metadata), 100n));

        deployer = await blockchain.treasury('deployer');

        const deployResult = await influenceMaster.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
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

    it('should deploy', async () => {
        const res = await influenceMaster.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            'Mint: 100'
        );


    });
});
