import wollok.game.*
import escenario.*
import contadores.*

object textoDeNivel 
{
	const posicion = game.at(1, game.height()-1)
	
	method ubicar()
	{
		var posicionDeAlLado = game.at(posicion.x()+2, posicion.y())
		
		game.addVisualIn(self, posicion)
		game.addVisualIn(new DosDigitos_Unidad(escenario, mostrarUltimoCero), posicionDeAlLado)
		game.addVisualIn(new DosDigitos_Decena(escenario, mostrarUltimoCero), posicionDeAlLado)
	}
	
	method image() = "assets/Interfaz/DatosEnPartida/Nivel.png"
}

object textoDeExperiencia
{
	const posicion = game.at(13, game.height()-1)
	
	method ubicar()
	{
		var posicionDeAlLado = game.at(posicion.x()+1, posicion.y())
		
		game.addVisualIn(self, posicion)
		game.addVisualIn(new DosDigitos_Unidad(nivelDeSobrevivienteSeleccinoado, mostrarUltimoCero), posicionDeAlLado)
		game.addVisualIn(new DosDigitos_Decena(nivelDeSobrevivienteSeleccinoado, mostrarUltimoCero), posicionDeAlLado)
	}
	
	method image() = "assets/Interfaz/DatosEnPartida/Exp.png"
}

object nivelDeSobrevivienteSeleccinoado
{
	method numeroAMostrar() = escenario.sobrevivienteSeleccionado().nivel()
}