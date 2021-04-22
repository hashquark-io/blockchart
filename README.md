# blockchart - An open dfinity token chart  network.

The blockchart sample application provides a simple implementation of an open professional network that demonstrates how to use **inter-canister calls** within a project.

In the blockchart sample application, there are four canisters:

* The `blockchart` canister creates and stores basic profile information for a user, including work experience token 
* The `connectd` canister creates and stores a user's connections.
* The `token` canister  is erc 20 token.
* The `chart ` canister creates and stores a user's talk.

## Before you begin

Before building the sample application, verify the following:

* You have downloaded and installed the DFINITY Canister SDK as described in [Download and install](https://sdk.dfinity.org/docs/quickstart/quickstart.html#download-and-install).
* You have stopped any Internet Computer network processes running on the local computer.

## Demo

1. Clone the `blockchart` repository.

2. Change to the local `blockchart` working directory.

    ```bash
    cd blockchart
    ```

3. Install the required node modules (only needed the first time).

    ```bash
    npm install
    ```

4. Open the `dfx.json` file in a text editor and verify the `dfx` setting has same the version number as the `dfx` executable you have installed.

5. Start the replica.

    ```bash
    dfx start --background
    ```

6. Register unique canister identifiers for the `linkedup` project by running the following command:

    ```bash
    dfx canister create --all
    ```

7. Build the application by running the following command:

    ```bash
    dfx build
    ```

8. Deploy the application on the local network by running the following command:

    ```bash
    dfx canister install connectd
        dfx canister install chart 
         eval dfx canister install token --argument '"(\"ieth\",\"ieth\",18,100000,1000)"'
         eval dfx canister install blockchart --argument '"(principal \"${token_canister_principal}\")"'
         dfx canister install blockchart_assets 
    ```

9. Copy the canister identifier for the `blockchart_assets` canister (you can use `dfx canister id blockchart_assets`).

10. Open the `blockchart_assets` canister frontend in your web browser.

    For example, if using the default localhost address and port number, the URL looks similar to this:

    ```bash
    http://localhost:8000/?canisterId=7kncf-oidaa-aaaaa-aaaaa-aaaaa-aaaaa-aaaaa-q
    ```