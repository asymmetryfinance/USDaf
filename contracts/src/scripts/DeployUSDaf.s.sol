// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {StdCheats} from "forge-std/StdCheats.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {StringFormatting} from "../test/Utils/StringFormatting.sol";
import {Accounts} from "../test/TestContracts/Accounts.sol";
import {ERC20Faucet} from "../test/TestContracts/ERC20Faucet.sol";
import {ETH_GAS_COMPENSATION} from "../Dependencies/Constants.sol";
import {IBorrowerOperations} from "../Interfaces/IBorrowerOperations.sol";
import "../AddressesRegistry.sol";
import "../ActivePool.sol";
import "../BoldToken.sol";
import "../BorrowerOperations.sol";
import "../CollSurplusPool.sol";
import "../DefaultPool.sol";
import "../GasPool.sol";
import "../HintHelpers.sol";
import "../MultiTroveGetter.sol";
import "../SortedTroves.sol";
import "../StabilityPool.sol";
import "../test/TestContracts/BorrowerOperationsTester.t.sol";
import "../test/TestContracts/TroveManagerTester.t.sol";
import "../TroveNFT.sol";
import "../CollateralRegistry.sol";
import "../test/TestContracts/MetadataDeployment.sol";
import "../Zappers/WETHZapper.sol";
import "../Zappers/GasCompZapper.sol";
import "../Zappers/LeverageLSTZapper.sol";
import "../Zappers/LeverageWETHZapper.sol";
import "../Zappers/Modules/Exchanges/HybridCurveUniV3ExchangeHelpers.sol";
import {BalancerFlashLoan} from "../Zappers/Modules/FlashLoans/BalancerFlashLoan.sol";
import "../Zappers/Modules/Exchanges/Curve/ICurveStableswapNGFactory.sol";
import "../Zappers/Modules/Exchanges/UniswapV3/ISwapRouter.sol";
import "../Zappers/Modules/Exchanges/UniswapV3/IQuoterV2.sol";
import "../Zappers/Modules/Exchanges/UniswapV3/IUniswapV3Pool.sol";
import "../Zappers/Modules/Exchanges/UniswapV3/IUniswapV3Factory.sol";
import "../Zappers/Modules/Exchanges/UniswapV3/INonfungiblePositionManager.sol";
import "../Zappers/Modules/Exchanges/HybridCurveUniV3Exchange.sol";
import {WETHTester} from "../test/TestContracts/WETHTester.sol";
import "forge-std/console2.sol";
import {IRateProvider, IWeightedPool, IWeightedPoolFactory} from "./Interfaces/Balancer/IWeightedPool.sol";
import {IVault} from "./Interfaces/Balancer/IVault.sol";
import {WETHPriceFeed} from "../PriceFeeds/WETHPriceFeed.sol";
import {SpotUsdOracle} from "../PriceFeeds/SpotUsdOracle.sol";
import {WrappedAmplUsdOracle} from "../PriceFeeds/WrappedAmplUsdOracle.sol";
import {IWETH} from "../Interfaces/IWETH.sol";
import {MockInterestRouter} from "../MockInterestRouter.sol";
import {WrappedSpot} from "../WrappedSpot.sol";
import {ISimpleProxyFactory} from "./Interfaces/ISimpleProxyFactory.sol";
import {UnwrappedZapper} from "../Zappers/UnwrappedZapper.sol";
import {SpotZapper} from "../Zappers/SpotZapper.sol";
import {AmplZapper} from "../Zappers/AmplZapper.sol";

// ---- Usage ----

// deploy:
// forge script src/scripts/DeployUSDaf.s.sol:DeployUSDafScript --verify --slow --legacy --etherscan-api-key $KEY --rpc-url $RPC_URL --broadcast

interface IOracle {
    function initialize(address _owner) external;
}

