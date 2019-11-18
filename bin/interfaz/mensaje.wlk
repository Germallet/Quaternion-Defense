import wollok.game.*
import objetosEnJuego.objetosEnJuego.*
import escenario.*
import eventos.*

object mensaje inherits ObjetoEnJuego
{	
	override method image() = "assets/Interfaz/Mensaje/Cuadro.png"	
	method posicion() = game.at(16, game.height()-2)
		
	method mostrarInformacionDe(_objetoConInformacion)
	{
		self.ocultar()
		game.addVisualIn(self, self.posicion())
		game.addVisualIn(mensajeTexto,  self.posicion())
		mensajeTexto.establecerTexto(_objetoConInformacion)
	}
	
	method mostrarInformacionDe(_objetoConInformacion, tiempo)
	{
		self.mostrarInformacionDe(_objetoConInformacion)
		new EventoSimple(eventos1Segundo, tiempo, { self.ocultar() }).comenzar()
	}
	
	method ocultar()
	{
		if(game.hasVisual(self))
		{
			game.removeVisual(self)
			game.removeVisual(mensajeTexto)
		}
	}	
}

object mensajeTexto inherits ObjetoEnJuego
{
	var objetoConTexto = null
	override method image() = "assets/Interfaz/Mensaje/" + objetoConTexto.informacion() + ".png"
	
	method establecerTexto(_objetoConTexto)
	{
		objetoConTexto = _objetoConTexto
	}
}

object tutorial
{
	var indice = 1
	
	const eventoTutorial = new EventoPeriodico(eventos1Segundo, 12, { self.avanzarTutorial() })
	
	method informacion() = "Tutorial/Tutorial_" + indice
	method iniciar()
	{
		mensaje.mostrarInformacionDe(self, 12 * 9)
		eventoTutorial.comenzar()
	}
	method avanzarTutorial()
	{
		if (indice < 9)
			indice++
		else
			eventoTutorial.interrumpir()
	}
}