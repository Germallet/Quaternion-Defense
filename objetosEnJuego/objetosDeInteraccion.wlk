import wollok.game.*

import objetosEnJuego.imagenEnlazada.*
import objetosEnJuego.objetosEnJuego.*

import items.consumibles.*
import eventos.*

/******************** Objetos De Interaccion ********************/
class ObjetoDeInteraccion inherits ObjetoEnJuego
{
	const barraDeProgreso = new BarraDeProgreso(self)
	const interaccion = new EventoPeriodico(eventos1Segundo, self.frecuencia(), { self.progresar() if(self.seProgresoTotalmente()) self.terminar() })
	
	var interactores = new List() // Deberia ser un new Set() pero el juego deja de responder :)
	var position
	
	method frecuencia() = 1
	
	method progreso()
	method total()
	method progresar()
	
	method terminar() {	self.dejarDeInteractuarConTodos() }
	method seProgresoTotalmente() = self.progreso() == self.total()
	
	override method interactuarCon(interactor)
	{
		interactores.add(interactor)
		interactores = interactores.withoutDuplicates()
		interactor.establecerObjetoDeInteraccion(self)
		
		if(not game.hasVisual(barraDeProgreso))
		{
			game.addVisualIn(barraDeProgreso, position)
			interaccion.comenzar()
		}
	}
	
	method dejarDeInteractuarCon(interactor)
	{
		interactores.remove(interactor)
		interactor.establecerObjetoDeInteraccion(null)
		
		if(interactores.isEmpty())
		{
			interaccion.interrumpir()
			game.removeVisual(barraDeProgreso)
		}	
	}
	
	method dejarDeInteractuarConTodos()
	{
		interactores.forEach{ interactor => self.dejarDeInteractuarCon(interactor) }
	}
	
	method ubicarEn(_position)
	{
		position = _position
		game.addVisualIn(self, position)
	}
}

class Arbusto inherits ObjetoDeInteraccion
{
	const property image = "assets/Terreno/Recursos/" + self.nombreDeArbusto() + "_" + new Range(start = 1, end = 2).anyOne() + ".png"
	var progreso = 0
	
	method nombreDeArbusto()
	
	override method total() = 10
	override method progreso() = progreso
	
	override method progresar() { progreso = progreso + interactores.size() }
	
	override method dejarDeInteractuarCon(interactor)
	{
		super(interactor)
		if(interactores.isEmpty())
			progreso =0
	}
	
	override method terminar()
	{
		new HierbaVerde(0.randomUpTo(3).roundUp()).agregarAInventario() // Se obtienen entre 0 y 3 Hierbas Verdes
		self.dejarDeInteractuarConTodos()
		game.removeVisual(self)
	}
}
class ArbustoVerde inherits Arbusto
{
	override method nombreDeArbusto() = "Arbusto_1"
}
class ArbustoNevado inherits Arbusto
{
	override method nombreDeArbusto() = "Arbusto_2"
}
