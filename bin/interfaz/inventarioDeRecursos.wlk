import wollok.game.*
import interfaz.*
import items.recursos.*

object inventarioDeRecursos
{	
	const posicion = game.at(game.width()-2, 2)
	
	method generar()
	{
		new CasillaRecurso(madera).ubicarEn(game.at(posicion.x(), posicion.y()))
		new CasillaRecurso(piedra).ubicarEn(game.at(posicion.x() + 1, posicion.y()))
		new CasillaRecurso(hierro).ubicarEn(game.at(posicion.x(), posicion.y() - 1))
		new CasillaRecurso(oro).ubicarEn(game.at(posicion.x() + 1, posicion.y() - 1))
	}
	
	method reiniciarRecursos()
	{
		madera.reiniciar()
		piedra.reiniciar()
		hierro.reiniciar()
		oro.reiniciar()
	}
}

class CasillaRecurso inherits CasillaDeInventarioEnInterfaz
{
	const recurso
	
	constructor(_recurso)
	{
		recurso = _recurso
	}
	
	override method itemEnCasilla() = recurso
}