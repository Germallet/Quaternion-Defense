import wollok.game.*

import objetosEnJuego.elementos.*
import objetosEnJuego.proyectiles.*

import interfaz.mensaje.*

import sonidos.*
import escenario.*
import sonidos.*
import eventos.*
import personajes.personajes.*

/******************** Habilidades ********************/
class Habilidad
{
	var usuario = null
	var position = null
	var enfriamiento = null
	
	var estado = habilidadDisponible
	
	method nombre() = "Ninguna_Habilidad"
	
	method nivel() = usuario.nivel()

	method enfriamiento() = enfriamiento

	method timepoDeEnfriamientoFinal() = self.tiempoDeEnfriamiento() - usuario.reduccionDeEnfriamiento()
	
	method habilitar() { estado = habilidadDisponible }
	
	method deshabilitar() { estado = habilidadNoDisponible }
	
	method momentoDeEnfriamiento() = estado.momentoDeEnfriamiento(self)
	
	method tiempoDeEnfriamiento()
	
	method reducirEnfriamiento(segundos) { estado.reducirEnfriamiento(self, segundos) }
	method aumentarEnfriamiento(segundos) {	estado.aumentarEnfriamiento(self, segundos)  }

	method comenzarEnfriamiento()
	{
		self.deshabilitar()
		self.efectoAlComenzarEnfriamiento()
		
		enfriamiento = new EventoPeriodicoTemporal(eventos1Segundo, self.timepoDeEnfriamientoFinal(), 1, {}, { self.termianarEnfriamiento() })
		enfriamiento.comenzar()
	}
	
	method efectoAlComenzarEnfriamiento() {}
	
	method termianarEnfriamiento()
	{
		self.habilitar()
		enfriamiento.interrumpir()
		self.efectoAlTerminarEnfriamiento()
	}
	
	method efectoAlTerminarEnfriamiento() {}
	
	method refrescar() { estado.refrescar(self) }
	
	method activar() { estado.activar(self) }
	
	method efectoActivacionNoDisponible() {}
	
	method efectoDeActivacion() {}
	
	method equiparEn(_usuario)
	{
		usuario = _usuario
		self.efectoAlEquipar()
	}
	
	method efectoAlEquipar() {}
	
	method desequipar()
	{
		usuario = null
		self.efectoAlDesequipar()
	}
	
	method efectoAlDesequipar() {}
	
	method coste() = 0
	
	method position() = position
	method image() = "assets/Habilidades/" + self.nombre() + "_" + estado.nombre() + ".png"
			
	method informacion() = "Habilidades/" + self.nombre()
}

object habilidadDisponible
{
	method nombre() = "Disponible"
	
	method activar(habilidad)
	{
		habilidad.efectoDeActivacion()
		habilidad.comenzarEnfriamiento()
	}

	method reducirEnfriamiento(habilidad, segundos) {}
	method aumentarEnfriamiento(habilidad, segundos) {}
	
	method momentoDeEnfriamiento(habilidad) = 0
	method refrescar(habilidad) {}
	
}

object habilidadNoDisponible
{
	method nombre() = "No_Disponible"
	
	method activar(habilidad)
	{
		habilidad.efectoActivacionNoDisponible()
	}

	method reducirEnfriamiento(habilidad, segundos)
	{
		habilidad.enfriamiento().modificarDuracion(-segundos)
	}
	method aumentarEnfriamiento(habilidad, segundos)
	{
		habilidad.enfriamiento().modificarDuracion(segundos)
	}
	
	method momentoDeEnfriamiento(habilidad) = habilidad.enfriamiento().momento()
	method refrescar(habilidad) { habilidad.enfriamiento().ejecutar() }
	
}

/******************** ACTIVAS ********************/

class HabilidadActiva inherits Habilidad
{
	override method efectoActivacionNoDisponible()
	{
		sonido.reproducir("Habilidad_En_Enfriamiento.wav")
	}
	
	override method equiparEn(usuario)
	{
		super(usuario)
		usuario.agregarHabilidadActiva(self)
	}
	
	override method tiempoDeEnfriamiento() = 0
	
	override method desequipar()
	{
		usuario.removerHabilidadActiva(self)
		super()
	}
}

