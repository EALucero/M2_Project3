//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
	*@title Contrato Donations
	*@notice Este es un contrato con fines educativos.
	*@author i3arba - 77 Innovation Labs
	*@custom:security No usar en producción.
*/
contract Donaciones {

	/*///////////////////////
					Variables
	///////////////////////*/
	///@notice variable inmutable para almacenar la dirección que debe retirar las donaciones
	address immutable i_beneficiario;
	
	///@notice mapping para almacenar el valor donado por usuario
	mapping(address usuario => uint256 valor) public s_donaciones;
	
	/*///////////////////////
						Events
	////////////////////////*/
	///@notice evento emitido cuando se realiza una nueva donación
	event Donaciones_DonacionRecibida(address donador, uint256 valor);
	///@notice evento emitido cuando se realiza un retiro
	event Donaciones_RetiroRealizado(address receptor, uint256 valor);
	
	/*///////////////////////
						Errors
	///////////////////////*/
	///@notice error emitido cuando falla una transacción
	error Donaciones_TransaccionFallida(bytes error);
	///@notice error emitido cuando una dirección diferente al beneficiario intenta retirar
	error Donaciones_RetiradorNoAutorizado(address llamador, address beneficiario);
	
	/*///////////////////////
					Functions
	///////////////////////*/
	constructor(address _beneficiario) {
		i_beneficiario = _beneficiario;
	}
	
	///@notice función para recibir ether directamente
	receive() external payable {}
	fallback() external payable {}
	
	/**
		*@notice función para recibir donaciones
		*@dev esta función debe sumar el valor donado por cada dirección a lo largo del tiempo
		*@dev esta función debe emitir un evento informando la donación.
	*/
	function donar() external payable {
		s_donaciones[msg.sender] = s_donaciones[msg.sender] += msg.value;
	
		emit Donaciones_DonacionRecibida(msg.sender, msg.value);
	}
	
	/**
		*@notice funcion para retirar el valor de las donaciones
		*@notice el valor del retiro debe ser el valor de la nota enviada
		*@dev solo el beneficiario puede retirar
		*@param _valor El valor de la nota fiscal
	*/
	function retiro(uint256 _valor) external {
		if(msg.sender != i_beneficiario) revert Donaciones_RetiradorNoAutorizado(msg.sender, i_beneficiario);
		
		emit Donaciones_RetiroRealizado(msg.sender, _valor);
		
		_transferirEth(_valor);
	}
	
	/**
		*@notice función privada para realizar la transferencia del ether
		*@param _valor El valor a ser transferido
		*@dev debe revertir si falla
	*/
	function _transferirEth(uint256 _valor) private {
		(bool exito, bytes memory error) = msg.sender.call{value: _valor}("");
		if(!exito) revert Donaciones_TransaccionFallida(error);
	}
}