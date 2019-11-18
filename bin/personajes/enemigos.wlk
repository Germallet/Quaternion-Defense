import wollok.game.*
import items.equipos.*
import personajes.*
import escenario.*
import direcciones.*
import probabilidad.*
import habilidades.*
import eventos.*
import objetosEnJuego.drops.*
import items.materiales.*
import items.consumibles.*

/******************** Clase Enemigo ********************/
class Enemigo inherits Personaje
{	
	const dropsPosibles
	
	/******************** Estadisticas ********************/
	
	override method ataque() = ataque + 1.5 * escenario.nroHorda() + 3 * escenario.nivel()
	override method defensa() = defensa + escenario.nroHorda() + 2 * escenario.nivel()
	override method vidaMaxima() = vidaMaxima + 2 * escenario.nroHorda() + 10 * escenario.nivel()
	
	/******************** Combate ********************/
	// Verdadero si hay objetivo en el rango de ataque
	method haySobrevivientesEnRango() = escenario.sobrevivientes().any{ sobreviviente => arma.estaEnRango(sobreviviente) and sobreviviente.esAtacable() }
	method hayEstructurasEnRango() = escenario.estructuras().any{ estructura => arma.estaEnRango(estructura) }
		
	override method hayObjetivosEnRango() = self.haySobrevivientesEnRango() or self.hayEstructurasEnRango()
	
	// Posibles objetivos en rango
	method sobrevivienteEnRango() = escenario.sobrevivientes().filter{ sobreviviente => arma.estaEnRango(sobreviviente)}.anyOne()
	method estructuraEnRango() = escenario.estructuras().filter{ estructura => arma.estaEnRango(estructura)}.anyOne()
	
	// Obtiene un objetivo dentro del rango de ataque
	override method objetivoEnRango() 
	{
		var objetivo
		
		if(self.haySobrevivientesEnRango())
			objetivo = self.sobrevivienteEnRango()
		else if(self.hayEstructurasEnRango())
			objetivo = self.estructuraEnRango()
			
		return objetivo
	}
	
	method drop() = new Drop(dropsPosibles.anyOne(), self.position())
	
	override method efectoAlMorir(asesino)
	{
		self.drop().aparecer()
		escenario.removerEnemigo(self)
	}

	
	/******************** IA ********************/
	method obtenerSobrevivienteMasCercano() = escenario.sobrevivientes().min({ sobreviviente => position.distance(sobreviviente.position()) })
	method direccionesAtravesables() = [izquierda, arriba, abajo, derecha].filter({direccion => escenario.esAtravesable(direccion.posicion(position))})
	method direccionMasConveniente(direcciones, objetivo) = direcciones.min({ direccion => direccion.posicion(position).distance(objetivo.position()) })
	
	method moverHaciaSobrevivienteCercano()
	{
		if(not escenario.sobrevivientes().isEmpty())
		{
			var objetivo = self.obtenerSobrevivienteMasCercano()
			
			var direccionesAtravesables = self.direccionesAtravesables()
			if(not direccionesAtravesables.isEmpty())
			{
				var direccionMasConveniente = self.direccionMasConveniente(direccionesAtravesables, objetivo)
				self.moverHaciaSiEsPosible(direccionMasConveniente)				
			}
		}
	}
	
	method movimientoYAtaque()
	{
		// Ataca si tiene objetivos si no hay objetivos de ataque se mueve
		if(self.hayObjetivosEnRango())
			self.atacarA(self.objetivoEnRango())
		else
			self.moverHaciaSobrevivienteCercano()
	}
	
	/******************** Eventos ********************/
	// Gestiona todos los eventos 
	override method eventos() =
	[
		new EventoPeriodico(eventos1Segundo, self.tiempoDeAccion(), { self.movimientoYAtaque() })
	]
	/******************** Otros ********************/
	method agarrarDrop(drop) { drop.desaparecer() }
	override method inicializar() { super() orientacion = izquierda }
	override method image() = "assets/Personajes/Enemigos/" + self.nombre() + "/" + self.estadoDeAnimacion() + ".png" // Obtiene la imagen de la carpeta assets aprovechando para donde mira el enemigo
}

class ZombieTipo1 inherits Enemigo
{
	constructor()
	{
		arma = [new GarraZombie(usuario = self), new GarraZombiePerforante(usuario = self)].anyOne()
		ataque = 26
		defensa = 36
		
		vidaMaxima = 200
		vidaActual = vidaMaxima
		
		dropsPosibles = [new Garra(2), new Garra(3), new Cuero(2), new Cuero(3), new Pluma(2), new Pluma(3), new Cuerda(2), new Cuerda(3), new HierbaVerde(1), new BotasViejas()]
	}
	
	override method nombre() = "Zombie1"
	
	override method experienciaQueDa() = 2
}

class ZombieTipo2 inherits Enemigo
{
	var resurreccion

	constructor()
	{
		arma = new GarraZombie(usuario = self)
		ataque = 21
		defensa = 28
		
		vidaMaxima = 120
		vidaActual = vidaMaxima
		
		dropsPosibles = [new Garra(2), new Garra(3), new Cuero(2), new Cuero(3), new Pluma(2), new Pluma(3), new Cuerda(2), new Cuerda(3), new HierbaVerde(1)]
	
		self.agregarHabilidadPasiva(new AutoRevivir(usuario = self))
	}
		
	method agregarHabilidadPasiva(_resurreccion){ resurreccion = _resurreccion }
	
	method removerHabilidadPasiva(_resurreccion){ resurreccion = null }
	
	override method nombre() = "Zombie2"
	
	override method experienciaQueDa() = 2
}

class ZombieGordo inherits Enemigo
{
	constructor()
	{
		arma = new GarraZombieCegadora(usuario = self)
		ataque = 36
		defensa = 60
		
		vidaMaxima = 300
		vidaActual = vidaMaxima
		
		dropsPosibles = [new Pluma(2), new Pluma(3), new Cuerda(2), new Cuerda(3), new Diamante(1)]
	}
	
	override method nombre() = "ZombieGordo"
	
	method explotar()
	{
		escenario.sobrevivientes().filter{ sobreviviente => position.distance(sobreviviente.position()) <= 4 }.forEach{ sobreviviente => sobreviviente.sufrirDanio(ataque, self) }
	}
	
	override method efectoAlMorir(asesino)
	{
		self.explotar()
	}

	override method experienciaQueDa() = 4
}

class ZombieTanque inherits Enemigo
{
	constructor()
	{
		arma = new GarraZombieRobaVida(usuario = self)
		ataque = 54
		defensa = 120
		
		vidaMaxima = 500
		vidaActual = vidaMaxima
		
		dropsPosibles = [new Cuero(3), new Cuero(4), new Garra(3), new Garra(4), new Diamante(1)]
	}

	override method nombre() = if(self.vidaActual()>self.porcentajeDeVidaMaxima(50)) "ZombieTanque" else "ZombieTanqueEnsangrentado"
	
	override method experienciaQueDa() = 6
}