/*
class ChispaFinal inherits HabilidadActiva
{
	override method tiempoDeEnfriamiento() = 20 - nivel * 2
	
	override method nombre() = "Chispa_Final"
	
	override method efectoDeActivacion()
	{
		var sentido = usuario.orientacion()
		game.schedule(100, // SCHEDULE!
			{
				10.times{
					num =>
					var centro = sentido.posicion(usuario.position(), num)
					new Rayo(usuario).activarEn(centro)
				}	
			}
		)	
	}
}  

// Realiza un ataque con los equipos del usuario potenciado un 20%
class AtaqueRapido inherits HabilidadActiva
{	
	override method tiempoDeEnfriamiento() = 18 - nivel * 2
	
	override method nombre() = "Ataque_Rapido"
	
	override method activar()
	{
		// Como realiza un ataque solo se activa si hay enemigos cerca para realizar el ataque
		if(usuario.hayEnemigosEnRangoDe(usuario.manoDerecha()) or usuario.hayEnemigosEnRangoDe(usuario.manoIzquierda()))
		{
			super()
		}
		else
			sonido.reproducirWav("Habilidad_En_Enfriamiento")
	}
	
	override method efectoDeActivacion()
	{
		// Realiza un ataque con un buff de ataque
		usuario.modificarMultiplicadorDeAtaque(usuario.nivel() / 10)
		usuario.atacarSiHayEnemigoEnRango()
		usuario.modificarMultiplicadorDeAtaque(-usuario.nivel() / 10)
	}
}

class SacrificioDeSangre inherits HabilidadActiva
{	
	override method tiempoDeEnfriamiento() = 30
	
	override method nombre() = "Sacrificio_De_Sangre"
	
	override method efectoDeActivacion()
	{
		var sacrificio = usuario.barraDeVida().porcentajeDeVidaMaxima(nivel*10)
		usuario.sufrirDanio(sacrificio)
		usuario.modificarAtaque(sacrificio/2)
		
		game.schedule(nivel*5.limitBetween(10, 20), { usuario.modificarAtaque(-sacrificio/2) }) // SCHEDULE!
	}
} */
class AtaqueSimple inherits HabilidadActiva
{	
	override method tiempoDeEnfriamiento() = 18 - self.nivel() * 2
	
	override method nombre() = "Ataque_Simple"
	
	override method activar()
	{
		// Solo puede activarse si hay objetivos en rango
		if(usuario.hayObjetivosEnRango())
			super()
		else
			sonido.reproducir("Habilidad_En_Enfriamiento.wav")
	}
	
	override method efectoDeActivacion()
	{
		const objetivo = usuario.objetivoEnRango()
		usuario.modificarMultiplicadorDeAtaque(usuario.nivel() * 10)
		usuario.atacarA(objetivo)
		usuario.modificarMultiplicadorDeAtaque(-usuario.nivel() * 10)
		
		self.efecto(objetivo)	
	}
	
	method efecto(objetivo) {}
}

class AtaqueIgneo inherits AtaqueSimple
{	
	override method nombre() = "Ataque_Igneo"
	
	override method efecto(objetivo) { objetivo.quemar(2, usuario) }
	
	override method coste() = 1
}

class AtaqueGelido inherits AtaqueSimple
{	
	override method nombre() = "Ataque_Gelido"
	
	override method efecto(objetivo) { objetivo.escarchar(2) }
	
	override method coste() = 1
}

class AtaqueOscuro inherits AtaqueSimple
{	
	override method nombre() = "Ataque_Oscuro"
	
	override method efecto(objetivo) { objetivo.cegar(2) }
	
	override method coste() = 1
}

class AtaquePerforante inherits AtaqueSimple
{	
	override method nombre() = "Ataque_Perforante"
	
	override method tiempoDeEnfriamiento() = 22 - self.nivel() * 2
	
	override method efecto(objetivo) { objetivo.desangrar(2) }
	
	override method efectoDeActivacion()
	{
		const objetivo = usuario.objetivoEnRango()
		const mitadDeDesfensa = objetivo.defensa() * 0.5
		
		usuario.modificarMultiplicadorDeAtaque(usuario.nivel() * 10)
		objetivo.modificarDefensa(-mitadDeDesfensa)
		
		usuario.atacarA(objetivo)
		
		objetivo.modificarDefensa(mitadDeDesfensa)
		usuario.modificarMultiplicadorDeAtaque(-usuario.nivel() * 10)
		
		self.efecto(objetivo)	
	}
	
