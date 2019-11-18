import wollok.game.*
import eventos.*

object sonido 
{
	var estado = sonidoDesactivado
	
	method cambiarEstado(nuevoEstado)
	{
		estado = nuevoEstado		
	}
	
	method reproducir(audio)
	{
		estado.reproducir(audio)
	}
}
object sonidoActivado
{
	method reproducir(audio)
	{
		game.sound("assets/Sonidos/" + audio)
	}
}
object sonidoDesactivado
{
	method reproducir(audio) {}
}

class SonidoEnBucle
{
	const eventoDeAudio
	
	constructor(audio, duracion)
	{
		eventoDeAudio = new EventoPeriodico(eventos02Segundos, duracion, {sonido.reproducir(audio)})
	}
	
	method reproducir()
	{
		eventoDeAudio.ejecutar()
		eventoDeAudio.comenzar()
	}
	
	method detener()
	{
		eventoDeAudio.interrumpir()
	}
}

class SonidoConjunto
{
	var reproduciendo = false
		
	method reproducir(audio)
	{
		if (not reproduciendo)
		{
			sonido.reproducir(audio)
			reproduciendo = true
		}
	}
}