const assert = require('assert');

const SistemaSanitario = artifacts.require("SistemaSanitario");
const interface = SistemaSanitario['abi'];
const bytecode = SistemaSanitario['bytecode'];
//console.log(SistemaSanitario);
//console.log ("Interface", interface);
//console.log ("bytecode", bytecode );

// Para las pruebas:
// acounts[0] sera sanidad
// acounts[1] sera medico 1 autorizado
// acounts[2] sera medico 2 NO autorizado
// acounts[3] sera ciudadano 1
// acounts[4] sera ciudadano 2
// acounts[6] sera Aseguradora 1
before(async () => {
    accounts = await web3.eth.getAccounts();
    console.log("Accounts", accounts);
    manager = accounts[0];
    SSID = await new web3.eth.Contract(interface)
        .deploy({ data: bytecode, arguments: ["CASS", "AND"]})
        .send({ from: manager, gas: 5000000 });
    console.log ("SSID Deployed at:", SSID.options.address );
  });

  // verificamos si el contrato se ha desplegado
  contract("SistemaSanitario", () => {
    it('deploys a contract', () => {
      assert.ok(SSID.options.address);
    });

  // verificamos que la address de sanidad es la [0]
  it("SANIDAD", async () => {
    const sanidad = await SSID.methods.sanidad_addr().call();
    console.log("SANIDAD",sanidad);
    assert.equal(sanidad, accounts[0]);
  });

  //Damos de alta una aseguradora
    it("alta aseguradora 1", async () => {
    console.log("alta aseguradora 1",accounts[6]);
    assert.ok(await SSID.methods.altaAseguradora(accounts[6], "Accidentes de trabajo")
    .send({ from : accounts[0], gas: '5000000'}));
  });

  //Damos de alta un medico 1 Dentista
  it("alta medico 1", async () => {
    console.log("alta medico 1",accounts[1]);
    assert.ok(await SSID.methods.altaMedico("Dentista")
    .send({ from : accounts[1], gas: '5000000'}));
  });

  //Damos de alta un medico 2 Cirujano
  it("alta medico 2", async () => {
    console.log("alta medico 2");
    console.log("medico 2",accounts[2]);
    assert.ok(await SSID.methods.altaMedico("Cirujano")
    .send({ from : accounts[2], gas: '5000000'}));
  });

  //comprovamos que se ha dado de alta el medico Dentista
  it("consulta medico 1", async () => {
    console.log("consulta medico 1");
    console.log("medico 1",accounts[1]);
    medico = await SSID.methods.consultaMedico(accounts[1]).call();
    console.log("medico 1 consulta: ", medico);
    assert.equal(medico[0], "Dentista");
  });

  //Autorizamos medico 1
  it("Autorizamos medico 1", async () => {
    console.log("Sanidad autoriza medico 1");
    assert.ok(await SSID.methods.autorizarMedico(accounts[1]).send({ from : accounts[0], gas: '5000000'}));
  })
  
  //Autorizamos medico 2 por parte de otro medico (KO)
  it("Autorizamos medico 2", async () => {
    console.log("Medico autoriza medico 2 (KO)");
    try{
      assert.ko(await SSID.methods.autorizarMedico(accounts[2]).send({ from : accounts[1], gas: '5000000'}));
    }catch(err) {
      console.log(err);
    }
  });
  //Damos de alta un Ciudadano 1 por parte de sanidad (OK)
  it("alta ciudadano 1", async () => {
    console.log("alta ciudadano 1",accounts[3]);
    assert.ok(await SSID.methods.altaCiudadano(accounts[3])
    .send({ from : accounts[0], gas: '5000000'}));
  });

  //Damos de alta un Ciudadano 2 por parte de un medico (KO) 
  it("alta ciudadano 2", async () => {
    console.log("alta ciudadano 2",accounts[4]);
    try {
      assert.ok(await SSID.methods.altaCiudadano(accounts[4])
      .send({ from: accounts[1], gas: '5000000'}));
    } catch (err) {
      console.log(err)
    }
  });

  //Insertar Expediente por parte de un medico autorizado
  it("insertar expediente a ciudadano 1 por medico autorizado", async () => {
    console.log("insertar expediente 0 a ciudadano 1 por medico autorizado");
    console.log("medico   : ", accounts[1]);
    console.log("ciudadano: ", accounts[3]);
    assert.ok(await SSID.methods.insertExpediente(accounts[3], "Fiebre", "Aspirina", 3)
    .send( { from: accounts[1], gas: '5000000'}));
  });

  //Insertar Expediente por parte de un medico NO autorizado
  it("insertar expediente a ciudadano 1 por medico NO autorizado", async () => {
    console.log("insertar expediente a ciudadano 1 por medico NO autorizado");
    console.log("medico   : ", accounts[2]);
    console.log("ciudadano: ", accounts[3]);
    try{
      assert.ko(await SSID.methods.insertExpediente(accounts[3], "Dolor pie", "Reposo", 5)
      .send( { from: accounts[2], gas: '5000000'}));
    }catch(err) {
      console.log(err);
    }
  });

  //Insertar Expediente por parte de un medico a medico NO permitido
  //Primero damos de alta el medico 1 como ciudadano
  //Damos de alta un Ciudadano 1 por parte de sanidad (OK)
  it("alta ciudadano/medico 1", async () => {
    console.log("alta ciudadano/medico 1",accounts[1]);
    assert.ok(await SSID.methods.altaCiudadano(accounts[1])
    .send({ from : accounts[0], gas: '5000000'}));
  });

  it("insertar expediente a medico 1 por medico 1 NO permitido", async () => {
    console.log("insertar expediente medico 1 por medico 1 NO permitido");
    console.log("medico   : ", accounts[1]);
    console.log("ciudadano: ", accounts[1]);
    try{
      assert.ko(await SSID.methods.insertExpediente(accounts[1], "Dolor cabeza", "Dormir", 1)
      .send( { from: accounts[1], gas: '5000000'}));
    }catch(err) {
      console.log(err);
    }
  });

  //Consulta Expediente por parte de un medico autorizado
  it("consulta expediente 0 de ciudadano 1 por medico autorizado", async () => {
    console.log("consulta expediente 0 de ciudadano 1 por medico autorizado");
    console.log("medico   : ", accounts[1]);
    console.log("ciudadano: ", accounts[3]);
    expediente = await SSID.methods.consultaExpediente(accounts[3], 0)
    .call({ from: accounts[1] });
    console.log("Expediente: ", expediente);
    assert.equal(expediente[2], "Dentista");
  });

  //Consulta Expediente por parte de un medico NO autorizado
  it("consulta expediente 0 de ciudadano 1 por medico NO autorizado", async () => {
    console.log("consulta expediente 0 de ciudadano 1 por medico NO autorizado");
    console.log("medico   : ", accounts[2]);
    console.log("ciudadano: ", accounts[3]);
    try{
        assert.ko(await SSID.methods.consultaExpediente(accounts[3], 0)
                    .call({ from: accounts[2] }));
    }catch(err) {
        console.log(err);
    }
  });

  //Consulta Expediente por parte de una aseguradora
  it("consulta expediente 0 de ciudadano 1 por aseguradora autorizado", async () => {
    console.log("consulta expediente 0 de ciudadano 1 por aseguradora autorizada");
    console.log("aseguradora : ", accounts[6]);
    console.log("ciudadano   : ", accounts[3]);
    expediente = await SSID.methods.consultaExpedienteAseguradora(accounts[3], 0)
    .call({ from: accounts[6], value: 1000000 });
    console.log("Expediente: ", expediente);
    assert.equal(expediente[2], "Dentista");
  });

  //Consulta Expediente por parte de una aseguradora
  it("consulta expediente 0 de ciudadano 1 por aseguradora autorizado (value insufuciente)", async () => {
    console.log("consulta expediente 0 de ciudadano 1 por aseguradora autorizada(value insufuciente) ");
    console.log("aseguradora : ", accounts[6]);
    console.log("ciudadano   : ", accounts[3]);
    expediente = await SSID.methods.consultaExpedienteAseguradora(accounts[3], 0)
    .call({ from: accounts[6], value: 100000 });
    console.log("Expediente: ", expediente);
    assert.equal(expediente[2], "Dentista");
  });

  /*
contract("SistemaSanitario", accounts => {
  it("Should make first account an owner", async () => {
    let instance = await SistemaSanitario.deployed();
    let owner = await instance.owner();
    assert.equal(owner, accounts[0]);
    console.log("Address Deployed",instance.address);
  });
 */
});