	override method coste() = 2
}

class AtaqueDeExperiencia inherits AtaqueSimple
{	
	override method nombre() = "Ataque_De_Experiencia"
	override method tiempoDeEnfriamiento() = 16 - self.nivel() * 2
	override method efecto(objetivo) { usuario.ganarExperiencia((self.nivel()-2).limitBetween(1,3)) }
}

/******************** Regeneracion ********************/
class Regeneracion inherits HabilidadActiva
{	
	const categoria 
	var regeneracion = null

	override method nombre() = "Regeneracion" +  categoria.sufijo()
	
	method duracion() = (5*self.nivel()).limitBetween(10, 20) + 1 // + 1 Fixea el caso ded 15 segundos que al no ser par pierde un tick de curacion
	
	method porcentaje() = categoria.porcentaje()
	
	override method tiempoDeEnfriamiento() = 60 - 4*self.nivel()
	
	override method efectoDeActivacion()
	{
		regeneracion = new EventoPeriodicoTemporal(eventos1Segundo, self.duracion(), 2, { usuario.curar(usuario.porcentajeDeVidaMaxima(self.porcentaje())) }) 
		
		regeneracion.comenzar()
	}
	
	override method coste() = categoria.coste()
}

object regeneracionNormal
{
	method sufijo() = ""
	
	method porcentaje() = 3
	
	method coste() = 0
}

object regeneracionMas
{
	method sufijo() = "+"
	
	method porcentaje() = 5

	method coste() = 1
}

object regeneracionMasMas
{
	method sufijo() = "++"
	
	method porcentaje() = 7

	method coste() = 2
}

/******************** Cura ********************/
class Cura inherits HabilidadActiva
{	
	const categoria
	
	override method nombre() = "Cura" + categoria.sufijo()
	
	method curacion() = usuario.porcentajeDeVidaMaxima(categoria.porcentajeBase() + 5 * self.nivel())
	
	override method tiempoDeEnfriamiento() = categoria.tiempoDeEnfriamiento(self.nivel())
	
	override method efectoDeActivacion()
	{
		usuario.curar(self.curacion())
	}
	
	override method coste() = categoria.coste()
}

object curaNormal
{
	method sufijo() = ""
	
	method porcentajeBase() = 0
	
	method tiempoDeEnfriamiento(nivelHabilidad) = 22 - 2 * nivelHabilidad

	method coste() = 0
}

object curaMas
{
	method sufijo() = "+"
	
	method porcentajeBase() = 10
	
	method tiempoDeEnfriamiento(nivelHabilidad) = 25 - 2 * nivelHabilidad

	method coste() = 1
}

object curaMasMas
{
	method sufijo() = "++"
	
	method porcentajeBase() = 20
	
	method tiempoDeEnfriamiento(nivelHabilidad) = 28 - 2 * nivelHabilidad

	method coste() = 2
}

/******************** Revivir ********************/
class Revivir inherits HabilidadActiva
{	
	const categoria
	
	constructor(_categoria)
	{
		categoria = _categoria
	}
	
	override method nombre() = "Revivir" + categoria.sufijo()
	
	override method tiempoDeEnfriamiento() = categoria.tiempoDeEnfriamiento(self.nivel())
	
	override method activar()
	{
		// Solo puede activarse si hay sobrevivientes derribados
		if(not escenario.sobrevivientes().filter{ sobreviviente => sobreviviente.estado() == derribado }.isEmpty())
			super()
		else
			sonido.reproducir("Habilidad_En_Enfriamiento.wav")
	}
	
	override method efectoDeActivacion()
	{
		categoria.efectoDeActivacion(usuario, self.nivel())
	}
	
	override method coste() = categoria.coste()
}

class ResurreccionIndividual
{
	method multiplicadorPorcentual()
	
	method porcentajeDeVidaAlRevivir(usuario, nivelHabilidad) = usuario.porcentajeDeVidaMaxima(self.multiplicadorPorcentual()*nivelHabilidad)
	
	method tiempoDeEnfriamiento(nivelHabilidad) = 95 - 5 * nivelHabilidad
	
