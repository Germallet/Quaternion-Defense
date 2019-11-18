import wollok.game.*

import objetosEnJuego.objetosConVida.*

import probabilidad.*
import estadosTemporales.*
import direcciones.*
import escenario.*
import eventos.*
import objetosEnJuego.imagenEnlazada.*

class Personaje inherits ObjetoConVida
{
	var property arma
	
	// Estadisticas del personaje
	var defensa 
	var ataque
	var ataquePerforante = 0
	
	var multiplicadorDeAtaque = 100
	var multiplicadorDeDanioRecibido = 100
	
	var constanteDeDanioRecibido = 0
	
	var presicion = 90
	
	var probabilidadDeCritico = 000
	var probabilidadDeEvasion = 000
	var probabilidadDeBloqueo = 000
	
	var multiplicadorDeCritico = 150
	
	//Estados Temporales
	var property quemadura = null
	var property sangrado = null
	var property escarcha = null
	var property congelado = null
	var property ceguera = null
	
	var property estadoDeQuemadura = noTieneEstadoAlterado
	var property estadoDeSangrado = noTieneEstadoAlterado
	var property estadoDeEscarcha = noTieneEstadoAlterado
	var property estadoDeCongelado = noTieneEstadoAlterado
	var property estadoDeCeguera = noTieneEstadoAlterado
	
	// Valores relativos al movimiento
	var property position = game.at(1,1) 
	var property orientacion = abajo 
	
	// Listas de resurrecciones y estados alterados que puede tener un personaje
	var resurrecciones = new List()
	var estadosTemporales = new List() // Deberia ser un Set
	
	//Comportamientos
	var property comportamientoDeMovimiento = normal
	var comportamientoDeAtaque = ataqueHabilitado
	var comportamientoDeHabilidades = habilidadesHabilitadas
	var property estado = parado
	var estadoDeEventos = eventosInactivos
	
	/******************** Estadisticas ********************/
	method nombre()
	
	method ataque() = ataque
	
	method modificarAtaque(modificacion)
	{
		ataque = ataque + modificacion
	}
	
	method ataquePerforante() = ataquePerforante
	
	method multiplicadorDeAtaque() = multiplicadorDeAtaque/100
	
	method modificarMultiplicadorDeAtaque(multiplicador)
	{
		multiplicadorDeAtaque = multiplicadorDeAtaque + multiplicador
	}
	
	method multiplicadorDeDanioRecibido() = multiplicadorDeDanioRecibido/100
	
	method modificarMultiplicadorDeDanioRecibido(multiplicador)
	{
		multiplicadorDeDanioRecibido = multiplicadorDeDanioRecibido + multiplicador
	}
	
	method defensa() = defensa
	
	method modificarDefensa(modificacion)
	{
		defensa = defensa + modificacion
	}
	
	method modificarConstanteDeDanioRecibido(modificacion)
	{
		constanteDeDanioRecibido = constanteDeDanioRecibido + modificacion
	}
	
	/******************** Presicion ********************/
	method presicion() = 0.max(100.min(presicion))
	
	method modificarPresicion(modificacion) { presicion = presicion + modificacion }
	/******************** Evasion ********************/
	method probabilidadDeEvasion() = probabilidadDeEvasion
	
	method modificarProbabilidadDeEvasion(probabilidad)
	{
		probabilidadDeEvasion = probabilidadDeEvasion + probabilidad
	}
	
	/******************** Bloqueo ********************/
	method probabilidadDeBloqueo() = probabilidadDeBloqueo
	
	method modificarProbabilidadDeBloqueo(probabilidad)
	{
		probabilidadDeBloqueo = probabilidadDeBloqueo + probabilidad
	}
	
	/******************** Critico ********************/
	method probabilidadDeCritico() = probabilidadDeCritico
	
	method multiplicadorDeCritico() = if(probabilidad.en100De(probabilidadDeCritico)) multiplicadorDeCritico/100 else 1
	
	method modificarProbabilidadDeCritico(probabilidad)
	{
		probabilidadDeCritico = probabilidadDeCritico + probabilidad
	}
	method modificarMultiplicadorCritico(multiplicador)
	{
		multiplicadorDeCritico = multiplicadorDeCritico + multiplicador
	}
	
	/******************** Estado ********************/
	method cambiarEstado(_estado)
	{
		estado = _estado
		estado.aplicarEfectos(self)
	}
	
	method estado() = estado
		
	/******************** Combate ********************/
	method atacarA(objetivo) { comportamientoDeAtaque.atacar(self, objetivo) }
	