contract DeployUSDafScript is StdCheats, MetadataDeployment {
    using Strings for *;
    using StringFormatting for *;

    ICurveStableswapNGFactory constant curveStableswapFactory =
        ICurveStableswapNGFactory(0x6A8cbed756804B16E05E741eDaBd5cB544AE21bf);
    uint128 constant BOLD_TOKEN_INDEX = 0;
    uint128 constant USDC_INDEX = 1;

    bytes32 SALT;
    address deployer;

    address owner = 0x63B8537C7a18F0Df8780cB5F36085E5FFAdb02a5; // @todo - change that

    uint256 lastTroveIndex;

    struct LiquityContractsTestnet {
        IAddressesRegistry addressesRegistry;
        IActivePool activePool;
        IBorrowerOperations borrowerOperations;
        ICollSurplusPool collSurplusPool;
        IDefaultPool defaultPool;
        ISortedTroves sortedTroves;
        IStabilityPool stabilityPool;
        ITroveManager troveManager;
        ITroveNFT troveNFT;
        MetadataNFT metadataNFT;
        WETHPriceFeed priceFeed;
        GasPool gasPool;
        IInterestRouter interestRouter;
        IERC20Metadata collToken;
        address zapper;
        GasCompZapper gasCompZapper;
        ILeverageZapper leverageZapper;
        address oracle;
    }

    struct LiquityContractAddresses {
        address activePool;
        address borrowerOperations;
        address collSurplusPool;
        address defaultPool;
        address sortedTroves;
        address stabilityPool;
        address troveManager;
        address troveNFT;
        address metadataNFT;
        address priceFeed;
        address gasPool;
        address interestRouter;
    }

    struct Zappers {
        WETHZapper wethZapper;
        GasCompZapper gasCompZapper;
    }

    struct TroveManagerParams {
        uint256 CCR;
        uint256 MCR;
        uint256 SCR;
        uint256 LIQUIDATION_PENALTY_SP;
        uint256 LIQUIDATION_PENALTY_REDISTRIBUTION;
    }

    struct DeploymentVarsTestnet {
        uint256 numCollaterals;
        IERC20Metadata[] collaterals;
        IAddressesRegistry[] addressesRegistries;
        ITroveManager[] troveManagers;
        LiquityContractsTestnet contracts;
        bytes bytecode;
        address boldTokenAddress;
        uint256 i;
    }

    struct DeploymentResult {
        LiquityContractsTestnet[] contractsArray;
        ICollateralRegistry collateralRegistry;
        IBoldToken boldToken;
        IERC20 usdc;
        ICurveStableswapNGPool usdcCurvePool;
        HintHelpers hintHelpers;
        MultiTroveGetter multiTroveGetter;
        IExchangeHelpers exchangeHelpers;
    }

    address wrappedSpot;
    address wrappedAmpl = 0xEDB171C18cE90B633DB442f2A6F72874093b49Ef;

    uint256 constant _24_HOURS = 86400;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant SPOT = 0xC1f33e0cf7e40a67375007104B929E49a581bafE;

    function run() public returns (DeploymentResult memory deployed) {
        SALT = keccak256(abi.encodePacked(block.timestamp));

        uint256 privateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        deployer = vm.addr(privateKey);
        vm.startBroadcast(privateKey);

        console2.log(deployer, "deployer");
        console2.log(deployer.balance, "deployer balance");

        TroveManagerParams[] memory troveManagerParamsArray = new TroveManagerParams[](2);
        troveManagerParamsArray[0] = TroveManagerParams(150e16, 110e16, 110e16, 5e16, 10e16); // WSPOT
        troveManagerParamsArray[1] = TroveManagerParams(150e16, 110e16, 110e16, 5e16, 10e16); // WAMPL

        string[] memory collNames = new string[](2);
        string[] memory collSymbols = new string[](2);
        collNames[0] = "Ampleforth Wrapped SPOT Token";
        collNames[1] = "Ampleforth Wrapped AMPL Token";
        collSymbols[0] = "WSPOT";
        collSymbols[1] = "WAMPL";

        deployed =
            _deployAndConnectContracts(troveManagerParamsArray, collNames, collSymbols);

        vm.stopBroadcast();

        string memory governanceManifest = "";
        vm.writeFile("deployment-manifest.json", _getManifestJson(deployed, governanceManifest));
    }

    // See: https://solidity-by-example.org/app/create2/
    function getBytecode(bytes memory _creationCode, address _addressesRegistry) public pure returns (bytes memory) {
        return abi.encodePacked(_creationCode, abi.encode(_addressesRegistry));
    }

    function _deployAndConnectContracts(
        TroveManagerParams[] memory troveManagerParamsArray,
        string[] memory _collNames,
        string[] memory _collSymbols
    ) internal returns (DeploymentResult memory r) {
        assert(_collNames.length == troveManagerParamsArray.length);
        assert(_collSymbols.length == troveManagerParamsArray.length);

        DeploymentVarsTestnet memory vars;
        vars.numCollaterals = troveManagerParamsArray.length;
        // Deploy Bold
        vars.bytecode = abi.encodePacked(type(BoldToken).creationCode, abi.encode(deployer));
        vars.boldTokenAddress = vm.computeCreate2Address(SALT, keccak256(vars.bytecode));
        r.boldToken = new BoldToken{salt: SALT}(deployer);
        assert(address(r.boldToken) == vars.boldTokenAddress);

        // USDC and USDC-BOLD pool
        r.usdc = IERC20(USDC);
        r.usdcCurvePool = _deployCurveBoldUsdcPool(r.boldToken, r.usdc);

        r.contractsArray = new LiquityContractsTestnet[](vars.numCollaterals);
        vars.collaterals = new IERC20Metadata[](vars.numCollaterals);
        vars.addressesRegistries = new IAddressesRegistry[](vars.numCollaterals);
        vars.troveManagers = new ITroveManager[](vars.numCollaterals);

        // deploy wrapped spot
        wrappedSpot = address(new WrappedSpot());
        console2.log(wrappedSpot, "wrappedSpot: ");

        vars.collaterals[0] = IERC20Metadata(wrappedSpot);
        vars.collaterals[1] = IERC20Metadata(wrappedAmpl);

        // Deploy AddressesRegistries and get TroveManager addresses
        for (vars.i = 0; vars.i < vars.numCollaterals; vars.i++) {
            (IAddressesRegistry addressesRegistry, address troveManagerAddress) =
                _deployAddressesRegistry(troveManagerParamsArray[vars.i]);
            vars.addressesRegistries[vars.i] = addressesRegistry;
            vars.troveManagers[vars.i] = ITroveManager(troveManagerAddress);
        }

        r.collateralRegistry = new CollateralRegistry(r.boldToken, vars.collaterals, vars.troveManagers);
        r.hintHelpers = new HintHelpers(r.collateralRegistry);
        r.multiTroveGetter = new MultiTroveGetter(r.collateralRegistry);

        // Deploy per-branch contracts for each branch
        for (vars.i = 0; vars.i < vars.numCollaterals; vars.i++) {
            vars.contracts = _deployAndConnectCollateralContractsMainnet(
                vars.collaterals[vars.i],
                r.boldToken,
                r.collateralRegistry,
                vars.addressesRegistries[vars.i],
                address(vars.troveManagers[vars.i]),
                r.hintHelpers,
                r.multiTroveGetter
            );
            r.contractsArray[vars.i] = vars.contracts;
        }

        r.boldToken.setCollateralRegistry(address(r.collateralRegistry));
    }

    function _deployAddressesRegistry(TroveManagerParams memory _troveManagerParams)
        internal
        returns (IAddressesRegistry, address)
    {
        IAddressesRegistry addressesRegistry = new AddressesRegistry(
            deployer,
            _troveManagerParams.CCR,
            _troveManagerParams.MCR,
            _troveManagerParams.SCR,
            _troveManagerParams.LIQUIDATION_PENALTY_SP,
            _troveManagerParams.LIQUIDATION_PENALTY_REDISTRIBUTION
        );
        address troveManagerAddress = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(TroveManager).creationCode, address(addressesRegistry)))
        );

        return (addressesRegistry, troveManagerAddress);
    }

    function _deployAndConnectCollateralContractsMainnet(
        IERC20Metadata _collToken,
        IBoldToken _boldToken,
        ICollateralRegistry _collateralRegistry,
        IAddressesRegistry _addressesRegistry,
        address _troveManagerAddress,
        IHintHelpers _hintHelpers,
        IMultiTroveGetter _multiTroveGetter
    ) internal returns (LiquityContractsTestnet memory contracts) {
        LiquityContractAddresses memory addresses;
        contracts.collToken = _collToken;

        // Deploy all contracts, using testers for TM and PriceFeed
        contracts.addressesRegistry = _addressesRegistry;

        // Deploy Metadata
        contracts.metadataNFT = deployMetadata(SALT);
        addresses.metadataNFT = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(MetadataNFT).creationCode, address(initializedFixedAssetReader)))
        );
        assert(address(contracts.metadataNFT) == addresses.metadataNFT);

        addresses.borrowerOperations = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(BorrowerOperations).creationCode, address(contracts.addressesRegistry)))
        );

        uint256 _stalenessThreshold = 1 days;
        if (address(_collToken) == address(wrappedSpot)) {
            _stalenessThreshold = 1 days; // heartbeat 86400
            contracts.oracle = _deploySpotOracle();
        } else {
            _stalenessThreshold = 1 hours; // heartbeat 3600
            contracts.oracle = _deployWamplOracle();
        }

        contracts.priceFeed = new WETHPriceFeed(addresses.borrowerOperations, contracts.oracle, _stalenessThreshold);
        contracts.interestRouter = new MockInterestRouter();

        addresses.troveManager = _troveManagerAddress;
        addresses.troveNFT = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(TroveNFT).creationCode, address(contracts.addressesRegistry)))
        );
        addresses.stabilityPool = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(StabilityPool).creationCode, address(contracts.addressesRegistry)))
        );
        addresses.activePool = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(ActivePool).creationCode, address(contracts.addressesRegistry)))
        );
        addresses.defaultPool = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(DefaultPool).creationCode, address(contracts.addressesRegistry)))
        );
        addresses.gasPool = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(GasPool).creationCode, address(contracts.addressesRegistry)))
        );
        addresses.collSurplusPool = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(CollSurplusPool).creationCode, address(contracts.addressesRegistry)))
        );
        addresses.sortedTroves = vm.computeCreate2Address(
            SALT, keccak256(getBytecode(type(SortedTroves).creationCode, address(contracts.addressesRegistry)))
        );

        IAddressesRegistry.AddressVars memory addressVars = IAddressesRegistry.AddressVars({
            collToken: _collToken,
            borrowerOperations: IBorrowerOperations(addresses.borrowerOperations),
            troveManager: ITroveManager(addresses.troveManager),
            troveNFT: ITroveNFT(addresses.troveNFT),
            metadataNFT: IMetadataNFT(addresses.metadataNFT),
            stabilityPool: IStabilityPool(addresses.stabilityPool),
            priceFeed: contracts.priceFeed,
            activePool: IActivePool(addresses.activePool),
            defaultPool: IDefaultPool(addresses.defaultPool),
            gasPoolAddress: addresses.gasPool,
            collSurplusPool: ICollSurplusPool(addresses.collSurplusPool),
            sortedTroves: ISortedTroves(addresses.sortedTroves),
            interestRouter: contracts.interestRouter,
            hintHelpers: _hintHelpers,
            multiTroveGetter: _multiTroveGetter,
            collateralRegistry: _collateralRegistry,
            boldToken: _boldToken,
            WETH: IWETH(WETH)
        });
        contracts.addressesRegistry.setAddresses(addressVars);

        contracts.borrowerOperations = new BorrowerOperations{salt: SALT}(contracts.addressesRegistry);
        contracts.troveManager = new TroveManager{salt: SALT}(contracts.addressesRegistry);
        contracts.troveNFT = new TroveNFT{salt: SALT}(contracts.addressesRegistry);
        contracts.stabilityPool = new StabilityPool{salt: SALT}(contracts.addressesRegistry);
        contracts.activePool = new ActivePool{salt: SALT}(contracts.addressesRegistry);
        contracts.defaultPool = new DefaultPool{salt: SALT}(contracts.addressesRegistry);
        contracts.gasPool = new GasPool{salt: SALT}(contracts.addressesRegistry);
        contracts.collSurplusPool = new CollSurplusPool{salt: SALT}(contracts.addressesRegistry);
        contracts.sortedTroves = new SortedTroves{salt: SALT}(contracts.addressesRegistry);

        assert(address(contracts.borrowerOperations) == addresses.borrowerOperations);
        assert(address(contracts.troveManager) == addresses.troveManager);
        assert(address(contracts.troveNFT) == addresses.troveNFT);
        assert(address(contracts.stabilityPool) == addresses.stabilityPool);
        assert(address(contracts.activePool) == addresses.activePool);
        assert(address(contracts.defaultPool) == addresses.defaultPool);
        assert(address(contracts.gasPool) == addresses.gasPool);
        assert(address(contracts.collSurplusPool) == addresses.collSurplusPool);
        assert(address(contracts.sortedTroves) == addresses.sortedTroves);

        // Connect contracts
        _boldToken.setBranchAddresses(
            address(contracts.troveManager),
            address(contracts.stabilityPool),
            address(contracts.borrowerOperations),
            address(contracts.activePool)
        );

        if (address(_collToken) == address(wrappedSpot)) {
            contracts.zapper = address(new SpotZapper(contracts.addressesRegistry));
        } else {
            contracts.zapper = address(new AmplZapper(contracts.addressesRegistry));
        }
    }

    function _deploySpotOracle() internal returns (address _oracle) {
        ISimpleProxyFactory _factory = ISimpleProxyFactory(0x156e0382068C3f96a629f51dcF99cEA5250B9eda);

         // Set salt values
        bytes32 _salt = bytes32(abi.encodePacked(deployer, uint96(0x0123)));

        // Sanity check
        address _oracleProxyAddr = _factory.predictDeterministicAddress(_salt);
        require(_oracleProxyAddr != address(0), "!ADDRESS");

        // Deploy implementation
        address __oracleImplementation = address(new SpotUsdOracle());

        // Deploy proxy
        _oracle = _factory.deployDeterministic(
            _salt,
            __oracleImplementation,
            ""
        );
        require(_oracle == _oracleProxyAddr, "!PREDICT");

        IOracle(_oracle).initialize(owner);
    }

    function _deployWamplOracle() internal returns (address _oracle) {
        ISimpleProxyFactory _factory = ISimpleProxyFactory(0x156e0382068C3f96a629f51dcF99cEA5250B9eda);

         // Set salt values
        bytes32 _salt = bytes32(abi.encodePacked(deployer, uint96(0x01234)));

        // Sanity check
        address _oracleProxyAddr = _factory.predictDeterministicAddress(_salt);
        require(_oracleProxyAddr != address(0), "!ADDRESS");

        // Deploy implementation
        address __oracleImplementation = address(new WrappedAmplUsdOracle());

        // Deploy proxy
        _oracle = _factory.deployDeterministic(
            _salt,
            __oracleImplementation,
            ""
        );
        require(_oracle == _oracleProxyAddr, "!PREDICT");

        IOracle(_oracle).initialize(owner);
    }

    function _deployCurveBoldUsdcPool(IBoldToken _boldToken, IERC20 _usdc) internal returns (ICurveStableswapNGPool) {
        // deploy Curve StableswapNG pool
        address[] memory coins = new address[](2);
        coins[BOLD_TOKEN_INDEX] = address(_boldToken);
        coins[USDC_INDEX] = address(_usdc);
        uint8[] memory assetTypes = new uint8[](2); // 0: standard
        bytes4[] memory methodIds = new bytes4[](2);
        address[] memory oracles = new address[](2);
        ICurveStableswapNGPool curvePool = curveStableswapFactory.deploy_plain_pool(
            "USDC-USDaf",
            "USDCUSDaf",
            coins,
            200, // A
            1000000, // fee
            20000000000, // _offpeg_fee_multiplier
            866, // _ma_exp_time
            0, // implementation id
            assetTypes,
            methodIds,
            oracles
        );

        return curvePool;
    }

    function _getBranchContractsJson(LiquityContractsTestnet memory c) internal pure returns (string memory) {
        return string.concat(
            "{",
            string.concat(
                // Avoid stack too deep by chunking concats
                string.concat(
                    string.concat('"addressesRegistry":"', address(c.addressesRegistry).toHexString(), '",'),
                    string.concat('"activePool":"', address(c.activePool).toHexString(), '",'),
                    string.concat('"borrowerOperations":"', address(c.borrowerOperations).toHexString(), '",'),
                    string.concat('"collSurplusPool":"', address(c.collSurplusPool).toHexString(), '",'),
                    string.concat('"defaultPool":"', address(c.defaultPool).toHexString(), '",'),
                    string.concat('"sortedTroves":"', address(c.sortedTroves).toHexString(), '",'),
                    string.concat('"stabilityPool":"', address(c.stabilityPool).toHexString(), '",'),
                    string.concat('"troveManager":"', address(c.troveManager).toHexString(), '",')
                ),
                string.concat(
                    string.concat('"troveNFT":"', address(c.troveNFT).toHexString(), '",'),
                    string.concat('"metadataNFT":"', address(c.metadataNFT).toHexString(), '",'),
                    string.concat('"priceFeed":"', address(c.priceFeed).toHexString(), '",'),
                    string.concat('"gasPool":"', address(c.gasPool).toHexString(), '",'),
                    string.concat('"interestRouter":"', address(c.interestRouter).toHexString(), '",'),
                    string.concat('"zapper":"', address(c.zapper).toHexString(), '",'),
                    string.concat('"gasCompZapper":"', address(c.gasCompZapper).toHexString(), '",'),
                    string.concat('"leverageZapper":"', address(c.leverageZapper).toHexString(), '",')
                ),
                string.concat(
                    string.concat('"collToken":"', address(c.collToken).toHexString(), '"') // no comma
                )
            ),
            "}"
        );
    }

    function _getDeploymentConstants() internal pure returns (string memory) {
        return string.concat(
            "{",
            string.concat(
                string.concat('"ETH_GAS_COMPENSATION":"', ETH_GAS_COMPENSATION.toString(), '",'),
                string.concat('"INTEREST_RATE_ADJ_COOLDOWN":"', INTEREST_RATE_ADJ_COOLDOWN.toString(), '",'),
                string.concat('"MAX_ANNUAL_INTEREST_RATE":"', MAX_ANNUAL_INTEREST_RATE.toString(), '",'),
                string.concat('"MIN_ANNUAL_INTEREST_RATE":"', MIN_ANNUAL_INTEREST_RATE.toString(), '",'),
                string.concat('"MIN_DEBT":"', MIN_DEBT.toString(), '",'),
                string.concat('"SP_YIELD_SPLIT":"', SP_YIELD_SPLIT.toString(), '",'),
                string.concat('"UPFRONT_INTEREST_PERIOD":"', UPFRONT_INTEREST_PERIOD.toString(), '"') // no comma
            ),
            "}"
        );
    }

    function _getManifestJson(DeploymentResult memory deployed, string memory _governanceManifest)
        internal
        pure
        returns (string memory)
    {
        string[] memory branches = new string[](deployed.contractsArray.length);

        // Poor man's .map()
        for (uint256 i = 0; i < branches.length; ++i) {
            branches[i] = _getBranchContractsJson(deployed.contractsArray[i]);
        }

        return string.concat(
            "{",
            string.concat(
                string.concat('"constants":', _getDeploymentConstants(), ","),
                string.concat('"collateralRegistry":"', address(deployed.collateralRegistry).toHexString(), '",'),
                string.concat('"boldToken":"', address(deployed.boldToken).toHexString(), '",'),
                string.concat('"hintHelpers":"', address(deployed.hintHelpers).toHexString(), '",'),
                string.concat('"multiTroveGetter":"', address(deployed.multiTroveGetter).toHexString(), '",'),
                string.concat('"exchangeHelpers":"', address(deployed.exchangeHelpers).toHexString(), '",'),
                string.concat('"branches":[', branches.join(","), "],"),
                string.concat('"governance":', _governanceManifest, '" ') // no comma
            ),
            "}"
        );
    }
}

