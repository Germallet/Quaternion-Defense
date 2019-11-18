import objetosConVida.*
import wollok.game.*
import escenario.*
import imagenEnlazada.*
import eventos.*

class Estructura inherits ObjetoConVida
{
	const property defensa = 0
	var position = null
	
	constructor()
	{
		barraDeVida = new BarraDeVida(self, true)
	}
	
	override method recibioDanioLetal(danio, agresor)
	{
		//Destruirse
		game.removeVisual(self)
		game.removeVisual(barraDeVida)
		escenario.estructuras().remove(self)
	}
	
	method nombre()
	
	method construirEn(_posicion)
	{
		position = _posicion
		//escenario.fondo(position).convertirEnTierra()
		escenario.estructuras().add(self)
		game.addVisualIn(self, position)
		game.addVisualIn(barraDeVida, position)
	}
	
	method recibirAtaqueNormal(danio, agresor)
	{
		self.sufrirDanio(danio, agresor)
	}
	
	method position() = position
	override method esAtravesable() = false
	override method image() = "assets/Estructuras/" + self.nombre() + ".png"
}

class EstructuraOfensiva inherits Estructura
{
	const property ataque = 0
	const rango = 0
	const eventoAtaque
	
	constructor() = super()
	{
		eventoAtaque = new EventoPeriodico(eventos1Segundo, 1, { self.atacarSiHayEnemigoEnRango() })
	}
	
	method presicion() = 100
	
	method estaEnRango(objetivo) = position.distance(objetivo.position()) <= rango
	
	// Filtra de la lista de enemigos los que estan dentro del rango de la estrectura
	method enemigosEnRango() = escenario.enemigos().filter{ enemigo => self.estaEnRango(enemigo) }
	
	// Comprueba si hay enemigos en rango
	method hayEnemigosEnRango() = escenario.enemigos().any{ enemigo => self.estaEnRango(enemigo) }
	
	// Atacara a cualquier unidad enemiga en su rango de ataque
	method atacarSiHayEnemigoEnRango() 
	{
		//Ataca un enemigo en rango aleatoreamente
		if(self.hayEnemigosEnRango())
			self.atacarA(self.enemigosEnRango().anyOne())
	}
	
	method atacarA(objetivo)
	{
		objetivo.recibirAtaqueNotmal(self.ataque(), self) //CalCulo del daño total
	}
	
	method matasteA(muerto) {}
	
	override method construirEn(_posicion)
	{
		super(_posicion)
		eventoAtaque.comenzar()
	}
	
	override method recibioDanioLetal(danio, agresor)
	{
		super(danio, agresor)
		eventoAtaque.interrumpir()
	}
}

class MuroDeMadera inherits Estructura
{
	constructor() = super()
	{
		vidaMaxima = 100
		vidaActual = vidaMaxima
	   	defensa = 15
	} 
	
	override method nombre() = "Muro_De_Madera"
}

class MuroDePiedra inherits Estructura
{
	constructor() = super()
	{
		vidaMaxima = 200
		vidaActual = vidaMaxima
	   	defensa = 30
	} 
	
	override method nombre() = "Muro_De_Piedra"
}

class TorreDePiedra inherits EstructuraOfensiva
{
	constructor() = super()
	{
		vidaMaxima = 60
		vidaActual = vidaMaxima
		ataque = 15
	   	defensa = 10
	 	rango = 5
	} 
	
	override method nombre() = "Torre_De_Piedra"
}
