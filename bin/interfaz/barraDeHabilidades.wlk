import wollok.game.*
import escenario.*
import contadores.*
import personajes.habilidades.*

object barraDeHabilidades 
{
	const posicion = game.at(5, game.height()-1)
	
	method generar()
	{
		const cantHabilidadesActivas = 3
		const cantHabilidadesPasivas = 3
		
		cantHabilidadesActivas.times{ num => new CasillaHabilidadActiva(num-1).ubicar(game.at(posicion.x()+num, posicion.y())) }
		cantHabilidadesPasivas.times{ num => new CasillaHabilidadPasiva(num-1).ubicar(game.at(posicion.x()+num+cantHabilidadesActivas, posicion.y())) }
	}
}

class CasillaHabilidad
{
	var numeroDeHabilidad
	 
	constructor(_numeroDeHabilidad)
	{
		numeroDeHabilidad = _numeroDeHabilidad
	}
	
	//method enfriamientoDeHabilidad() = self.habilidadEnCasilla().momentoDeEnfriamiento()
	
	method ubicar(position)
	{
		game.addVisualIn(self, position)
		game.addVisualIn(new DosDigitos_Unidad(self, mostrarTodosLosCerosSiNoEsCero), position)
		game.addVisualIn(new DosDigitos_Decena(self, mostrarTodosLosCerosSiNoEsCero), position)
	}
	
	method habilidadEnCasilla()
	
	method numeroAMostrar() = self.habilidadEnCasilla().momentoDeEnfriamiento()
	
	method image() = self.habilidadEnCasilla().image()
}

class CasillaHabilidadActiva inherits CasillaHabilidad
{
	override method habilidadEnCasilla() = escenario.sobrevivienteSeleccionado().habilidadActiva(numeroDeHabilidad)
}

class CasillaHabilidadPasiva inherits CasillaHabilidad
{
	override method habilidadEnCasilla() = escenario.sobrevivienteSeleccionado().habilidadPasiva(numeroDeHabilidad)
}


