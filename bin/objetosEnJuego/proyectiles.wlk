import wollok.game.*
import objetosEnJuego.objetosEnJuego.*

import eventos.*
import escenario.*
import probabilidad.*

class Proyectil inherits ObjetoEnJuego 
{
	const property tirador
	const property direccion
	var property position
	const disparo
	const danio
	
	constructor(_tirador, _danio)
	{
		tirador = _tirador
		direccion = tirador.orientacion()
		position = tirador.position()
		danio = _danio
		
		disparo = new EventoPeriodico(eventos02Segundos, 0.2, { self.avanzarSiEsPosible() })
	}
	
	method objetivo() = game.colliders(self).last()

	method disparar()
	{
		disparo.comenzar()
		game.addVisual(self)	
	}
	
	method direccionAAvanzar() = direccion.posicion(self.position())
	
	method avanzarSiEsPosible()
	{
		if(escenario.estaDentro(self.direccionAAvanzar()))
		{
			self.avanzar()
			if(not escenario.esAtravesable(self.position()))
				self.impactar()
		}
			
		else
			self.desaparecer()
	}
	
	method avanzar() { position = self.direccionAAvanzar()	}
	
	method impactar()
	{
		const objetivo = self.objetivo()
		objetivo.recibirAtaqueDeHabilidad(danio, tirador)
		self.efecto(objetivo, tirador)
	}
	
	method efecto(_objetivo, _tirador)
	
	method desaparecer()
	{
		game.removeVisual(self)
		disparo.interrumpir()
	}
	
	override method esAtravesable() = true
}

class FlechaSimple inherits Proyectil
{	
	method nombre() = "Flecha_Simple"
	override method efecto(_objetivo, _tirador) {}
	override method image() = "assets/Proyectiles/" + self.nombre() + "/" + direccion.toString() + ".png"
}

class FlechaIgnea inherits FlechaSimple
{
	override method nombre() = "Flecha_Ignea"
	override method efecto(objetivo, tirador) {	objetivo.quemar(tirador, 3) }
}

class FlechaGelida inherits FlechaSimple
{
	override method nombre() = "Flecha_Gelida"
	override method efecto(objetivo, tirador) { objetivo.escarchar(3) }
}

class FlechaOscura inherits FlechaSimple
{
	override method nombre() = "Flecha_Oscura"
	override method efecto(objetivo, tirador) { objetivo.cegar(3) }
}

class FlechaPerforante inherits FlechaSimple
{
	override method nombre() = "Flecha_Perforante"
	override method efecto(objeto, tirador) { objeto.desangrar(3) }
}

/*class GranadaExplosiva inherits Proyectil
{
	constructor(_danio) = super(_danio)
	{
		comportamiento = colisiona
	}
	
	override method impactar(posicion, tirador)
	{
		var objetivosEnRango = (escenario.enemigos() + escenario.sobrevivientes()).filter{ objetivo => posicion.distance(objetivo.position()) <= 1 }
		
		objetivosEnRango.forEach{ _objetivo => _objetivo.recibirAtaqueDeHabilidad(tirador, danio) }
	}
	
	override method image() = "assets/Proyectiles/GranadaExplosiva/" + direccion.toString() + ".png"
}

class BalaDePistola inherits Proyectil
{
	constructor(_danio) = super(_danio)
	{
		comportamiento = colisiona
	}
	
	override method impactar(posicion, tirador) {  posicion.allElements().last().recibirAtaqueDeHabilidad(tirador, danio) }
	
	override method image() = "assets/Proyectiles/BalaDePistola/" + direccion.toString() + ".png"
}*/