	method atacarSiHayObjetivosEnRango()
	{
		if(self.hayObjetivosEnRango())
			self.atacarObjetivoEnRango()
	}
	
	method atacarObjetivoEnRango()
	{
		self.atacarA(self.objetivoEnRango())
	}
	
	method hayObjetivosEnRango()
	
	method objetivoEnRango()
	
	method comportamientoDeAtaque() = comportamientoDeAtaque
	
	method habilitarAtaque() { comportamientoDeAtaque = ataqueHabilitado }
	
	method deshabilitarAtaque() { comportamientoDeAtaque = ataqueDeshabilitado }
	
	method matasteA(muerto) { arma.matoA(muerto) }

	method esAtacable() = estado.esAtacable()
	
	/******************** Daño ********************/
	method constanteDeDanioRecibido() = constanteDeDanioRecibido
	
	// Al recibir daño letal, se revive si se puede, si no, se muere
	override method recibioDanioLetal(danio, agresor)
	{
		const resolucion = new EventoSimple(eventos1Segundo, 4, 
		{ 
			if(not self.puedeRevivir())
				self.morir(agresor)
			else
				resurrecciones.first().activar()
		})
		
		self.cambiarEstado(derribado)
		resolucion.comenzar()
	}
	
	// Al recibir un ataque controla si se esquivo o bloqueo el mismo
	method recibirAtaqueNormal(danio, agresor)
	{
		if(probabilidad.en100De(agresor.presicion() - probabilidadDeEvasion)) // Si no esquiva
		{
			if(probabilidad.en100De(probabilidadDeBloqueo)) // Si bloquea
			{
				const bloqueo = new AnimacionEnlazada(0.2, 2, self, "assets/Bloqueo/Esquivo")
				const tiempo = new EventoSimple(eventos02Segundos, 0.4, { bloqueo.interrumpir() })
				
				bloqueo.comenzar()
				tiempo.comenzar()
				
				self.sufrirDanio(danio * 0.5, agresor) // Sufre daño reducidoa la mitad por bloqueo
			}
			else
				self.sufrirDanio(danio, agresor) // Sufre daño normal
		}
		else
		{
			const esquivo = new AnimacionEnlazada(0.2, 2, self, "assets/Efectos/Esquivo")
			const tiempo = new EventoSimple(eventos02Segundos, 0.6, { esquivo.interrumpir() })
			
			esquivo.comenzar()
			tiempo.comenzar()
		}
	}
	
	override method recibirAtaqueDeHabilidad(danio, agresor) 
	{ 
		const danioASufrir = (danio + self.constanteDeDanioRecibido()) * self.multiplicadorDeDanioRecibido()
		
		self.sufrirDanio(danioASufrir, agresor)
	} 
	
	method terminarEstadosTemporales()
	{
		//Termina los estados alterador si se encontraba con alguno
		estadosTemporales.forEach{ estadoTemporal => estadoTemporal.terminar() }
	}
	
	// Morir: Borra el visual del tablero // Muerte por default para un personaje
	method morir(asesino)
	{
		estado.morir(self, asesino)
	}
	
	method efectoAlMorir(asesino) {}
	/******************** Resurrecion ********************/
	method resurrecciones() = resurrecciones
	
	method revivir(porcentajeDeVida) { estado.revivir(self, porcentajeDeVida) }
	method puedeRevivir() = not resurrecciones.isEmpty()
	
	method agregarResurreccion(resurreccion) { resurrecciones.add(resurreccion) }
	method removerResurreccion(resurreccion) { resurrecciones.remove(resurreccion) }

	/******************** Habilidades ********************/
	method habilitarHabilidades() { comportamientoDeHabilidades = habilidadesHabilitadas }
	method deshabilitarHabilidades() { comportamientoDeHabilidades = habilidadesDeshabilitadas }
	
	method reduccionDeEnfriamiento() = 0
	
	method comportamientoDeHabilidades() = comportamientoDeHabilidades
	
	/******************** Estados Temporales ********************/
	override method quemar(quemador, gravedad) { new Quemadura(self, quemador, gravedad).aplicar() }
	override method desangrar(gravedad)	{ new Sangrado(self, gravedad).aplicar() }
	override method escarchar(gravedad)	{ new Escarcha(self, gravedad).aplicar() }
	override method congelar(gravedad) { new Congelado(self, gravedad).aplicar() }
	override method cegar(gravedad) { new Ceguera(self, gravedad).aplicar() }
	