// == Return ==
// deployed: struct DeployUSDafScript.DeploymentResult DeploymentResult({ contractsArray: [LiquityContractsTestnet({ addressesRegistry: 0xEc500Fda25b00814935a251f407395A9040C8510, activePool: 0x1E357f9e9962Ce395A7D4b56a39367e38A812DA8, borrowerOperations: 0x88fc8916094Caf0b9cdb959CED2567C8AD04bbD9, collSurplusPool: 0xaadB8c77ac3B95529C1C015A3Ab1874d4dbaB821, defaultPool: 0x5BB81766905d46B726D8083f0881cbeE0278DE04, sortedTroves: 0xD2c48Ac7e8Afb139766093f6165B05482Abb1F49, stabilityPool: 0xb27F30D9d930AF8d231DE0b83f93755e8519c369, troveManager: 0xc5077D6131c422f8090D55200735badA10C237dF, troveNFT: 0xc73066683cB018e439CEF841fAECC3F35BDfD6E0, metadataNFT: 0x1139F1374985D00914a63346A7A993B68622558C, priceFeed: 0x5b601Ad4A40882421Be00F6b8ffF50F9bf804b78, gasPool: 0xfFb1AD11107C9b53273E493cE8905fa091583bf2, interestRouter: 0xe18547f5e5e30F991371beE3d9245986468A80F9, collToken: 0x253Da8f1F6cD0fb33AADc13999Df9B124F1df194, unwrappedZapper: 0x140c32b45Bbf84310139A37Da87Eedf14b166d37, gasCompZapper: 0x0000000000000000000000000000000000000000, leverageZapper: 0x0000000000000000000000000000000000000000 })], collateralRegistry: 0xA70D1455f393f709de0F94aB9e6d9F5777096650, boldToken: 0xfDE46D5B766138164680D5BBA2DC1a67b6e2a387, usdc: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, usdcCurvePool: 0x0000000000000000000000000000000000000000, hintHelpers: 0x3FabB13195599BEF352157A2c6C6937AEAd18a1F, multiTroveGetter: 0x483DF4b557Dda871b13c9d90cd900BadAC0EA3d7, exchangeHelpers: 0x0000000000000000000000000000000000000000 })

// == Logs ==
//   0x285E3b1E82f74A99D07D2aD25e159E75382bB43B deployer
//   1019710610195366688 deployer balance
//   0x253Da8f1F6cD0fb33AADc13999Df9B124F1df194 wrappedSpot: