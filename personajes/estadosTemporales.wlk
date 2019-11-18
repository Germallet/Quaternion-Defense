import wollok.game.*
import eventos.*

import personajes.personajes.*
import objetosEnJuego.imagenEnlazada.*

/******************** Estado Alterado ********************/
class EstadoAlterado
{
	const victima
	var gravedad
	
	const property efecto 
	const property animacion
	
	method aumentarDuracion(aumento)
	{
		efecto.aumentarDemora(aumento)
	}
	
	method reiniciarDuracion()
	{
		efecto.reiniciar()
	}
	
	method victima() = victima
	method gravedad() = gravedad
	
	method aumentarGravedad(n)
	{
		gravedad = gravedad + n
	}
}

class Quemadura inherits EstadoAlterado
{
	const duracion = 5
	const agresor
	
	constructor(_victima, _agresor, _gravedad) 
	{
		gravedad = _gravedad
		victima = _victima
	 	agresor = _agresor
			
		animacion = new AnimacionEnlazada(0.1, 4, victima, "assets/EstadosAlterados/Quemadura/")
		efecto = new EventoPeriodicoTemporal(eventos1Segundo, duracion, 1, { victima.sufrirDanio(gravedad, agresor) }, { self.terminar() })
	}
	
	method agresor() = agresor
	
	method aplicar() { victima.estadoDeQuemadura().aplicar(self) }
	
	method comenzar()
	{
		victima.quemadura(self)
		victima.estadoDeQuemadura(tieneEstadoAlterado)
		
		efecto.comenzar()
		animacion.comenzar()
	}
	
	method terminar()
	{
		victima.quemadura(null)
		victima.estadoDeQuemadura(noTieneEstadoAlterado)
		
		efecto.interrumpir()
		animacion.interrumpir()
	}
	
	method reAplicar()
	{
		const quemaduraAnterior = victima.quemadura()
		
		quemaduraAnterior.terminar()
		
		const quemaduraDeMayorGravedad = [quemaduraAnterior, self].max{ quemadura => quemadura.gravedad() }
		
		quemaduraDeMayorGravedad.aplicar()
	}
	
}

class Sangrado inherits EstadoAlterado
{
	const duracion = 10
	
	constructor(_victima, _gravedad)
	{
		gravedad = _gravedad
		victima = _victima
		
		animacion = new AnimacionEnlazada(0.2, 3, victima, "assets/EstadosAlterados/Sangrado/")
		efecto = new EventoSimple(eventos1Segundo, duracion, { victima.curarSangrado() })
	}
	
	method aplicar() { victima.estadoDeSangrado().aplicar(self) }
	
	method comenzar()
	{
		victima.modificarConstanteDeDanioRecibido(gravedad)
		victima.sangrado(self)
		victima.estadoDeSangrado(tieneEstadoAlterado)
		
		efecto.comenzar()
		animacion.comenzar()
	}
	
	method terminar()
	{
		victima.modificarConstanteDeDanioRecibido(-gravedad)
		victima.sangrado(null)
		victima.estadoDeSangrado(noTieneEstadoAlterado)
		
		efecto.interrumpir()
		animacion.interrumpir()
	}
	
	method reAplicar()
	{
		const sangradoAnterior = victima.sangrado()
		
		sangradoAnterior.aumentarGravedad(gravedad*2)
		sangradoAnterior.reiniciarDuracion()
	}
	
	override method aumentarGravedad(n)
	{
		super(n)
		victima.modificarConstanteDeDanioRecibido(n)
	}
}

class Escarcha inherits EstadoAlterado
{
	const duracion = 6
	
	constructor(_victima, _gravedad)
	{
		gravedad = _gravedad
		victima = _victima
		
		animacion = new ImagenEnlazada(victima, "assets/EstadosAlterados/Escarcha/"+ gravedad.toString() +".png")
		efecto = new EventoSimple(eventos1Segundo, duracion, { victima.curarEscarcha() })
	}

	method aplicar() { victima.estadoDeEscarcha().aplicar(self) }
	
	method comenzar()
	{
		victima.modificarProbabilidadDeBloqueo(-10*gravedad)
		victima.modificarProbabilidadDeEvasion(-10*gravedad)
		victima.modificarAtaque(-5*gravedad)
		
		victima.escarcha(self)
		victima.estadoDeEscarcha(tieneEstadoAlterado)
		
		efecto.comenzar()
		game.addVisual(animacion)
	}
	
	method terminar()
	{
		victima.modificarProbabilidadDeBloqueo(10*gravedad)
		victima.modificarProbabilidadDeEvasion(10*gravedad)
		victima.modificarAtaque(5*gravedad)
		
		victima.escarcha(null)
		victima.estadoDeEscarcha(noTieneEstadoAlterado)
		
		efecto.interrumpir()
		game.removeVisual(animacion)
	}
	
	method reAplicar()
	{
		const escarchaAnterior = victima.escarcha()
		
		escarchaAnterior.aumentarGravedad(gravedad)
		escarchaAnterior.efecto().reiniciar()
	}
	
	override method aumentarGravedad(n)
	{
		super(n)
		
		if(gravedad <5)
		{
			victima.modificarProbabilidadDeBloqueo(-10*n)
			victima.modificarProbabilidadDeEvasion(-10*n)
			victima.modificarAtaque(-5*n)
		}
		else
		{
			self.terminar()
			
			const congelado = new Congelado(victima, 4)
			congelado.aplicar()
		}
	}
}

class Congelado inherits EstadoAlterado
{
	constructor(_victima, _gravedad)
	{
		victima = _victima
		gravedad = _gravedad
		
		animacion = new ImagenEnlazada(victima, "assets/EstadosAlterados/Congelado.png")
		
		efecto = new EventoSimple(eventos1Segundo, gravedad, { victima.curarCongelado() })
	}

	method aplicar() { victima.estadoDeCongelado().aplicar(self) }
	
	method comenzar()
	{
		victima.deshabilitarAtaque()
		victima.deshabilitarHabilidades()
		victima.comportamientoDeMovimiento(inmobilizadoTotalmente)
		
		victima.congelado(self)
		victima.estadoDeCongelado(tieneEstadoAlterado)
		
		efecto.comenzar()
		game.addVisualIn(animacion, victima.position())
	}
	
	method terminar()
	{
		victima.habilitarAtaque()
		victima.habilitarHabilidades()
		victima.comportamientoDeMovimiento(normal)
		
		victima.congelado(null)
		victima.estadoDeCongelado(noTieneEstadoAlterado)
		
		efecto.interrumpir()
		game.removeVisual(animacion)
	}
	
	method reAplicar()
	{
		const congeladoAnterior = victima.congelado()
		
		congeladoAnterior.aumentarGravedad(1)
	}
	
	override method aumentarGravedad(n) 
	{
		super(1)
		efecto.modificarDemora(1)
	}
}

class Ceguera inherits EstadoAlterado
{
	const duracion = 6
	
	constructor(_victima, _gravedad)
	{
		gravedad = _gravedad
		victima = _victima
		
		animacion = new ImagenEnlazada(victima, "assets/EstadosAlterados/Ceguera.png")
		
		efecto = new EventoSimple(eventos1Segundo, duracion, { self.terminar() })
	}
	
	method ralentizacion() = 30 + gravedad*10
	
	method aplicar() { victima.estadoDeCeguera().aplicar(self) }
	
	method comenzar()
	{
		victima.modificarPresicion(-gravedad*10)
		victima.ceguera(self)
		victima.estadoDeCeguera(tieneEstadoAlterado)
		
		efecto.comenzar()
		game.addVisual(animacion)
	}
	
	method reAplicar()
	{
		const cegueraAnterior = victima.ceguera()
		
		cegueraAnterior.reiniciarDuracion()
		cegueraAnterior.aumentarGravedad(gravedad)
	}
	
	method terminar()
	{
		efecto.interrumpir()
		victima.modificarPresicion(gravedad*10)
		victima.ceguera(null)
		victima.estadoDeCeguera(noTieneEstadoAlterado)
		
		game.removeVisual(animacion)
	}
	
	override method aumentarGravedad(n)
	{
		super(n)
		victima.modificarPresicion(-n*10)
	}
}

