import wollok.game.*
import objetosEnJuego.objetosEnJuego.*

import escenario.*
import sonidos.*
import objetosEnJuego.fondos.*
import eventos.*

//Elemento danino (fuego, rayo, posibles futuros elementos que produzcan un efecto dañino y animacion
class Elemento inherits ObjetoEnJuego
{	
	const iniciador
	var estado
	
	const eventoDeElemento
	
	constructor(duracion, _iniciador)
	{
		iniciador = _iniciador
		eventoDeElemento = new EventoPeriodicoTemporal(eventos02Segundos, duracion, 0.2, { self.avanzarEfecto() }, { self.efectoAlTerminar() game.removeVisual(self) })
	}
	
	method nombre()
	method animacion() = ""	
	
	method efectoInicial()
	method efectoPeriodico()
	method efectoAlTerminar()
	
	method activarEn(posicion)
	{
		game.addVisualIn(self, posicion)
		estado = 0
		eventoDeElemento.comenzar()
		self.efectoInicial()
	}
	
	method avanzarEfecto()
	{
		estado++
		if(estado >= 4)
			estado = 0
		self.efectoPeriodico()
	}
	
	method apagar()
	{
		self.efectoAlTerminar()
		eventoDeElemento.ejecutar()
	}
	
	override method image() = "assets/Efectos/" + self.nombre() + "/" + self.animacion() + estado + ".png"
}

class Fuego inherits Elemento
{
	const sonidoConjunto
	const gravedad
	
	constructor( _iniciador, _gravedad, _sonidoConjunto) = super(4, _iniciador)
	{
		gravedad = _gravedad
		sonidoConjunto = _sonidoConjunto
	}
	
	override method efectoInicial()
	{
		sonidoConjunto.reproducir("Fuego.wav")
	}	
	override method efectoPeriodico()
	{
		game.colliders(self).forEach{ objeto => objeto.quemar(iniciador, gravedad)}
	}	
	override method efectoAlTerminar()
	{
		game.colliders(self).head().convertirEn(tierra)
	}
	
	override method nombre() = "Fuego"
}

class Rayo inherits Elemento
{
	constructor(_iniciador) = super(4, _iniciador)
	
	override method efectoInicial()
	{		
	}
	override method efectoPeriodico()
	{
		game.colliders(self).forEach{ objeto => objeto.sufrirDanio(15 ,iniciador)}
	}
	override method efectoAlTerminar()
	{
	}
	
	override method nombre() = "Rayo"
	
	override method animacion() = iniciador.orientacion().toString() + "_"
}
