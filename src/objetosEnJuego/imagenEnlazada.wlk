import wollok.game.*
import objetosEnJuego.objetosEnJuego.*

import escenario.*
import eventos.*

class ImagenEnlazada inherits ObjetoEnJuego
{
	const property objetoEnlazado
	var image
	
	constructor(_objetoEnlazado)
	{
		objetoEnlazado = _objetoEnlazado
		image = ""
	}
	
	constructor(_objetoEnlazado, _image)
	{
		objetoEnlazado = _objetoEnlazado
		image = _image
	}

	override method interactuarCon(objeto) { objetoEnlazado.interactuarCon(objeto) }	
	override method quemar(quemador, gravedad) { objetoEnlazado.quemar(quemador, gravedad) }
	override method desangrar(gravedad) { objetoEnlazado.desangrar(gravedad) }
	override method escarchar(gravedad) { objetoEnlazado.escarchar(gravedad) }
	override method congelar(gravedad) { objetoEnlazado.congelar(gravedad) }
	override method cegar(gravedad) { objetoEnlazado.cegar(gravedad) }
	override method revivir(porcentajeDeVida) { objetoEnlazado.revivir(porcentajeDeVida) }  
	override method sufrirDanio(danio, agresor) { objetoEnlazado.sufrirDanio(danio, agresor) }
	override method recibirAtaqueDeHabilidad(danio, agresor) { objetoEnlazado.recibirAtaqueDeHabilidad(danio, agresor) }
	
	method position() = self.objetoEnlazado().position()
	override method image() = image
}

class AnimacionEnlazada inherits ImagenEnlazada
{
	const direccionImagen
	const animacion 
	
	var momentoDeAnimacion
	
	constructor(periodo, momentoMaximo, objetoEnlazado , _direccionImagen) = super(objetoEnlazado)
	{
		direccionImagen = _direccionImagen
		
		animacion = new EventoPeriodico(eventos02Segundos, periodo, { self.avanzarAnimacion(momentoMaximo) })
		
		momentoDeAnimacion = 0
	}
	
	method avanzarAnimacion(momentoMaximo) 
	{
		momentoDeAnimacion++
		
		if(momentoDeAnimacion == momentoMaximo)
			momentoDeAnimacion = 0
	}
	
	method comenzar()
	{		
		game.addVisual(self)
		animacion.comenzar()
	}
	
	method interrumpir()
	{	
		animacion.interrumpir()
		game.removeVisual(self)
	}
	
	override method position() = objetoEnlazado.position()
	override method image() = direccionImagen + "/" + momentoDeAnimacion.toString() + ".png"
}

class ParpadeoRojo inherits ImagenEnlazada
{
	override method image() = "assets/Efectos/Rojo_Transparente.png"
}
class ExplosionPerforante inherits ImagenEnlazada
{
	override method image() = "assets/Efectos/Explosion_Perforante.png"
}

class BarraDeVida inherits ImagenEnlazada
{
	const ocultarBarraLlena
	
	constructor(_objetoEnlazado) = super(_objetoEnlazado)
	{
		ocultarBarraLlena = false
	}
	
	constructor(_objetoEnlazado, _ocultarBarraLlena) = super(_objetoEnlazado)
	{
		ocultarBarraLlena = _ocultarBarraLlena
	}
	
	// Calcula el porcentaje de vida y lo convierte en un múltiplo de 10 (ej 97 -> 100 ; 62 -> 70)
	method porcentajeDeVidaRedondeado() = (objetoEnlazado.vidaActual() / objetoEnlazado.vidaMaxima()).truncate(1)  * 100
	
	method estaLlena() = self.porcentajeDeVidaRedondeado() == 100
	
	method sufijo() = if(ocultarBarraLlena and self.estaLlena()) "Oculta" else self.porcentajeDeVidaRedondeado().toString()
	
	override method image() = "assets/Interfaz/BarraDeVida/Barra_De_Vida_" + self.sufijo() + ".png"
}


class BarraDeProgreso inherits ImagenEnlazada
{
	// Calcula el porcentaje de vida y lo convierte en un múltiplo de 10 (ej 97 -> 100 ; 62 -> 70)
	method porcentajeDeProgresoRedondeado() = (objetoEnlazado.progreso() / objetoEnlazado.total()).truncate(1)  * 100
	
	override method image() = "assets/Interfaz/BarraDeInteraccion/Barra_De_Interaccion_" + self.porcentajeDeProgresoRedondeado().toString() + ".png"
}

class BarraDeEscudo inherits ImagenEnlazada
{
	// Calcula el porcentaje de vida y lo convierte en un múltiplo de 20 (ej 87 -> 100 ; 52 -> 60)
	method porcentajeDeEscudoRedondeadoAMultiploDe20() 
	{
		var porcentaje = (objetoEnlazado.escudoActual() / objetoEnlazado.escudoMaximo()).truncate(1)  * 100
	
		if(porcentaje%20 != 0)
			porcentaje = porcentaje + 10
		
		return porcentaje
	}
	override method image() = "assets/Interfaz/BarraDeEscudo/Barra_De_Escudo_" + self.porcentajeDeEscudoRedondeadoAMultiploDe20().toString() + ".png"
}

