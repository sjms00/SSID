pragma solidity 0.4.25;
import "./TokenSSID.sol";

contract SistemaSanitario is TokenSSID {
    string sanidad_nombre;
    string sanidad_pais;
    address public sanidad_addr;

    struct Medico {
        address medico;
        string especialidad;
        uint fechaalta;
        uint fechabaja;
        bool autorizado;
        bool isExist;
    }
        
    struct Expediente{
        uint fecha;
        address medico;
        string especialidad;
        string dolencia;
        string tratamiento;
        uint duracion;
    }
        
    struct Ciudadano {
        address ciudadano;
        uint SSID;
        uint fechaalta;
        uint fechabaja;
        uint estado;
        bool isExist;
        Expediente[] expediente;
    }
    struct Aseguradora {
        address seguro;
        string especialidad;
        uint fechaalta;
        uint fechabaja;
        bool autorizado;
        bool isExist;
    }
    mapping(address => Medico) public medicos;
    mapping(address => Ciudadano) public ciudadanos;
    mapping(address => Aseguradora) public aseguradoras;

    modifier restrictedBySanidad() {
        require(sanidad_addr == msg.sender, "Restringuida a Sanidad");
        _;
    }
    modifier restrictedByMedicoAutorizado() {
        require(medicos[msg.sender].autorizado, "Requiere medico autorizado");
        _;
    }
   modifier restrictedByAseguradoraAutorizada() {
        require(aseguradoras[msg.sender].autorizado, "Requiere aseguradora autorizada");
        _;
    }
    // event utilizado para dejar en el log los datos de los expedientes insertados y consultados
    event eventExpediente(
        string _expediente,
        address _addressMedico,
        address _addressCiudadano,
        uint _SSID,
        uint _numExpediente,
        uint _fecha
        );
    /** 
    * @dev Al contructor le pasamos como parametros nombre sel sistema sanitario y el pais para una 
    * ampliación de las funcionalidades
    * @param _nombre string nombre sel sistema sanitario
    * @param _pais string indicando el pais del sistema sanitario
    */
    constructor(string _nombre, string _pais) public {
        sanidad_nombre = _nombre;
        sanidad_pais = _pais;
        sanidad_addr = msg.sender;
    }
    
    /** 
    * @dev Alta de un medico, los medicos se dan de alta ellos mismos
    * revert si medico ya existe
    * @param _especialidad string especialidad del medico que se da de alta
    */
    function altaMedico (string _especialidad)  public {
        address aux;
        aux = msg.sender;
        require(aux != sanidad_addr, "Address invalida");
        require(!medicos[aux].isExist, "Medico ya existe");

        medicos[aux].medico = aux;
        medicos[aux].especialidad = _especialidad;
        medicos[aux].fechaalta = now;
        medicos[aux].autorizado = false;
        medicos[aux].isExist = true;
    }
    /**  
    * @dev Consulta médico, solo Sanidad puede consultar medico
    * revert si medico no existe
    * @param _adrMedico address del medico a dar de alta
    * @return string especialidad del medico
    * @return uint fecha de alta
    * @return uint fecha de baja
    * @return bool si esta autorizado o no
    */
    function consultaMedico(address _adrMedico) public view restrictedBySanidad returns (string, uint, uint, bool){
        require(medicos[_adrMedico].isExist, "Medico no existe");
        return (
            medicos[_adrMedico].especialidad,
            medicos[_adrMedico].fechaalta,
            medicos[_adrMedico].fechabaja,
            medicos[_adrMedico].autorizado
        );
    }
    /**
    * @dev Baja de un medico, solo Sanidad puede dar de baja un medico, queda desautorizado
    * revert si el medico no existe
    * @param _adrMedico address del medico
    */
    function bajaMedico(address _adrMedico) public restrictedBySanidad {
        require(medicos[_adrMedico].isExist, "Medico no existe");
        medicos[_adrMedico].fechabaja = now;
        medicos[_adrMedico].autorizado = false;
    }
    /**
    * @dev Autorizar medico, solo Sanidad puede autorizar a un medico
    * revert si no es sanidad quin lo ejecuta
    * revert si el medico ya estaba autorizado
    * revert si el medico no existe
    * @param _adrMedico address del medico
    */
    function autorizarMedico (address _adrMedico)  public restrictedBySanidad {
        address aux;
        aux = msg.sender;
        require(aux == sanidad_addr, "Solo Sanidad puede autorizar");
        require(!medicos[_adrMedico].autorizado, "Medico ya estaba autorizado");
        require(medicos[_adrMedico].isExist, "Medico no existente");
        medicos[_adrMedico].autorizado = true;
    }
    /**
    * @dev desautorizar medico, solo Sanidad puede desautorizar a un medico
    * revert si no es sanidad quin lo ejecuta
    * revert si el medico ya estaba desautorizado
    * revert si el medico no existe
    * @param _adrMedico address del medico
    */
    function desautorizarMedico (address _adrMedico)  public restrictedBySanidad {
        address aux;
        aux = msg.sender;
        require(aux == sanidad_addr, "Solo Sanidad puede desautorizar");
        require(medicos[_adrMedico].autorizado, "Medico ya estaba desautorizado !");
        require(medicos[_adrMedico].isExist, "Medico no existente");
        medicos[_adrMedico].autorizado = false;
    }
    /**
    * @dev Alta ciudadano, solo Sanidad puede dar de alta un ciudadano, se le asigna un Token SSID
    * revert si el ciudadano ya existe
    * @param _adrCiudadano address del ciudadano
    */
    function altaCiudadano (address _adrCiudadano)  public restrictedBySanidad {
        require(!ciudadanos[_adrCiudadano].isExist,"Ciudadano ya existe");
        ciudadanos[_adrCiudadano].ciudadano = _adrCiudadano;
        ciudadanos[_adrCiudadano].fechaalta = now;
        ciudadanos[_adrCiudadano].estado = 1; // 1 Alta
        ciudadanos[_adrCiudadano].isExist = true;
        ciudadanos[_adrCiudadano].SSID = mintTo(_adrCiudadano);
    }
    /**
    * @dev Baja ciudadano, solo Sanidad puede dar de baja un ciudadano
    * revert si el ciudadano no existe
    * @param _adrCiudadano address del ciudadano
    */
    function bajaCiudadano (address _adrCiudadano)  public restrictedBySanidad {
        require(ciudadanos[_adrCiudadano].isExist, "Ciudadano no existe");
        ciudadanos[_adrCiudadano].fechabaja = now;
        ciudadanos[_adrCiudadano].estado = 2; // 2 Baja
    }
    /**
    * @dev Modificar el estado de un ciudadano, solo Sanidad puede modificar el estado un ciudadano
    * solo se permite estado: 0=desaperecido, 1=alta
    * revert si el ciudadano no existe
    * @param _adrCiudadano address del ciudadano
    * @param _estado uint con el valor del nuevo estado
    */
    function modifCiudadano (address _adrCiudadano, uint _estado)  public restrictedBySanidad {
        require(ciudadanos[_adrCiudadano].isExist, "Ciudadano no existe");
        require(_estado <2, "Estados permitidos: 0=desaperecido, 1=alta");
        ciudadanos[_adrCiudadano].fechabaja = now;
        ciudadanos[_adrCiudadano].estado = _estado; // 2 Baja
    }

    // Solo Sanidad puede dar de alta una Aseguradora
     /**
    * @dev Alta aseguradora, solo Sanidad puede dar de alta una aseguradora
    * revert si la aseguradora ya existe
    * @param _adrAseguradora address de la aseguradora
    * @param _especialidad string con la especialidad de la aseguradora
    */
    function altaAseguradora (address _adrAseguradora, string _especialidad)  public restrictedBySanidad {
        require(!aseguradoras[_adrAseguradora].isExist,"Aseguradora ya existe");
        aseguradoras[_adrAseguradora].seguro = _adrAseguradora;
        aseguradoras[_adrAseguradora].especialidad = _especialidad;
        aseguradoras[_adrAseguradora].fechaalta = now;
        aseguradoras[_adrAseguradora].autorizado = true; 
        aseguradoras[_adrAseguradora].isExist = true;
    }
    
    /**
    * @dev Insertar expediente, solo lo puede realizar un medico autorizado por Sanidad
    * revert si el ciudadano no existe
    * revert si el ciudadano es el propio medico, no se permite autodiagnosticar
    * revert si el estado del ciudadano no es igual a 1 (alta)
    * @param _adrCiudadano address del ciudadano al que se a diagnosticado
    * @param _dolencia string con la dolencia diagnosticada
    * @param _tratamiento string con el tratamiento medico
    * @param _duracion uint con la duracion del tratamiento
    * @dev se genera un evento con información del medico que lo ha diagnosticado, ciudadano, 
    * token SSID, Nº expediente y fecha
    */
    function insertExpediente (address _adrCiudadano,string _dolencia,string _tratamiento,uint _duracion) public restrictedByMedicoAutorizado{
        Expediente memory aux_Expediente;
        uint _IDexpediente;
        uint _SSID;
        require(ciudadanos[_adrCiudadano].isExist, "Ciudadano no existe");
        require(_adrCiudadano != msg.sender, "No se permite autodiagnosticar");
        require(ciudadanos[_adrCiudadano].estado == 1, "Estado incorrecto de ciudadano");
        aux_Expediente.fecha = now;
        aux_Expediente.medico = msg.sender;
        aux_Expediente.especialidad = medicos[msg.sender].especialidad;
        aux_Expediente.dolencia = _dolencia;
        aux_Expediente.tratamiento = _tratamiento;
        aux_Expediente.duracion = _duracion;
        _IDexpediente = ciudadanos[_adrCiudadano].expediente.push(aux_Expediente) - 1;
        _SSID = ciudadanos[_adrCiudadano].SSID;

        emit eventExpediente(
            "Expediente insertado por:",
            msg.sender,
            _adrCiudadano,
            _SSID,
            _IDexpediente,
            now
        );
    }

    /**
    * @dev Consultar expediente, solo lo puede realizar un medico autorizado por Sanidad
    * revert si el ciudadano no existe
    * revert si el ID del expediente no existe
    * @param _adrCiudadano address del ciudadano al que se a diagnosticado
    * @param _IDexpediente uint ID del expediente a consultar
    * @dev se genera un evento con información del medico que lo ha consultado, ciudadano, 
    * token SSID, Nº expediente y fecha
    * @return uint fecha del expediente
    * @return address del medico que lo diagnosticó
    * @return string especialidad del medico que lo diagnosticó
    * @return string de la dolencia
    * @return string con el tratamiento
    * @return uint con el token SSID del ciudadano
    */
    function consultaExpediente (address _adrCiudadano, uint _IDexpediente)  public restrictedByMedicoAutorizado returns(uint,address,string,string,string,uint) {
        address aux_medico;
        aux_medico = msg.sender;
        require(ciudadanos[_adrCiudadano].isExist, "Ciudadano no existe");
        require(ciudadanos[_adrCiudadano].expediente.length > _IDexpediente, "ID expediente no existe");
     
        emit eventExpediente(
            "Expediente consultado por:",
            msg.sender,
            _adrCiudadano,
            ciudadanos[_adrCiudadano].SSID,
            _IDexpediente,
            now
        );
        return(
            ciudadanos[_adrCiudadano].expediente[_IDexpediente].fecha,
            ciudadanos[_adrCiudadano].expediente[_IDexpediente].medico,
            ciudadanos[_adrCiudadano].expediente[_IDexpediente].especialidad,
            ciudadanos[_adrCiudadano].expediente[_IDexpediente].dolencia,
            ciudadanos[_adrCiudadano].expediente[_IDexpediente].tratamiento,
            ciudadanos[_adrCiudadano].SSID
            );
    }
    
    /**
    * @dev Consultar expediente, solo lo puede realizar una aseguradora autorizada por Sanidad
    * revert si el ciudadano no existe
    * revert si el ID del expediente no existe
    * @param _adrCiudadano address del ciudadano al que se a diagnosticado
    * @param _IDexpediente uint ID del expediente a consultar
    * @dev se genera un evento con información de la aseguradora que lo ha consultado, ciudadano, 
    * token SSID, Nº expediente y fecha
    * @return uint fecha del expediente
    * @return address del medico que lo diagnosticó
    * @return string especialidad del medico que lo diagnosticó
    * @return string de la dolencia
    * @return string con el tratamiento
    * @return uint con el token SSID del ciudadano
    */
     function consultaExpedienteAseguradora (address _adrCiudadano, uint _IDexpediente)  
        public payable restrictedByAseguradoraAutorizada returns(uint,address,string,string,string,uint) {
        address aux_aseguradora;
        aux_aseguradora = msg.sender;
        require(msg.value >= 1000000, "Pago insuficiente");
        require(ciudadanos[_adrCiudadano].isExist, "Ciudadano no existe");
        require(ciudadanos[_adrCiudadano].expediente.length > _IDexpediente, "ID expediente no existe");
     
        emit eventExpediente(
            "Expediente consultado por:",
            msg.sender,
            _adrCiudadano,
            ciudadanos[_adrCiudadano].SSID,
            _IDexpediente,
            now
        );
        return(
            ciudadanos[_adrCiudadano].expediente[_IDexpediente].fecha,
            ciudadanos[_adrCiudadano].expediente[_IDexpediente].medico,
            ciudadanos[_adrCiudadano].expediente[_IDexpediente].especialidad,
            ciudadanos[_adrCiudadano].expediente[_IDexpediente].dolencia,
            ciudadanos[_adrCiudadano].expediente[_IDexpediente].tratamiento,
            ciudadanos[_adrCiudadano].SSID
            );
    }
} 