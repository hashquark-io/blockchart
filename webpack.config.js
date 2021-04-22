const path = require("path");
const TerserPlugin = require("terser-webpack-plugin");
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const dfxJson = require("./dfx.json");
// var HtmlWebpackPlugin = require('html-webpack-plugin')
// List of all aliases for canisters. This creates the module alias for
// the `import ... from "ic:canisters/xyz"` where xyz is the name of a
// canister.
const aliases = Object.entries(dfxJson.canisters).reduce((acc, [name,]) => {

  // Get the network name, or `local` by default.
  const networkName = process.env['DFX_NETWORK'] || 'local';
  const outputRoot = path.join(__dirname, '.dfx', networkName, 'canisters', name);

  return {
    ...acc, 
    ['dfx-generated/' + name]: path.join(outputRoot, name + '.js')
  };
}, {
});

/**
 * Generate a webpack configuration for a canister.
 */
function generateWebpackConfigForCanister(name, info) {
  if (typeof info.frontend !== 'object') {
    return;
  }

  const inputRoot = __dirname;
  const entry = path.join(inputRoot, info.frontend.entrypoint);

  return {
    mode: "production",
    entry,
    devtool: "cheap-module-eval-source-map",
    optimization: {
      minimize: true,
      minimizer: [new TerserPlugin()],
    },  
    resolve: {
      alias: aliases,
    },
    output: {
      filename: "index.[hash:8].js",
      path: path.join(__dirname, "dist", name),
    },
    plugins: [    new HtmlWebpackPlugin({  // Also generate a test.html
      template: 'src/blockchart/assets/index.html'
    }),   new CleanWebpackPlugin()],
    module: {
      rules: [{
        test: /\.css$/,
        use: ['style-loader', 'css-loader']
      }]
    }
  };
}

// If you have webpack configurations you want to build as part of this
// config, add them here.
module.exports = [
  ...Object.entries(dfxJson.canisters).map(([name, info]) => {
    return generateWebpackConfigForCanister(name, info);
  }).filter(x => !!x),
];
