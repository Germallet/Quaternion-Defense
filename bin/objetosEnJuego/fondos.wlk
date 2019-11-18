import wollok.game.*
import objetosEnJuego.objetosEnJuego.*
import objetosEnJuego.elementos.*

import escenario.*
import sonidos.*
import probabilidad.*


class FondoEscenario inherits ObjetoEnJuego
{
	const property posicion
	var suelo
	
	var estadoDrop = noTieneDrop
	var drop = null
	
	constructor(_suelo, posX, posY)
	{
		posicion = game.at(posX, posY)
		self.convertirEn(_suelo)
	}
	
	method agregarDrop(_drop)
	{
		drop = _drop
		estadoDrop = tieneDrop
	}
	method removerDrop()
	{
		drop = null
		estadoDrop = noTieneDrop
	}
	
	method drop() = drop
	
	method pisar(pisador) { estadoDrop.agarrarDrop(self, pisador) }
	
	method convertirEn(nuevoSuelo) { suelo = nuevoSuelo }
	
	method ubicar() { game.addVisualIn(self, posicion) }
	
	method encenderFuego(usuario, gravedad, sonidoConjunto) { suelo.encenderFuego(usuario, gravedad, sonidoConjunto, posicion) }
	
	override method image() = suelo.image()
	override method esAtravesable() = suelo.esAtravesable()
}

object tieneDrop
{
	method agarrarDrop(fondo, pisador) { pisador.agarrarDrop(fondo.drop()) }
}

object noTieneDrop
{
	method agarrarDrop(fondo, pisador) {}
}
class Suelo
{
	method esAtravesable() = true
	method encenderFuego(usuario, gravedad, sonidoConjunto, posicion)
	{
		new Fuego(usuario, gravedad , sonidoConjunto).activarEn(posicion)
	}
}
object tierra inherits Suelo
{
	method image() = "assets/Terreno/Suelo/Transparente.png"
}
object pasto inherits Suelo
{
	method image() = "assets/Terreno/Suelo/Pasto.png"
}
object arena inherits Suelo
{
	method image() = "assets/Terreno/Suelo/Arena.png"
}
object nieve inherits Suelo
{
	method image() = "assets/Terreno/Suelo/Nieve.png"
}
object agua inherits Suelo
{
	method image() = "assets/Terreno/Suelo/Agua.png"
	override method esAtravesable() = false
	override method encenderFuego(usuario, gravedad, sonidoConjunto, posicion) {}
}

class FondoBordeConSuelo inherits ObjetoEnJuego
{
	const suelo
	
	constructor(_suelo)
	{
		suelo = _suelo
	}
	method convertirEn(nuevoSuelo) {}
	override method esAtravesable() = false
	method encenderFuego(usuario, gravedad, sonidoConjunto) {}	
	override method image() = suelo.image()
	
	method ubicar(posX, posY)
	{
		game.addVisualIn(self, game.at(posX, posY))
	}
}

class FondoInterfaz inherits ObjetoEnJuego
{
	const property image
	constructor(imagen)
	{
		image = "assets/Interfaz/Marco/" + imagen + ".png"
	}
	method convertirEn(nuevoSuelo) {}
	override method esAtravesable() = false
	method encenderFuego(usuario, gravedad, sonidoConjunto) {}
	
	method ubicar(posX, posY)
	{
		game.addVisualIn(self, game.at(posX, posY))
	}
}

object fondoFueraDelMapa inherits ObjetoEnJuego
{
	override method image() = ""
	method convertirEn(nuevoSuelo) {}
	override method esAtravesable() = false
	method encenderFuego(usuario, gravedad, sonidoConjunto) {}
}