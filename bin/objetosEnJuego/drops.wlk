import wollok.game.*
import objetosEnJuego.objetosEnJuego.*
import eventos.*
import escenario.*

class Drop inherits ObjetoEnJuego
{
	const item
	const fondo
	const tiempo
	
	constructor(_item, _position)
	{
		item = _item
		fondo = escenario.fondo(_position)
		tiempo = new EventoSimple(eventos1Segundo, 10, { self.desaparecer() })
	}
	
	method serAgarrado()
	{
		item.agregarAInventario()
		self.desaparecer()
	}
	
	method aparecer()
	{
		game.addVisualIn(self, fondo.posicion())
		tiempo.comenzar()
		
		fondo.agregarDrop(self)
	}
	
	method desaparecer() 
	{ 
		tiempo.interrumpir()
		fondo.removerDrop()
		game.removeVisual(self)
	}
	
	override method image() = item.image()
}