	method efectoDeActivacion(usuario, nivelHabilidad)
	{
		escenario.sobrevivientes().filter{ sobreviviente => sobreviviente.estado() == derribado }.anyOne().revivir(self.porcentajeDeVidaAlRevivir(usuario, nivelHabilidad))
	}

	method image() = "assets/Habilidades/Revivir.png"
}

object revivirNormal inherits ResurreccionIndividual
{
	method sufijo() = ""
	
	override method multiplicadorPorcentual() = 10
	
	method coste() = 0
}

object revivirMas inherits ResurreccionIndividual
{
	method sufijo() = "+"
	
	override method multiplicadorPorcentual() = 20
	
	method coste() = 2
}

object revivirMasMas
{
	method sufijo() = "++"
	
	method tiempoDeEnfriamiento(nivelHabilidad) = 99
	
	method efectoDeActivacion(usuario, nivelHabilidad)
	{
		escenario.sobrevivientes().forEach{ sobreviviente => sobreviviente.revivir(usuario.porcentajeDeVidaMaxima(20*nivelHabilidad)) }
	}
	
	method coste() = 3
}

/******************** Flechazos ********************/
class Flechazo inherits HabilidadActiva
{
	override method tiempoDeEnfriamiento() = 19 - self.nivel()
	method danio() = usuario.ataque() * (1 + self.nivel() * self.multiplicadorDeNivel())
	method multiplicadorDeNivel() = 0.1
	method flecha()
	override method efectoDeActivacion() { self.flecha().disparar() }
	override method coste() = 1
}

class FlechazoSimple inherits Flechazo
{	
	override method nombre() = "Flechazo_Simple"
	override method flecha() = new FlechaSimple(usuario, self.danio())
}

class FlechazoIgneo inherits Flechazo
{	
	override method nombre() = "Flechazo_Igneo"
	override method flecha() = new FlechaIgnea(usuario, self.danio()) 
}

class FlechazoGelido inherits Flechazo
{	
	override method nombre() = "Flechazo_Gelido"
	override method flecha() = new FlechaGelida(usuario, self.danio()) 
}

class FlechazoOscuro inherits FlechazoSimple
{	
	override method nombre() = "Flechazo_Oscuro"
	override method flecha() = new FlechaOscura(usuario, self.danio()) 
}

class FlechazoPerforante inherits FlechazoSimple
{	
	override method nombre() = "Flechazo_Perforante"
	override method multiplicadorDeNivel() = 0.2
	override method tiempoDeEnfriamiento() = 27 - self.nivel()
	override method flecha() = new FlechaPerforante(usuario, self.danio())
	override method coste() = 2
}

/******************** Armas de Fuego ********************/
/* 
class Lanzagranadas inherits HabilidadActiva
{	
	override method nombre() = "Lanzagranadas"
	
	method danio() = usuario.ataque() * (2 + 0.1 * self.nivel())
	
	override method tiempoDeEnfriamiento() = 30 - 2 * self.nivel()
	
	override method efectoDeActivacion()
	{
		new GranadaExplosiva(self.danio()).disparar(usuario)
	}
	
	override method coste() = 2
}

class Pistola inherits HabilidadActiva
{	
	override method nombre() = "Pistola"
	
	method danio() = usuario.ataque() * (1 + 0.1 * self.nivel())
	
	override method tiempoDeEnfriamiento() = 16 - 2 * self.nivel()
	
	override method efectoDeActivacion()
	{
		new BalaDePistola(self.danio()).disparar(usuario)
	}
	
	override method coste() = 1
}
*/

/******************** CocktailMolotov ********************/
class CocktailMolotov inherits HabilidadActiva
{	
	override method tiempoDeEnfriamiento() = 30 - self.nivel() * 2
	
	override method nombre() = "Cocktail_Molotov"
	
	method gravedad() = self.nivel().limitBetween(2, 4)
	
	override method efectoDeActivacion()
	{
		const sentido = usuario.orientacion()
		
		const efecto = new EventoSimple(eventos02Segundos, 0.2, 
		{
			var sonidoConjunto = new SonidoConjunto();
			
			sonido.reproducir("Romper_Botella.wav")
			
			3.times
			{
				num =>
				const centro = sentido.posicion(usuario.position(), 4+num)
				const ortogonal1 = sentido.ortogonales().first().posicion(centro)
				const ortogonal2 = sentido.ortogonales().last().posicion(centro)
				
				escenario.fondo(centro).encenderFuego(usuario, self.gravedad(), sonidoConjunto)
				escenario.fondo(ortogonal1).encenderFuego(usuario, self.gravedad(), sonidoConjunto)
				escenario.fondo(ortogonal2).encenderFuego(usuario, self.gravedad(), sonidoConjunto)
			}		
		})
		
		efecto.comenzar()
	}
}