	method curarQuemadura() { estadoDeQuemadura.curar(quemadura) }
	method curarSangrado() { estadoDeSangrado.curar(sangrado) }
	method curarEscarcha() { estadoDeEscarcha.curar(escarcha) }
	method curarCongelado() { estadoDeCongelado.curar(congelado) }
	method curarCeguera() { estadoDeCeguera.curar(ceguera) }
	
	/******************** Movimiento y Posicion ********************/
	method moverHacia(direccion)
	{
		comportamientoDeMovimiento.moverHacia(self, direccion)
		estado.efectoAlMover(self)
	}
	
	method moverHaciaSiEsPosible(direccion) { comportamientoDeMovimiento.moverHaciaSiEsPosible(self, direccion) }
	
	method posicionDeEnFrente() = orientacion.posicion(position)
	method objetoDeEnFrente() = self.posicionDeEnFrente().allElements().last()
	
	method estadoDeAnimacion() = estado.animacion(self)
	
	/******************** Eventos ********************/
	method eventos()
	
	method interrumpirEventos() { estadoDeEventos.interrumpirEventos(self) }
	method comenzarEventos() { estadoDeEventos.comenzarEventos(self) }
	
	method estadoDeEventos(_estadoDeEventos) { estadoDeEventos = _estadoDeEventos }
	
	/******************** Otros ********************/
	// Experiencia que da al ser asesinado
	method experienciaQueDa() = 0
	method tiempoDeAccion() = 1 // En segundos
	
	method inicializar(posicion)
	{
		self.inicializar()
		position = posicion
		self.comenzarEventos()
	}
	override method esAtravesable() = false
	// Para tests de movimiento de personaje :(
	method pisar(pisador){}
}

/******************** Estados de Movilidad ********************/
// Mueve al personaje en un sentido y establece hacia donde está mirando el personaje
object normal 
{
	method moverHacia(personaje, direccion)
	{
		const nuevaPosicion = direccion.posicion(personaje.position())
		
		personaje.orientacion(direccion)
		personaje.position(nuevaPosicion)
		escenario.fondo(nuevaPosicion).pisar(personaje)
	}
	method moverHaciaSiEsPosible(personaje, direccion)
	{
		if (escenario.esAtravesable(direccion.posicion(personaje.position())))
			self.moverHacia(personaje,direccion)
		else
			personaje.orientacion(direccion)
	}
}

object confundido
{
	 method moverHacia(personaje, direccion)
	{
		const direccionOpuesta = direccion.opuesta()	
		const nuevaPosicion = direccionOpuesta.posicion(personaje.position())
		
		personaje.orientacion(direccionOpuesta)
		personaje.position(nuevaPosicion)
		escenario.fondo(nuevaPosicion).pisar(personaje)
	}
	method moverHaciaSiEsPosible(personaje, direccion)
	{
		var direccionOpuesta = direccion.opuesta()
		if (escenario.esAtravesable(direccionOpuesta.posicion(personaje.position())))
			self.moverHacia(personaje,direccion)
		else
			personaje.orientacion(direccionOpuesta)
	}
}

object inmobilizadoTotalmente
{
	method moverHacia(personaje, direccion) {}
	method moverHaciaSiEsPosible(personaje, direccion)	{}
}

object inmobilizadoParcialmente
{
	method moverHacia(personaje, direccion) { personaje.orientacion(direccion) }
	method moverHaciaSiEsPosible(personaje, direccion) { personaje.orientacion(direccion) }
}

/******************** Comportamiento de Ataque ********************/
object ataqueHabilitado
{
	method atacar(atacante, objetivo)
	{
		const arma = atacante.arma()
		
		// Ecuaciones para el calculo del daño
		const poderDeAtaque = (arma.ataque() + atacante.ataque()) * atacante.multiplicadorDeAtaque()
		
		const danioNormal = poderDeAtaque * atacante.multiplicadorDeDanio() / (objetivo.defensa() + 100) 
		const danioPerforante = arma.ataquePerforante() + atacante.ataquePerforante()
		const danioDeAtaque = (danioNormal + danioPerforante + objetivo.constanteDeDanioRecibido()) * atacante.multiplicadorDeCritico() * objetivo.multiplicadorDeDanioRecibido()
		
		// El objetivo Recibe el daño
		objetivo.recibirAtaqueNormal(danioDeAtaque, atacante)
		arma.atacoA(danioDeAtaque, objetivo)
	}
}

object ataqueDeshabilitado
{
	method atacar(atacante, objetivo)	{}
}

