(self["webpackChunkxstarter_frontend"]=self["webpackChunkxstarter_frontend"]||[]).push([[168],{81830:(e,t,n)=>{"use strict";n.d(t,{ZD:()=>o,a4:()=>i,Qf:()=>r,k2:()=>l,qg:()=>d,Z9:()=>p});const a=5,o={5:"0x4EB937e7523f8E64091f09B5B92846E005999b97",31337:"0x052D9775D73623d96105DD6FB5e6fC906D261999",100:""};o.default=o[a];const s="31337",i={"0x0000000000000000000000000000000000000000":"100"===s?"xDai":"ETH"},r={1:"Ethereum Main Net",31337:"Hardhat Localhost",100:"xDai Layer 2",56:"Binance Smart Chain",77:"POA Sokol Testnet",5:"GOERLI Testnet"},l={31337:!0,100:!0,5:!0};console.log("process env");const d="https://rpc.goerli.mudit.blog/",p={0:"ILO PROPOSED",1:"ILO HAS BEEN SET UP BY ADMIN",2:"ILO HAS RECEIVED PROJECT FUNDS",3:"ILO HAS BEEN VALIDATED",4:"ILO TOKENS HAS BEEN APPROVED FOR LIQUIDITY POOL",5:"ILO LIQUIDITY PAIR CREATED",6:"ILO FINALIZED: LIQUIDITY POOL CREATED AND TIME LOCKS SET"}},93681:(e,t,n)=>{"use strict";n.d(t,{Z:()=>u});var a=n(83673);const o=(0,a.HX)("data-v-0762fa0f");(0,a.dD)("data-v-0762fa0f");const s={class:"dark-light-background row justify-center content-center",style:{"max-width":"1000px","max-height":"600px","min-height":"400px","min-width":"65%","border-radius":"15px"}};(0,a.Cn)();const i=o(((e,t,n,i,r,l)=>{const d=(0,a.up)("q-dialog");return(0,a.wg)(),(0,a.j4)(d,{modelValue:e.showDialog,"onUpdate:modelValue":t[1]||(t[1]=t=>e.showDialog=t),persistent:e.persistent},{default:o((()=>[(0,a.Wm)("div",s,[(0,a.WI)(e.$slots,"default",{},void 0,!0)])])),_:3},8,["modelValue","persistent"])})),r=(0,a.aZ)({name:"GeneralModal",props:{modelValue:{type:Boolean,required:!0},persistent:{type:Boolean,default:!1}},computed:{showDialog:{set:function(e){this.$emit("update:modelValue",e)},get:function(){return this.modelValue}}}});var l=n(5926),d=n(7518),p=n.n(d);r.render=i,r.__scopeId="data-v-0762fa0f";const u=r;p()(r,"components",{QDialog:l.Z})},76168:(e,t,n)=>{"use strict";n.r(t),n.d(t,{default:()=>Y});var a=n(83673),o=n(37400),s=n.n(o),i=n(56607),r=n.n(i);const l={key:0,class:"logo-style",src:s()},d={key:1,class:"logo-style",src:r()},p={class:"q-gutter-x-sm"},u={class:"col-auto"},c={class:"col-12 q-pa-md segoe-bold text-wr text-center"},m=(0,a.Wm)("div",null," Please Manually Switch To The Goerli Network ",-1),y=(0,a.Uk)(" For More Info On How To Switch Manually Click ");function T(e,t,n,o,s,i){const r=(0,a.up)("q-toolbar-title"),T=(0,a.up)("q-btn"),g=(0,a.up)("q-toolbar"),h=(0,a.up)("q-route-tab"),b=(0,a.up)("q-badge"),v=(0,a.up)("q-tabs"),k=(0,a.up)("q-header"),f=(0,a.up)("router-view"),w=(0,a.up)("q-page-container"),x=(0,a.up)("q-footer"),A=(0,a.up)("WalletConnectModal"),I=(0,a.up)("GeneralModal"),L=(0,a.up)("q-layout");return(0,a.wg)(),(0,a.j4)(L,{view:"hHh lpR fFf"},{default:(0,a.w5)((()=>[(0,a.Wm)(k,{elevated:"",class:["text-white q-pt-sm",{"bg-dark":e.$q.dark.isActive,"bg-light":!e.$q.dark.isActive}],"height-hint":"98"},{default:(0,a.w5)((()=>[(0,a.Wm)(g,null,{default:(0,a.w5)((()=>[(0,a.Wm)(r,{style:{width:"10%"}},{default:(0,a.w5)((()=>[(0,a.Wm)("div",null,[e.$q.dark.isActive?((0,a.wg)(),(0,a.j4)("img",l)):((0,a.wg)(),(0,a.j4)("img",d))])])),_:1}),(0,a.Wm)("div",p,[(0,a.Wm)(T,{rounded:"",outline:"",size:"md",label:e.connectBtnLabel,icon:e.metamaskInstalled?void 0:"error_outline",color:e.metamaskInstalled?e.darkLightText:"negative",onClick:e.connectOrInstallBtn},null,8,["label","icon","color","onClick"]),(0,a.Wm)(T,{round:"",flat:"",color:e.darkLightText,icon:e.$q.dark.isActive?"light_mode":"dark_mode",onClick:e.setDarkMode},null,8,["color","icon","onClick"])])])),_:1}),(0,a.Wm)(v,{align:"center",class:{"text-dark":!e.$q.dark.isActive,"text-light":e.$q.dark.isActive}},{default:(0,a.w5)((()=>[(0,a.Wm)(h,{to:"/",label:"ILO"}),(0,a.Wm)(h,{to:"/page2",label:"Governance",disable:""},{default:(0,a.w5)((()=>[(0,a.Wm)(b,{label:"Coming Soon",color:e.darkLightText,"text-color":e.darkLightTextReverse,style:{"font-size":"8px"},floating:""},null,8,["color","text-color"])])),_:1}),(0,a.Wm)(h,{to:"/page3",label:"NFT",disable:""},{default:(0,a.w5)((()=>[(0,a.Wm)(b,{label:"Coming Soon",color:e.darkLightText,"text-color":e.darkLightTextReverse,style:{"font-size":"8px"},floating:""},null,8,["color","text-color"])])),_:1})])),_:1},8,["class"])])),_:1},8,["class"]),(0,a.Wm)(w,null,{default:(0,a.w5)((()=>[(0,a.Wm)(f)])),_:1}),(0,a.Wm)(x,{elevated:"",class:["text-white",{"bg-dark":e.$q.dark.isActive,"bg-light":!e.$q.dark.isActive}]},{default:(0,a.w5)((()=>[(0,a.Wm)(g,{class:"justify-center"},{default:(0,a.w5)((()=>[(0,a.Wm)("div",u,[(0,a.Wm)(T,{flat:"",color:e.darkLightText,label:"About xStarter",target:"_blank","icon-right":"open_in_new",type:"a",href:"https://www.xstarter.org/"},null,8,["color"])])])),_:1})])),_:1},8,["class"]),e.connectedAndPermissioned?(0,a.ry)("",!0):((0,a.wg)(),(0,a.j4)(A,{key:0,modelValue:e.showWalletConnectModal,"onUpdate:modelValue":t[1]||(t[1]=t=>e.showWalletConnectModal=t)},null,8,["modelValue"])),5!==e.chainId?((0,a.wg)(),(0,a.j4)(I,{key:1,modelValue:e.showSwitchChainManual,"onUpdate:modelValue":t[2]||(t[2]=t=>e.showSwitchChainManual=t)},{default:(0,a.w5)((()=>[(0,a.Wm)("div",c,[m,(0,a.Wm)("div",null,[y,(0,a.Wm)(T,{flat:"",type:"a",label:"HERE",style:{"text-decoration":"underline"},href:"https://metamask.zendesk.com/hc/en-us/articles/360043227612-How-to-add-custom-Network-RPC-and-or-Block-Explorer",target:"_blank"})])])])),_:1},8,["modelValue"])):(0,a.ry)("",!0)])),_:1})}n(10071);var g=n(61959),h=n(48825),b=n(76638),v=n(80602),k=n(11990),f=n.n(k),w=n(98580),x=n(81830);const A=JSON.parse('{"Mt":[{"inputs":[{"internalType":"address","name":"xStarterToken_","type":"address"},{"internalType":"address","name":"xStarterDeployer_","type":"address"},{"internalType":"address","name":"xStarterERCDeployer_","type":"address"},{"internalType":"uint256","name":"depositPerProposal_","type":"uint256"},{"internalType":"uint256","name":"minXSTN_","type":"uint256"},{"internalType":"uint256","name":"minXSTNLP_","type":"uint256"},{"internalType":"uint256","name":"blockTime_","type":"uint256"},{"internalType":"address","name":"addressOfDex_","type":"address"},{"internalType":"address","name":"addressOfDexFactory_","type":"address"},{"internalType":"address","name":"admin_","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousAdmin","type":"address"},{"indexed":true,"internalType":"address","name":"newAdmin","type":"address"}],"name":"AdministrationTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"proposalAddr_","type":"address"},{"indexed":true,"internalType":"address","name":"caller_","type":"address"},{"indexed":true,"internalType":"address","name":"ILO","type":"address"}],"name":"ILODeployed","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"proposer","type":"address"},{"indexed":true,"internalType":"address","name":"proposalAddr_","type":"address"}],"name":"ILOProposalRegistered","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"caller_","type":"address"},{"indexed":true,"internalType":"uint256","name":"amount_","type":"uint256"}],"name":"TokensDeposited","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"caller_","type":"address"},{"indexed":true,"internalType":"uint256","name":"amount_","type":"uint256"}],"name":"TokensWithdrawn","type":"event"},{"inputs":[],"name":"_addressOfDex","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"_addressOfDexFactory","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"xStarterGovernance_","type":"address"}],"name":"addGovernance","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"xStarterNFT_","type":"address"}],"name":"addNFT","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"admin","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"minXSTN_","type":"uint256"},{"internalType":"uint256","name":"minXSTNLP_","type":"uint256"}],"name":"changeMinTokensRequirements","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"proposalAddr_","type":"address"},{"internalType":"address","name":"ILOAdmin_","type":"address"}],"name":"deployILOContract","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"proposalAddr_","type":"address"}],"name":"deployXstarterILO","outputs":[{"internalType":"address","name":"ILO","type":"address"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"depositApprovedToken","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"addr_","type":"address"}],"name":"depositBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getMinTokensRequirements","outputs":[{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"proposalAddr_","type":"address"}],"name":"getProposal","outputs":[{"components":[{"internalType":"address","name":"proposalAddr","type":"address"},{"components":[{"internalType":"address","name":"proposer","type":"address"},{"internalType":"address","name":"admin","type":"address"},{"internalType":"address","name":"fundingToken","type":"address"},{"internalType":"string","name":"tokenName","type":"string"},{"internalType":"string","name":"tokenSymbol","type":"string"},{"internalType":"string","name":"infoURL","type":"string"},{"internalType":"uint256","name":"totalSupply","type":"uint256"},{"internalType":"uint8","name":"decimals","type":"uint8"},{"internalType":"uint8","name":"percentOfTokensForILO","type":"uint8"},{"internalType":"uint256","name":"blockNumber","type":"uint256"},{"internalType":"uint256","name":"timestamp","type":"uint256"},{"internalType":"bool","name":"isApproved","type":"bool"},{"internalType":"bool","name":"isRegistered","type":"bool"},{"internalType":"bool","name":"isOpen","type":"bool"},{"internalType":"uint256","name":"deployedBlockNumber","type":"uint256"},{"internalType":"uint256","name":"deployedTimestamp","type":"uint256"},{"internalType":"bool","name":"isDeployed","type":"bool"},{"internalType":"address","name":"ILOAddress","type":"address"}],"internalType":"struct ILOProposal","name":"info","type":"tuple"},{"components":[{"internalType":"uint48","name":"contribTimeLock","type":"uint48"},{"internalType":"uint48","name":"liqPairLockLen","type":"uint48"},{"internalType":"uint48","name":"startTime","type":"uint48"},{"internalType":"uint48","name":"endTime","type":"uint48"},{"internalType":"uint256","name":"minPerSwap","type":"uint256"},{"internalType":"uint256","name":"minPerAddr","type":"uint256"},{"internalType":"uint256","name":"maxPerAddr","type":"uint256"},{"internalType":"uint256","name":"softcap","type":"uint256"},{"internalType":"uint256","name":"hardcap","type":"uint256"},{"internalType":"uint256","name":"amountRaised","type":"uint256"},{"internalType":"bool","name":"pairCreated","type":"bool"},{"internalType":"address","name":"liqPairAddr","type":"address"},{"internalType":"address","name":"projectToken","type":"address"},{"internalType":"uint8","name":"percentTokensForTeam","type":"uint8"},{"internalType":"uint8","name":"ILOStatus","type":"uint8"}],"internalType":"struct ILOAdditionalInfo","name":"moreInfo","type":"tuple"}],"internalType":"struct CompactInfo","name":"i_","type":"tuple"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"round_","type":"uint256"}],"name":"getProposals","outputs":[{"components":[{"internalType":"address","name":"proposalAddr","type":"address"},{"components":[{"internalType":"address","name":"proposer","type":"address"},{"internalType":"address","name":"admin","type":"address"},{"internalType":"address","name":"fundingToken","type":"address"},{"internalType":"string","name":"tokenName","type":"string"},{"internalType":"string","name":"tokenSymbol","type":"string"},{"internalType":"string","name":"infoURL","type":"string"},{"internalType":"uint256","name":"totalSupply","type":"uint256"},{"internalType":"uint8","name":"decimals","type":"uint8"},{"internalType":"uint8","name":"percentOfTokensForILO","type":"uint8"},{"internalType":"uint256","name":"blockNumber","type":"uint256"},{"internalType":"uint256","name":"timestamp","type":"uint256"},{"internalType":"bool","name":"isApproved","type":"bool"},{"internalType":"bool","name":"isRegistered","type":"bool"},{"internalType":"bool","name":"isOpen","type":"bool"},{"internalType":"uint256","name":"deployedBlockNumber","type":"uint256"},{"internalType":"uint256","name":"deployedTimestamp","type":"uint256"},{"internalType":"bool","name":"isDeployed","type":"bool"},{"internalType":"address","name":"ILOAddress","type":"address"}],"internalType":"struct ILOProposal","name":"info","type":"tuple"},{"components":[{"internalType":"uint48","name":"contribTimeLock","type":"uint48"},{"internalType":"uint48","name":"liqPairLockLen","type":"uint48"},{"internalType":"uint48","name":"startTime","type":"uint48"},{"internalType":"uint48","name":"endTime","type":"uint48"},{"internalType":"uint256","name":"minPerSwap","type":"uint256"},{"internalType":"uint256","name":"minPerAddr","type":"uint256"},{"internalType":"uint256","name":"maxPerAddr","type":"uint256"},{"internalType":"uint256","name":"softcap","type":"uint256"},{"internalType":"uint256","name":"hardcap","type":"uint256"},{"internalType":"uint256","name":"amountRaised","type":"uint256"},{"internalType":"bool","name":"pairCreated","type":"bool"},{"internalType":"address","name":"liqPairAddr","type":"address"},{"internalType":"address","name":"projectToken","type":"address"},{"internalType":"uint8","name":"percentTokensForTeam","type":"uint8"},{"internalType":"uint8","name":"ILOStatus","type":"uint8"}],"internalType":"struct ILOAdditionalInfo","name":"moreInfo","type":"tuple"}],"internalType":"struct CompactInfo[]","name":"","type":"tuple[]"},{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"proposalAddr_","type":"address"}],"name":"isDeployed","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"noOfProposals","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"proposalAddr_","type":"address"}],"name":"registerILOProposal","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"renounceAdministration","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"setTokenAndLPAddr","outputs":[{"internalType":"address","name":"xStarterToken_","type":"address"},{"internalType":"address","name":"xStarterLP_","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"newAdmin","type":"address"}],"name":"transferAdministration","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount_","type":"uint256"}],"name":"withdrawTokens","outputs":[{"internalType":"bool","name":"success","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"xStarterContracts","outputs":[{"internalType":"address[5]","name":"","type":"address[5]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"xStarterDEXUsed","outputs":[{"internalType":"address","name":"dexAddress","type":"address"},{"internalType":"address","name":"dexFactoryAddress","type":"address"}],"stateMutability":"view","type":"function"}]}'),I=(0,a.HX)("data-v-ca6665b2");(0,a.dD)("data-v-ca6665b2");const L=(0,a.Wm)("div",{class:"q-mb-xl segoe-bold text-h4 text-center"}," Connect To Start Using xStarter ",-1),_={class:"row full-width content-center justify-center q-px-md q-mt-lg"};(0,a.Cn)();const C=I(((e,t,n,o,s,i)=>{const r=(0,a.up)("q-btn"),l=(0,a.up)("GeneralModal");return(0,a.wg)(),(0,a.j4)(l,{modelValue:e.showDialog,"onUpdate:modelValue":t[1]||(t[1]=t=>e.showDialog=t)},{default:I((()=>[L,(0,a.Wm)("div",_,[(0,a.Wm)(r,{outline:"",size:"md",label:"Connect With Metamask",color:e.metamaskInstalled?e.darkLightText:"negative",disable:!e.metamaskInstalled,style:{"min-height":"50px","border-radius":"10px"},class:"col-lg-5 col-12",onClick:e.connectEthereum,icon:"img:metamask.svg"},null,8,["color","disable","onClick"])])])),_:1},8,["modelValue"])}));var P=n(93681);const M=(0,a.aZ)({name:"WalletConnectModal",setup(){const e=(0,a.f3)("$connectEthereum"),t=(0,a.f3)("$metamaskInstalled");return{connectEthereum:e,metamaskInstalled:t}},components:{GeneralModal:P.Z},props:{modelValue:{type:Boolean,required:!0},persistent:{type:Boolean,default:!1}},computed:{showDialog:{set:function(e){this.$emit("update:modelValue",e)},get:function(){return this.modelValue}},darkLightText(){return this.$q.dark.isActive?"light":"dark"},darkLightTextReverse(){return this.$q.dark.isActive?"dark":"light"}}});var O=n(2165),q=n(7518),D=n.n(q);M.render=C,M.__scopeId="data-v-ca6665b2";const E=M;D()(M,"components",{QBtn:O.Z});const S=(0,a.aZ)({name:"MainLayout",components:{GeneralModal:P.Z,WalletConnectModal:E},setup(){const e=(0,h.Z)(),t=async()=>{e.dark.toggle()};let n,o,s;console.log("xstarter constructor abi",v.abiUtils.getConstructorObj(A.Mt));let i=(0,g.iH)(!1);const r=(0,g.iH)(!1);(0,a.JJ)("$launchPadLoaded",i);let l=(0,g.iH)(x.qg);(0,a.JJ)("$jsonRPCEndpoint",l);const d=(0,g.iH)(void 0);(0,a.JJ)("$ethereumProvider",d);let p=(0,g.iH)(void 0);(0,a.JJ)("$chainId",p);let u=(0,g.iH)({timestamp:0,blockNumber:0});(0,a.JJ)("$blockInfo",u);const c=(0,g.iH)(!1);(0,a.JJ)("$metamaskInstalled",c);const m=(0,g.iH)([]);(0,a.JJ)("$connectedAccounts",m);const y=(0,g.iH)(Boolean(c.value&&m.value.length>0));(0,a.JJ)("$connectedAndPermissioned",y);const T=async()=>{console.log("connecting using json rpc",l.value,"goerli"),n=await new b.ethers.providers.JsonRpcProvider(l.value),console.log("json rpc provider is",n),n&&(s=await new b.ethers.Contract(x.ZD.default,A.Mt,n),s&&(i.value=!0),n.on("block",(async e=>{console.log("received block event");const t=await n.getBlock();u.value={timestamp:t.timestamp,blockNumber:e}})))},k=async(e,t,n)=>{try{const a=await d.value.request({method:"wallet_watchAsset",params:{type:"ERC20",options:{address:e,symbol:t,decimals:18,image:n}}});a?console.log("was added"):console.log("not added")}catch(a){console.log(a)}};(0,a.JJ)("$metaMaskAssetAddRequest",k);const w=async(e,t,n,a,o,s,i)=>{let l=!1;try{await ethereum.request({method:"wallet_switchEthereumChain",params:[{chainId:e}]}),console.log("no error"),l=!0}catch(p){if(console.log("error is",p),4902===p.code||-32601===p.code)try{l=await d.value.request({method:"wallet_addEthereumChain",params:[{chainId:e,chainName:t,nativeCurrency:{name:n,symbol:a,decimals:18},rpcUrls:o,blockExplorerUrls:s,iconUrls:i}]}),l?console.log("chain was added"):console.log("chain not added")}catch(p){console.log(p),r.value=!0}else console.log("non switch error",p)}return l};(0,a.JJ)("$metaMaskEthereumChainAddRequest",w);const I=async(e=null)=>{if(c.value){console.log("meta mask installed");try{m.value=await d.value.request({method:"eth_accounts"})}catch(t){return void console.log(t)}y.value=c.value&&m.value.length>0,y.value?(n=new b.ethers.providers.Web3Provider(d.value),o=n.getSigner(),p.value=(await n.getNetwork())["chainId"],s=await new b.ethers.Contract(x.ZD[p.value]||"",A.Mt,o),s&&(i.value=!0),d.value.on("chainChanged",(e=>{window.location.reload()})),d.value.on("accountsChanged",(()=>{L(!0)})),n.on("block",(async e=>{console.log("received block event");const t=await n.getBlock();u.value={timestamp:t.timestamp,blockNumber:e}}))):(i.value=!1,n=void 0,o=void 0,s=void 0,console.log("connecteda"),e?window.location.reload():(n&&n.off("block"),await T()))}},L=async(e=null)=>{d.value=await f()(),c.value=!!d.value&&Boolean(d.value),console.log("etherruem prov is",d.value,c.value),c.value?await I(e):await T()};(0,a.bv)((()=>{L()}));const _=async()=>{if(c.value){if(console.log("ethereum provider",d.value),y.value)return;try{m.value=await d.value.request({method:"eth_requestAccounts"})}catch(e){}y.value=c.value&&m.value.length>0,y.value&&L(),console.log(o,"signer value")}else console.log("please install metamask")};(0,a.JJ)("$connectEthereum",_);const C=()=>n;(0,a.JJ)("$getProvider",C);const P=()=>o;(0,a.JJ)("$getSigner",P);const M=()=>y;(0,a.JJ)("$getConnectedAndPermissioned",M);const O=()=>s;(0,a.JJ)("$getLaunchPadContract",O);const q=async(e,t=[])=>{const n=O();return console.log("launchpad is",n),await n[e](...t)};return(0,a.JJ)("$callLaunchPadFunction",q),{setDarkMode:t,connectEthereum:_,checkExisting:L,getProvider:C,getSigner:P,getLaunchPadContract:O,connectUsingJsonRPCProvider:T,metaMaskEthereumChainAddRequest:w,metamaskInstalled:c,ethereumProvider:d,connectedAccounts:m,connectedAndPermissioned:y,launchPadContract:s,launchPadLoaded:i,chainId:p,blockInfo:u,showSwitchChainManual:r}},data(){return{showWalletConnectModal:!1}},computed:{darkLightText(){return this.$q.dark.isActive?"light":"dark"},darkLightTextReverse(){return this.$q.dark.isActive?"dark":"light"},connectBtnLabel(){if(console.log("connected permission",this.connectedAndPermissioned),this.connectedAndPermissioned){let e=this.connectedAccounts[0];return`${e.slice(0,6)}....${e.slice(e.length-4)}`}return this.metamaskInstalled?"Connect":"Install Metamask"}},methods:{connectOrInstallBtn(){if(!this.connectedAndPermissioned)if("Connect"===this.connectBtnLabel)this.showWalletConnectModal=!this.showWalletConnectModal;else{const e=new w.Z;e.startOnboarding()}},async signTx(){console.log("this signer",this.getSigner(),this.getProvider(),this.ethereumProvider.selectedAddress),console.log("connected accounts",this.connectedAccounts);const e=await this.getProvider().getBalance("0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc");console.log("response is",e,this.$ethers.utils.formatEther(e),e._isBigNumber)},async callContract(){const e=this.getLaunchPadContract(),t=await e.getProposals("0");console.log("get proposals",t);const n={address:e.address,topic:Object.values(e.filters)};e.on(n,(e=>{console.log("result in event is",e)})),console.log("ilo contract",e,t)}},mounted(){console.log("get provider",this.getProvider())},watch:{jsonRPCEndpoint:async function(){await this.checkExisting(!1)}}});var W=n(83066),J=n(53812),$=n(39570),R=n(13747),B=n(24858),Z=n(27011),N=n(76332),H=n(52035),Q=n(2350),V=n(57547),F=n(42770),U=n(69721),j=n(72652),G=n(41762),X=n(75096),z=n(60677);S.render=T;const Y=S;D()(S,"components",{QLayout:W.Z,QHeader:J.Z,QToolbar:$.Z,QToolbarTitle:R.Z,QBtn:O.Z,QBtnDropdown:B.Z,QList:Z.Z,QItem:N.Z,QItemSection:H.Z,QItemLabel:Q.Z,QTabs:V.Z,QRouteTab:F.Z,QBadge:U.Z,QPageContainer:j.Z,QFooter:G.Z,QAvatar:X.Z}),D()(S,"directives",{ClosePopup:z.Z})},37400:(e,t,n)=>{e.exports=n.p+"img/xstarter_dark_logo.3c81782b.png"},56607:(e,t,n)=>{e.exports=n.p+"img/xstarter_light_logo.2f86b50b.png"}}]);