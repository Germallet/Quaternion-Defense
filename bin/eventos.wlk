import wollok.game.*

class ListaDeEventos
{
	const property eventos = new List()
	
	method agregarEvento(evento)
	{
		eventos.add(evento)
	}
	
	method agregarEventos(_eventos)
	{
		_eventos.forEach{ evento => eventos.add(evento) }
	}
	
	method removerEvento(evento)
	{
		eventos.remove(evento)
	}
	
	method removerEventos(_eventos)
	{
		_eventos.forEach{ evento => eventos.remove(evento) }
	}
	
	method avanzarTiempo(segundos)
	{
		eventos.forEach{ evento => evento.avanzarTiempo(segundos) }
	}
	
	method ejecutarEventos()
	{
		eventos.forEach{ evento => evento.ejecutar() }	
	}
}

object eventos02Segundos inherits ListaDeEventos {}
object eventos1Segundo inherits ListaDeEventos {}

class Evento
{
	const lista 
	const accion
	
	method comenzar()
	{
		lista.agregarEvento(self)
	}
	method interrumpir()
	{
		lista.removerEvento(self)
		self.reiniciar()
	}
	method ejecutar() {	accion.apply() }
	
	method reiniciar()
}

class EventoSimple inherits Evento
{
	var demora
	var momento
	
	constructor(_lista, _demora, _accion) 
	{
		demora = _demora
		accion = _accion
		momento = demora
	
		lista = _lista
	}
	
	override method ejecutar()
	{		
		self.interrumpir()
		super()
	}
	
	method avanzarTiempo(segundos)
	{
		momento = 0.max(momento - segundos)
		
		if(	momento == 0)
		{
			momento = demora
			self.ejecutar()	
		}
	}
	
	override method reiniciar() { momento = demora }
	
	method modificarDemora(segundos) 
	{ 
		demora = demora + segundos  
		momento = momento + segundos
	}
	
	method momento() = momento
}

class EventoPeriodico inherits Evento
{
	var periodo
	var momento
	
	constructor(_lista, _periodo, _accion)
	{
		periodo = _periodo
		momento = periodo
		accion = _accion
		
		lista = _lista
	}
	
	method avanzarTiempo(segundos)
	{
		momento = 0.max(momento - segundos)
		
		if(momento == 0)
		{
			momento = periodo
			self.ejecutar()	
		}
	}
	
	override method reiniciar() { momento = periodo }
	
	method aumentarPeriodo(segundos)
	{
		periodo = periodo + segundos
		momento = momento + segundos
	}
	
	method momento() = momento
}

class EventoPeriodicoTemporal
{
	const eventoPeriodico
	const eventoSimple
	
	constructor(lista, duracion, accion)
	{
		eventoPeriodico = new EventoPeriodico(lista, 1, accion)
		eventoSimple = new EventoSimple(lista, duracion, { eventoPeriodico.interrumpir() })
	}
	
	constructor(lista, duracion, periodo, accion)
	{
		eventoPeriodico = new EventoPeriodico(lista, periodo, accion)
		eventoSimple = new EventoSimple(lista, duracion, { eventoPeriodico.interrumpir() })
	}
	
	constructor(lista, duracion, periodo, accion, accionAlTerminar)
	{
		eventoPeriodico = new EventoPeriodico(lista, periodo, accion)
		eventoSimple = new EventoSimple(lista, duracion, { eventoPeriodico.interrumpir() accionAlTerminar.apply() })
	}
	
	method avanzarTiempo(segundos)
	{
		eventoPeriodico.avanzarTiempo()
		eventoSimple.avanzarTiempo()
	}
	
	method comenzar()
	{
		eventoPeriodico.comenzar()
		eventoSimple.comenzar()	
	}
	
	method interrumpir()
	{
		eventoPeriodico.interrumpir()
		eventoSimple.interrumpir()
	}
	
	method reiniciar()
	{
		eventoPeriodico.reiniciar()
		eventoSimple.reiniciar()
	}
	
	method ejecutar()
	{
		eventoSimple.ejecutar()	
	}
	
	method modificarDuracion(segundos)
	{
		eventoSimple.modificarDemora(segundos)
	}
	
	method momento() = eventoSimple.momento()
	method momentoDePeriodo() = eventoPeriodico.momento()
	
}