/******************** Comportamiento de Habilidad ********************/
object habilidadesHabilitadas
{
	method activarHabilidad(personaje, n)
	{
		personaje.habilidadesActivas().get(n).activar()
	}
}

object habilidadesDeshabilitadas
{
	method activarHabilidad(personaje, n)	{}
}

/******************** Estado Eventos ********************/
object eventosActivos
{
	method comenzarEventos(personaje) {}

	method interrumpirEventos(personaje)
	{
		personaje.eventos().forEach{ evento => evento.interrumpir() }
		personaje.estadoDeEventos(eventosInactivos)
	}
}

object eventosInactivos
{
	method comenzarEventos(personaje) 
	{
		personaje.eventos().forEach{ evento => evento.comenzar() }
		personaje.estadoDeEventos(eventosActivos)
	}

	method interrumpirEventos(personaje) {}
}

/******************** Comportamiento de Estados Alterados ********************/
object noTieneEstadoAlterado
{
	method aplicar(estado) { estado.comenzar() }
	method curar(estado) {}
}

object tieneEstadoAlterado
{
	method aplicar(estado) { estado.reAplicar() }
	method curar(estado) { estado.terminar() }
}

/******************** Estado ********************/
class EstadoDePie
{
	method revivir(personaje, porcentaje) {}
	
	method morir(personaje) {}
	
	method activarHabilidad(personaje, n)
	{
		personaje.habilidadesActivas().get(n).activar()
	}
	
	method animacion(personaje) = personaje.orientacion().toString()
	
	method esAtacable() = true
}

object parado
{
	method aplicarEfectos(personaje)
	{
		personaje.habilitarCuracion()
		personaje.habilitarAtaque()
		personaje.habilitarHabilidades()
		
		personaje.comportamientoDeMovimiento(normal)
		
		personaje.comenzarEventos()
	}
	
	method revivir(personaje, porcentaje) {}
	
	method morir(personaje, asesino) {}
	
	method efectoAlMover(personaje) {}
	
	method activarHabilidad(personaje, n) {	personaje.comportamiendoDeHabilidades().activarHabilidad(personaje, n) }
	
	method dejarDeInteractuar(objetoDeInteraccion) {}
	
	method animacion(personaje) = personaje.orientacion().toString()
	
	method esAtacable() = true
}

object interactuando
{
	method aplicarEfectos(personaje)
	{
		//personaje.habilitarCuracion()
		//personaje.comenzarEventos()
	}
	
	method revivir(personaje, porcentaje) {}
	
	method morir(personaje, asesino) {}
	
	method efectoAlMover(personaje)
	{
		personaje.cambiarEstado(parado)
		personaje.interrumpirInteraccion()
	}
	
	method activarHabilidad(personaje, n)
	{
		personaje.comportamiendoDeHabilidades().activarHabilidad(personaje, n)
		personaje.cambiarEstado(parado)
		personaje.interrumpirInteraccion()
	}
	
	method dejarDeInteractuar(objetoDeInteraccion)
	{
		objetoDeInteraccion.dejarDeInteractuarCon(self)
	}
	
	method animacion(personaje) = personaje.orientacion().toString()
	
	method esAtacable() = true
}

object derribado
{
	method aplicarEfectos(personaje)
	{
		personaje.deshabilitarCuracion()
		personaje.deshabilitarAtaque()
		personaje.deshabilitarHabilidades()
		
		personaje.comportamientoDeMovimiento(inmobilizadoTotalmente)
		
		personaje.interrumpirEventos()
		personaje.terminarEstadosTemporales()
	}
	
	method revivir(personaje, porcentaje)
	{
		personaje.cambiarEstado(parado)
		personaje.curar(personaje.porcentajeDeVidaMaxima(porcentaje))
	}
	
	method morir(personaje, asesino) 
	{
		personaje.cambiarEstado(muerto)
		personaje.removerVisuales()
		asesino.matasteA(personaje)
		personaje.efectoAlMorir(asesino)
	}
	
	method efectoAlMover(personaje) {}
	
	method activarHabilidad(personaje, n) {}
	
	method dejarDeInteractuar(objetoDeInteraccion) {}
	
	method animacion(personaje) = "Derribado"
	
	method esAtacable() = false
}

object muerto
{
	method aplicarEfectos(personaje) {}
	
	method revivir(personaje, porcentaje) {}
	method morir(personaje, asesino) {}
	method efectoAlMover(personaje) {}
	method activarHabilidad(personaje, n) {}
	method dejarDeInteractuar(objetoDeInteraccion) {}
	method animacion(personaje) = "Derribado"
	
	method esAtacable() = false
}