/******************** PASIVAS ********************/
/******************** Clase Habilidad Pasiva ********************/
class HabilidadPasiva inherits Habilidad
{
	override method efectoDeActivacion() {}
	
	override method tiempoDeEnfriamiento() = 0
	
	method aplicarEfectoContinuo() {}
	
	method removerEfectoContinuo() {}
	
	override method equiparEn(_usuario)
	{
		super(_usuario)
		usuario.agregarHabilidadPasiva(self)
		self.aplicarEfectoContinuo()
	}
	
	override method desequipar()
	{
		usuario.removerHabilidadPasiva(self)
		self.removerEfectoContinuo()
	}
	
}

/******************** Habilidades Pasivas ********************/
class AutoRevivir inherits HabilidadPasiva
{
	method porcentajeDeVida() = 20 + 5 * self.nivel()
	
	method vidaTrasResurreccion() = usuario.porcentajeDeVidaMaxima(self.porcentajeDeVida())
	
	override method tiempoDeEnfriamiento() =  95 - self.nivel()*5
	
	override method nombre() = "AutoRevivir"
	
	override method efectoDeActivacion()
	{
		usuario.revivir(self.vidaTrasResurreccion())
	}
	
	override method efectoAlEquipar()
	{
		usuario.agregarResurreccion(self)
	}
	
	override method efectoAlDesequipar()
	{
		usuario.removerResurreccion(self)
	}
	
	override method efectoAlComenzarEnfriamiento()
	{
		usuario.removerResurreccion(self)
	}
	
	override method efectoAlTerminarEnfriamiento()
	{
		usuario.agregarResurreccion(self)
	}
}

/******************** Clase Cambio De Estadistica ********************/
class HabilidadDeCambioDeEstadistica inherits HabilidadPasiva
{
	const estadistica

	override method nombre() = self.nombreHabilidad() + estadistica.sufijo()
	
	method nombreHabilidad()
	
	method modificacionPorcentual() = estadistica.base() + estadistica.modificacionPorNivel()*self.nivel()
	
		override method coste() = estadistica.coste()
}

/******************** Tipo de Cambio de Estadistica********************/
object estadisticaNormal  
{
	method sufijo() = ""
	
	method modificacionPorcentualTipo1(nivel) =  15 + 2 * nivel
	method modificacionPorcentualTipo2(nivel) =  5 + 2 * nivel
	
	method modificacionDanioCritico(nivel) = 20 * nivel
	
	method modificacionPlana(nivel) =  5 * nivel	
	
	method coste() = 0
}

object estadisticaMas  
{
	method sufijo() = "+"
	
	method modificacionPorcentualTipo1(nivel) =  15 + 2 * nivel
	method modificacionPorcentualTipo2(nivel) =  25 + 2 * nivel
	
	method modificacionDanioCritico(nivel) = 30 * nivel
	
	method modificacionPlana(nivel) =  15 + 5 * nivel	
	
	method coste() = 1
}

object estadisticaMasMas
{
	method sufijo() = "++"
	
	method modificacionPorcentualTipo1(nivel) =  25 + 2 * nivel
	method modificacionPorcentualTipo2(nivel) =  35 + 2 * nivel
	
	method modificacionDanioCritico(nivel) = 40 * nivel
	
	method modificacionPlana(nivel) = 30 + 5 * nivel
	
	method coste() = 2
}

/******************** Cambios De Estadistica ********************/
class Valentia inherits HabilidadDeCambioDeEstadistica
{	
	override method nombreHabilidad() = "Valentia"
	
	override method efectoAlEquipar()
	{
		usuario.modificarMultiplicadorDeAtaque(estadistica.modificacionPorcentualTipo1())
	}
	
	override method efectoAlDesequipar()
	{
		usuario.modificarMultiplicadorDeAtaque(-estadistica.modificacionPorcentualTipo1())
	}
}

