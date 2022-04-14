import Header from "../../components/Header";
import { listTokensOfOwner } from "../../utils";
import {
  NFT_CONTRACT_ADDRESS,
  NFT_ABI,
  STAKING_CONTRACT_ADDRESS,
  STAKING_ABI,
} from "../../constants";
import { useAppContext } from "../../context/state";
import { useState } from "react";
import { Contract } from "ethers";
import styles from "../../styles/appStyling.module.scss";
import { getProviderOrSigner } from "../../utils";
export default function Staking() {
  const userState = useAppContext();
  const [usersTokens, setUsersTokens] = useState([]);
  const [tokensToBeStaked, setTokensToBeStaked] = useState([]);
  const [stakedTokens, setStakedTokens] = useState([]);
  const [tokensToBeUnstaked, setTokensToBeUnstaked] = useState([]);
  async function getOwnersTokens() {
    const tokens = await listTokensOfOwner(
      NFT_CONTRACT_ADDRESS,
      NFT_ABI,
      userState.userWallet
    );
    console.log(tokens);
    setUsersTokens(tokens);
  }
  async function getTokens() {
    getOwnersTokens();
  }
  function updateTokensToBeStaked(token) {
    const tempArr = [...tokensToBeStaked];
    if (tempArr.includes(token)) {
      const isToken = (entry) => entry == token;
      const index = tempArr.findIndex(isToken);
      tempArr.splice(index, 1);
    } else {
      tempArr.push(token);
    }

    setTokensToBeStaked(tempArr);
  }

  function updateTokensToBeUnstaked(token) {
    const tempArr = [...tokensToBeUnstaked];
    if (tempArr.includes(token)) {
      const isToken = (entry) => entry == token;
      const index = tempArr.findIndex(isToken);
      tempArr.splice(index, 1);
    } else {
      tempArr.push(token);
    }
    console.log(tempArr);
    setTokensToBeUnstaked(tempArr);
  }

  async function handleStake() {
    if (!tokensToBeStaked.length) {
      window.alert("You must select some tokens to stake");
      return;
    }
    try {
      const signer = await getProviderOrSigner(true);
      const contract = new Contract(
        STAKING_CONTRACT_ADDRESS,
        STAKING_ABI,
        signer
      );
      const tx = await contract.stake(tokensToBeStaked);
      const receipt = await tx.wait();
      setTokensToBeStaked([]);
      console.log(receipt);
    } catch (error) {
      console.error(error);
    }
  }
  async function handleApproval() {
    try {
      const signer = await getProviderOrSigner(true);
      const contract = new Contract(NFT_CONTRACT_ADDRESS, NFT_ABI, signer);
      const tx = await contract.setApprovalForAll(
        STAKING_CONTRACT_ADDRESS,
        true
      );
      await tx.wait();
      console.log("Approved");
    } catch (error) {
      console.error(error);
    }
  }

  async function handleUnstake() {
    try {
      const signer = await getProviderOrSigner(true);
      const contract = new Contract(
        STAKING_CONTRACT_ADDRESS,
        STAKING_ABI,
        signer
      );
      const tx = await contract.unstake(tokensToBeUnstaked);
      await tx.wait();
      setTokensToBeUnstaked([]);
      console.log("Unstaked");
    } catch (error) {
      console.error(error);
    }
  }

  async function getUserStakedTokens() {
    try {
      const signer = await getProviderOrSigner(true);
      const contract = new Contract(
        STAKING_CONTRACT_ADDRESS,
        STAKING_ABI,
        signer
      );
      const userAddress = await signer.getAddress();
      const userStakedTokens = await contract.getStakedTokens(userAddress);
      console.log(userStakedTokens);
      setStakedTokens(userStakedTokens);
    } catch (error) {
      console.error(error);
    }
  }
  return (
    <div>
      <Header />
      <main className={styles.mainContainer}>
        <button onClick={() => handleStake()}>Stake</button>
        <button onClick={() => handleUnstake()}>Unstake</button>
        <button onClick={() => getTokens()}>Get Tokens</button>
        <button onClick={() => handleApproval()}>setApprovalForAll</button>
        <button onClick={() => getUserStakedTokens()}>getStakedTokens</button>
      </main>{" "}
      <h3 className={styles.heading}>Tokens not staked</h3>
      <div className={styles.stakeContainer}>
        {[...usersTokens].map((token) => (
          <article className={styles.stakedItemContainer} key={token}>
            <label for={token}>
              <img src="https://images.unsplash.com/photo-1510759591315-6425cba413fe?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1770&q=80" />
              <h6>{token}</h6>
              <input
                type="checkbox"
                id={token}
                onChange={() => updateTokensToBeStaked(Number(token))}
              />
            </label>
          </article>
        ))}
      </div>
      <h3 className={styles.heading}>Staked tokens</h3>
      <div className={styles.stakeContainer}>
        {stakedTokens.map((token) => (
          <article className={styles.stakedItemContainer} key={token}>
            <label for={token + 1}>
              <img src="https://images.unsplash.com/photo-1510759591315-6425cba413fe?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1770&q=80" />
              <h6>{token + 1}</h6>
              <input
                type="checkbox"
                id={token + 1}
                onChange={() => updateTokensToBeUnstaked(token + 1)}
              />
            </label>
          </article>
        ))}
      </div>
    </div>
  );
}
