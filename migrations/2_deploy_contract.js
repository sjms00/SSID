const SistemaSanitario = artifacts.require("./SistemaSanitario.sol");
module.exports = async function(deployer) {
  await deployer.deploy(SistemaSanitario, "CASS", "AND")
};