class Vida inherits HabilidadDeCambioDeEstadistica
{
	override method nombreHabilidad() = "Vida"
	
	override method efectoAlEquipar()
	{
		usuario.modificarMultiplicadorDeVidaMaxima(estadistica.modificacionPorcentualTipo1())
	}
	
	override method efectoAlDesequipar()
	{
		usuario.modificarMultiplicadorDeVidaMaxima(-estadistica.modificacionPorcentualTipo1())
	}
	
	override method image() = "assets/Habilidades/Vida.png"
}

class Escudo inherits HabilidadDeCambioDeEstadistica
{
	override method nombreHabilidad() = "Escudo"
	
	override method efectoAlEquipar()
	{
		usuario.modificarMultiplicadorDeDefensa(estadistica.modificacionPorcentualTipo1())
	}
	
	override method efectoAlDesequipar()
	{
		usuario.modificarMultiplicadorDeDefensa(-estadistica.modificacionPorcentualTipo1())
	}
}

class Proteccion inherits HabilidadDeCambioDeEstadistica
{
	override method nombreHabilidad() = "Proteccion"
	
	override method efectoAlEquipar()
	{
		usuario.modificarMultiplicadorDeDanioRecibido(estadistica.modificacionPorcentualTipo1())
	}
	
	override method efectoAlDesequipar()
	{
		usuario.modificarMultiplicadorDeDanioRecibido(-estadistica.modificacionPorcentualTipo1())
	}
}

class Aceleracion inherits HabilidadDeCambioDeEstadistica
{
	override method nombreHabilidad() = "Aceleracion"
	
	override method efectoAlEquipar()
	{
		usuario.acelerar(estadistica.modificacionPlana())
	}
	
	override method efectoAlDesequipar()
	{
		usuario.ralentizar(-estadistica.modificacionPlana())
	}
}

class Presicion inherits HabilidadDeCambioDeEstadistica
{
	override method nombreHabilidad() = "Presicion"
	
	override method efectoAlEquipar()
	{
		usuario.modificarPresicion(estadistica.modificacionPorcentualTipo2())
	}
	
	override method efectoAlDesequipar()
	{
		usuario.modificarPresicion(-estadistica.modificacionPorcentualTipo2())
	}
}

class Bloqueo inherits HabilidadDeCambioDeEstadistica
{
	override method nombreHabilidad() = "Bloqueo"
	
	override method efectoAlEquipar()
	{
		usuario.modificarProbabilidadDeBloque(estadistica.modificacionPorcentualTipo2())
	}
	
	override method efectoAlDesequipar()
	{
		usuario.modificarProbabilidadDeBloque(-estadistica.modificacionPorcentualTipo2())
	}
}

class Critico inherits HabilidadDeCambioDeEstadistica
{
	override method nombreHabilidad() = "Critico"
	
	override method efectoAlEquipar()
	{
		usuario.modificarProbabilidadDeCritico(estadistica.modificacionPorcentualTipo2())
	}
	
	override method efectoAlDesequipar()
	{
		usuario.modificarProbabilidadDeCritico(-estadistica.modificacionPorcentualTipo2())
	}
}

class DanioCritico inherits HabilidadDeCambioDeEstadistica
{
	override method nombreHabilidad() = "Daño Critico"
	
	override method efectoAlEquipar()
	{
		usuario.modificarMultiplicadorDeCritico(estadistica.modificacionDanioCritico())
	}
	
	override method efectoAlDesequipar()
	{
		usuario.modificarMultiplicadorDeCritico(-estadistica.modificacionDanioCritico())
	}
}

class Despiadado inherits HabilidadDeCambioDeEstadistica
{
	override method nombreHabilidad() = "Despiadado"
	
	override method efectoAlEquipar()
	{
		usuario.modificarProbabilidadDeCritico(estadistica.modificacionPorcentualTipo1())
		usuario.modificarMultiplicadorDeCritico(estadistica.modificacionDanioCritico())
	}
	
	override method efectoAlDesequipar()
	{
		usuario.modificarProbabilidadDeCritico(-estadistica.modificacionPorcentualTipo1())
		usuario.modificarMultiplicadorDeCritico(-estadistica.modificacionDanioCritico())
	}
	
	override method coste() = estadistica.coste()*2
}

